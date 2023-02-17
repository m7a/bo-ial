#!/bin/sh -e
# IAL 1.6.0 script for Java API Doc, (c) 2023 Ma_Sys.ma <info@masysma.net>

target=java
version=11

! [ -d "$target" ] || rm -r "$target"
mkdir -p "$target"
[ -n "$MDVL_CI_PHOENIX_ROOT" ] || MDVL_CI_PHOENIX_ROOT="$(cd \
						"$(dirname "$0")/.." && pwd)"
"$MDVL_CI_PHOENIX_ROOT/co-maartifact/maartifact.pl" extract \
		"ial_in_java_$version.deb" "$target" "openjdk-$version-doc"
mv "$target/usr/share/doc/openjdk-$version-jre-headless"/* "$target"
rm -r "$target/usr"

printf "%s\n" "ial_add_data([" > "$target/script.js"
grep -E '^<li>.*title=".*$' < "$target/api/allclasses.html" | sed \
	-e 's/<span class="[^"]\+">\([^<]\+\)<\/span>/\1/g' \
	-e 's/<li><a href="\([^"]\+\)" title="[a-z0-9]\+ in \([^"]\+\)"[^>]*>\(<i>\)\?\([^<]\+\)\(<\/i>\)\?<\/a><\/li>$/	{ id: "java'"$version"'", box: "doc", title: "\2.\4", link: "'"$target"'\/api\/\1", primary: ["\2.\4", "\4"], secondary: [] },/g' \
	>> "$target/script.js"
printf "\t{}\n]);\n" >> "$target/script.js"
printf "\n<script type=\"text/javascript\" src=\"%s\"></script>\n" \
							"$target/script.js"
