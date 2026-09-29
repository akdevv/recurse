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
  <key>LSMinimumSystemVersion</key><string>26.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP" >/dev/null 2>&1
echo "built $APP"
[ "$1" = "--open" ] && open "$APP"
exit 0
