#!/bin/zsh
# SVG → .icns  (QuickLook 렌더 + 둥근 사각형 알파 마스크 + iconutil)
# 사용: scripts/make-icon.sh <input.svg> <output.icns>
set -e
SVG="$1"; OUT="$2"
[[ -f "$SVG" && -n "$OUT" ]] || { echo "usage: $0 <input.svg> <output.icns>"; exit 1; }
TMP=$(mktemp -d)
qlmanage -t -s 1024 -o "$TMP" "$SVG" >/dev/null 2>&1
SRC="$TMP/$(basename "$SVG").png"
[[ -f "$SRC" ]] || { echo "QuickLook 렌더 실패: $SVG"; exit 1; }
# QuickLook 은 흰 배경을 깔기 때문에 아이콘 외곽(64..960, rx188)을 알파로 깎는다
python3 - "$SRC" "$TMP/icon.png" <<'PY'
import sys
from PIL import Image, ImageDraw
src, dst = sys.argv[1], sys.argv[2]
im = Image.open(src).convert("RGBA")
mask = Image.new("L", im.size, 0)
ImageDraw.Draw(mask).rounded_rectangle((64, 64, 960, 960), radius=188, fill=255)
im.putalpha(mask)
im.save(dst)
PY
ICONSET="$TMP/icon.iconset"; mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s "$TMP/icon.png" --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  d=$((s*2)); sips -z $d $d "$TMP/icon.png" --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$OUT"
cp "$TMP/icon.png" "${OUT%.icns}-1024.png"
rm -rf "$TMP"
echo "✓ $OUT"
