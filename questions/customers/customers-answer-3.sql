/*
    Answers Q3 for Customer data

    RFM Customer Segmentation.

    Tasks:
    - Need to get purchase gaps using a CTE
    - aggregate

    Plan:
    - Solution 1: Use window functions
    - Alternative: Use group by

*/

WITH PURCHASE_GAPS AS (
    SELECT
        customer_id,
        purchase_timestamp,
        total_amount_usd,
        LAG(purchase_timestamp, 1) OVER( PARTITION BY customer_id ORDER BY purchase_timestamp) as prev_order,
        DATE_DIFF('day', prev_order, purchase_timestamp) AS days_between_purchases
    FROM
        FCT_CUSTOMER_PURCHASES
)

SELECT
    DISTINCT customer_id,
    MAX(purchase_timestamp) OVER(CUSTOMER) AS most_recent_order,
    COUNT(*) OVER(CUSTOMER) AS N_ORDERS,
    SUM(total_amount_usd) OVER(CUSTOMER) AS total_money,
    AVG(days_between_purchases) OVER(CUSTOMER)  AS 'frequency(days)'
FROM PURCHASE_GAPS
    WINDOW CUSTOMER AS (PARTITION BY customer_id)
ORDER BY customer_id
;
