# GetStorage web compatibility patch

Source: `get_storage` 2.1.1 from https://pub.dev/packages/get_storage/versions/2.1.1.
The upstream MIT license is retained in LICENSE.

Only `lib/src/storage/html.dart` is changed: browser storage uses `package:web`
instead of `dart:html`. Container names, JSON format, public APIs, and the native
storage driver remain unchanged, so existing preferences need no migration.

shortcut: keep this local patch until upstream GetStorage supports Wasm, then
restore the hosted dependency and remove this directory.
