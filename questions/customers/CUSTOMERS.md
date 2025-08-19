# Customer SQL Questions
The following Q's relate to the `FCT_CUSTOMER_PURCHASES` table.

| transaction_id | customer_id | product_name | quantity | total_amount_usd | purchase_timestamp |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `txn-aaa-001` | `cust-101` | Everything Bagel | 1 | 3.50 | `2025-07-01 08:02:00` |
| `txn-aaa-002` | `cust-101` | Everything Bagel | 1 | 3.50 | `2025-07-02 08:05:00` |
| `txn-aaa-003` | `cust-101` | Everything Bagel | 1 | 3.50 | `2025-07-03 07:58:00` |
| `txn-aaa-004` | `cust-101` | Everything Bagel | 1 | 3.50 | `2025-07-04 08:10:00` |
| `txn-aaa-005` | `cust-101` | Everything Bagel | 1 | 3.50 | `2025-07-05 08:01:00` |
| `txn-aaa-006` | `cust-101` | Everything Bagel | 1 | 3.50 | `2025-07-06 08:03:00` |
| `txn-aaa-007` | `cust-101` | Everything Bagel | 1 | 3.50 | `2025-07-07 08:04:00` |
| `txn-bbb-008` | `cust-102` | Cinnamon Raisin Bagel | 2 | 7.00 | `2025-07-01 10:15:00` |
| `txn-bbb-009` | `cust-102` | Cinnamon Raisin Bagel | 2 | 7.00 | `2025-07-04 10:21:00` |
| `txn-bbb-010` | `cust-102` | Cinnamon Raisin Bagel | 2 | 7.00 | `2025-07-08 10:11:00` |
| `txn-bbb-011` | `cust-102` | Cinnamon Raisin Bagel | 2 | 7.00 | `2025-07-11 10:18:00` |
| `txn-bbb-012` | `cust-102` | Cinnamon Raisin Bagel | 2 | 7.00 | `2025-07-15 10:14:00` |
| `txn-bbb-013` | `cust-102` | Cinnamon Raisin Bagel | 2 | 7.00 | `2025-07-18 10:25:00` |
| `txn-ccc-014` | `cust-103` | Dozen Assorted Bagels | 1 | 24.00 | `2025-07-15 16:30:00` |


## Q1: Find weekly active customers:

**Part 1:** Customers who've made a purchase within 7 days.
* current week
* previous week

**Part 2:** Count the weekly active customers. (Count zero if none)

> [!TIP]
> Use `GENERATE_SERIES('2025-01-06'::TIMESTAMP, '2025-03-31'::TIMESTAMP)` to create the interval
<details>

  <summary>More details code</summary>

```sql
SELECT
    -- Generate the series and cast the output to a DATE
    CAST(week_start AS DATE) AS week_start_date
FROM
    GENERATE_SERIES(
        '2025-01-06'::TIMESTAMP, -- Start date (the first Monday of 2025)
        '2025-03-31'::TIMESTAMP, -- End date
        INTERVAL '7' DAY         -- The weekly step
    ) AS s(week_start);
```
This can work too:
```sql
WITH RECURSIVE weekly_series(week_date) AS (
    -- 1. Anchor Member: The starting date
    SELECT '2025-01-06'::DATE
    
    UNION ALL
    
    -- 2. Recursive Member: Add 7 days to the previous date
    SELECT week_date + INTERVAL '7' DAY
    FROM weekly_series
    
    -- 3. Termination Condition: Stop when the date exceeds the end date
    WHERE week_date + INTERVAL '7' DAY <= '2025-03-31'::DATE
)
SELECT week_date FROM weekly_series;
```
</details>

## Question 2: New vs. Retained Customer Analysis
For each week, show the count of new customers (those making their first-ever purchase that week) versus
retained customers (those who have purchased in a prior week).

Challenge: This requires identifying each customer's first purchase event and then classifying all their
subsequent transactions across time-bucketed weeks.

<details>
<summary>Answer</summary>
1. `customer_first_purchase` CTE: The MIN(...) OVER (PARTITION BY customer_id) window function is the key. It efficiently finds the earliest purchase_timestamp for each customer and attaches it to every one of that customer's records.
2. `classified_purchases` CTE: This step buckets all events into weeks using DATE_TRUNC('week', ...). It then compares the transaction's week with the customer's first-ever purchase week to label the customer's status for that specific transaction.
3. Final Aggregation: The final SELECT statement pivots the data. It groups all records by the purchase_week. The COUNT(DISTINCT ...) is crucial because a customer might make multiple purchases in a week but should only be counted once. The FILTER (WHERE ...) clause is a clean way to perform conditional aggregation, counting only the customers that match the 'New' or 'Retained' criteria for that week.

```sql
WITH 
-- Step 1: For each purchase, find the customer's first-ever purchase timestamp.
customer_first_purchase AS (
    SELECT
        customer_id,
        purchase_timestamp,
        MIN(purchase_timestamp) OVER (PARTITION BY customer_id) AS first_purchase_timestamp
    FROM FCT_CUSTOMER_PURCHASES
),

-- Step 2: Classify each purchase as 'New' or 'Retained' based on the week.
-- A customer is 'New' only during the week of their first-ever purchase.
classified_purchases AS (
    SELECT
        customer_id,
        -- Standardize all timestamps to the beginning of their respective week (Monday).
        DATE_TRUNC('week', purchase_timestamp)::DATE AS purchase_week,
        CASE
            WHEN DATE_TRUNC('week', purchase_timestamp) = DATE_TRUNC('week', first_purchase_timestamp)
            THEN 'New'
            ELSE 'Retained'
        END AS customer_type
    FROM customer_first_purchase
)

-- Step 3: Group by week and count the distinct new and retained customers.
SELECT
    purchase_week,
    COUNT(DISTINCT customer_id) FILTER (WHERE customer_type = 'New') AS new_customers,
    COUNT(DISTINCT customer_id) FILTER (WHERE customer_type = 'Retained') AS retained_customers
FROM classified_purchases
GROUP BY purchase_week
ORDER BY purchase_week;
```

</details>

## Question 3: RFM Customer Segmentation
For each customer, provide:
* most recent purchase
* frequency of their purchases
* monetory: how much they spent in total


## Question 4: Incremental Pipeline Design at Scale
Imagine the `FCT_CUSTOMER_PURCHASES` table contains billions of rows.
You need to maintain a summary table of the top 100 highest-spending customers for each calendar month.
A full table scan and recalculation each day is too slow and costly.

How would you design an efficient, incremental data pipeline that updates this monthly summary table as new
daily data arrives, without reprocessing the entire history? Describe the logic and the key SQL command
(e.g., MERGE) you would use.

<details>
<summary>Answer</summary>

1. Keep an intermediate table with a summary of every customer's total monthly spend
    i. Columns: `purchase_month`, `customer_id`, `total`

The daily pipeline executes the following logic:
1. Isolate & Aggregate Daily Data: First, create a temporary table containing only the new purchases for the processing day. Aggregate this data to get the total amount spent per customer for each affected month (this handles late data gracefully).
2. Update Monthly Aggregates with MERGE: Use the MERGE command to update the AGG_MONTHLY_SPENDING table. For each customer in the daily data, it either updates their existing monthly total or inserts a new record if it's their first purchase of the month.
3. Rebuild the Final Top 100 Table: After the intermediate table is up-to-date, completely overwrite the TOP_100_SPENDERS_BY_MONTH table. Since this step only reads from the much smaller AGG_MONTHLY_SPENDING table, it's extremely fast.

```sql
-- Step 1: Create a temporary aggregation of the new day's data.
-- We run this for the data that arrived today (e.g., for '2025-08-14').
CREATE OR REPLACE TEMP TABLE daily_customer_spend AS
SELECT
    DATE_TRUNC('month', purchase_timestamp)::DATE AS purchase_month,
    customer_id,
    SUM(total_amount_usd) AS daily_total_spend
FROM FCT_CUSTOMER_PURCHASES
-- This WHERE clause is critical for incrementality!
WHERE purchase_timestamp >= '2025-08-14' AND purchase_timestamp < '2025-08-15'
GROUP BY 1, 2;


-- Step 2: Use MERGE to update the main monthly aggregation table.
MERGE INTO AGG_MONTHLY_SPENDING AS target
USING daily_customer_spend AS source
    -- Match records on the same month and customer
    ON target.purchase_month = source.purchase_month AND target.customer_id = source.customer_id

-- If a customer already has an entry for that month, add today's spend to their total.
WHEN MATCHED THEN
    UPDATE SET total_monthly_spending = target.total_monthly_spending + source.daily_total_spend

-- If this is the customer's first purchase of the month, insert a new record.
WHEN NOT MATCHED THEN
    INSERT (purchase_month, customer_id, total_monthly_spending)
    VALUES (source.purchase_month, source.customer_id, source.daily_total_spend);
```
## Handling Edge Cases and Improvements ⚙️
Late-Arriving Data: This design handles late data perfectly. If a purchase from July arrives in August, the DATE_TRUNC function will correctly assign it to July's purchase_month, and the MERGE statement will correctly update July's totals.

Performance: For extreme scale, the AGG_MONTHLY_SPENDING table should be partitioned by purchase_month. This ensures that the MERGE operation only has to work on the specific monthly partitions affected by the daily data load, making it even faster.

Idempotency: The pipeline can be safely re-run for a specific day. Because it's adding a delta, you would first need to subtract the previous run's contribution before re-running the MERGE if you suspect duplicate processing.
</details>

# Question 5: Customer Loyalty
Who are the most loyal customers? People who buy everything bagels? Or plain bagels?

# Question 6: Rolling Average
Show which weeks have an average > 3 week rolling average.