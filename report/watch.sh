#!/bin/bash
# The fast build in watch mode without the nice colors in code snippets

DEST=rapport-final-tb-plx.pdf

# Define this flag so Syntastica plugin is disabled, see style.typ
echo -n fast >build.mode.txt

echo Starting watch build and opening $DEST
xdg-open "$DEST"
typst watch main.typ "$DEST"
