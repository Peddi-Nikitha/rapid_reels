# Reels: dynamic like / comment / share — implementation todo

This document summarizes the **current code paths**, **what the database already supports**, and a **concrete checklist** to make reels engagement fully functional and consistent across user and provider flows.

---

## 1. Current behavior (by screen)

### Customer (user) role

| Screen | Route / entry | Video UX | Like | Comment | Share |
|--------|----------------|----------|------|---------|-------|
| **My Reels gallery** | `MyReelsGalleryScreen` → `ReelPlayerScreen` | Full `ReelPlayerScreen` with `ReelVideoLayer` | Local `setState` only (`_likedReels`) — **not persisted** | Bottom sheet increments `_commentIncrements` — **not persisted** | Navigates to share route + local `_sharedReels` — **share count not incremented in Firestore from here** |
| **Discover** | `DiscoverFeedScreen` | Thumbnail stack; **tap opens `ReelViewerScreen`** (simple player, **no** social rail) | Local `setState` — **not persisted** | Same as above — **not persisted** | Same pattern as gallery |
| **Home** (trending strip) | `HomeScreen` | `ReelViewerScreen` on tap | **`FirestoreService.toggleReelLike`** | **`FirestoreService.addReelComment`** | **`incrementReelShares`** + clipboard (implemented) |

**Takeaway:** Engagement is **only wired to Firestore on the home screen**. `ReelPlayerScreen` and `DiscoverFeedScreen` still use the old “mock local state” pattern.

### Provider role

| Screen | Entry | Video UX | Like / comment / share |
|--------|--------|----------|-------------------------|
| **Provider My Reels** | `ProviderMyReelsScreen` | `_viewReel` → **`ReelViewerScreen`** only (title + video) | **No UI** — N/A for provider preview |

**Takeaway:** Providers see analytics in list/grid (`analytics.views` etc.) but there is **no TikTok-style rail** on open; that is acceptable for “owner preview” unless product wants parity with discover.

---

## 2. Database & models — what exists today

### Planned schema (`rapid_reels_app/lib/core/firebase/DATABASE_SCHEMA_PLAN.md`)

- Collection **`reels/{reelId}`** with embedded **`analytics`** (views, likes, shares, comments counts, etc.).
- The plan doc does **not** list subcollections for comments or a `likedBy` field; those were added in code.

### Implemented in `FirestoreService` (actual behavior)

| Feature | Storage | Notes |
|---------|---------|--------|
| **Views** | `reels/{id}` → `analytics.views`, `analytics.lastViewedAt` | `incrementReelViews` exists |
| **Likes** | `reels/{id}` → `analytics.likes` + top-level **`likedBy`: `List<String>`** (user IDs) | `toggleReelLike` uses a **transaction** |
| **Comments (count)** | `analytics.comments` incremented | Kept in sync when a comment is added |
| **Comment bodies** | **`reels/{reelId}/comments/{commentId}`** | `addReelComment` writes `commentId`, `reelId`, `userId`, `text`, `createdAt` |
| **Shares** | `analytics.shares` | `incrementReelShares` |

### `FirebaseReelModel` gap

- Parses **`analytics`** (including `likes`, `comments`, `shares`).
- Does **not** parse **`likedBy`**, so the UI cannot show “already liked” after a cold load without either:
  - extending the model + `fromFirestore` / `toFirestore`, or
  - a small `getReel(reelId)` / snapshot that includes `likedBy` for the current user check.

**Conclusion:** The backend paths for like/comment/share **exist and are used from `home_screen.dart`**. Discover and reel player **do not call them**. Comment **documents** are stored, but there is **no `getReelComments` / stream** in the service yet — so users never see a thread, only counts.

---

## 3. Why “nothing happens” when tapping like / comment (user perception)

1. **Discover / Reel player:** Actions only flip **in-memory** maps; **no `FirestoreService` calls**, so nothing appears in the database and counts reset on navigation/refresh.
2. **Hydration:** Even if writes existed, without **`likedBy` on the model** (or a side query), reopening the app would not show the correct heart state.
3. **Comments:** Posting only bumps a local increment; **no list of comments** is loaded from `reels/.../comments`.
4. **Inconsistent entry points:** Home uses real APIs; other screens do not — feels “broken” when users compare flows.

---

## 4. Target architecture (single source of truth)

1. **One shared engagement layer** (Riverpod providers or a small `ReelEngagementController`) used by:
   - `ReelPlayerScreen`
   - `DiscoverFeedScreen` (prefer **navigating to `ReelPlayerScreen`** or a shared `ReelFeedPage` widget so logic is not duplicated)
2. **Like:** `toggleReelLike` + optimistic UI + rollback on error (copy **`home_screen.dart`** pattern: `_handleReelLike`).
3. **Comment:** `addReelComment` + **`Stream`/pagination** of `reels/{id}/comments` ordered by `createdAt` desc.
4. **Share:** `incrementReelShares` once per successful share action + existing share UI (`ReelShareScreen` / system share) — align with home to avoid double-counting.
5. **Views:** Call `incrementReelViews` when a reel becomes active (page changed / video plays) in `ReelPlayerScreen` and any full-screen feed (debounce to avoid spam).

---

## 5. Implementation checklist

### Data model & Firestore

- [ ] Add **`likedBy`** (or `likedUserIds`) to **`FirebaseReelModel`** with safe parsing (`List<String>.from(...)`) and include in **`toFirestore`** only if you write full documents from the client (often likes are updated via `FieldValue` only — **read** path matters most).
- [ ] Add **`getReel(String reelId)`** if missing, for refreshing a single reel after actions.
- [ ] Add **`streamReelComments(reelId)`** → `reels/{reelId}/comments` orderBy `createdAt` desc, limit page size.
- [ ] Optional: **`streamReel(reelId)`** for live analytics counts on the active reel.
- [ ] Update **`DATABASE_SCHEMA_PLAN.md`** (optional but recommended): document `likedBy` and `reels/{reelId}/comments` subcollection.
- [ ] **Firestore indexes:** composite index if you query comments with multiple where clauses; `orderBy('createdAt')` on subcollection usually needs index when combined with filters.
- [ ] **Security rules:** ensure authenticated users can create comments on **public** reels (or reels they can read); restrict who can write `likedBy` / `analytics` if not using only Cloud Functions (transactions from client need allowed writes).

### UI — customer

- [ ] **`ReelPlayerScreen`:** Replace local-only like/comment/share with **`toggleReelLike`**, **`addReelComment`**, **`incrementReelShares`** (and login guards like home).
- [ ] **`ReelPlayerScreen`:** Load **initial liked state** from `likedBy.contains(currentUserId)` once model supports it.
- [ ] **`ReelPlayerScreen`:** Comment sheet: show **list** (stream) + composer; on post, count updates from server or optimistic + reconcile.
- [ ] **`DiscoverFeedScreen`:** Prefer **inline video + same action column** as `ReelPlayerScreen`, **or** open **`ReelPlayerScreen`** with the loaded list so one implementation owns engagement. Avoid duplicating three different UX patterns (thumbnail → `ReelViewerScreen` vs full player).
- [ ] **`ReelViewerScreen`:** Either keep as **minimal preview only**, or add optional overlay props — avoid a fourth duplicate of like/comment; better to route to `ReelPlayerScreen` when social actions are needed.
- [ ] **Home screen:** Reuse shared providers so `_likedReels` / increments stay in sync with other screens (or remove duplicate state).

### UI — provider

- [ ] **Decide product behavior:** Provider preview stays **analytics-only** (no like rail) **or** use read-only counts + link to “View as public” → `ReelPlayerScreen` read-only mode.
- [ ] If preview should match discover: **`ProviderMyReelsScreen._viewReel`** could push **`ReelPlayerScreen`** with `reels: [_reels]` for parity (watch for auth: providers are users too — same `toggleReelLike` if `userId` is set).

### Quality & edge cases

- [ ] **Unauthenticated users:** SnackBar + redirect to login (already on home).
- [ ] **Offline / failures:** Revert optimistic like; show error SnackBar (home pattern).
- [ ] **Idempotent shares:** Don’t increment shares on every sheet open — only on actual share (home uses clipboard + increment once per action).
- [ ] **Performance:** Debounce view increments; batch provider fetches (already partially done).

### Testing

- [ ] Manual: like → kill app → reopen reel → heart state correct.
- [ ] Manual: comment appears in stream and count matches `analytics.comments`.
- [ ] Rules: attempt cross-user tampering on wrong `reelId`.

---

## 6. File reference (quick navigation)

| Area | Files |
|------|--------|
| Full player + local-only engagement | `rapid_reels_app/lib/features/reels/presentation/screens/reel_player_screen.dart` |
| Discover feed + local-only engagement | `rapid_reels_app/lib/features/discover/presentation/screens/discover_feed_screen.dart` |
| Working reference implementation | `rapid_reels_app/lib/features/home/presentation/screens/home_screen.dart` (`_handleReelLike`, `_showCommentBottomSheet`, `_handleReelShare`) |
| API | `rapid_reels_app/lib/core/firebase/services/firestore_service.dart` (`toggleReelLike`, `addReelComment`, `incrementReelShares`, `incrementReelViews`, `getDiscoverReels`) |
| Model | `rapid_reels_app/lib/core/firebase/models/firebase_reel_model.dart` |
| Provider gallery (video only) | `rapid_reels_app/lib/features/provider/presentation/screens/provider_my_reels_screen.dart` |
| Schema doc | `rapid_reels_app/lib/core/firebase/DATABASE_SCHEMA_PLAN.md` |

---

## 7. Suggested order of work

1. Model + `getReel` / liked state from `likedBy`.
2. Refactor engagement into a **shared provider** using existing `FirestoreService` methods.
3. Wire **`ReelPlayerScreen`** first (most used from My Reels).
4. Unify **Discover** with the same player or shared widget.
5. Add **comment stream UI** and service method.
6. Tighten **rules/indexes** and update schema doc.
7. Optional: provider “view as audience” mode.

This sequence delivers **visible persistence** early (like/share/counts), then **full comment threads**, then **polish and parity** across entry points.
