-- Answers Q1 for Customer data
-- Find weekly active customers:

-- Simple approach
WITH SIMPLE_CUSTOMERS AS (
    SELECT
        DATE_TRUNC('WEEK', purchase_timestamp) as week,
        customer_id
    FROM
        FCT_CUSTOMER_PURCHASES
    GROUP BY WEEK, customer_id
),
WEEK_START AS (
    SELECT
        DATE_TRUNC('WEEK', s1::DATE) as week_start
    FROM
        GENERATE_SERIES(
            '2025-01-01'::TIMESTAMP,
            '2026-01-01'::TIMESTAMP,
            INTERVAL '1 week'
        ) AS s1
)
SELECT
    WEEK_START.WEEK_START,
    COUNT(DISTINCT customer_id)
FROM
    SIMPLE_CUSTOMERS
RIGHT JOIN WEEK_START ON WEEK_START.WEEK_START = SIMPLE_CUSTOMERS.week
GROUP BY WEEK_START.WEEK_START
;


-- Let's do the same thing, just for month
WITH SIMPLE_CUSTOMERS AS (
    SELECT
        -- Truncate to the beginning of the month
        DATE_TRUNC('MONTH', purchase_timestamp) as month,
        customer_id
    FROM
        FCT_CUSTOMER_PURCHASES
    GROUP BY
        month, customer_id
),
     MONTH_START AS (
         SELECT
             -- Generate a series for the first day of each month
             DATE_TRUNC('MONTH', m1::DATE) as month_start
         FROM
             GENERATE_SERIES(
                     '2025-01-01'::TIMESTAMP,
                     '2026-01-01'::TIMESTAMP,
                 -- Step by 1 month instead of 1 week
                     INTERVAL '1 month'
             ) AS m1
     )
SELECT
    MONTH_START.month_start,
    COUNT(DISTINCT customer_id) AS distinct_customers
FROM
    SIMPLE_CUSTOMERS
        -- Join the calendar table on the right to ensure all months appear
        RIGHT JOIN
    MONTH_START ON MONTH_START.month_start = SIMPLE_CUSTOMERS.month
GROUP BY
    MONTH_START.month_start
ORDER BY
    MONTH_START.month_start
;