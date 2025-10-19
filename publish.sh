#!/bin/bash

set -e

# generate secure .env file
echo "🔐 Generating secure .env file..."
dart run enven


# update version by year month + git revision
current_version=$(grep 'version:' pubspec.yaml | awk '{print $2}')
echo "current version: $current_version"

git_rev=$(git rev-list --all|wc -l|xargs)
yMd=$(date '+%Y%m%d')

base_version=$(echo "$current_version" | cut -d'+' -f1)
new_version="${base_version}+${git_rev}"
echo "new_version: $new_version"

echo "Updating version to: $new_version"
sed -i '' "s/version: $current_version/version: $new_version/" pubspec.yaml

# make sure pubspec is up to date
flutter pub get

# build app
if [ "$(uname)" == "Darwin" ]; then
    echo "=== macOS ==="
    # build for macos
    flutter build macos --release --no-tree-shake-icons

    # build web (optimized for Safari/iOS)
    echo "🌐 Building Flutter Web (CanvasKit renderer)..."
    FLUTTER_WEB_RENDERER=canvaskit flutter build web --release --no-tree-shake-icons --base-href "/"

    # optional: optimize index.html for mobile PWA
    echo "⚙️ Injecting viewport meta for better mobile scaling..."
    sed -i '' '/<meta charset="UTF-8">/a\
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">' build/web/index.html

    # deploy
    echo "🚀 Deploying to Firebase..."

    # deploy
    firebase deploy
else
    echo "=== windows ==="
    # build for windows
    flutter build windows --release --no-tree-shake-icons
fi