# LunaCycle — Period & Cycle Tracker

A private, offline-first period tracker for Android and iOS, drawn in a soft
cherry-blossom sketch style. No account, no server, no ad or analytics SDKs.

## Setup

Requires Flutter 3.41+ (Dart 3.11). The first build downloads the encrypted
SQLite binaries, so it needs internet access.

```bash
flutter pub get
dart run build_runner build      # regenerates lib/core/database/app_database.g.dart
flutter run
```

## Build

```bash
flutter build apk --debug                 # Android, debug
flutter build appbundle --release         # Android, Play Store (set up signing first)
flutter build ios --release               # iOS (needs Apple signing in Xcode)
```

Optional build-time values:

| Define | Purpose |
| --- | --- |
| `LUNA_SUPPORT_EMAIL` | Address shown under Profile > Contact support |
| `LUNA_PLUS_PRODUCT_IDS` | Comma-separated store product ids. Without it, purchases stay switched off |

Example: `flutter build appbundle --dart-define=LUNA_SUPPORT_EMAIL=help@example.com`

## Tests

```bash
flutter analyze
flutter test test                                   # unit and widget tests
flutter test integration_test -d DEVICE_ID          # on a simulator or phone
flutter test tool/render_screens.dart               # writes build/screens/*.png for visual review
```

## Architecture

Feature-first, with `data`, `domain` and `presentation` folders per feature.

```
lib/
  app/            startup, providers, router, theme tokens
  core/           database, encryption, security, notifications, sketch widgets
  features/
    onboarding, home, calendar, period_logging, symptoms, prediction,
    insights, reminders, settings, privacy, premium, wellness
```

Key rules the code relies on:

- **Dates** are `CalendarDate` values stored as `YYYY-MM-DD` text, so a logged day
  never moves when the timezone changes.
- **Observations and estimates are separate.** The prediction engine
  (`features/prediction/domain/cycle_prediction_engine.dart`) is pure Dart and
  reads records but never writes them. Calculation metadata goes in its own table.
- **Prediction method:** median of up to six recent valid cycles. Gaps under 15
  or over 90 days are flagged and ignored, not deleted. Confidence comes from the
  spread of cycle lengths, capped by the regularity the person chose. This is a
  product heuristic and not a clinically validated model.
- **Conflicts are never resolved silently.** `period_rules.dart` reports what is
  wrong and the UI asks the person what to do.

### Design system

`core/widgets/sketch/` draws everything from seeded randomness, so the
hand-drawn wobble stays still between frames. `SakuraBackdrop` is the ink tree
behind each page, and `SketchCard` is the double pencil outline. Colours are
semantic roles in `app/theme/luna_tokens.dart`. Calendar states differ by shape
as well as colour: solid disc, dashed ring, hatched tile, flower, dot.

### Privacy model

| Area | Implementation |
| --- | --- |
| Database | SQLite3MultipleCiphers (ChaCha20-Poly1305) with a random 256-bit key in Keychain / Android Keystore |
| Device backups | Disabled on Android; database excluded from iCloud on iOS |
| App lock | PBKDF2-hashed PIN with escalating lockout, optional biometrics. It gates the interface; the database key is separate |
| App switcher | `FLAG_SECURE` on Android; native cover view on iOS |
| Encrypted backup | Argon2id and AES-256-GCM with an authenticated header |
| Notifications | Discreet text by default; never carries health data unless the person opts in |

**Deletion policy.** "Delete all data" erases every table with `secure_delete`
on, vacuums the file, cancels notifications and removes the PIN. Files the person
exported are outside the app and must be deleted by them. There is no cloud copy.

### Adding cloud backup later

`DataTransferService.exportJson` and `BackupCipher.encrypt` already produce an
encrypted blob on the device, so an uploader would only store those bytes. It must
be opt-in, never send the password or key, include account and cloud-data deletion,
and document that a lost password cannot be recovered. Don't describe it as
end-to-end encrypted until that has been implemented and tested.

## App icon and splash

The icon masters are in `tool/icon/`: `app_icon_full.png` is opaque and edge to edge for
iOS, which rounds it itself, and `app_icon_rounded.png` has transparent corners for Android.
`tool/render_app_icon.dart` draws the launch image; `tool/install_icons.sh` installs
both on each platform (macOS only).

- Icon masters: 1024x1024 PNG. The iOS master has no alpha channel.
- Android launcher: 48, 72, 96, 144, 192 px. Launch image: 120 to 480 px.
- iOS launch image: 160, 320, 480 px on `#FFF8F9`.

## Release checklist

Must be done before publishing:

- [ ] A qualified clinician reviews `wellness/domain/content_library.dart`, then update `kContentReviewStatus`.
- [ ] A lawyer reviews the privacy policy and terms in `support_screens.dart`.
- [ ] Android release signing in `android/app/build.gradle.kts` (currently the debug key).
- [ ] Set `LUNA_SUPPORT_EMAIL`.
- [ ] Update `kAppVersion` to match `pubspec.yaml`.
- [ ] Complete the Play Data Safety form and the App Store privacy labels (health data).
- [ ] Test on real Android and iOS phones: notifications firing, biometrics, file export and import, reboot behaviour.
- [ ] Measure scrolling and startup on a low-end Android phone.

Only if selling LunaCycle Plus:

- [ ] Create the store products and set `LUNA_PLUS_PRODUCT_IDS`.
- [ ] Add server-side receipt validation. The app currently trusts the store's purchase callback on the device.

## Implemented versus future work

**Implemented:** onboarding, home, calendar with year view, period logging and
correction, flow, pain, symptoms, moods, notes, optional modules (temperature,
mucus, weight, sleep, ovulation tests, private log), prediction, insights and
charts, history, local notifications, medication schedules, app lock, encrypted
database, JSON and CSV export, encrypted backup and restore, data deletion, five
colour themes, dark mode, in-app instructions, offline health articles.

**Not implemented yet:**

- Translations. Interface text is written in English directly in the widgets.
- Cloud backup or multi-device sync (see above).
- Importing CSV files. CSV is export-only; JSON and encrypted backups can be imported.
- A sleep chart. Sleep values are saved and exported but not charted.
- Premium reports and extended analysis. Plus currently unlocks two colour themes only.
