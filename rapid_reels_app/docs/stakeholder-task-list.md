# Rapid Reels — stakeholder task list (updated)

**Product name:** Use **Rapid Reels** consistently (see `lib/core/constants/app_strings.dart`).

**Note on original wording:** “Grinded” → treat as **grainy / low-quality image**. “Banner section group” → **visually group** the banner carousel, indicators, and related actions. “Vendors” → **providers** in this codebase.

**Completed (repo):** **1**, **2**, **4–15** (customer + provider sections below). **Item 3 (home onboarding)** is **deprecated / removed** from the app (see §3).

---

## Customer app

### 1. OTP verification — brand logo — **Done**

- [x] Add the **Rapid Reels** brand mark on the OTP verification screen (`lib/features/auth/presentation/screens/otp_verification_screen.dart`): `Image.asset` via `AppAssets.logo` (currently `onboarding_1.jpg`; swap for `logo.png` when ready) with gradient wordmark fallback.

### 2. Offer popup and coupons — **Done**

- [x] Home **offer popup**: loads first active Firestore offer; hero image via `CachedNetworkImage` (high quality); card layout; code + CTAs; fallback when no image/offer (`home_screen.dart`).
- [x] **Coupon code** on **booking summary** (`booking_summary_screen.dart`): apply / validate via `validateOfferCode`, discount lines, metadata on booking; advance scaled when coupon applied.
- [x] Related: offer timing unchanged (`_showOfferPopup`, cooldown prefs on `home_screen.dart`).

### 3. Replace home “Quick Actions” with first-time onboarding — **Deprecated (removed from app)**

**Status:** This feature is **not shipped**. All coach-mark / first-run tutorial code has been **removed** from [`home_screen.dart`](../lib/features/home/presentation/screens/home_screen.dart); the **`showcaseview`** dependency was removed from [`pubspec.yaml`](../pubspec.yaml).

**Still in place from earlier work (unchanged):**

- Quick Actions row remains **removed**; **Book Now** stays as a full-width CTA **below** the promo banner.
- Home **offer popup** is independent of onboarding and still uses `_checkOfferPopup()` on load (`home_screen.dart`).

**If product revives onboarding later:** reintroduce via a package (e.g. [`showcaseview`](https://pub.dev/packages/showcaseview)) or a custom overlay; keep `ShowCaseWidget` (or `ShowcaseView.register`) above the subtree that includes both **Home** and **bottom nav** if you need to highlight tab items.

#### Archived notes (do not implement unless product re-opens item 3)

<details>
<summary>Former research / checklist (historical)</summary>

- Stakeholder research table and Flutter package options were previously captured here; treat as **non-binding** while item 3 stays deprecated.
- Optional: replay from Profile, analytics events — **not implemented**.

</details>

### 4. Home layout — banner, Book Now, floating action button — **Done**

- **Grouped** the **banner** block in `home_screen.dart`: `GlassSurfaceCard` + **Spotlight** header (`AppStrings.homeBannerSectionTitle`), carousel, page dots, then **Book Now** (`_buildHomeBookNowButton`) inside the same section.
- **Removed** the Home tab **FAB** “Book Now” from `lib/shared/widgets/main_scaffold.dart` (primary booking CTA remains on the home banner).

### 5. Trending reels — sort by likes — **Done**

- `getDiscoverReels` in `firestore_service.dart` orders by **`FirebaseReelModel.compareForTrending`** (likes first, then tie-breakers). Home trending strip and discover feed use this ordering.

### 6. Custom bottom navigation bar — **Done**

- `lib/shared/widgets/rapid_bottom_nav_bar.dart`: branded bar with **SafeArea**, top border/shadow, four tabs. `main_scaffold.dart` uses it instead of `BottomNavigationBar`.

### 7. Reels tab icon — **Done**

- Reels tab uses **`Icons.movie_filter_outlined` / `Icons.movie_filter_rounded`** (short-video / reels affordance) in `rapid_bottom_nav_bar.dart`.

### 8. Rename “My” → “My Events” — **Done**

- Label **`AppStrings.navMyEvents`** (“My Events”) in `rapid_bottom_nav_bar.dart` (aligned with `DynamicMyEventsScreen`).

### 9. Provider discovery — location and rating filters — **Done**

- **Select Provider** (`provider_selection_screen.dart`): filter sheet includes **location** (match booking/saved city, **all locations**, or a specific city via `AppCities.customerFilterCities`) and **minimum rating** (slider). Reload uses `getProviders` with `city` / `minRating` where applicable; summary line under the count shows the active location mode.
- **Home** (`home_screen.dart`): **Provider rating** chips (Any, 3.5+, 4+, 4.5+) apply to **Nearby Photography Studios** and **Featured Providers** (`_loadNearbyVenues` / `_loadFeaturedProviders`). City remains the existing home city picker; changing city reloads nearby + featured.
- Shared city list: `lib/core/constants/app_cities.dart` (aligned with the former home inline list).

### 10. Privacy — hide provider phone numbers — **Done**

- **Provider profile** (`provider_details_screen.dart`): secondary action is **Email** (mailto via `url_launcher`); phone/SMS/dialer paths removed from the customer contact UI.
- **Booking summary** (`booking_summary_screen.dart`): provider block uses **Updates** + `AppStrings.providerContactViaApp` instead of showing a phone number.
- **Event details** (`event_details_screen.dart`): removed call button and phone line; **View provider** navigates to provider details; privacy copy via `AppStrings.providerContactViaApp`.

### 11. Remove “30%” coupon messaging — **Done**

- **`offers_screen.dart`**: Birthday Bash entry — no fixed **30%** in title/description/discount badge; code `BDAYVIP`, badge **Limited offer**.
- **`offers_coupons_screen.dart`**: expired New Year sample — neutral copy and **Promo** instead of **30%**.

---

## Provider app

### 12. Booking calendar — green markers on dates with bookings — **Done**

- `ProviderBookingCalendarScreen`: **`AppColors.success`** for default `markerDecoration` and `markerBuilder` — **green** dot when that day has **any** booking (not status-colored). **Today** keeps the primary-tinted circle.

### 13. Dashboard “Total” stat — navigation — **Done**

- **Total** opens the **provider bookings list** (`/provider-bookings/:providerId`), same destination pattern as **Today** and **Pending** (full list with tabs). Calendar remains on the **Booking calendar** card below.

### 14. New provider — admin approval before reels — **Done**

- **Login** (`provider_login_screen.dart`): **Rejected** (and inactive non-pending) blocked; **Pending** may sign in to see the dashboard.
- **Dashboard** overview: banner when `verificationStatus != 'approved'` (`AppStrings.providerPendingApprovalProvider`).
- **Reels tab**: locked message until approved; **My Reels** / **Upload** gated by `streamProviderDoc` + `upload_footage_screen.dart` approval check.
- **Customers** (`provider_details_screen.dart`): info banner + **Book Now** disabled until `verificationStatus == 'approved'` (`AppStrings.providerPendingApprovalCustomer`). Admin approval continues to use existing Firestore `verificationStatus` + admin screens.

### 15. Provider dashboard app bar — **Done**

- Removed **calendar** and **availability** `AppBar` actions; **notifications** kept.
- **Title** column: small **Rapid Reels** + **business name**; `toolbarHeight` / `scrolledUnderElevation` tuned for a clearer shell.

---

## Suggested implementation order

1. Small copy/branding: ~~OTP logo~~ **done**, ~~My → My Events, Reels icon~~ **done (items 7–8)**.  
2. Navigation shell: ~~custom bottom bar, remove Home FAB~~ **done (items 4, 6)**; ~~home banner grouping~~ **done (item 4)**.  
3. ~~**First-run onboarding (item 3)**~~ **deprecated — removed from codebase.**  
4. ~~Privacy: hide phones~~ **done (item 10)**.  
5. ~~Trending: like-based sort (data + UI)~~ **done (item 5)**.  
6. ~~Offers: popup polish + coupon in booking flow~~ **done** (item 2).  
7. ~~Discovery: filters~~ **done (item 9)**; ~~30% copy~~ **done (item 11)**.  
8. ~~Provider: calendar markers, dashboard app bar, approval gating, Total navigation~~ **done (items 12–15)**.

---

## References (onboarding — **deprecated**)

Only relevant if item 3 is revived: [VWO onboarding](https://vwo.com/blog/mobile-app-onboarding-guide/), [Adapty](https://adapty.io/blog/how-to-fix-your-onboarding-flow/), [NextNative checklist](https://nextnative.dev/blog/app-onboarding-checklist); packages such as [showcaseview](https://pub.dev/packages/showcaseview), [spotlight](https://pub.dev/packages/spotlight), [feature_spotlight](https://pub.dev/packages/feature_spotlight).
