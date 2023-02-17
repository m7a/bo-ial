#!/bin/sh -e
# IAL 1.6.0 script for Jargon File, (c) 2023 Ma_Sys.ma <info@masysma.net>

target=jargon

! [ -d "$target" ] || rm -rf "$target"
mkdir -p "$target"
[ -n "$MDVL_CI_PHOENIX_ROOT" ] || MDVL_CI_PHOENIX_ROOT="$(cd \
						"$(dirname "$0")/.." && pwd)"
"$MDVL_CI_PHOENIX_ROOT/co-maartifact/maartifact.pl" \
				extract ial_in_jargon.tar.gz "$target" \
				http://catb.org/jargon/jargon-4.4.7.tar.gz

mv "$target"/jargon-*.*.*/* "$target"
rmdir "$target"/jargon-*.*.*

printf "%s\n" "ial_add_data([" > "$target/script.js"
sed -e 's/<a href="\([^"]\+\)">\([^<]\+\)<\/a>/\nENTRY%\1%\2\n/g' -e 's/ /_/g' \
	< "$target/html/go01.html" | grep -E "^ENTRY" | \
	sed 's/^ENTRY%\([^%]\+\)%\([^%]\+\)$/	{ id: "jargon", box: "doc", title: "\2", link: "'"$target"'\/html\/\1", primary: ["\2"], secondary: [] },/g' \
	>> "$target/script.js"
printf "\t{}\n]);\n" >> "$target/script.js"
printf "\n<script type=\"text/javascript\" src=\"%s\"></script>\n" \
							"$target/script.js"
