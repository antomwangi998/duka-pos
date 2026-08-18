# Duka POS — Deni (Credit) Tracking, App Icon & Scan Sounds

This zip contains your existing `duka-pos` project with three additions on top:

## 1. Customers & Deni (credit) tracking
New `lib/features/customer/` module (same clean-architecture pattern as the
rest of the app: entities → repository → use cases → bloc → pages).

- **Customers list** (`/customers`) — search, total outstanding deni banner.
- **Add customer** (`/customers/add`) — name, phone, notes.
- **Customer detail** (`/customers/:id`) — balance card, "Record Payment"
  sheet, full transaction ledger, tap-to-call.
- **Checkout page** — choosing "Credit" now opens a customer picker (search
  existing or quick-add new) before the sale can complete. The sale is saved
  with a link to the customer, and a debt transaction is recorded
  automatically, updating their running balance.
- Access points added: Settings → Management → "Customers & Deni", and a
  people icon on the home scanner overlay.

## 2. Scan sounds
Two short WAV tones were synthesized (no external audio assets needed):
`assets/sounds/scan_success.wav` (double-beep) and `scan_error.wav` (low
buzz). Wired via `lib/core/utils/scan_feedback_helper.dart` using
`audioplayers`, played alongside the existing vibration on every scan, and
on a failed product lookup.

## 3. New app icon
`assets/icon/app_icon.png` (master) and `app_icon_foreground.png` (Android
adaptive icon layer) — a warm amber background with a white/purple awning
motif over a basket + checkmark. Configured in `pubspec.yaml` under
`flutter_launcher_icons`.

## Setup — run these after pulling this zip in

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run flutter_launcher_icons
```

- `build_runner` generates the new Hive adapters
  (`customer_model.g.dart`, `debt_transaction_model.g.dart`) — these are
  gitignored/not included in the zip, same as all other `.g.dart` files in
  this repo.
- `flutter_launcher_icons` applies the new icon to Android + iOS.

## Notes / things worth reviewing
- `SaleRecordModel` gained two new optional Hive fields (`customerId`,
  `customerName`, indices 8 & 9) — additive, so existing sale records will
  just have them as `null`.
- Credit sales require selecting a customer; the "Complete Sale" button is
  disabled and relabeled "Select a Customer" until one is picked.
- The icon design is a first pass — happy to iterate on colors/motif if you
  want a different direction once you see it rendered on-device.
