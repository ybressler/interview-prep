-- This is my long winded answer
WITH ORDERED_EVENTS AS (
    SELECT
        event_id,
        event_timestamp,
        customer_id,
        LAG(event_timestamp) OVER (PARTITION BY customer_id ORDER BY event_timestamp ASC) AS PREV_TS
    FROM
        FCT_CUSTOMER_CLICKSTREAM
),
ORDERED_EVENTS_SESSION_STUFF AS (
    SELECT
        event_timestamp,
        customer_id,
        CASE
            WHEN PREV_TS IS NULL THEN 0
            WHEN event_timestamp - PREV_TS <= INTERVAL '30 MINUTES' THEN 0
            ELSE 1
        END AS NEW_SESSION
    FROM
        ORDERED_EVENTS
),
EVENTS_AS_SESSIONS AS (
    SELECT
        customer_id,
        event_timestamp,
        1+ SUM(NEW_SESSION) OVER(PARTITION BY CUSTOMER_ID ORDER BY event_timestamp) AS session_id
    FROM
        ORDERED_EVENTS_SESSION_STUFF
),
SESSION_DURATIONS AS (
    SELECT DISTINCT
        customer_id,
        SESSION_ID,
        MIN(event_timestamp) OVER (W1) AS event_start,
        MAX(event_timestamp) OVER (W1) AS event_end
    FROM
        EVENTS_AS_SESSIONS
        WINDOW W1 AS (
            PARTITION BY customer_id, session_id
        )
)
-- use the following as a sanity check, if you want
-- SELECT *, event_end - event_start as duration FROM SESSION_DURATIONS
SELECT
    AVG(event_end-event_start) AS AVG_SESSION_DURATION
from
    SESSION_DURATIONS
;

-- You can combine the first 2 CTE's to form a single thingy
WITH ORDERED_EVENTS_SESSION_STUFF AS (
    SELECT
        event_timestamp,
        customer_id,
        CASE
            WHEN event_timestamp - LAG(event_timestamp) OVER (PARTITION BY customer_id ORDER BY event_timestamp ASC) >
            INTERVAL '30 MINUTES' THEN 1
            ELSE 0
        END
        AS NEW_SESSION
    FROM
        FCT_CUSTOMER_CLICKSTREAM
),
EVENTS_AS_SESSIONS AS (
    SELECT
        customer_id,
        event_timestamp,
        1+ SUM(NEW_SESSION) OVER(PARTITION BY CUSTOMER_ID ORDER BY event_timestamp) AS session_id
    FROM
        ORDERED_EVENTS_SESSION_STUFF
),
SESSION_DURATIONS AS (
    SELECT DISTINCT
        customer_id,
        SESSION_ID,
        MIN(event_timestamp) OVER (W1) AS event_start,
        MAX(event_timestamp) OVER (W1) AS event_end
    FROM
        EVENTS_AS_SESSIONS
        WINDOW W1 AS (
            PARTITION BY customer_id, session_id
        )
)
-- use the following as a sanity check, if you want
-- SELECT *, event_end - event_start as duration FROM SESSION_DURATIONS
SELECT
    AVG(event_end-event_start) AS AVG_SESSION_DURATION
from
    SESSION_DURATIONS
;