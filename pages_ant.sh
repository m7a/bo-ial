#!/bin/sh -e
# IAL 1.6.0 script for ANT Documentation, (c) 2023 Ma_Sys.ma <info@masysma.net>

target=ant

! [ -d "$target" ] || rm -r "$target"
mkdir -p "$target"
[ -n "$MDVL_CI_PHOENIX_ROOT" ] || MDVL_CI_PHOENIX_ROOT="$(cd \
						"$(dirname "$0")/.." && pwd)"
"$MDVL_CI_PHOENIX_ROOT/co-maartifact/maartifact.pl" \
					extract ial_in_ant.deb "$target" ant-doc
mv "$target/usr/share/doc/ant/manual" "$target/cnt"
rm -r "$target/usr"

printf "%s\n" "ial_add_data([" > "$target/script.js"
grep -E '^  <li><a href="Tasks/' "$target/cnt/tasklist.html" | sed \
	-e 's/<em>\([^<]\+\)<\/em>/\1/g' \
	-e 's/^  <li><a href="\([^"]\+\)">\([^<]\+\)<\/a>.*<\/li>$/	{ id: "ant", box: "doc", title: "\2", link: "'"$target"'\/cnt\/\1", primary: ["\2"], secondary: [] },/g' \
	>> "$target/script.js"
printf "\t{}\n]);\n" >> "$target/script.js"
printf "\n<script type=\"text/javascript\" src=\"%s\"></script>\n" \
							"$target/script.js"
