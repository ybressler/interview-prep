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



-- Now the Q
WITH WEEKLY_SERIES AS (
    SELECT
        DISTINCT( DATE_TRUNC('WEEK', event_date))::DATE AS WEEK
    FROM
        user_events
),
COHORT_START AS (
    select
        DATE_TRUNC('week', event_date)::DATE AS COHORT_WEEK,
        user_id
    from
        user_events
    where
        event_type = 'signup'
),
WEEKLY_ACTIVE AS (
    select
        A.WEEK,
        B.user_id
    from
        WEEKLY_SERIES AS A
    LEFT JOIN user_events AS B ON DATE_TRUNC('WEEK', B.event_date) = A.WEEK
    GROUP BY A.WEEK, B.user_id
)
select
    A.COHORT_WEEK,
    COUNT(DISTINCT A.user_id) AS cohort_size,
    100 * COUNT(B.WEEK) FILTER(WHERE B.WEEK = A.COHORT_WEEK) / COUNT(DISTINCT A.user_id) AS WEEK_0,
    100 * COUNT(B.WEEK) FILTER(WHERE B.WEEK = A.COHORT_WEEK + INTERVAL '1 WEEK') / COUNT(DISTINCT A.user_id)  AS WEEK_1,
    100 * COUNT(B.WEEK) FILTER(WHERE B.WEEK = A.COHORT_WEEK + INTERVAL '2 WEEKS') / COUNT(DISTINCT A.user_id) AS WEEK_2,
    100 * COUNT(B.WEEK) FILTER(WHERE B.WEEK = A.COHORT_WEEK + INTERVAL '3 WEEKS') / COUNT(DISTINCT A.user_id) AS WEEK_3
from
    COHORT_START AS A
JOIN WEEKLY_ACTIVE AS B ON A.user_id = B.user_id
GROUP BY A.COHORT_WEEK
;

-- Probably a better solution is do a self-join, no CTE's