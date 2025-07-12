#!/bin/bash
# The slow build for release export. It includes the nice colors in code snippets, made by the Syntastica plugin
# It can take a few minutes if there are a lot of code snippets

DEST=rapport-final-tb-plx.pdf

# Define this flag so Syntastica plugin is enabled, see style.typ
echo -n full >build.mode.txt

echo Starting full build to generate $DEST
echo Note: this can be slow and take a few minutes at maximum
echo Running: typst compile main.typ "$DEST"
time typst compile main.typ "$DEST"
echo Done !
echo Opening $DEST
xdg-open "$DEST"
