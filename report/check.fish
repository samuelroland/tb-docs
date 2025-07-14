#!/bin/fish
# Little script to check if all keys in the bibliography have been referenced in the Typst report
set BIBKEYSFILE (mktemp)
set TYPKEYSFILE (mktemp)
set TYPIDSFILE (mktemp)
set BIB_FILE bibliography.yml

echo -n Checking keys inside $BIB_FILE
cat $BIB_FILE | grep -P "^[^\s].*:" | grep -v "#" | cut -d ":" -f1 | sort -u >$BIBKEYSFILE
echo " - found" (cat $BIBKEYSFILE | wc -l ) keys
echo -n Searching for reference in Typst content
cat **.typ | grep -Po "@[A-Za-z0-9]+" | grep -oP "[^@]*" | sort -u >$TYPKEYSFILE
echo " - found" (cat $TYPKEYSFILE | wc -l ) references
echo Searching for id definitions to ignore in Typst content
cat **.typ | grep -Po "<[A-Za-z-0-9]+>" | grep -oP "[^<>]*" | sort -u >$TYPIDSFILE

echo \nHere are all the keys in $BIB_FILE that are never referenced in your Typst content\n

# Remove the lines from typst references of the list of keys from the bibliography file
# With `comm` this means we calculate the lines unique to file 1 by removing the 2 other columns
# see `man comm` for details
comm $BIBKEYSFILE $TYPKEYSFILE -2 -3
