# generate secure .env file
dart run enven

if [ "$(uname)" == "Darwin" ]; then
    echo "=== macOS ==="
    # build for macos
    flutter build macos --target=lib/main.dart --release --no-tree-shake-icons

    # build for web
    flutter build web --target=lib/main.dart --release --no-tree-shake-icons

    # deploy
    firebase deploy
else
    echo "=== windows ==="
    # build for windows
    flutter build windows --target=lib/main.dart --release --no-tree-shake-icons
fi