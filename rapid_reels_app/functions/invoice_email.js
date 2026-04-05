/**
 * Post-payment invoice PDF + SMTP email (e.g. Gmail App Password via nodemailer).
 */

const PDFDocument = require("pdfkit");
const nodemailer = require("nodemailer");
const admin = require("firebase-admin");

const ISO_DATE_LEN = 10;

/**
 * @param {object} booking
 * @return {string}
 */
function formatEventDate(booking) {
  const ed = booking.eventDate;
  if (ed && typeof ed.toDate === "function") {
    const d = ed.toDate();
    return d.toISOString().slice(0, ISO_DATE_LEN);
  }
  if (ed instanceof Date) return ed.toISOString().slice(0, ISO_DATE_LEN);
  return "";
}

/**
 * @param {object} booking
 * @param {object} paymentIntent Stripe PaymentIntent
 * @param {string} bookingId
 * @param {string} providerBusinessName
 * @return {Promise<Buffer>}
 */
function buildInvoicePdfBuffer({
  booking,
  paymentIntent,
  bookingId,
  providerBusinessName,
}) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({size: "A4", margin: 50});
    const chunks = [];
    doc.on("data", (c) => chunks.push(c));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);

    const currency = String(paymentIntent.currency || "gbp").toUpperCase();
    const paid =
      (paymentIntent.amount_received || paymentIntent.amount || 0) / 100;
    const pkg = booking.package || {};
    const symbol = currency === "GBP" ? "\u00a3" : `${currency} `;

    doc.fontSize(18).text("INVOICE", {align: "right"});
    doc.moveDown(0.5);
    doc.fontSize(9).fillColor("#666666");
    doc.text(
        providerBusinessName || "Rapid Reels",
        {align: "right"},
    );
    doc.fillColor("#000000");
    doc.moveDown(1.5);
    doc.fontSize(10);
    doc.text(`Invoice number: ${bookingId}`);
    doc.text(`Issue date: ${new Date().toISOString().slice(0, ISO_DATE_LEN)}`);
    doc.moveDown();
    doc.fontSize(12).text("Bill to", {underline: true});
    doc.fontSize(10);
    doc.text(booking.contactPerson || "Customer");
    if (booking.contactNumber) doc.text(String(booking.contactNumber));
    doc.moveDown();
    doc.fontSize(12).text("Event details", {underline: true});
    doc.fontSize(10);
    doc.text(`Event: ${booking.eventName || "—"}`);
    doc.text(`Type: ${booking.eventType || "—"}`);
    const evd = formatEventDate(booking);
    if (evd) doc.text(`Event date: ${evd}`);
    if (booking.eventTime) doc.text(`Time: ${booking.eventTime}`);
    doc.moveDown();
    doc.fontSize(12).text("Charges", {underline: true});
    doc.fontSize(10);
    doc.text(`${pkg.name || "Service package"} — ${symbol}${paid.toFixed(2)}`);
    doc.moveDown();
    doc.fontSize(11).text(
        `Amount paid: ${symbol}${paid.toFixed(2)}`,
        {align: "right"},
    );
    doc.moveDown(0.5);
    doc.fontSize(9).fillColor("#444444");
    doc.text(`Payment: Stripe`);
    doc.text(`Transaction ID: ${paymentIntent.id}`);
    doc.fillColor("#000000");
    doc.moveDown(2);
    doc.fontSize(9).text(
        "Thank you for your payment. This invoice was generated automatically.",
        {align: "center"},
    );
    doc.end();
  });
}

/**
 * @param {object} p
 * @return {string}
 */
function buildInvoiceHtml({
  booking,
  bookingId,
  paymentIntent,
  providerBusinessName,
}) {
  const currency = String(paymentIntent.currency || "gbp").toUpperCase();
  const paid =
      (paymentIntent.amount_received || paymentIntent.amount || 0) / 100;
  const pkg = booking.package || {};
  const symbol = currency === "GBP" ? "&pound;" : `${currency} `;
  const evd = formatEventDate(booking);
  const brand = providerBusinessName || "Rapid Reels";

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Payment receipt — ${bookingId}</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.5; color: #222;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 560px; margin: 0 auto;">
    <tr>
      <td style="padding: 24px 0;">
        <h1 style="margin: 0 0 8px; font-size: 20px;">Payment received</h1>
        <p style="margin: 0; color: #555; font-size: 14px;">
          ${brand}
        </p>
      </td>
    </tr>
    <tr>
      <td style="padding: 16px; background: #f5f5f5; border-radius: 8px;">
        <p style="margin: 0 0 12px; font-size: 14px;">
          Thank you for your payment. Your booking is confirmed. A PDF invoice is attached.
        </p>
        <table width="100%" cellpadding="8" style="font-size: 14px;">
          <tr><td><strong>Invoice #</strong></td><td>${bookingId}</td></tr>
          <tr><td><strong>Event</strong></td><td>${escapeHtml(booking.eventName || "—")}</td></tr>
          ${evd ? `<tr><td><strong>Event date</strong></td><td>${evd}</td></tr>` : ""}
          <tr><td><strong>Package</strong></td><td>${escapeHtml(pkg.name || "—")}</td></tr>
          <tr><td><strong>Amount paid</strong></td><td>${symbol}${paid.toFixed(2)}</td></tr>
          <tr><td><strong>Stripe reference</strong></td><td>${paymentIntent.id}</td></tr>
        </table>
      </td>
    </tr>
    <tr>
      <td style="padding: 24px 0; font-size: 12px; color: #888;">
        If you have questions, reply to this email or contact support through the app.
      </td>
    </tr>
  </table>
</body>
</html>`;
}

/**
 * @param {string} s
 * @return {string}
 */
function escapeHtml(s) {
  return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
}

/**
 * @param {object} opts
 * @return {Promise<void>}
 */
async function maybeSendInvoiceEmail({
  db,
  bookingRef,
  bookingId,
  bookingSnapshotData,
  paymentIntent,
  logger,
  smtp,
}) {
  if (!smtp || !smtp.user || !smtp.pass) {
    logger.info("Invoice email skipped: SMTP_USER / SMTP_PASS not configured");
    return;
  }

  const existingMeta = bookingSnapshotData.metadata || {};
  if (existingMeta.invoiceEmailSentAt) {
    logger.info("Invoice email skipped: already sent", {bookingId});
    return;
  }

  const customerId = String(bookingSnapshotData.customerId || "");
  if (!customerId) {
    logger.warn("Invoice email skipped: missing customerId", {bookingId});
    await bookingRef.update({
      "metadata.invoiceEmailSkipped": "no_customer_id",
      "metadata.invoiceEmailSkippedAt": admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  const userSnap = await db.collection("users").doc(customerId).get();
  const to = (userSnap.data() && userSnap.data().email) ?
      String(userSnap.data().email).trim() :
      "";
  if (!to) {
    logger.warn("Invoice email skipped: user has no email", {bookingId, customerId});
    await bookingRef.update({
      "metadata.invoiceEmailSkipped": "no_customer_email",
      "metadata.invoiceEmailSkippedAt": admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  let providerBusinessName = "";
  const providerId = String(bookingSnapshotData.providerId || "");
  if (providerId) {
    const provSnap = await db.collection("providers").doc(providerId).get();
    if (provSnap.exists) {
      providerBusinessName = String(provSnap.data().businessName || "");
    }
  }

  const booking = bookingSnapshotData;
  const pdfBuffer = await buildInvoicePdfBuffer({
    booking,
    paymentIntent,
    bookingId,
    providerBusinessName,
  });

  const html = buildInvoiceHtml({
    booking,
    bookingId,
    paymentIntent,
    providerBusinessName,
  });

  const from = smtp.from || smtp.user;
  const port = smtp.port || 465;
  const secure = smtp.secure !== undefined ? smtp.secure : port === 465;

  const transportOpts = {
    host: smtp.host || "smtp.gmail.com",
    port,
    secure,
    auth: {
      user: smtp.user,
      pass: smtp.pass,
    },
  };
  if (port === 587) {
    transportOpts.secure = false;
    transportOpts.requireTLS = true;
  }

  const transporter = nodemailer.createTransport(transportOpts);

  const subject = `Invoice — ${booking.eventName || "Your booking"} (${bookingId})`;

  await transporter.sendMail({
    from: `"${providerBusinessName || "Rapid Reels"}" <${from}>`,
    to,
    subject,
    html,
    text: `Thank you for your payment.\n\nInvoice #: ${bookingId}\nAmount: ${paymentIntent.currency} ${((paymentIntent.amount_received || paymentIntent.amount || 0) / 100).toFixed(2)}\nStripe: ${paymentIntent.id}\n\nYour PDF invoice is attached.`,
    attachments: [
      {
        filename: `invoice-${bookingId}.pdf`,
        content: pdfBuffer,
        contentType: "application/pdf",
      },
    ],
  });

  await bookingRef.update({
    "metadata.invoiceEmailSentAt": admin.firestore.FieldValue.serverTimestamp(),
    "metadata.invoiceStripePaymentIntentId": String(paymentIntent.id || ""),
    "metadata.invoiceEmailRecipient": to,
  });

  logger.info("Invoice email sent", {bookingId, to});
}

module.exports = {
  maybeSendInvoiceEmail,
  buildInvoicePdfBuffer,
  buildInvoiceHtml,
};
