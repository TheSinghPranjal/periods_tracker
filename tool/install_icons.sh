#!/bin/bash
# Installs the app icon from tool/icon/ into the Android and iOS asset folders,
# and the launch image rendered by tool/render_app_icon.dart.
# macOS only, because it uses sips.
#   app_icon_full.png     opaque and edge to edge, because iOS rounds it itself
#   app_icon_rounded.png  transparent corners, for Android's square launcher slot
set -euo pipefail
cd "$(dirname "$0")/.."

resize() { sips -s format png -z "$2" "$2" "$1" --out "$3" >/dev/null; }

full=tool/icon/app_icon_full.png
rounded=tool/icon/app_icon_rounded.png

android=android/app/src/main/res
for pair in mdpi:48:120:108 hdpi:72:180:162 xhdpi:96:240:216 xxhdpi:144:360:324 xxxhdpi:192:480:432; do
  IFS=: read -r density icon launch adaptive <<<"$pair"
  resize "$rounded" "$icon" "$android/mipmap-$density/ic_launcher.png"
  resize tool/icon/app_icon_foreground.png "$adaptive" "$android/mipmap-$density/ic_launcher_foreground.png"
  resize build/icons/launch.png "$launch" "$android/mipmap-$density/launch_image.png"
done

ios=ios/Runner/Assets.xcassets
for spec in 20x20@1x:20 20x20@2x:40 20x20@3x:60 29x29@1x:29 29x29@2x:58 29x29@3x:87 \
  40x40@1x:40 40x40@2x:80 40x40@3x:120 60x60@2x:120 60x60@3x:180 76x76@1x:76 \
  76x76@2x:152 83.5x83.5@2x:167 1024x1024@1x:1024; do
  IFS=: read -r name px <<<"$spec"
  resize "$full" "$px" "$ios/AppIcon.appiconset/Icon-App-$name.png"
done

resize build/icons/launch.png 160 "$ios/LaunchImage.imageset/LaunchImage.png"
resize build/icons/launch.png 320 "$ios/LaunchImage.imageset/LaunchImage@2x.png"
resize build/icons/launch.png 480 "$ios/LaunchImage.imageset/LaunchImage@3x.png"
echo "Icons installed."
