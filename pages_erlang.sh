#!/bin/sh -e
# IAL 1.6.0 script to process Erlang Docs, (c) 2023 Ma_Sys.ma <info@masysma.net>

target=erlang
! [ -d "$target" ] || rm -r "$target"
mkdir -p "$target"
[ -n "$MDVL_CI_PHOENIX_ROOT" ] || MDVL_CI_PHOENIX_ROOT="$(cd \
						"$(dirname "$0")/.." && pwd)"
"$MDVL_CI_PHOENIX_ROOT/co-maartifact/maartifact.pl" \
				extract ial_in_erlang.deb "$target" erlang-doc

mv "$target/usr/share/doc/erlang-doc"/* "$target"
rm -r "$target/usr"

printf "%s\n" "ial_add_data([" > "$target/script.js"

# A bit of an inefficient implementation (quadratic), but fast enough for now.
# a)    <td><a href="../lib/sasl-3.3/doc/html/alarm_handler.html">alarm_handler</a></td>
# b)    <li title="which_applications-1"><a href="application.html#which_applications-1">which_applications/1</a></li>
abscut=$(($(cd "$target"; pwd | wc -c) + 1))
knowroot=
grep -E '^    <td><a href' < "$target/doc/man_index.html" | \
							while read -r line; do
	file="$target/doc/$(printf "%s\n" "$line" | cut -d"\"" -f 2)"
	relroot="$(cd "$(dirname "$file")"; pwd | cut -c "${abscut}-" | \
							sed 's/\//\\\//g')"
	if printf "%s" "$knowroot" | grep -qF "$relroot"; then
		continue
	else
		knowroot="$knowroot
$relroot"
	fi
	grep -E '^    <li title="[^"]+"><a href="[^"]+">[^<]+</a></li>$' < "$file" | sed 's/^    <li title="[^"]\+"><a href="\([^#]\+\)\.html#\([^#]\+\)">\([^<]\+\)<\/a><\/li>$/	{ id: "erlang", box: "doc", title: "\1:\3", link: "'"$target\/$relroot"'\/\1.html#\2", primary: [ "\1:\3" ], secondary: [ "\1", "\3" ] },/g'
done >> "$target/script.js"
printf "\t{}\n]);\n" >> "$target/script.js"
printf "\n<script type=\"text/javascript\" src=\"%s\"></script>\n" \
							"$target/script.js"
