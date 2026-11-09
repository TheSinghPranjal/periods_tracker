#!/bin/bash
# Resizes build/icons/*.png (from tool/render_app_icon.dart) into the Android
# and iOS asset folders. macOS only, because it uses sips.
set -euo pipefail
cd "$(dirname "$0")/.."

resize() { sips -s format png -z "$2" "$2" "$1" --out "$3" >/dev/null; }

android=android/app/src/main/res
for pair in mdpi:48:120 hdpi:72:180 xhdpi:96:240 xxhdpi:144:360 xxxhdpi:192:480; do
  IFS=: read -r density icon launch <<<"$pair"
  resize build/icons/icon.png "$icon" "$android/mipmap-$density/ic_launcher.png"
  resize build/icons/launch.png "$launch" "$android/mipmap-$density/launch_image.png"
done

ios=ios/Runner/Assets.xcassets
for spec in 20x20@1x:20 20x20@2x:40 20x20@3x:60 29x29@1x:29 29x29@2x:58 29x29@3x:87 \
  40x40@1x:40 40x40@2x:80 40x40@3x:120 60x60@2x:120 60x60@3x:180 76x76@1x:76 \
  76x76@2x:152 83.5x83.5@2x:167 1024x1024@1x:1024; do
  IFS=: read -r name px <<<"$spec"
  resize build/icons/icon.png "$px" "$ios/AppIcon.appiconset/Icon-App-$name.png"
done
# App Store icons may not contain an alpha channel.
sips -s format jpeg build/icons/icon.png --out build/icons/flat.jpg >/dev/null
sips -s format png build/icons/flat.jpg --out "$ios/AppIcon.appiconset/Icon-App-1024x1024@1x.png" >/dev/null

resize build/icons/launch.png 160 "$ios/LaunchImage.imageset/LaunchImage.png"
resize build/icons/launch.png 320 "$ios/LaunchImage.imageset/LaunchImage@2x.png"
resize build/icons/launch.png 480 "$ios/LaunchImage.imageset/LaunchImage@3x.png"
echo "Icons installed."
