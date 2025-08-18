/*
    Answers Q4 for Customer data

    Incremental Pipeline Design at Scale:
    Top 100 highest-spending customers for each calendar month.

    Tasks:
    - Write non-optimized query
    - Split into incremental parts
*/

CREATE OR REPLACE TABLE MONTHLY_TOTAL_PURCHASES AS (
    SELECT
        DATE_TRUNC('month', purchase_timestamp) AS cal_month,
        customer_id,
        SUM(total_amount_usd) AS TOTAL_SPEND
    FROM
        FCT_CUSTOMER_PURCHASES
    WHERE
       cal_month <= DATE('2025-09-01')
    GROUP BY 1, 2
    ORDER BY cal_month, total_spend
);

-- Just insert new rows
WITH NEW_PURCHASES AS (
    SELECT
        DATE_TRUNC('month', purchase_timestamp) AS cal_month,
        customer_id,
        SUM(total_amount_usd) AS TOTAL_SPEND
    FROM FCT_CUSTOMER_PURCHASES
    WHERE
        DATE_TRUNC('month', purchase_timestamp)  > (SELECT MAX(cal_month) FROM MONTHLY_TOTAL_PURCHASES)
    GROUP BY 1, 2
)

INSERT INTO MONTHLY_TOTAL_PURCHASES  (cal_month, customer_id, TOTAL_SPEND)
    SELECT
        cal_month,
        customer_id,
        TOTAL_SPEND
FROM
    NEW_PURCHASES
;

-- Now update that table (duckdb doesn't have merge)
WITH NEW_PURCHASES AS (
    SELECT
        DATE_TRUNC('month', purchase_timestamp) AS cal_month,
        customer_id,
        SUM(total_amount_usd) AS TOTAL_SPEND
    FROM FCT_CUSTOMER_PURCHASES
    WHERE DATE_TRUNC('month', purchase_timestamp)   > (SELECT MAX(cal_month) FROM MONTHLY_TOTAL_PURCHASES)
    GROUP BY 1, 2
)
MERGE INTO MONTHLY_TOTAL_PURCHASES AS target USING NEW_PURCHASES AS source
    ON target.cal_month = source.cal_month AND target.customer_id = source.customer_id
WHEN MATCHED THEN
    UPDATE SET total_spend = target.total_spend + source.total_spend
WHEN NOT MATCHED THEN
    INSERT (cal_month, customer_id, TOTAL_SPEND)
    VALUES (source.cal_month, source.customer_id, source.TOTAL_SPEND)
;



-- Now do the query
SELECT
    cal_month,
    customer_id,
    TOTAL_SPEND,
    DENSE_RANK() OVER (PARTITION BY cal_month ORDER BY TOTAL_SPEND DESC) AS POS
FROM
    MONTHLY_TOTAL_PURCHASES
QUALIFY POS <= 2
;
