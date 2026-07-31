#!/bin/bash

set -e

# update version by year month + git revision
current_version=$(grep 'version:' pubspec.yaml | awk '{print $2}')
echo "current version: $current_version"

git_rev=$(git rev-list --all|wc -l|xargs)

base_version=$(echo "$current_version" | cut -d'+' -f1)
new_version="${base_version}+${git_rev}"
echo "new_version: $new_version"

echo "Updating version to: $new_version"
sed -i '' "s/version: $current_version/version: $new_version/" pubspec.yaml

# make sure pubspec is up to date
flutter pub get

# generate env
echo "🔐 Generating env file..."
dart run enven

# build app
if [ "$(uname)" == "Darwin" ]; then
    echo "=== macOS ==="
    # build for macos
    flutter build macos --release --no-tree-shake-icons

    # build web (optimized for Safari/iOS)
    echo "🌐 Building Flutter Web (CanvasKit renderer)..."
    FLUTTER_WEB_RENDERER=canvaskit flutter build web --release --no-tree-shake-icons --base-href "/"

    echo "🚀 Deploying to Firebase..."
    firebase deploy --only hosting --project e-tr4ck3r
else
    echo "publish.sh only supports web and macOS" >&2
    exit 1
fi
