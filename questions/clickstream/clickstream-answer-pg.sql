-- First solution
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
EVENTS_WITH_SESSION_ID AS (
    SELECT
        event_timestamp,
        customer_id,
        SUM(NEW_SESSION) OVER (PARTITION BY customer_id ORDER BY event_timestamp) AS SESSION_ID
    FROM ORDERED_EVENTS_SESSION_STUFF
),
SESSION_DURATION AS (
    SELECT
        customer_id,
        SESSION_ID,
        max(event_timestamp) - min(event_timestamp) AS session_duration
    from EVENTS_WITH_SESSION_ID
    GROUP BY customer_id, SESSION_ID
)
SELECT
    AVG(session_duration) AS AVG_SESSION,
        EXTRACT(EPOCH FROm AVG(session_duration)) AS AVG_SESSION_TOTAL_SECONDS
FROM SESSION_DURATION
;

-- Let's do it in a more sophisticated way
-- First solution
WITH ORDERED_EVENTS_SESSION_STUFF AS (
    SELECT
        event_timestamp,
        customer_id,
        event_timestamp - LAG(event_timestamp) OVER W1 > INTERVAL '30 MINUTES' AS NEW_SESSION
    FROM
        FCT_CUSTOMER_CLICKSTREAM
    WINDOW W1 AS (PARTITION BY customer_id ORDER BY event_timestamp ASC)
),
EVENTS_WITH_SESSION_ID AS (
    SELECT
        event_timestamp,
        customer_id,
        SUM(COALESCE(NEW_SESSION::INT, 0)) OVER(W1) AS SESSION_ID
    FROM
        ORDERED_EVENTS_SESSION_STUFF
        WINDOW W1 AS (PARTITION BY customer_id ORDER BY event_timestamp ASC)
)
SELECT
    AVG(SESSION_DUR)
FROM (
    SELECT MAX(event_timestamp) - MIN(event_timestamp) AS SESSION_DUR
    FROM EVENTS_WITH_SESSION_ID
      GROUP BY customer_id, SESSION_ID
      )
;

