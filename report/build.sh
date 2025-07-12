#!/bin/bash
# The slow build with nice colors in code snippets made by the Syntastica plugin

DEST=rapport-final-tb-plx.pdf

# Define this flag so Syntastica plugin is enabled, see style.typ
echo -n full >build.mode.txt

echo Starting full build to generate $DEST
echo Note: this can be slow and take a few minutes at maximum
typst compile main.typ "$DEST"
xdg-open "$DEST"
