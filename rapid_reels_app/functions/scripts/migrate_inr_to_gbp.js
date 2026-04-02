/* eslint-disable no-console */
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const SERVER_TIMESTAMP = admin.firestore.FieldValue.serverTimestamp();

const argv = process.argv.slice(2);
const arg = (name, fallback = "") => {
  const prefix = `--${name}=`;
  const hit = argv.find((a) => a.startsWith(prefix));
  return hit ? hit.slice(prefix.length) : fallback;
};
const hasFlag = (name) => argv.includes(`--${name}`);

const fxRate = Number(arg("fxRate", "0.0095"));
const batchId = arg("batchId", `fx_${new Date().toISOString().replace(/[:.]/g, "-")}`);
const dryRun = hasFlag("dryRun");
const limit = Number(arg("limit", "0"));

if (!Number.isFinite(fxRate) || fxRate <= 0) {
  throw new Error("Invalid --fxRate. Example: --fxRate=0.0095");
}

function toGbp(inr) {
  return Number((inr * fxRate).toFixed(2));
}

function isInr(currency) {
  return String(currency || "").trim().toLowerCase() === "inr";
}

function bookingPatch(data) {
  const payment = data.payment || {};
  if (!isInr(payment.currency)) return null;
  const total = Number(payment.totalAmount || 0);
  const advance = Number(payment.advanceAmount || 0);
  const remaining = Number(payment.remainingAmount || 0);
  return {
    "payment.currency": "gbp",
    "payment.totalAmount": toGbp(total),
    "payment.advanceAmount": toGbp(advance),
    "payment.remainingAmount": toGbp(remaining),
    "payment.fxMigration": {
      sourceCurrency: "inr",
      targetCurrency: "gbp",
      fxRate,
      originalAmountInr: total,
      convertedAmountGbp: toGbp(total),
      migrationBatchId: batchId,
      convertedAt: SERVER_TIMESTAMP,
    },
    updatedAt: SERVER_TIMESTAMP,
  };
}

function paymentTransactionPatch(data) {
  if (!isInr(data.currency)) return null;
  const amount = Number(data.amount || 0);
  return {
    currency: "gbp",
    amount: toGbp(amount),
    fxMigration: {
      sourceCurrency: "inr",
      targetCurrency: "gbp",
      fxRate,
      originalAmountInr: amount,
      convertedAmountGbp: toGbp(amount),
      migrationBatchId: batchId,
      convertedAt: SERVER_TIMESTAMP,
    },
    updatedAt: SERVER_TIMESTAMP,
  };
}

function walletTransactionPatch(data) {
  if (!isInr(data.currency)) return null;
  const amount = Number(data.amount || 0);
  return {
    currency: "GBP",
    amount: toGbp(amount),
    fxMigration: {
      sourceCurrency: "inr",
      targetCurrency: "gbp",
      fxRate,
      originalAmountInr: amount,
      convertedAmountGbp: toGbp(amount),
      migrationBatchId: batchId,
      convertedAt: SERVER_TIMESTAMP,
    },
  };
}

function referralPatch(data) {
  const reward = data.reward || {};
  if (!isInr(reward.currency)) return null;
  const referrer = Number(reward.referrerReward || 0);
  const referred = Number(reward.referredReward || 0);
  return {
    "reward.currency": "GBP",
    "reward.referrerReward": toGbp(referrer),
    "reward.referredReward": toGbp(referred),
    fxMigration: {
      sourceCurrency: "inr",
      targetCurrency: "gbp",
      fxRate,
      originalAmountInr: referrer + referred,
      convertedAmountGbp: toGbp(referrer + referred),
      migrationBatchId: batchId,
      convertedAt: SERVER_TIMESTAMP,
    },
  };
}

async function migrateCollection({name, patchBuilder}) {
  const snap = await db.collection(name).get();
  let scanned = 0;
  let candidates = 0;
  let updated = 0;
  let skipped = 0;
  const preview = [];
  let batch = db.batch();
  let opsInBatch = 0;

  for (const doc of snap.docs) {
    scanned += 1;
    const patch = patchBuilder(doc.data());
    if (!patch) {
      skipped += 1;
      continue;
    }
    candidates += 1;
    if (limit > 0 && updated >= limit) continue;

    if (dryRun) {
      preview.push({id: doc.id, patch});
      updated += 1;
      continue;
    }

    batch.update(doc.ref, patch);
    opsInBatch += 1;
    updated += 1;
    if (opsInBatch >= 400) {
      await batch.commit();
      batch = db.batch();
      opsInBatch = 0;
    }
  }

  if (!dryRun && opsInBatch > 0) {
    await batch.commit();
  }

  return {name, scanned, candidates, updated, skipped, preview};
}

async function main() {
  console.log("Starting INR->GBP migration");
  console.log(JSON.stringify({dryRun, fxRate, batchId, limit}, null, 2));

  const results = [];
  results.push(await migrateCollection({name: "bookings", patchBuilder: bookingPatch}));
  results.push(await migrateCollection({
    name: "payment_transactions",
    patchBuilder: paymentTransactionPatch,
  }));
  results.push(await migrateCollection({
    name: "wallet_transactions",
    patchBuilder: walletTransactionPatch,
  }));
  results.push(await migrateCollection({name: "referrals", patchBuilder: referralPatch}));

  const totals = results.reduce((acc, item) => {
    acc.scanned += item.scanned;
    acc.candidates += item.candidates;
    acc.updated += item.updated;
    acc.skipped += item.skipped;
    return acc;
  }, {scanned: 0, candidates: 0, updated: 0, skipped: 0});

  console.log("Migration summary");
  console.table(results.map((r) => ({
    collection: r.name,
    scanned: r.scanned,
    candidates: r.candidates,
    updated: r.updated,
    skipped: r.skipped,
  })));
  console.log(JSON.stringify({totals}, null, 2));

  if (dryRun) {
    const sample = results.flatMap((r) => r.preview.slice(0, 3).map((p) => ({
      collection: r.name,
      id: p.id,
      patch: p.patch,
    })));
    console.log("Dry-run sample patches");
    console.log(JSON.stringify(sample, null, 2));
  }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error("Migration failed", error);
      process.exit(1);
    });
