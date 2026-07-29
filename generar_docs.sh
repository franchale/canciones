#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_PDF="$SCRIPT_DIR/output/pdf"
OUTPUT_ODT="$SCRIPT_DIR/output/odt"
OUTPUT_HTML="$SCRIPT_DIR/output/html"

if ! command -v pandoc &>/dev/null; then
  echo "Error: pandoc no está instalado." >&2
  exit 1
fi

echo "Generando documentos desde Markdown..."
echo ""

count=0
for md in "$SCRIPT_DIR"/*.md; do
  [ -f "$md" ] || continue
  nombre="$(basename "$md" .md)"

  # Saltar README
  [ "$nombre" = "README" ] && continue

  echo "  $nombre"

  pandoc "$md" \
    --from gfm \
    --to pdf \
    --pdf-engine=xelatex \
    -V geometry:margin=2.5cm \
    -V fontsize=12pt \
    -V mainfont="DejaVu Sans" \
    -V monofont="DejaVu Sans Mono" \
    --listings \
    -o "$OUTPUT_PDF/$nombre.pdf"

  pandoc "$md" \
    --from gfm \
    --metadata lang=es-MX \
    -o "$OUTPUT_ODT/$nombre.odt"

  pandoc "$md" \
    --from gfm \
    --to html5 \
    --standalone \
    --self-contained \
    --metadata lang=es-MX \
    -H <(printf '%s' '<style>body{font-family:"DejaVu Sans","Segoe UI",Arial,sans-serif;max-width:800px;margin:0 auto;padding:2em 1.5em;line-height:1.7;color:#24292f}h1{border-bottom:2px solid #e1e4e8;padding-bottom:.3em}h2{color:#1a5a96;border-bottom:1px solid #e1e4e8;padding-bottom:.2em}pre{background:#f6f8fa;border:1px solid #e1e4e8;border-radius:6px;padding:1em;overflow-x:auto;font-size:.95em}code{font-family:"DejaVu Sans Mono","SF Mono","Cascadia Code",monospace;background:#f6f8fa;padding:.15em .3em;border-radius:3px;font-size:.9em}pre code{background:0 0;padding:0}hr{border:none;border-top:1px solid #e1e4e8;margin:1.5em 0}blockquote{border-left:4px solid #d0d7de;padding:0 1em;color:#57606a}</style>') \
    -o "$OUTPUT_HTML/$nombre.html"

  count=$((count + 1))
done

echo ""
echo "Listo: $count canciones exportadas."
echo "  PDF  → $OUTPUT_PDF/"
echo "  ODT  → $OUTPUT_ODT/"
echo "  HTML → $OUTPUT_HTML/"
