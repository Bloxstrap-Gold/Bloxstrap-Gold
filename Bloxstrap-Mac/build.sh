#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_BUNDLE="${SCRIPT_DIR}/BloxstrapGold.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "🔨 Building Bloxstrap Gold for macOS..."

mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

swiftc -O \
    "${SCRIPT_DIR}/Sources/AppState.swift" \
    "${SCRIPT_DIR}/Sources/FastFlagManager.swift" \
    "${SCRIPT_DIR}/Sources/MultiInstanceManager.swift" \
    "${SCRIPT_DIR}/Sources/SoundManager.swift" \
    "${SCRIPT_DIR}/Sources/RunawayButton.swift" \
    "${SCRIPT_DIR}/Sources/MainWindowController.swift" \
    "${SCRIPT_DIR}/Sources/main.swift" \
    -o "${MACOS_DIR}/BloxstrapGold"

# Install application icon and audio assets into Resources
if [ -f "${SCRIPT_DIR}/AppIcon.icns" ]; then
    cp "${SCRIPT_DIR}/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"
fi

if [ -f "${SCRIPT_DIR}/oof.wav" ]; then
    cp "${SCRIPT_DIR}/oof.wav" "${RESOURCES_DIR}/oof.wav"
fi

if [ -f "${SCRIPT_DIR}/oof.ogg" ]; then
    cp "${SCRIPT_DIR}/oof.ogg" "${RESOURCES_DIR}/oof.ogg"
fi

if [ -d "${SCRIPT_DIR}/../website" ]; then
    echo "📦 Bundling website for in-app store preview..."
    rm -rf "${RESOURCES_DIR}/website"
    cp -r "${SCRIPT_DIR}/../website" "${RESOURCES_DIR}/website"
fi

cat << 'EOF' > "${CONTENTS_DIR}/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>BloxstrapGold</string>
    <key>CFBundleIdentifier</key>
    <string>com.bloxstrapgold.macos</string>
    <key>CFBundleName</key>
    <string>Bloxstrap Gold</string>
    <key>CFBundleDisplayName</key>
    <string>Bloxstrap Gold</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>2.11.4</string>
    <key>CFBundleVersion</key>
    <string>2.11.4</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>com.bloxstrapgold.activation</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>bloxstrap-gold</string>
            </array>
        </dict>
    </array>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Touch app bundle so macOS registers icon and metadata
touch "${APP_BUNDLE}"

# Create convenient symlink in user home directory (~/Bloxstrap-Mac) so 'open Bloxstrap-Mac/BloxstrapGold.app' works anywhere
mkdir -p "${HOME}/Bloxstrap-Mac"
ln -sfn "${APP_BUNDLE}" "${HOME}/Bloxstrap-Mac/BloxstrapGold.app"

echo "✨ Successfully compiled BloxstrapGold.app at: ${APP_BUNDLE}"
echo "✨ Symlinked to: ${HOME}/Bloxstrap-Mac/BloxstrapGold.app"
