-- Describing the bank_transaction_table
desc BANK_TRANSACTION;

-- 1. Query to find the highest amount debited from the bank each year
SELECT EXTRACT(YEAR FROM "DATE") AS year,
       MAX(CAST(WITHDRAWAL_AMT AS NUMBER(10,2) DEFAULT NULL ON CONVERSION ERROR)) AS highest_debited_amount_from_each_year
FROM BANK_TRANSACTION
GROUP BY EXTRACT(YEAR FROM "DATE")
ORDER BY year DESC;

-- 2. Query to find the lowest amount debited from the bank each year
SELECT EXTRACT(YEAR FROM "DATE") AS year,
       MIN(CAST(WITHDRAWAL_AMT AS NUMBER(10,2) DEFAULT NULL ON CONVERSION ERROR)) AS lowest_debited_amount_from_each_year
FROM BANK_TRANSACTION
GROUP BY EXTRACT(YEAR FROM "DATE")
ORDER BY year ASC;

-- 3. Query to find the 5th highest withdrawal amount at each year
WITH processed_transactions AS (
SELECT
    TO_NUMBER(TRIM(' ' FROM (REPLACE(WITHDRAWAL_AMT, '"', '')))) AS withdrawal_amount,
    EXTRACT(YEAR FROM "DATE") AS year
FROM
    BANK_TRANSACTION
WHERE
    WITHDRAWAL_AMT IS NOT NULL
    AND REGEXP_LIKE(TRIM(' ' FROM (REPLACE(WITHDRAWAL_AMT, '"', ''))), '^[0-9]+(\.[0-9]+)?$')
),
ranked_transactions AS (
SELECT
    year,
    withdrawal_amount,
    ROW_NUMBER() OVER (PARTITION BY year ORDER BY withdrawal_amount DESC) AS rnk
FROM
    processed_transactions
)
SELECT year, withdrawal_amount AS fifth_highest_withdrawal_amount_at_each_year
FROM ranked_transactions
WHERE rnk = 5
ORDER BY year ASC;


-- 4. Query to find the withdrawal transaction between 5-May-2018 and 7-Mar-2019
SELECT COUNT(WITHDRAWAL_AMT) AS withdrawal_count
FROM BANK_TRANSACTION
WHERE "DATE" >= TO_DATE('5-May-18','dd-mon-yy')
    AND "DATE" <= TO_DATE('7-Mar-19','dd-mon-yy')
    AND withdrawal_amt IS NOT NULL;

-- 5. Query to find the first 5 largest withdrawal transactions are occured in year 18
SELECT TO_NUMBER(TRIM (' ' FROM (REPLACE(WITHDRAWAL_AMT, '"', ''))))
AS FIRST_FIVE_LARGEST_TRANSACTIONS_IN_THE_YEAR_18 FROM BANK_TRANSACTION
WHERE WITHDRAWAL_AMT IS NOT NULL AND EXTRACT(YEAR FROM "DATE") = 2018
AND REGEXP_LIKE(TRIM(' ' FROM (REPLACE(WITHDRAWAL_AMT, '"', ''))), '^[0-9]+(\.[0-9]+)?$')
ORDER BY TO_NUMBER(TRIM(' ' FROM (REPLACE(WITHDRAWAL_AMT, '"', '')))) DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;