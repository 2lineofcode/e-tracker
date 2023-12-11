flutter build macos --target=lib/main_prod.dart --release --no-tree-shake-icons
flutter build web --target=lib/main_prod.dart --release --no-tree-shake-icons
firebase deploy