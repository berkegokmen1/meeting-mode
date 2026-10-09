#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
APP="$PWD/build/release/Meeting Mode.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$PWD/build/AppIcon.iconset"
xcrun swift -module-cache-path "$PWD/build/ModuleCache" scripts/icon.swift "$PWD/build/AppIcon.iconset"
python3 - "$PWD/build/AppIcon.iconset" "$APP/Contents/Resources/AppIcon.icns" <<'PYICON'
import pathlib, struct, sys
root=pathlib.Path(sys.argv[1])
chunks=[]
for tag,name in [('icp4','icon_16x16'),('icp5','icon_32x32'),('icp6','icon_32x32@2x'),('ic07','icon_128x128'),('ic08','icon_256x256'),('ic09','icon_512x512'),('ic10','icon_512x512@2x')]:
    data=(root/(name+'.png')).read_bytes()
    chunks.append(tag.encode()+struct.pack('>I',len(data)+8)+data)
body=b''.join(chunks)
pathlib.Path(sys.argv[2]).write_bytes(b'icns'+struct.pack('>I',len(body)+8)+body)
PYICON
xcrun swiftc -module-cache-path "$PWD/build/ModuleCache" Sources/Journal.swift Sources/main.swift -o "$PWD/build/MeetingMode-new" -framework AppKit -framework ServiceManagement -target arm64-apple-macos13.0
mv -f "$PWD/build/MeetingMode-new" "$APP/Contents/MacOS/MeetingMode"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.berkegokmen.meetingmode</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundleName</key><string>Meeting Mode</string>
<key>CFBundleExecutable</key><string>MeetingMode</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.3</string>
<key>CFBundleVersion</key><string>4</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP"
pkgbuild --component "$APP" --install-location /Applications --identifier com.berkegokmen.meetingmode --version 0.1.3 "$PWD/build/MeetingMode-0.1.3.pkg"
