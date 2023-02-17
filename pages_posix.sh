#!/bin/sh -e
# IAL 1.6.0 script to download POSIX, (c) 2023 Ma_Sys.ma <info@masysma.net>

target=posix
archive=susv4-2018

! [ -d "$target" ] || rm -r "$target"
mkdir -p "$target"
[ -n "$MDVL_CI_PHOENIX_ROOT" ] || MDVL_CI_PHOENIX_ROOT="$(cd \
						"$(dirname "$0")/.." && pwd)"
"$MDVL_CI_PHOENIX_ROOT/co-maartifact/maartifact.pl" \
	extract ial_in_posix.zip "$target" \
	"https://pubs.opengroup.org/onlinepubs/9699919799/download/$archive.zip"

printf "%s\n" "ial_add_data([" > "$target/script.js"
cat "$target/$archive"/idx/i?.html | grep -F disc | \
	sed 's/<li type=disc><a href="\.\.\/\([^"]\+\)">\([^<]\+\)<\/a>.*$/	{ id: "posix", box: "doc", title: "\2", link: "'"$target"'\/'"$archive"'\/\1", primary: ["\2"], secondary: [] },/g' \
	>> "$target/script.js"
printf "\t{}\n]);\n" >> "$target/script.js"
printf "\n<script type=\"text/javascript\" src=\"%s\"></script>\n" \
							"$target/script.js"
