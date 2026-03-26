# Event catalogue management (provider role) — implementation plan

This document describes the **current user and provider booking surfaces**, the **data model today**, **gaps** relative to “one provider manages multiple bookable events with gallery and rich details,” and a **phased plan** to implement a dynamic **event catalogue** that stays compatible with the existing customer booking flow.

---

## 1. Goals

- Providers can create, edit, reorder, publish/unpublish, and delete **multiple catalogue entries** (marketable “events” or **service offerings**), each with **hero + gallery images**, **copy**, **highlights**, and **linked pricing tiers** (packages).
- Customers booking a provider see **the same structured content** the provider curated (detail page + booking path), not only a flat provider profile and generic package carousel.
- **Backward compatible:** existing bookings and providers without a catalogue continue to work; new fields are optional with sensible fallbacks.
- Align **listing → selection → package → summary → payment** with Firestore-backed data where the app already uses static or provider-level-only structures.

---

## 2. Current behaviour — user (customer) role

Routes are defined in `lib/core/constants/app_routes.dart` and wired in `lib/core/router/app_router.dart`.

| Step | Route | Screen | Role in flow |
|------|--------|--------|----------------|
| 1 | `/event-type-selection` | `EventTypeSelectionScreen` | User picks a **global** event type (`wedding`, `birthday`, …). Navigates to **package selection** with `extra: { eventType }`. |
| 2 | `/package-selection` | `PackageSelectionScreen` | **Static** `PackageOffering` list (Bronze/Silver/Gold) — **not** loaded from provider or Firestore. |
| 3 | `/event-details` or `/event-details-form` | `EventDetailsFormScreen` | User enters event name, date, guest count, etc.; builds `bookingData`. |
| 4 | `/venue-selection` | `VenueSelectionScreen` | Venue + city (`venueCity`) into `bookingData`. |
| 5 | `/provider-selection` | `ProviderSelectionScreen` | Loads providers via `FirestoreService.getProviders` (city, active, verified). **Does not pass `eventTypes` into `getProviders`** — filtering by selected event type is only applied in memory if at all; **verify and fix** so catalogue/event-type alignment is reliable. |
| 6 | `/provider-portfolio` | `ProviderPortfolioScreen` | Provider hero (`coverImages`), bio, **portfolio reels** (embedded `portfolio` or `getProviderReels`). User proceeds toward package customization. |
| 7 | `/package-customization` | `PackageCustomizationScreen` | Add-ons / customizations on top of selected package. |
| 8 | `/booking-summary` | `BookingSummaryScreen` | Review; reads `bookingData` including `package` map, `providerId`, event fields. Uses `FirestoreService` + `BookingFirebaseAdapter` for persistence. |
| 9 | `/payment` | `PaymentScreen` | Payment step. |

**Parallel entry:** `ProviderDetailsScreen` (`features/providers/...`) — opened from home/discover-style flows with `providerId`; loads **`FirebaseProviderModel`** from Firestore (cover, bio, **tabs**: portfolio-style content). This is the main **“what we show the user before booking”** surface besides `ProviderPortfolioScreen`.

**Post-booking:** `DynamicMyEventsScreen` → `EventDetailsScreen` / `LiveEventTrackingScreen` — these reflect **`bookings`** + live event data, not a separate “catalogue” entity today.

**Takeaway for catalogue work:** Today the “product” the user books is **`eventType` (global) + `provider.packages[]` (on provider doc) + static package step**, not a first-class **provider-owned catalogue item** with its own media and description. **`PackageSelectionScreen` is the biggest mismatch** with provider-managed pricing.

---

## 3. Current behaviour — provider role

| Area | Route pattern | Screen | Notes |
|------|----------------|--------|--------|
| Dashboard | `/provider-dashboard/:providerId` | `ProviderDashboardScreen` | Stats, today’s bookings, links to bookings/reels/profile. **No catalogue CRUD.** |
| Bookings | `/provider-bookings/:providerId` | `ProviderBookingsScreen` | Lists `FirebaseBookingModel` by provider. |
| Booking detail / ops | `/provider-booking-timeline/...`, `provider-customer-contact`, `provider-venue-navigation`, `provider-pre-event-checklist`, `provider-booking-status` | Various | Operational; consume **booking** fields (`eventType`, `package`, venue, …). |
| Calendar | `/provider-booking-calendar/:providerId` | `ProviderBookingCalendarScreen` | Schedule. |
| Earnings | `/provider-earnings/:providerId` | `ProviderEarningsScreen` | Financial. |
| Reels | `/provider-my-reels/:providerId`, editor, upload | | Content delivery, not catalogue marketing pages. |
| Onboarding / profile | `provider-business-profile`, `provider-portfolio-upload`, `provider-service-areas`, `provider-document-upload`, `provider-availability-calendar`, `provider-verification` | | Shapes **`FirebaseProviderModel`**: `eventTypes`, `packages`, `portfolio`, `coverImages`, etc. |

**Data model (Firestore):** `providers/{providerId}` holds **`eventTypes`**, **`packages`** (flat `PackageOffering` list), **`portfolio`**, **`coverImages`**, bio, location, availability — see `lib/core/firebase/models/firebase_provider_model.dart`.

**Takeaway:** Providers can maintain **packages on the provider document** and **portfolio**, but there is **no subcollection or document type** for “multiple distinct bookable events” each with **dedicated gallery + long-form detail**. **`ProviderDashboardScreen` has no entry point** for a catalogue manager.

---

## 4. Gap analysis

| Gap | Impact |
|-----|--------|
| No `catalogueEventId` (or equivalent) on bookings | Cannot trace which marketing “event” was sold; hard to edit catalogue without breaking historical display. |
| `PackageSelectionScreen` uses **hardcoded** packages | User pricing step does not reflect provider-managed packages from Firestore. |
| Provider `packages[]` is a **single flat list** | Cannot attach **per-offering galleries**, **SEO titles**, **rich descriptions**, or **multiple distinct offerings** of the same `eventType` without overloading fields. |
| `ProviderSelectionScreen` may not filter by **`eventType`** at query level | Catalogue must align with **event type** (and city); current loader should be audited (pass `eventTypes: [bookingData['eventType']]` into `getProviders` where intended). |
| `ProviderDetailsScreen` / portfolio flow | Need a **“Services & packages”** (or **Events**) section fed by catalogue, not only generic provider packages array. |
| Image storage | Cover images exist on provider; catalogue needs **multiple images per entry** — define **Firebase Storage** paths and reuse existing upload patterns from portfolio/cover flows. |

---

## 5. Target concept: catalogue entry (provider-owned “event product”)

### 5.1 Suggested Firestore shape (recommended)

**Option A (preferred for scale): subcollection**

- `providers/{providerId}/catalogue_events/{catalogueEventId}`

Each document includes (illustrative):

- **Identity:** `title`, `shortDescription`, `slug` (optional), `eventType` (matches app enums: `wedding`, …)
- **Media:** `heroImageUrl`, `galleryImageUrls[]` (ordered)
- **Marketing:** `longDescription` (markdown or plain), `highlights[]` (strings), `tags[]` (optional)
- **Commercial:** `packageIds[]` referencing **either** embedded package ids on the provider **or** inline `PackageOffering`-shaped maps (see compatibility below)
- **Lifecycle:** `isPublished`, `sortOrder`, `createdAt`, `updatedAt`
- **Optional:** `startingPrice` (denormalized for cards), `durationRange` copy for cards

**Option B:** top-level collection `catalogue_events` with `providerId` + composite indexes for queries. Use if you need cross-provider admin search later; otherwise subcollection keeps security rules simpler.

### 5.2 Booking document extension

On `bookings/{bookingId}` (and `FirebaseBookingModel` / adapters):

- Add optional **`catalogueEventId`**
- Add optional **snapshot** fields for immutability after booking: `catalogueTitle`, `catalogueHeroUrl` (or store under `metadata`)

Existing bookings: `catalogueEventId == null` → UI falls back to current `eventType` + `package` display.

### 5.3 Relationship to existing `providers.packages`

- **Phase 1:** Catalogue entries **reference** existing `packageId` values on the provider document; package customization flow unchanged.
- **Phase 2 (optional):** Move packages under each catalogue entry or duplicate **tiers** per entry for cleaner UX — only if product needs different package sets per catalogue item.

---

## 6. User-flow compatibility (what must change in the app)

Keep the **same high-level order** (type → details → venue → provider → **pick offering** → customize → summary → pay), inserting **“pick catalogue offering”** where it fits best:

**Recommended insertion point:** After **`ProviderPortfolioScreen`** (or merged into an expanded **provider detail** step):

1. User selects provider → show **catalogue list** filtered by `bookingData['eventType']` and `isPublished`.
2. User opens **catalogue detail** (full gallery + copy) → taps **Book** → selected **`catalogueEventId`** + **default or chosen package** → existing **`PackageCustomizationScreen`** receives enriched `bookingData`.

**Alternative:** From `ProviderDetailsScreen`, deep-link to a catalogue detail route before entering the global booking stack — same underlying `bookingData` keys.

**Package selection route:** Either deprecate **global** `PackageSelectionScreen` for this flow or repurpose it to load **provider catalogue + packages** once a provider is known — **today it is static**, so the plan should explicitly **replace or gate** static packages when `providerId` + `catalogueEventId` are in context.

---

## 7. Provider-flow additions

| Deliverable | Description |
|-------------|-------------|
| **Catalogue list screen** | Under provider app: list all catalogue entries, publish toggle, sort, empty state, link from dashboard. |
| **Catalogue editor** | Create/edit title, type, copy, highlights, hero + gallery (pick from uploads or Storage), attach packages (multi-select from provider’s `packages` or inline create). |
| **Preview** | “View as customer” using same widgets as user-side detail (shared widget layer). |
| **Media upload** | Reuse or extend patterns from `ProviderPortfolioUploadScreen` / cover image handling; enforce size limits and progress UI. |

**Navigation:** New routes, e.g. `/provider-catalogue/:providerId`, `/provider-catalogue/:providerId/edit/:catalogueEventId` (exact names to match `AppRoutes` conventions).

---

## 8. Firestore & security

- **Rules:** Allow read on published catalogue for authenticated users (or public read if marketing pages are public); writes only for `providerId` matching authenticated provider account.
- **Indexes:** If querying `catalogue_events` by `eventType` + `isPublished`, add composite index (or query by `providerId` then filter in app for small lists).
- **Storage rules:** Folder per provider, e.g. `providers/{providerId}/catalogue/{catalogueEventId}/...`

---

## 9. Phased implementation checklist

### Phase A — Models & backend plumbing

- [ ] Define `FirebaseCatalogueEventModel` (or equivalent) + `fromFirestore` / `toFirestore`.
- [ ] Add `FirestoreService` methods: `streamCatalogueEvents(providerId)`, `getCatalogueEvent`, `setCatalogueEvent`, `deleteCatalogueEvent`, optional reorder batch update.
- [ ] Extend `FirebaseBookingModel` + `booking_firebase_mappers` / adapter with optional `catalogueEventId` + snapshot fields.
- [ ] Update seed data (`seed_sample_providers.dart`) with sample catalogue entries for QA.

### Phase B — Provider UI

- [ ] Add routes + dashboard card / tab entry for **Manage event catalogue**.
- [ ] Build list + editor + image pickers + publish/sort.
- [ ] Validation: at least one package or explicit “contact for quote” flag if product allows.

### Phase C — Customer UI

- [ ] Shared **catalogue card** + **catalogue detail** widgets (used by provider preview and user app).
- [ ] Integrate into `ProviderPortfolioScreen` and/or `ProviderDetailsScreen` after provider selection or on provider profile.
- [ ] Pass `catalogueEventId` + package into `bookingData` through `PackageCustomizationScreen` and `BookingSummaryScreen`.
- [ ] **Fix provider list filtering:** pass `eventTypes` from `bookingData` into `getProviders` (and reconcile with `ProviderCard` display).
- [ ] Replace or bypass **static** `PackageSelectionScreen` when booking is provider-scoped (load real packages for selected catalogue entry).

### Phase D — My Events & provider bookings

- [ ] Show catalogue title/hero in `EventDetailsScreen` / booking detail when snapshot fields exist.
- [ ] `ProviderBookingDetailsScreen`: display which catalogue offering was booked.

### Phase E — QA & polish

- [ ] Offline / loading / empty states; image failures.
- [ ] Edit catalogue after bookings: snapshot on booking prevents breaking history.
- [ ] Performance: lazy-load gallery; cap image count.

---

## 10. Files likely to touch (reference)

| Area | Paths (non-exhaustive) |
|------|-------------------------|
| Routes | `lib/core/constants/app_routes.dart`, `lib/core/router/app_router.dart` |
| Provider model | `lib/core/firebase/models/firebase_provider_model.dart` |
| Booking model | `lib/core/firebase/models/firebase_booking_model.dart`, `lib/features/booking/data/adapters/booking_firebase_*.dart` |
| Firestore | `lib/core/firebase/services/firestore_service.dart` |
| User booking UI | `.../booking/presentation/screens/` (`provider_selection_screen.dart`, `provider_portfolio_screen.dart`, `package_selection_screen.dart`, `package_customization_screen.dart`, `booking_summary_screen.dart`) |
| Provider profile | `lib/features/providers/presentation/screens/provider_details_screen.dart` |
| Provider app | `lib/features/provider/presentation/screens/provider_dashboard_screen.dart`, new catalogue screens |
| My events | `lib/features/my_events/presentation/screens/event_details_screen.dart` |

---

## 11. Success criteria

- A provider can maintain **multiple** catalogue entries with **galleries and rich text**, independent of portfolio reels.
- A customer can discover those entries in the **existing booking path** and complete checkout with **Firestore-backed** package data.
- Bookings created before this feature **unchanged** in behaviour; new bookings optionally store **`catalogueEventId`** + display snapshots.
- **`PackageSelectionScreen` no longer the only source of truth** for pricing when a provider and catalogue are in scope — data comes from **provider + catalogue**.

---

## 12. Open product decisions (to lock before build)

1. **Single vs multiple packages per catalogue entry** — reference shared provider packages vs duplicate tiers per entry.
2. **Global `PackageSelectionScreen`** — remove for main funnel, keep for quick demos, or drive entirely from first provider selection.
3. **Discover / home** — whether catalogue entries appear outside provider profile (out of scope unless product asks for it).

---

*Document generated for Rapid_Reels: aligns with routes in `app_routes.dart`, provider document shape in `firebase_provider_model.dart`, and booking shape in `firebase_booking_model.dart`.*
