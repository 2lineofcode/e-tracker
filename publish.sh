#!/bin/bash

set -e

# set build version from git revision
current_version=$(grep 'version:' pubspec.yaml | awk '{print $2}')
echo "current version: $current_version"

git_rev=$(git rev-list --all|wc -l|xargs)

base_version=$(echo "$current_version" | cut -d'+' -f1)
new_version="${base_version}+${git_rev}"
echo "new_version: $new_version"

month_names=(Jan Feb Mar Apr Mei Jun Jul Agus Sep Okt Nov Des)
read -r publish_day publish_month publish_year <<< "$(date '+%d %m %Y')"
publish_date="$publish_day ${month_names[$((10#$publish_month - 1))]} $publish_year"

sed -i '' -E "s|<div class=\"loading-text\">e-Tracker \([^<]*</div>|<div class=\"loading-text\">e-Tracker (${new_version}) ${publish_date}</div>|" web/index.html

# make sure pubspec is up to date
flutter pub get

# generate env
echo "🔐 Generating env file..."
dart run enven

# build app
if [ "$(uname)" == "Darwin" ]; then
    echo "=== macOS ==="
    # build for macos
    flutter build macos --release --no-tree-shake-icons --build-name="$base_version" --build-number="$git_rev" --dart-define="BUILD_DATE=$publish_date"

    # Build Wasm with a JavaScript fallback for unsupported browsers.
    echo "🌐 Building Flutter Web (Wasm + JavaScript fallback)..."
    flutter build web --release --wasm --no-pub --base-href "/" --build-name="$base_version" --build-number="$git_rev" --dart-define="BUILD_DATE=$publish_date"

    echo "🚀 Deploying to Firebase..."
    firebase deploy --only hosting --project e-tr4ck3r
else
    echo "publish.sh only supports web and macOS" >&2
    exit 1
fi
