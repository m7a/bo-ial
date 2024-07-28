#!/bin/sh -eu

target=posix

#! [ -d "$target" ] || rm -r "$target"
#mkdir -p "$target"

[ -n "${MDVL_CI_PHOENIX_ROOT:-}" ] || MDVL_CI_PHOENIX_ROOT="$(cd \
						"$(dirname "$0")/.." && pwd)"
archive="$MDVL_CI_PHOENIX_ROOT/x-artifacts/posix-2024.tar.gz"
if [ -f "$archive"  ]; then
	tar -C "$target" -xf "$archive"
else
	mkdir "$target"/2024 || true
	cd "$target"/2024
	# https://stackoverflow.com/questions/273743/
	# using-wget-to-recursively-fetch-a-directory-with-arbitrary-files-in-it
	# /65442746#65442746
	url=https://pubs.opengroup.org/onlinepubs/9799919799
	wget --recursive --no-parent --random-wait --wait 2 \
			--no-http-keep-alive --no-host-directories --level=inf \
			--accept '*' --reject="index.html?*" --cut-dirs=2 \
			--page-requisites --relative \
		"$url"/ "$url"/Figures/ "$url"/frontmatter/ "$url"/help/ \
			"$url"/images/ "$url"/jscript/ "$url"/basedefs/ \
			"$url"/functions/ "$url"/utilities/ "$url"/xrat/
	cd ..
	tar -c 2024 | gzip -9 > "$archive"
	cd ..
fi

printf "%s\n" "ial_add_data([" > "$target/script.js"
cat "$target/2024"/idx/i?.html | grep -F disc | \
	sed 's/<li type=disc><a href="\.\.\/\([^"]\+\)">\([^<]\+\)<\/a>.*$/	{ id: "posix", box: "doc", title: "\2", link: "'"$target"'\/2024\/\1", primary: ["\2"], secondary: [] },/g' \
	>> "$target/script.js"
printf "\t{}\n]);\n" >> "$target/script.js"
printf "\n<script type=\"text/javascript\" src=\"%s\"></script>\n" \
							"$target/script.js"
