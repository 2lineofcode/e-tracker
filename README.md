# e-Tracker

Personal expense tracker built with Flutter and Supabase.

Requires Flutter 3.47.7 or later with Dart 3.13.5 or later.
Configure `.env` using `.env.example`, then run `flutter pub get` and `dart run enven`.

## Publishing

On macOS, `./publish.sh` builds the native macOS app and the web release, then
deploys `build/web` to Firebase Hosting project `e-tr4ck3r`.
The script stamps the loading screen with the Git revision and execution date.

The web release uses `--wasm` with automatic JavaScript/CanvasKit fallback.
Flutter currently defaults Safari/WebKit to the fallback renderer. The bootstrap
uses local renderer assets and keeps the loading screen until the first frame.
Firebase Hosting sends COOP/COEP headers for multithreaded Wasm rendering and
requires cache revalidation to avoid mixing files from different releases.

For a local web build without deploying:

```sh
flutter build web --release --wasm --base-href /
```

`packages/get_storage` preserves GetStorage 2.1.1's storage format and native
driver while replacing its web driver with `package:web`. The `isolate_manager`
override keeps SQL editor highlighting compatible with Wasm. Remove
these workarounds when the upstream dependencies support this configuration.
