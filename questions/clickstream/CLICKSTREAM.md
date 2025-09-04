# Clickstream SQL Questions
The following Q's relate to the `FCT_CUSTOMER_CLICKSTREAM` table.



## Q1: What is the average session duration for each customer?
_Not bagel-related specifically, but similar to FANG interview style Q's..._

NOTE: a session is defined as a sequence of events without a 30-minute interruption.

```sql
SELECT
    *
FROM
    FCT_CUSTOMER_CLICKSTREAM
;
```
