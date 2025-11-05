DROP TABLE IF EXISTS FCT_CUSTOMER_PURCHASES;

CREATE TABLE FCT_CUSTOMER_PURCHASES (
    transaction_id,
    customer_id,
    product_name,
    quantity,
    total_amount_usd,
    purchase_timestamp
) AS (
    VALUES
        -- Customer 101: Purchases a bagel every day
        ('txn-aaa-001', 'cust-101', 'Everything Bagel', 1, 3.50, '2025-07-01 08:02:00'::TIMESTAMP),
        ('txn-aaa-002', 'cust-101', 'Everything Bagel', 1, 3.50, '2025-07-02 08:05:00'::TIMESTAMP),
        ('txn-aaa-003', 'cust-101', 'Everything Bagel', 1, 3.50, '2025-07-03 07:58:00'::TIMESTAMP),
        ('txn-aaa-004', 'cust-101', 'Everything Bagel', 1, 3.50, '2025-07-04 08:10:00'::TIMESTAMP),
        ('txn-aaa-005', 'cust-101', 'Everything Bagel', 1, 3.50, '2025-07-05 08:01:00'::TIMESTAMP),
        ('txn-aaa-006', 'cust-101', 'Everything Bagel', 1, 3.50, '2025-07-06 08:03:00'::TIMESTAMP),
        ('txn-aaa-007', 'cust-101', 'Everything Bagel', 1, 3.50, '2025-07-07 08:04:00'::TIMESTAMP),

        -- Customer 102: Purchases twice a week (e.g., Tuesday & Friday)
        ('txn-bbb-008', 'cust-102', 'Cinnamon Raisin Bagel', 2, 7.00, '2025-07-01 10:15:00'::TIMESTAMP),
        ('txn-bbb-009', 'cust-102', 'Cinnamon Raisin Bagel', 2, 7.00, '2025-07-04 10:21:00'::TIMESTAMP),
        ('txn-bbb-010', 'cust-102', 'Cinnamon Raisin Bagel', 2, 7.00, '2025-07-08 10:11:00'::TIMESTAMP),
        ('txn-bbb-011', 'cust-102', 'Cinnamon Raisin Bagel', 2, 7.00, '2025-07-11 10:18:00'::TIMESTAMP),
        ('txn-bbb-012', 'cust-102', 'Cinnamon Raisin Bagel', 2, 7.00, '2025-07-15 10:14:00'::TIMESTAMP),
        ('txn-bbb-013', 'cust-102', 'Cinnamon Raisin Bagel', 2, 7.00, '2025-07-18 10:25:00'::TIMESTAMP),

        -- Customer 103: Purchases once a month
        ('txn-ccc-014', 'cust-103', 'Dozen Assorted Bagels', 1, 24.00, '2025-07-15 16:30:00'::TIMESTAMP),

        ('txn-ccc-015', 'cust-104', 'Plan Bagel', 1, 4.00, '2025-08-15 16:30:00'::TIMESTAMP),

        ('txn-ccc-016', 'cust-105', 'Plan Bagel', 1, 4.00, '2025-09-01 16:30:00'::TIMESTAMP),
        ('txn-ccc-017', 'cust-106', 'Plan Bagel', 2, 8.00, '2025-09-02 16:45:00'::TIMESTAMP),

        -- Customers for monthly analysis (Q4)
        -- Big spender
        ('txn-ccc-018', 'cust-107', 'Plan Bagel', 12, 24.00, '2025-9-15 16:45:00'::TIMESTAMP),
        ('txn-ccc-019', 'cust-107', 'Plan Bagel', 12, 24.00, '2025-10-15 16:45:00'::TIMESTAMP),
        ('txn-ccc-020', 'cust-107', 'Plan Bagel', 12, 24.00, '2025-11-15 16:45:00'::TIMESTAMP),
        -- Small spender
        ('txn-ccc-021', 'cust-108', 'Plan Bagel', 1, 3.00, '2025-9-15 16:47:00'::TIMESTAMP),
        ('txn-ccc-022', 'cust-108', 'Plan Bagel', 1, 3.00, '2025-10-15 16:47:00'::TIMESTAMP),
        ('txn-ccc-023', 'cust-108', 'Plan Bagel', 1, 3.00, '2025-11-15 16:47:00'::TIMESTAMP)
    )
;