WITH ACTIVE_CUSTOMERS AS (
    SELECT
        user_id
    FROM orders
    WHERE order_date >= CURRENT_TIMESTAMP - INTERVAL '90 DAYS'
    GROUP BY user_id
    HAVING COUNT(*) FILTER (WHERE status = 'completed') >= 3
),
ALMOST_THERE AS (
    SELECT DISTINCT
        A.user_id,
        COUNT( O.order_id) OVER W1 AS TOTAL_ORDERS,
        SUM(O.total_amount) OVER W1 AS TOTAL_AMOUNT,
        AVG(O.total_amount) OVER W1 AS AVG_AMOUNT,
        OI.product_id,
        SUM(OI.quantity) OVER (PARTITION BY A.user_id, OI.product_id) AS total_purchased
    from
        ACTIVE_CUSTOMERS AS A
    LEFT JOIN orders as O ON A.user_id = O.user_id
    LEFT JOIN ORDER_ITEMS AS OI ON O.order_id = OI.order_id
    WHERE status='completed' AND O.order_date >= CURRENT_TIMESTAMP - INTERVAL '90 DAYS'
    WINDOW W1 AS (PARTITION BY A.user_id)
),
LAST_ONE AS (
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY total_purchased DESC) AS POS
FROM
    ALMOST_THERE
)
SELECT user_id,TOTAL_ORDERS, TOTAL_AMOUNT, AVG_AMOUNT, product_id AS fav_item FROM LAST_ONE WHERE POS=1
;


-- This got messy, let's clean up
WITH ORDER_STATS AS (
    SELECT
        user_id,
        COUNT(*) AS TOTAL_ORDERS,
        SUM(total_amount) AS TOTAL_AMOUNT,
        AVG(total_amount) AS AVG_ORDER_VALUE
    FROM
        ORDERS
    WHERE order_date >= CURRENT_DATE - INTERVAL '90 DAYS' AND status = 'completed'
    GROUP BY user_id
    HAVING COUNT(*) >=3
),
TOP_PRODUCTS AS (
    SELECT
        O.user_id,
        OI.product_id,
        ROW_NUMBER() OVER (PARTITION BY O.user_id ORDER BY SUM(OI.quantity) DESC) AS POS
    from
        order_items AS OI
    LEFT JOIN ORDERS AS O
    ON O.ORDER_ID=OI.order_id
    WHERE O.order_date >= CURRENT_DATE - INTERVAL '90 DAYS' AND O.status = 'completed'
    GROUP BY O.user_id, OI.product_id
)
SELECT
    OS.*,
    TP.product_id AS FAV_PRODUCT
FROM ORDER_STATS AS OS
INNER JOIN TOP_PRODUCTS AS TP ON OS.user_id = TP.user_id
WHERE TP.POS = 1
order by TOTAL_AMOUNT DESC

;


-- Possible improvements?
-- Let's only filter once! (use base for CTE)
WITH BASE_ORDERS AS (
    SELECT *
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '90 DAYS'
      AND status = 'completed'
),
     ORDER_STATS AS (
         SELECT
             user_id,
             COUNT(*) AS total_orders,
             SUM(total_amount) AS total_amount,
             AVG(total_amount) AS avg_order_value
         FROM BASE_ORDERS
         GROUP BY user_id
         HAVING COUNT(*) >= 3
     ),
 TOP_PRODUCTS AS (
     SELECT
         O.user_id,
         OI.product_id,
         ROW_NUMBER() OVER (PARTITION BY O.user_id ORDER BY SUM(OI.quantity) DESC) AS POS
     from
         order_items AS OI
             LEFT JOIN BASE_ORDERS AS O
                       ON O.ORDER_ID=OI.order_id
     WHERE O.order_date >= CURRENT_DATE - INTERVAL '90 DAYS' AND O.status = 'completed'
     GROUP BY O.user_id, OI.product_id
     )
SELECT
    OS.*,
    TP.product_id AS FAV_PRODUCT
FROM ORDER_STATS AS OS
         INNER JOIN TOP_PRODUCTS AS TP ON OS.user_id = TP.user_id
WHERE TP.POS = 1
order by TOTAL_AMOUNT DESC
;