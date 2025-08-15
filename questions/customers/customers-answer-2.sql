-- Answers Q2 for Customer data
-- New vs. Retained Customer Analysis

-- Simple approach
WITH CUSTOMER_BY_WEEK AS (
    SELECT
        customer_id,
        DATE_TRUNC('WEEK', purchase_timestamp) as DT_WEEK
    FROM FCT_CUSTOMER_PURCHASES
    GROUP BY customer_id, DT_WEEK
),
CUSTOMER_JOIN_WEEK AS (
    SELECT
        customer_id,
        DT_WEEK,
        MIN(DT_WEEK) OVER(PARTITION BY customer_id) AS first_week
    FROM CUSTOMER_BY_WEEK
),
CALENDAR_WEEKS AS (
    SELECT
       UNNEST(GENERATE_SERIES(
            DATE_TRUNC('WEEK', MIN(purchase_timestamp)),
            DATE_TRUNC('WEEK', MAX(purchase_timestamp)),
        INTERVAL 1 WEEK
        ))::DATE AS DT_WEEK
    FROM
        FCT_CUSTOMER_PURCHASES
)
SELECT
    A.DT_WEEK,
    SUM(
        CASE
            WHEN A.DT_WEEK = B.first_week THEN 1
            ELSE 0
        END
    ) AS N_NEW_CUSTOMERS,
    SUM(
        CASE
           WHEN A.DT_WEEK > B.first_week THEN 1
            ELSE 0
        END
    )AS N_RETAINED_CUSTOMERS
FROM
    CALENDAR_WEEKS AS A
LEFT JOIN CUSTOMER_JOIN_WEEK AS B
    ON A.DT_WEEK = B.DT_WEEK
GROUP BY A.DT_WEEK
ORDER BY A.DT_WEEK
;

-- More advanced: Use a window fuction
WITH CALENDAR_WEEKS AS (
    SELECT
       UNNEST(GENERATE_SERIES(
            DATE_TRUNC('WEEK', MIN(purchase_timestamp)),
            DATE_TRUNC('WEEK', MAX(purchase_timestamp)),
        INTERVAL 1 WEEK
        ))::DATE AS DT_WEEK
    FROM
        FCT_CUSTOMER_PURCHASES
),
CUSTOMER_BY_WEEK AS (
    SELECT
        DISTINCT customer_id,
        DATE_TRUNC('WEEK', purchase_timestamp) as DT_WEEK,
        CASE
            WHEN  DATE_TRUNC('WEEK', purchase_timestamp) =
                 MIN(DATE_TRUNC('WEEK', purchase_timestamp)) OVER(PARTITION BY customer_id) THEN true
            ELSE false
        END AS IS_NEW
    FROM FCT_CUSTOMER_PURCHASES
)

SELECT
    A.DT_WEEK,
    COUNT(*) FILTER(WHERE IS_NEW) AS N_NEW,
    COUNT(*) FILTER(WHERE NOT IS_NEW) AS N_RETAINED
FROM CALENDAR_WEEKS AS A
    LEFT JOIN CUSTOMER_BY_WEEK AS B ON A.DT_WEEK = B.DT_WEEK
GROUP BY A.DT_WEEK
ORDER BY 1
;

-- Final improvement: Decrease size of join - preaggregate
WITH CALENDAR_WEEKS AS (
    SELECT
       UNNEST(GENERATE_SERIES(
            DATE_TRUNC('WEEK', MIN(purchase_timestamp)),
            DATE_TRUNC('WEEK', MAX(purchase_timestamp)),
        INTERVAL 1 WEEK
        ))::DATE AS DT_WEEK
    FROM
        FCT_CUSTOMER_PURCHASES
),
CUSTOMER_BY_WEEK AS (
    SELECT
        DISTINCT customer_id,
        DATE_TRUNC('WEEK', purchase_timestamp) as DT_WEEK,
        CASE
            WHEN  DATE_TRUNC('WEEK', purchase_timestamp) =
                 MIN(DATE_TRUNC('WEEK', purchase_timestamp)) OVER(PARTITION BY customer_id) THEN true
            ELSE false
        END AS IS_NEW
    FROM FCT_CUSTOMER_PURCHASES
),
CUSTOMERS_AGG AS (
    SELECT
        DT_WEEK,
        COUNT(*) FILTER(WHERE IS_NEW) AS N_NEW,
        COUNT(*) FILTER(WHERE NOT IS_NEW) AS N_RETAINED
    FROM
        CUSTOMER_BY_WEEK
    GROUP BY 1
)

SELECT
    A.DT_WEEK,
    COALESCE(B.N_NEW, 0) AS N_NEW,
    COALESCE(B.N_RETAINED, 0) AS N_RETAINED
FROM CALENDAR_WEEKS AS A
    LEFT JOIN CUSTOMERS_AGG AS B ON A.DT_WEEK = B.DT_WEEK
ORDER BY 1
;