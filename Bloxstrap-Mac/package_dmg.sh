#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_BUNDLE="${SCRIPT_DIR}/BloxstrapGold.app"
DMG_NAME="BloxstrapGold-macOS.dmg"
DMG_PATH="${SCRIPT_DIR}/${DMG_NAME}"
TEMP_DIR="${SCRIPT_DIR}/dmg_temp"

# Ensure the app is built
"${SCRIPT_DIR}/build.sh"

echo "📦 Packaging BloxstrapGold into ${DMG_NAME}..."

rm -rf "${TEMP_DIR}" "${DMG_PATH}"
mkdir -p "${TEMP_DIR}"

cp -R "${APP_BUNDLE}" "${TEMP_DIR}/"
ln -s /Applications "${TEMP_DIR}/Applications"

hdiutil create -volname "Bloxstrap Gold" -srcfolder "${TEMP_DIR}" -ov -format UDZO "${DMG_PATH}"
rm -rf "${TEMP_DIR}"

echo "✨ Successfully generated macOS installer DMG: ${DMG_PATH}"
