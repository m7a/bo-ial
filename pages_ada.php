#!/usr/bin/php -f
<?php
function exception_error_handler($severity, $message, $file, $line) {
	throw new ErrorException($message, 0, $severity, $file, $line);
}
function rmrf($dir) {
	// PHP does not easily do this?
	// https://stackoverflow.com/questions/3338123
	system("rm -r ".escapeshellcmd($dir));
}
function remove_spaces($arg) {
	// normalize spaces to one space and remove parentheses
	return preg_replace("/[()]/", "",
				preg_replace('/(\s|\xc2\xa0)+/', " ", $arg));
}
error_reporting(E_ALL | E_NOTICE);
set_error_handler("exception_error_handler");
if (is_dir("ada"))
	rmrf("ada");
mkdir("ada");

$phoenix_root = array_key_exists("MDVL_CI_PHOENIX_ROOT", $_ENV) ?
	$_ENV["MDVL_CI_PHOENIX_ROOT"] : realpath(dirname(__FILE__)."/..");
system(escapeshellcmd($phoenix_root."/co-maartifact/maartifact.pl extract ".
			"ial_in_ada.deb ada ada-reference-manual-2012"));
rename("ada/usr/share/doc/ada-reference-manual-2012/arm2012.html", "ada/cnt");
rmrf("ada/usr");

$ramdb = [];
$doc   = new DOMDocument();
$doc->loadHTML(file_get_contents("ada/cnt/rm-0-5.html"));
$divs  = $doc->getElementsByTagName("div");
foreach($divs as $div) {
	if($div->getAttribute("class") !== "Index")
		continue;
	$title = NULL;
	$buf   = "";
	foreach($div->childNodes as $child) {
		if($title == NULL) {
			$title = str_replace(" ", "_", trim(str_replace(", ",
				"_", remove_spaces($child->nodeValue))));
		} elseif($child->nodeType === XML_ELEMENT_NODE &&
						$child->tagName === "a") {
			// link
			$buf = str_replace(" ", "_", trim(preg_replace(
					"/( in | child of |subtype of )/", "",
					remove_spaces($buf))));
			// TODO z for now skip these strange entries with ,
			if($buf !== ",") {
				$names = [];
				$tspl  = explode(".", $title);
				if(!empty($tspl) && $tspl[0] != $title)
					$names = array_merge($names, $tspl);
				if(!empty($buf))
					array_push($names, $buf);
				$ttl = $title.($buf === ""? "": "/$buf");
				array_push($ramdb, [
					"id"        => "ada",
					"box"       => "doc",
					"title"     => $ttl,
					"link"      => "ada/cnt/".$child->
							getAttribute("href"),
					"primary"   => [$ttl],
					"secondary" => $names,
				]);
			}
			$buf = "";
		} else {
			$buf .= $child->nodeValue; // not a link -> assume text
		}
	}
}
file_put_contents("ada/script.js", "ial_add_data(".json_encode($ramdb,
						JSON_PRETTY_PRINT).");");
?>

<script type="text/javascript" href="ada/script.js">
