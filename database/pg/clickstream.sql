DROP TABLE IF EXISTS FCT_CUSTOMER_CLICKSTREAM;

CREATE TABLE FCT_CUSTOMER_CLICKSTREAM (
    event_id,
    customer_id,
    event_type,
    event_timestamp
) AS (
    VALUES
          ('evt-001', 'cust-101', 'page_view', '2025-07-01 08:00:00'::TIMESTAMP),
          ('evt-002', 'cust-101', 'add_to_cart', '2025-07-01 08:05:00'::TIMESTAMP),
          ('evt-003', 'cust-101', 'checkout', '2025-07-01 08:10:00'::TIMESTAMP),
          ('evt-004', 'cust-101', 'page_view', '2025-07-01 09:00:00'::TIMESTAMP), -- 50 min gap, new session
          ('evt-004.1', 'cust-101', 'page_view', '2025-07-01 09:01:00'::TIMESTAMP),
          ('evt-005', 'cust-102', 'page_view', '2025-07-01 10:00:00'::TIMESTAMP),
          ('evt-006', 'cust-102', 'page_view', '2025-07-01 10:20:00'::TIMESTAMP),
          ('evt-007', 'cust-102', 'add_to_cart', '2025-07-01 10:45:00'::TIMESTAMP) -- 25 min gap, same session
     )
;