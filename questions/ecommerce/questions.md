## SQL Question - Medium Difficulty
You're working at an e-commerce company.

We have two tables:
orders

order_id | user_id | order_date | total_amount | status
---------|---------|------------|--------------|----------
1        | 101     | 2024-01-15 | 150.00       | completed
2        | 102     | 2024-01-16 | 200.00       | completed
3        | 101     | 2024-01-20 | 75.00        | cancelled


order_items

item_id | order_id | product_id | quantity | price
--------|----------|------------|----------|-------
1       | 1        | 501        | 2        | 75.00
2       | 1        | 502        | 1        | 75.00
3       | 2        | 503        | 1        | 200.00


**Question:** Write a query to find all users who have made at least 3 completed orders in the last 90 days, and for each of these users, calculate:
* Their total number of completed orders
* Their total spend
* Their average order value
* The most frequently purchased product_id (if there's a tie, pick any one)

Return results ordered by total spend descending.


----
SQL Question - Hard Difficulty
You're building a user retention dashboard for a SaaS product. We need to understand cohort behavior.
New Table: user_events

```sql
-- Setup code
DROP TABLE IF EXISTS user_events;

CREATE TABLE user_events (
    event_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    event_date DATE NOT NULL,
    event_type VARCHAR(50) NOT NULL
);

INSERT INTO user_events (user_id, event_date, event_type) VALUES
-- User 1: signed up Jan 1, active in weeks 0, 1, 3, 4
(1, '2024-01-01', 'signup'),
(1, '2024-01-02', 'login'),
(1, '2024-01-08', 'login'),
(1, '2024-01-22', 'login'),
(1, '2024-01-29', 'login'),

-- User 2: signed up Jan 1, active in weeks 0, 2
(2, '2024-01-01', 'signup'),
(2, '2024-01-03', 'login'),
(2, '2024-01-15', 'login'),

-- User 3: signed up Jan 8, active in weeks 0, 1, 2
(3, '2024-01-08', 'signup'),
(3, '2024-01-10', 'login'),
(3, '2024-01-17', 'login'),
(3, '2024-01-20', 'login'),

-- User 4: signed up Jan 8, only week 0
(4, '2024-01-08', 'signup'),
(4, '2024-01-09', 'login'),

-- User 5: signed up Jan 15, active in weeks 0, 1, 3
(5, '2024-01-15', 'signup'),
(5, '2024-01-16', 'login'),
(5, '2024-01-24', 'login'),
(5, '2024-02-05', 'login');
```

---

## **Question:**

Write a query to calculate **weekly cohort retention**. For each signup week, show:

1. **cohort_week** - The week users signed up (use Monday as week start)
2. **cohort_size** - Number of users who signed up that week
3. **week_0** - % of cohort active in week 0 (signup week) 
4. **week_1** - % of cohort active in week 1 after signup
5. **week_2** - % of cohort active in week 2 after signup
6. **week_3** - % of cohort active in week 3 after signup

**Rules:**
- A user is "active" in a week if they have ANY event (signup or login) in that 7-day period
- Week 0 = the 7-day period starting from the Monday of their signup week
- Week 1 = the following 7 days, etc.
- Use Monday as the start of the week (DATE_TRUNC)
- Return retention as percentages rounded to 1 decimal place
- Order by cohort_week ascending

**Expected Output Format:**
```
cohort_week | cohort_size | week_0 | week_1 | week_2 | week_3
------------|-------------|--------|--------|--------|--------
2024-01-01  | 2           | 100.0  | 50.0   | 50.0   | 0.0
2024-01-08  | 2           | 100.0  | 50.0   | 50.0   | 0.0
...