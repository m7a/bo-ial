#!/bin/sh -eu
-- 2> /dev/null || true; mkdir archivebox 2> /dev/null || true
-- 2> /dev/null || true; script="archivebox/script.js"
-- 2> /dev/null || true; cp "${1:-/tmp/index.sqlite3}" "/tmp/index$$.sqlite3"
-- 2> /dev/null || true; sqlite3 "/tmp/index$$.sqlite3" < "$0" > "$script"
-- 2> /dev/null || true; rm "/tmp/index$$.sqlite3"
-- 2> /dev/null || true; printf "%s" '<script type="text/javascript" '
-- 2> /dev/null || true; printf "%s\n" 'src="archivebox/script.json"></script>'
-- 2> /dev/null || true; exit 0
--
-- Do not add any comments above the `exit 0` line!
--
-- Misc. notes:
-- cp /data/main/130_archivebox/data/index.sqlite3 /tmp
-- sqlite3 /tmp/index.sqlite3 < archivebrowser.sql
-- core_snapshot(id, timestamp, title, url)
-- core_snapshot_tags(snapshot_id, tag_id)
-- core_tag(name, slug, id)
-- https://database.guide/format-sqlite-results-as-json/
-- https://stackoverflow.com/questions/67471706/export-sqlite-table-which
--
CREATE TEMPORARY TABLE masysma_tag_priorities (
	name VARCHAR(100) NOT NULL,
	prio INTEGER      NOT NULL
);
INSERT INTO masysma_tag_priorities (name, prio) VALUES
	('alpha',       10), ('primary',     20), ('fun',         40),
	('swrec',       40), ('gam',         40), ('dcf77',       40),
	('book',        50);
WITH s1 AS (
	SELECT core_snapshot.id AS sid,
		(CASE WHEN core_snapshot.title IS NULL
			THEN "(" || core_snapshot.timestamp || ")"
			ELSE SUBSTR(core_snapshot.title, 1, 60) END) AS title,
		core_snapshot.timestamp AS dirname,
		MIN(masysma_tag_priorities.prio) AS min_prio,
		json_object('secondary',
			CASE WHEN core_tag.name IS NULL
			THEN json_array()
			ELSE json_group_array(core_tag.name) END) AS all_tags
	FROM core_snapshot
	LEFT JOIN core_snapshot_tags
		ON core_snapshot_tags.snapshot_id = core_snapshot.id
	LEFT JOIN core_tag ON core_tag.id = core_snapshot_tags.tag_id
	LEFT JOIN masysma_tag_priorities
		ON masysma_tag_priorities.name = core_tag.name
	GROUP BY core_snapshot.timestamp
),
s2 AS (
	SELECT json_patch(json_object(
			'id',        (CASE WHEN s1.min_prio IS NULL
					THEN 'misc' ELSE core_tag.name END),
			'box',       'abx',
			'title',     s1.title,
			'link',      'http://127.0.0.1:7994/archive/' ||
						s1.dirname || '/index.html',
			'primary',   json_array(s1.title)
		), s1.all_tags) AS line, 1 as const
	FROM s1
	LEFT JOIN core_snapshot_tags ON core_snapshot_tags.snapshot_id = s1.sid
	LEFT JOIN core_tag ON core_tag.id = core_snapshot_tags.tag_id
	LEFT JOIN masysma_tag_priorities
		ON masysma_tag_priorities.name = core_tag.name
	WHERE masysma_tag_priorities.prio = s1.min_prio OR s1.min_prio IS NULL
	GROUP BY s1.sid
	ORDER BY core_tag.name ASC
)
SELECT 'ial_add_data(' || json_group_array(json(s2.line)) || ');'
FROM s2
GROUP BY s2.const;
