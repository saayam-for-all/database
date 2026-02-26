--TEST CASE 1
-- attempt to insert duplicate meetings
INSERT INTO meetings (meeting_id, meeting_date, start_time, end_time, cohost_id) VALUES
('MIT-00-000-000-0011', '2026-02-09', '2026-02-09 09:00:00', '2026-02-09 10:00:00', 'SID-00-000-000-001'),
('MIT-00-000-000-0011', '2026-02-07', '2026-02-07 09:00:00', '2026-02-07 10:00:00', 'SID-00-000-000-001');

/*ERROR: duplicate key value violates unique constraint "meetings_pk"
Key (meeting_id)=(MIT-00-000-000-0011) already exists.

SQL state: 23505
Detail: Key (meeting_id)=(MIT-00-000-000-0011) already exists.*/

-- TEST CASE 2
-- attempt to insert cohost id that does not exist
INSERT INTO meetings (meeting_id, meeting_date, start_time, end_time, cohost_id) VALUES
('MIT-00-000-000-0013', '2026-02-09', '2026-02-09 09:00:00', '2026-02-09 10:00:00', 'SID-00-000-000-019');

/* OUTPUT : ERROR: insert or update on table "meetings" violates foreign key constraint "meetings_fk"
Key (cohost_id)=(SID-00-000-000-019) is not present in table "users".

SQL state: 23503
Detail: Key (cohost_id)=(SID-00-000-000-019) is not present in table "users". */

--TEST CASE 3
-- attempt to insert a participant that does not exist in users table
INSERT INTO meeting_participants(meeting_id, participant_id)
VALUES
('MIT-00-000-000-001', 'SID-00-000-000-019');

/* OUTPUT :ERROR: insert or update on table "meeting_participants" violates foreign key constraint "meeting_participants_fk_two"
Key (participant_id)=(SID-00-000-000-019) is not present in table "users".

SQL state: 23503
Detail: Key (participant_id)=(SID-00-000-000-019) is not present in table "users". */

--TEST CASE 4
-- Fetch all participants for a specific meeting_id using a JOIN.

--BEFORE INDEX
explain analyze
SELECT mp.participant_id
FROM meeting_participants mp
JOIN meetings m
ON mp.meeting_id = m.meeting_id
WHERE mp.meeting_id = 'MIT-00-000-000-009';
SET enable_seqscan = on;

/*"Nested Loop (cost=0.29..16.34 rows=1 width=19) (actual time=0.057..0.059 rows=1.00 loops=1)"
" Buffers: shared hit=4"
" -> Index Scan using meeting_id_idx on meeting_participants mp (cost=0.15..8.17 rows=1 width=38) (actual time=0.044..0.044 rows=1.00 loops=1)"
" Index Cond: ((meeting_id)::text = 'MIT-00-000-000-009'::text)"
" Index Searches: 1"
" Buffers: shared hit=2"
" -> Index Only Scan using meetings_pk on meetings m (cost=0.14..8.16 rows=1 width=516) (actual time=0.011..0.012 rows=1.00 loops=1)"
" Index Cond: (meeting_id = 'MIT-00-000-000-009'::text)"
" Heap Fetches: 1"
" Index Searches: 1"
" Buffers: shared hit=2"
"Planning Time: 0.294 ms"
"Execution Time: 0.092 ms" */

--AFTER INDEX
explain analyze
SELECT mp.participant_id
FROM meeting_participants mp
JOIN meetings m
ON mp.meeting_id = m.meeting_id
WHERE mp.meeting_id = 'MIT-00-000-000-009';
SET enable_seqscan = off;

/* "Nested Loop (cost=0.29..16.34 rows=1 width=19) (actual time=0.030..0.032 rows=1.00 loops=1)"
" Buffers: shared hit=4"
" -> Index Scan using meeting_id_idx on meeting_participants mp (cost=0.15..8.17 rows=1 width=38) (actual time=0.018..0.019 rows=1.00 loops=1)"
" Index Cond: ((meeting_id)::text = 'MIT-00-000-000-009'::text)"
" Index Searches: 1"
" Buffers: shared hit=2"
" -> Index Only Scan using meetings_pk on meetings m (cost=0.14..8.16 rows=1 width=516) (actual time=0.009..0.009 rows=1.00 loops=1)"
" Index Cond: (meeting_id = 'MIT-00-000-000-009'::text)"
" Heap Fetches: 1"
" Index Searches: 1"
" Buffers: shared hit=2"
"Planning:"
" Buffers: shared hit=28"
"Planning Time: 0.668 ms"
"Execution Time: 0.055 ms"*/

-- TEST CASE 5
-- Check rejection when end time is less than start time.
INSERT INTO meetings (meeting_id, meeting_date, start_time, end_time, cohost_id) VALUES
('MIT-00-000-000-0014', '2026-02-09', '2026-02-09 11:00:00', '2026-02-09 10:00:00', 'SID-00-000-000-019');

/* ERROR: new row for relation "meetings" violates check constraint "chk_meeting_duration"
Failing row contains (MIT-00-000-000-0014, 2026-02-09, 2026-02-09 11:00:00, 2026-02-09 10:00:00, SID-00-000-000-019).

SQL state: 23514
Detail: Failing row contains (MIT-00-000-000-0014, 2026-02-09, 2026-02-09 11:00:00, 2026-02-09 10:00:00, SID-00-000-000-019).*/

-- TEST CASE 6
-- attempt to insert meeting_id in meeting_participants when it doesn't exist in meetings
INSERT INTO meeting_participants(meeting_id,participant_id)
VALUES('MIT-00-000-000-014', 'SID-00-000-000-520');

/* OUTPUT : Result: ERROR: insert or update on table "meeting_participants" violates foreign key constraint "meeting_participants_fk_one"
Key (meeting_id)=(MIT-00-000-000-014) is not present in table "meetings".
SQL state: 23503
Detail: Key (meeting_id)=(MIT-00-000-000-014) is not present in table "meetings".*/ ALTER