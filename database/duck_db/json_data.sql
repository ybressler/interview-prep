CREATE OR REPLACE TABLE FCT_INGREDIENT_SHIPMENTS AS
      SELECT
          #1 AS shipment_id,
          #2 AS merchant,
          #3 AS ingridient,
          #4 AS number_of_pallets,
          #5 AS weight_kg,
          #6 AS arrival_timestamp,
          #7 AS pallet_contents
    FROM (VALUES
        (
            'ship-abc-001',
            'Valley Grain Co.',
            'High-Gluten Flour',
            1,
            1000,
            '2025-07-31 09:15:00'::TIMESTAMP,
            [{'package_size': '25kg bag', 'package_weight': 25, 'expiration_date': '2026-07-31'}]
        ),
        (
            'ship-abc-002',
            'Valley Grain Co.',
            'Sesame Seeds',
            1,
            150,
            '2025-07-31 09:15:00'::TIMESTAMP,
            [
                {'package_size': '25kg bag', 'package_weight': 25, 'expiration_date': '2027-01-31'},
                {'package_size': '5kg bag', 'package_weight': 5, 'expiration_date': '2027-01-31'}
            ]
        ),
        (
            'ship-def-003',
            'Sweetner Inc.',
            'Malt Syrup',
            1,
            200,
            '2025-07-30 14:00:00'::TIMESTAMP,
            [{'package_size': '50kg pail', 'package_weight': 50, 'expiration_date': '2027-07-30'}]
        ),
        (
            'ship-ghi-004',
            'Morton Salt',
            'Kosher Salt',
            1,
            300,
            '2025-07-29 11:30:00'::TIMESTAMP,
            [{'package_size': '25kg bag', 'package_weight': 25, 'expiration_date': '2030-07-29'}]
        )
    )