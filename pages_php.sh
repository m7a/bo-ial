#!/bin/sh -e
# IAL 1.6.0 script to download PHP Docs, (c) 2023 Ma_Sys.ma <info@masysma.net>

target=php

! [ -d "$target" ] || rm -r "$target"
mkdir -p "$target"
[ -n "$MDVL_CI_PHOENIX_ROOT" ] || MDVL_CI_PHOENIX_ROOT="$(cd \
						"$(dirname "$0")/.." && pwd)"
"$MDVL_CI_PHOENIX_ROOT/co-maartifact/maartifact.pl" \
		extract ial_in_php.tar.gz php \
		https://www.php.net/distributions/manual/php_manual_en.tar.gz

printf "%s\n" "ial_add_data([" > "$target/script.js"
grep -E '^<li><a href.*class="index".*$' "$target/php-chunked-xhtml/indexes.functions.html" | sed 's/<li><a href="\([^"]\+\)" class="index">\([^<]\+\)<\/a>[^<]\+\(<\/li>\)\?$/	{ id: "php", box: "doc",\n		title: "\2", link: "'"$target"'\/php-chunked-xhtml\/\1",\n		primary: ["\2"], secondary: [] },/g' | awk '/^\t\t(title|primary):/ { gsub(/\\/, "\\\\") } { print }' >> "$target/script.js"
printf "\t{}\n]);\n" >> "$target/script.js"
printf "\n<script type=\"text/javascript\" src=\"%s\"></script>\n" \
							"$target/script.js"
