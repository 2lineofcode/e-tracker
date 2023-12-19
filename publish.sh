#!/bin/bash

# generate secure .env file
dart run enven

# update version by year month + git revision
current_version=$(grep 'version:' pubspec.yaml | awk '{print $2}')
yM=$(date '+%Y%m')
git_rev=$(git rev-list --all|wc -l|xargs)
version_without_date=$(echo $current_version | sed 's/+\([0-9]\{8\}\)//')
new_version="$version_without_date+$yM$git_rev"
echo "Updating version to: $new_version"
sed -i '' "s/version: $current_version/version: $new_version/" pubspec.yaml

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