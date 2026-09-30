#!/bin/sh
# Builds build/Recurse.app (release). Usage: ./build-app.sh [--open]
set -e
cd "$(dirname "$0")"
swift build -c release
APP=build/Recurse.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$(swift build -c release --show-bin-path)/Recurse" "$APP/Contents/MacOS/"

# icon: the Liquid Glass render of the Recurse icon
ICON=build/AppIcon.iconset
mkdir -p "$ICON"
for s in 16 32 128 256 512; do
  sips -z $s $s AppIcon.png --out "$ICON/icon_${s}x${s}.png" >/dev/null
  sips -z $((s * 2)) $((s * 2)) AppIcon.png --out "$ICON/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICON" -o "$APP/Contents/Resources/AppIcon.icns"

# accent colour (teal) for system controls
xcrun actool Assets.xcassets --compile "$APP/Contents/Resources" --platform macosx --minimum-deployment-target 26.0 \
  --output-partial-info-plist build/assets-info.plist >/dev/null

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Recurse</string>
  <key>CFBundleIdentifier</key><string>dev.akdevv.recurse</string>
  <key>CFBundleExecutable</key><string>Recurse</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>26.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSAccentColorName</key><string>AccentColor</string>
</dict></plist>
PLIST
# widget: a WidgetKit extension that reads today's numbers from the App Group the app writes to (WidgetSnapshot).
# The team-prefixed group needs a real signing identity; without one the app is ad-hoc signed and has no widget.
IDENTITY=$(security find-identity -v -p codesigning | grep -m1 -o '"Apple Development[^"]*"' | tr -d '"')
if [ -n "$IDENTITY" ]; then
  WX="$APP/Contents/PlugIns/RecurseWidget.appex"
  mkdir -p "$WX/Contents/MacOS"
  xcrun swiftc -O -parse-as-library -application-extension -target arm64-apple-macos26.0 \
    Widget/RecurseWidget.swift Sources/Recurse/Core/WidgetSnapshot.swift Sources/Recurse/App/Theme.swift \
    -o "$WX/Contents/MacOS/RecurseWidget"
  cat > "$WX/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Recurse</string>
  <key>CFBundleDisplayName</key><string>Recurse</string>
  <key>CFBundleIdentifier</key><string>dev.akdevv.recurse.widget</string>
  <key>CFBundleExecutable</key><string>RecurseWidget</string>
  <key>CFBundlePackageType</key><string>XPC!</string>
  <key>CFBundleShortVersionString</key><string>0.1</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>26.0</string>
  <key>NSExtension</key><dict><key>NSExtensionPointIdentifier</key><string>com.apple.widgetkit-extension</string></dict>
</dict></plist>
PLIST
  GROUP="<key>com.apple.security.application-groups</key><array><string>L63A6B5UJ9.dev.akdevv.recurse</string></array>"
  HEAD='<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict>'
  echo "$HEAD<key>com.apple.security.app-sandbox</key><true/>$GROUP</dict></plist>" > build/widget.entitlements
  echo "$HEAD$GROUP</dict></plist>" > build/app.entitlements
  codesign --force --sign "$IDENTITY" --entitlements build/widget.entitlements "$WX" >/dev/null 2>&1
  codesign --force --sign "$IDENTITY" --entitlements build/app.entitlements "$APP" >/dev/null 2>&1
else
  echo "no Apple Development identity: building without the widget"
  codesign --force --sign - "$APP" >/dev/null 2>&1
fi
echo "built $APP"
[ "$1" = "--open" ] && open "$APP"
exit 0
