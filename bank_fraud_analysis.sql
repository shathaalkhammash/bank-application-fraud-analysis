USE BankFraudAnalysis;
GO


--1. OVERALL FRAUD KPIs
  

SELECT
    COUNT_BIG(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    SUM(CASE WHEN fraud_bool = 0 THEN 1 ELSE 0 END) AS legitimate_applications,
    CAST(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END)
        / COUNT_BIG(*)
        AS decimal(10, 2)
    ) AS fraud_rate_pct
FROM dbo.bank_fraud_cleaned;



--2. FRAUD TREND BY DATASET PERIOD

SELECT
    month AS dataset_period,
    COUNT_BIG(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    CAST(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END)
        / COUNT_BIG(*)
        AS decimal(10, 2)
    ) AS fraud_rate_pct
FROM dbo.bank_fraud_cleaned
GROUP BY month
ORDER BY month;


--3. FRAUD RATE BY DEVICE OS

SELECT
    device_os,
    COUNT_BIG(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    CAST(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END)
        / COUNT_BIG(*)
        AS decimal(10, 2)
    ) AS fraud_rate_pct
FROM dbo.bank_fraud_cleaned
GROUP BY device_os
ORDER BY fraud_rate_pct DESC;


--4. FRAUD RATE BY EMPLOYMENT STATUS

SELECT
    employment_status,
    COUNT_BIG(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    CAST(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END)
        / COUNT_BIG(*)
        AS decimal(10, 2)
    ) AS fraud_rate_pct
FROM dbo.bank_fraud_cleaned
GROUP BY employment_status
ORDER BY fraud_rate_pct DESC;


--5. FRAUD RATE BY HOUSING STATUS

SELECT
    housing_status,
    COUNT_BIG(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    CAST(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END)
        / COUNT_BIG(*)
        AS decimal(10, 2)
    ) AS fraud_rate_pct
FROM dbo.bank_fraud_cleaned
GROUP BY housing_status
ORDER BY fraud_rate_pct DESC;

--6. FRAUD RATE BY PROPOSED CREDIT LIMIT

SELECT
    proposed_credit_limit,
    COUNT_BIG(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    CAST(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END)
        / COUNT_BIG(*)
        AS decimal(10, 2)
    ) AS fraud_rate_pct
FROM dbo.bank_fraud_cleaned
GROUP BY proposed_credit_limit
ORDER BY fraud_rate_pct DESC;


--7. FRAUD RATE BY CREDIT-RISK SCORE GROUP

WITH credit_score_groups AS
(
    SELECT
        fraud_bool,
        CASE
            WHEN credit_risk_score <= 48  THEN 1
            WHEN credit_risk_score <= 73  THEN 2
            WHEN credit_risk_score <= 92  THEN 3
            WHEN credit_risk_score <= 107 THEN 4
            WHEN credit_risk_score <= 122 THEN 5
            WHEN credit_risk_score <= 141 THEN 6
            WHEN credit_risk_score <= 165 THEN 7
            WHEN credit_risk_score <= 192 THEN 8
            WHEN credit_risk_score <= 226 THEN 9
            ELSE 10
        END AS group_number,
        CASE
            WHEN credit_risk_score <= 48  THEN '01 | -170 to 48'
            WHEN credit_risk_score <= 73  THEN '02 | 49 to 73'
            WHEN credit_risk_score <= 92  THEN '03 | 74 to 92'
            WHEN credit_risk_score <= 107 THEN '04 | 93 to 107'
            WHEN credit_risk_score <= 122 THEN '05 | 108 to 122'
            WHEN credit_risk_score <= 141 THEN '06 | 123 to 141'
            WHEN credit_risk_score <= 165 THEN '07 | 142 to 165'
            WHEN credit_risk_score <= 192 THEN '08 | 166 to 192'
            WHEN credit_risk_score <= 226 THEN '09 | 193 to 226'
            ELSE '10 | 227 to 389'
        END AS credit_score_group
    FROM dbo.bank_fraud_cleaned
)
SELECT
    credit_score_group,
    COUNT_BIG(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    CAST(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END)
        / COUNT_BIG(*)
        AS decimal(10, 2)
    ) AS fraud_rate_pct
FROM credit_score_groups
GROUP BY group_number, credit_score_group
ORDER BY group_number DESC;


--8. FRAUD RATE BY CUSTOMER AGE

SELECT
    customer_age,
    COUNT_BIG(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    CAST(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END)
        / COUNT_BIG(*)
        AS decimal(10, 2)
    ) AS fraud_rate_pct
FROM dbo.bank_fraud_cleaned
GROUP BY customer_age
ORDER BY customer_age;

--9. FRAUD RATE BY BINARY RISK INDICATORS

WITH binary_risk_signals AS
(
    SELECT
        b.fraud_bool,
        r.feature_order,
        r.feature,
        r.signal_present
    FROM dbo.bank_fraud_cleaned AS b
    CROSS APPLY
    (
        VALUES
            (1, 'Foreign Request',
                CASE WHEN b.foreign_request = 1 THEN 1 ELSE 0 END),

            (2, 'No Keep-Alive Session',
                CASE WHEN b.keep_alive_session = 0 THEN 1 ELSE 0 END),

            (3, 'Invalid Mobile Phone',
                CASE WHEN b.phone_mobile_valid = 0 THEN 1 ELSE 0 END),

            (4, 'Invalid Home Phone',
                CASE WHEN b.phone_home_valid = 0 THEN 1 ELSE 0 END),

            (5, 'Free Email',
                CASE WHEN b.email_is_free = 1 THEN 1 ELSE 0 END),

            (6, 'No Other Cards',
                CASE WHEN b.has_other_cards = 0 THEN 1 ELSE 0 END)
    ) AS r(feature_order, feature, signal_present)
)
SELECT
    feature,
    CASE
        WHEN signal_present = 1 THEN 'Risk Signal Present'
        ELSE 'Risk Signal Absent'
    END AS signal_status,
    COUNT_BIG(*) AS total_applications,
    SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    CAST(
        100.0 * SUM(CASE WHEN fraud_bool = 1 THEN 1 ELSE 0 END)
        / COUNT_BIG(*)
        AS decimal(10, 2)
    ) AS fraud_rate_pct
FROM binary_risk_signals
GROUP BY feature_order, feature, signal_present
ORDER BY feature_order, signal_present DESC;

--10. RISK ANALYSIS KPIs

WITH credit_limit_rates AS
(
    SELECT
        proposed_credit_limit,
        100.0 * AVG(CAST(fraud_bool AS float)) AS fraud_rate_pct
    FROM dbo.bank_fraud_cleaned
    GROUP BY proposed_credit_limit
)
SELECT
    CAST(
        (SELECT MAX(fraud_rate_pct) FROM credit_limit_rates)
        AS decimal(10, 2)
    ) AS highest_credit_limit_risk_pct,

    CAST(
        100.0 * AVG(
            CASE
                WHEN credit_risk_score > 226
                THEN CAST(fraud_bool AS float)
            END
        )
        AS decimal(10, 2)
    ) AS highest_score_group_risk_pct,

    CAST(
        100.0 * AVG(
            CASE
                WHEN foreign_request = 1
                THEN CAST(fraud_bool AS float)
            END
        )
        AS decimal(10, 2)
    ) AS foreign_request_risk_pct,

    CAST(
        100.0 * AVG(
            CASE
                WHEN name_email_similarity <= 0.107
                THEN CAST(fraud_bool AS float)
            END
        )
        AS decimal(10, 2)
    ) AS low_name_email_similarity_risk_pct
FROM dbo.bank_fraud_cleaned;


 --11. FINAL DATA-QUALITY CHECK
SELECT
    COUNT_BIG(*) AS total_rows,

    SUM(
        CASE
            WHEN fraud_bool IS NULL OR fraud_bool NOT IN (0, 1)
            THEN 1 ELSE 0
        END
    ) AS invalid_fraud_values,

    SUM(CASE WHEN prev_address_months_count IS NULL THEN 1 ELSE 0 END)
        AS missing_previous_address,

    SUM(CASE WHEN current_address_months_count IS NULL THEN 1 ELSE 0 END)
        AS missing_current_address,

    SUM(CASE WHEN bank_months_count IS NULL THEN 1 ELSE 0 END)
        AS missing_bank_months,

    SUM(CASE WHEN device_distinct_emails_8w IS NULL THEN 1 ELSE 0 END)
        AS missing_device_email_count

FROM dbo.bank_fraud_cleaned;