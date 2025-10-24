#!/bin/bash

# PDF Export Script for Mermaid Markdown
# Usage: ./export-pdf.sh requirements.md

echo "🔄 Converting Markdown to HTML with Mermaid support..."

# Convert markdown to HTML with Mermaid
pandoc "$1" -o temp.html \
  --self-contained \
  --css=pdf-export.css \
  --metadata title="Anubis Requirements" \
  --from markdown+mermaid \
  --to html5

echo "📄 Converting HTML to PDF with Chrome..."

# Convert HTML to PDF with Chrome
/usr/bin/chromium-browser \
  --headless \
  --disable-gpu \
  --no-sandbox \
  --print-to-pdf="$(basename "$1" .md).pdf" \
  --print-to-pdf-no-header \
  --virtual-time-budget=30000 \
  "temp.html"

# Cleanup
rm temp.html

echo "✅ PDF generated: $(basename "$1" .md).pdf"