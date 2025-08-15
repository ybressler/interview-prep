-- Answers Q1 for Customer data
-- Find weekly active customers:

-- Simple approach
SELECT
    DATE_TRUNC('WEEK', purchase_timestamp) as week,
    customer_id
FROM
    FCT_CUSTOMER_PURCHASES
GROUP BY WEEK, customer_id
ORDER BY 1,2
;

-- Now, count per week
SELECT
    DATE_TRUNC('WEEK', purchase_timestamp) as week,
    COUNT(DISTINCT customer_id) as n_customers
FROM
    FCT_CUSTOMER_PURCHASES
GROUP BY WEEK
ORDER BY 1
;

-- We want weeks without customers too
-- Option 1: Simple
WITH DATE_RANGE AS (
    SELECT
       UNNEST(GENERATE_SERIES(
            DATE_TRUNC('WEEK', MIN(purchase_timestamp)),
            DATE_TRUNC('WEEK', MAX(purchase_timestamp)),
        INTERVAL 1 WEEK
        ))::DATE AS DT_RANGE
    FROM
        FCT_CUSTOMER_PURCHASES
)
SELECT
    DT_RANGE AS WEEK,
    COUNT(DISTINCT B.customer_id) AS N_CUSTOMERS
FROM DATE_RANGE AS A
LEFT JOIN FCT_CUSTOMER_PURCHASES AS B
    ON DATE_TRUNC('WEEK', B.purchase_timestamp) = A.DT_RANGE
GROUP BY WEEK
ORDER BY 1
;

-- Option 2: Use without groupby
WITH CALENDAR_WEEKS AS (
    SELECT
       UNNEST(GENERATE_SERIES(
            DATE_TRUNC('WEEK', MIN(purchase_timestamp)),
            DATE_TRUNC('WEEK', MAX(purchase_timestamp)),
        INTERVAL 1 WEEK
        ))::DATE AS DT_RANGE
    FROM
        FCT_CUSTOMER_PURCHASES
)
SELECT
    DISTINCT DT_RANGE AS WEEK,
    COUNT(DISTINCT B.customer_id) OVER( PARTITION BY DT_RANGE) AS N_CUSTOMERS
FROM CALENDAR_WEEKS AS A
LEFT JOIN FCT_CUSTOMER_PURCHASES AS B
    ON DATE_TRUNC('WEEK', B.purchase_timestamp) = A.DT_RANGE
ORDER BY 1
;

-- Option 3: Stepwise aggregation
WITH CALENDAR_WEEKS AS (
    SELECT
       UNNEST(GENERATE_SERIES(
            DATE_TRUNC('WEEK', MIN(purchase_timestamp)),
            DATE_TRUNC('WEEK', MAX(purchase_timestamp)),
        INTERVAL 1 WEEK
        ))::DATE AS DT_RANGE
    FROM
        FCT_CUSTOMER_PURCHASES
),
CUSTOMER_COUNTS AS (
    SELECT
        DATE_TRUNC('WEEK', purchase_timestamp) as PURCHASE_WEEK,
        COUNT(DISTINCT customer_id) AS N_CUSTOMERS
    FROM
        FCT_CUSTOMER_PURCHASES
    GROUP BY
        PURCHASE_WEEK
)
SELECT
    DT_RANGE AS WEEK,
    COALESCE(N_CUSTOMERS, 0) AS N_CUSTOMERS
FROM CALENDAR_WEEKS AS A
LEFT JOIN CUSTOMER_COUNTS AS B
    ON A.DT_RANGE = B.PURCHASE_WEEK
ORDER BY 1
;
