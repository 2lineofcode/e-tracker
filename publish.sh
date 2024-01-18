#!/bin/bash

# generate secure .env file
dart run enven

# update version by year month + git revision
current_version=$(grep 'version:' pubspec.yaml | awk '{print $2}')
echo "current version: $current_version"

git_rev=$(git rev-list --all|wc -l|xargs)
yMd=$(date '+%Y%m%d')

new_version="${current_version%+*}+$git_rev.$yMd"
echo "new_version: $new_version"

echo "Updating version to: $new_version"
sed -i '' "s/version: $current_version/version: $new_version/" pubspec.yaml

# make sure pubspec is up to date
flutter pub get

# build app
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