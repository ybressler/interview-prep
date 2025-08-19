/*
    Answers Q4 for Customer data

    Rolling Average
    Show which weeks have an average > 3 week rolling average.

*/

WITH PRE AS (
    SELECT
        DISTINCT
        DATE_TRUNC('week', purchase_timestamp) AS cal_week,
        AVG(total_amount_usd) OVER (PARTITION BY DATE_TRUNC('week', purchase_timestamp)) AS avg_spend,
        AVG(total_amount_usd) OVER (
            PARTITION BY DATE_TRUNC('week', purchase_timestamp)
            ORDER BY DATE_TRUNC('week', purchase_timestamp)
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
            ) as rolling_3_week
    FROM
        FCT_CUSTOMER_PURCHASES
    ORDER BY cal_week
)
SELECT
    *
FROM
    PRE
WHERE
    avg_spend > rolling_3_week

;