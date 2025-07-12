#!/bin/bash
# The fast build for redaction. It uses the basic syntax highlighting of Typst.
# The first build takes a few seconds, then less than a second.

DEST=rapport-final-tb-plx.pdf

# Define this flag so Syntastica plugin is disabled, see style.typ
echo -n fast >build.mode.txt

echo Starting watch build and opening $DEST
xdg-open "$DEST"
typst watch main.typ "$DEST"
