/*
  Telco Project - SQL Solutions

  Target database: Oracle XE
  Tables used: CUSTOMERS, TARIFFS, MONTHLY_STATS
  Expected output values were checked against the provided CSV files.
*/

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';

/* ---------------------------------------------------------------------------
  1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.

  Explanation:
  This query joins CUSTOMERS with TARIFFS because the tariff name is stored in
  the tariff table, while each customer's tariff is represented by TARIFF_ID.
  The filter is applied by tariff name so the answer remains readable and does
  not depend on memorizing that 'Kobiye Destek' has TARIFF_ID = 4. The output is
  sorted by CUSTOMER_ID to make the result stable and easy to review.

  Expected output:
  2,483 rows. First rows by CUSTOMER_ID are 15, 33, 34, 35, 44, 45, 49, 54, 55,
  and 61.
--------------------------------------------------------------------------- */
SELECT
  c.customer_id,
  c.name AS customer_name,
  c.city,
  c.signup_date,
  t.name AS tariff_name
FROM customers c
JOIN tariffs t
  ON t.tariff_id = c.tariff_id
WHERE t.name = N'Kobiye Destek'
ORDER BY c.customer_id;

/* ---------------------------------------------------------------------------
  1.2 Find the newest customer who subscribed to the 'Kobiye Destek' tariff.

  Explanation:
  This query uses the same join and tariff filter as the previous question, but
  it orders customers by SIGNUP_DATE in descending order. CUSTOMER_ID is used as
  a secondary descending sort key so the result is deterministic if more than
  one customer has the same newest signup date. FETCH FIRST 1 ROW ONLY returns
  only the newest matching customer.

  Expected output:
  CUSTOMER_ID = 8295, NAME = Ömer, CITY = AFYONKARAHİSAR,
  SIGNUP_DATE = 05/04/2026, TARIFF_NAME = Kobiye Destek.
--------------------------------------------------------------------------- */
SELECT
  c.customer_id,
  c.name AS customer_name,
  c.city,
  c.signup_date,
  t.name AS tariff_name
FROM customers c
JOIN tariffs t
  ON t.tariff_id = c.tariff_id
WHERE t.name = N'Kobiye Destek'
ORDER BY c.signup_date DESC, c.customer_id DESC
FETCH FIRST 1 ROW ONLY;

/* ---------------------------------------------------------------------------
  2.1 Find the distribution of tariffs among the customers.

  Explanation:
  This query groups customers by tariff to show how many customers belong to
  each package. The percentage column is calculated with an analytic COUNT over
  the whole customer table, so it does not require a separate subquery for the
  total customer count. Sorting by CUSTOMER_COUNT descending makes the most
  common tariff appear first.

  Expected output:
  Kurumsal SMS = 2,577, Genç Dinamik = 2,527,
  Kobiye Destek = 2,483, Çalışan GB = 2,413.
--------------------------------------------------------------------------- */
SELECT
  t.tariff_id,
  t.name AS tariff_name,
  COUNT(*) AS customer_count,
  ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_customers
FROM customers c
JOIN tariffs t
  ON t.tariff_id = c.tariff_id
GROUP BY t.tariff_id, t.name
ORDER BY customer_count DESC, t.tariff_id;

/* ---------------------------------------------------------------------------
  3.1 Identify the earliest customers to sign up.

  Explanation:
  The earliest signup cannot be found by the lowest CUSTOMER_ID because the
  assignment explicitly warns that IDs are not guaranteed to match signup order.
  This query first finds the minimum SIGNUP_DATE in the customer table, then
  returns every customer with that exact date. Returning all ties is important
  because several customers may have joined on the first available date.

  Expected output:
  35 rows. The earliest SIGNUP_DATE is 07/04/2025.
--------------------------------------------------------------------------- */
SELECT
  c.customer_id,
  c.name AS customer_name,
  c.city,
  c.signup_date,
  t.name AS tariff_name
FROM customers c
JOIN tariffs t
  ON t.tariff_id = c.tariff_id
WHERE c.signup_date = (
  SELECT MIN(signup_date)
  FROM customers
)
ORDER BY c.customer_id;

/* ---------------------------------------------------------------------------
  3.2 Find the distribution of these earliest customers across different cities.

  Explanation:
  This query reuses the same earliest-date condition from question 3.1, then
  groups only those earliest customers by CITY. The COUNT function gives the
  number of first-day customers in each city. Sorting by count and city makes
  the distribution easier to inspect.

  Expected output:
  30 city rows. ANTALYA, GAZİANTEP, ŞIRNAK, SAKARYA, and YOZGAT each have 2
  earliest customers; the remaining listed cities have 1.
--------------------------------------------------------------------------- */
SELECT
  c.city,
  COUNT(*) AS earliest_customer_count
FROM customers c
WHERE c.signup_date = (
  SELECT MIN(signup_date)
  FROM customers
)
GROUP BY c.city
ORDER BY earliest_customer_count DESC, c.city;

/* ---------------------------------------------------------------------------
  4.1 Identify customers whose monthly records are missing.

  Explanation:
  Every customer should have one row in MONTHLY_STATS, but the CSV contains
  only 9,950 monthly records for 10,000 customers. A LEFT JOIN keeps all
  customers and shows NULL on the monthly side when no matching usage row
  exists. Filtering for NULL monthly CUSTOMER_ID returns the customers affected
  by the insertion error.

  Expected output:
  50 missing customers. IDs:
  6, 10, 31, 39, 45, 81, 116, 136, 140, 156, 205, 211, 218, 221, 229, 233,
  301, 326, 329, 343, 413, 449, 458, 463, 467, 507, 526, 533, 534, 543, 577,
  583, 596, 604, 616, 617, 678, 783, 788, 819, 842, 869, 885, 889, 903, 905,
  930, 935, 953, 988.
--------------------------------------------------------------------------- */
SELECT
  c.customer_id,
  c.name AS customer_name,
  c.city,
  c.signup_date,
  t.name AS tariff_name
FROM customers c
JOIN tariffs t
  ON t.tariff_id = c.tariff_id
LEFT JOIN monthly_stats ms
  ON ms.customer_id = c.customer_id
WHERE ms.customer_id IS NULL
ORDER BY c.customer_id;

/* ---------------------------------------------------------------------------
  4.2 Find the distribution of missing customers across different cities.

  Explanation:
  This query uses the missing-record logic from question 4.1 and groups the
  missing customers by CITY. It answers where the insertion gap is concentrated
  geographically. The ordering shows the cities with the largest number of
  missing monthly records first.

  Expected output:
  OSMANİYE has 3 missing customers. MUŞ, KIRIKKALE, İZMİR, NEVŞEHİR, BİTLİS,
  ORDU, DENİZLİ, KAYSERİ, and SİVAS each have 2; the other listed cities have 1.
--------------------------------------------------------------------------- */
SELECT
  c.city,
  COUNT(*) AS missing_customer_count
FROM customers c
LEFT JOIN monthly_stats ms
  ON ms.customer_id = c.customer_id
WHERE ms.customer_id IS NULL
GROUP BY c.city
ORDER BY missing_customer_count DESC, c.city;

/* ---------------------------------------------------------------------------
  5.1 Find customers who used at least 75% of their data limit.

  Explanation:
  This query joins all three tables because usage values are in MONTHLY_STATS,
  tariff limits are in TARIFFS, and customer information is in CUSTOMERS. The
  DATA_LIMIT > 0 condition prevents division by zero for tariffs that do not
  include a data package. The usage percentage is calculated and returned so the
  result can be checked without manually comparing usage and limit values.

  Expected output:
  1,880 rows. First rows by CUSTOMER_ID include 1, 4, 28, 30, 38, 40, 42, 43,
  46, and 53.
--------------------------------------------------------------------------- */
SELECT
  c.customer_id,
  c.name AS customer_name,
  c.city,
  t.name AS tariff_name,
  ms.data_usage,
  t.data_limit,
  ROUND(ms.data_usage * 100 / t.data_limit, 2) AS data_usage_percentage
FROM customers c
JOIN tariffs t
  ON t.tariff_id = c.tariff_id
JOIN monthly_stats ms
  ON ms.customer_id = c.customer_id
WHERE t.data_limit > 0
  AND ms.data_usage >= t.data_limit * 0.75
ORDER BY c.customer_id;

/* ---------------------------------------------------------------------------
  5.2 Identify customers who completely exhausted all package limits.

  Explanation:
  This query checks data, minute, and SMS usage against the customer's tariff
  limits. A limit of zero is treated as "not included in this tariff", so it is
  not considered a blocker for the exhaustion check. This makes the logic fair
  for packages such as Kurumsal SMS, where only the SMS limit is meaningful.

  Expected output:
  0 rows in the provided dataset.
--------------------------------------------------------------------------- */
SELECT
  c.customer_id,
  c.name AS customer_name,
  c.city,
  t.name AS tariff_name,
  ms.data_usage,
  t.data_limit,
  ms.minute_usage,
  t.minute_limit,
  ms.sms_usage,
  t.sms_limit
FROM customers c
JOIN tariffs t
  ON t.tariff_id = c.tariff_id
JOIN monthly_stats ms
  ON ms.customer_id = c.customer_id
WHERE (t.data_limit = 0 OR ms.data_usage >= t.data_limit)
  AND (t.minute_limit = 0 OR ms.minute_usage >= t.minute_limit)
  AND (t.sms_limit = 0 OR ms.sms_usage >= t.sms_limit)
ORDER BY c.customer_id;

/* ---------------------------------------------------------------------------
  6.1 Find customers who have unpaid fees.

  Explanation:
  The PAYMENT_STATUS column contains PAID, LATE, and UNPAID statuses. This
  query treats both LATE and UNPAID as unresolved payment cases because neither
  one represents a fully paid monthly record. The join with TARIFFS adds the
  monthly fee and tariff name so the finance-related result is easier to review.

  Expected output:
  2,951 rows: 1,497 LATE records and 1,454 UNPAID records.
--------------------------------------------------------------------------- */
SELECT
  c.customer_id,
  c.name AS customer_name,
  c.city,
  t.name AS tariff_name,
  t.monthly_fee,
  ms.payment_status
FROM customers c
JOIN tariffs t
  ON t.tariff_id = c.tariff_id
JOIN monthly_stats ms
  ON ms.customer_id = c.customer_id
WHERE ms.payment_status IN ('LATE', 'UNPAID')
ORDER BY c.customer_id;

/* ---------------------------------------------------------------------------
  6.2 Find the distribution of all payment statuses across different tariffs.

  Explanation:
  This query groups monthly records by tariff and payment status. It includes
  all payment statuses instead of filtering, which gives a complete payment
  distribution for every tariff. The percentage column is calculated within each
  tariff, so it shows how each tariff's customer base is split across PAID,
  LATE, and UNPAID.

  Expected output:
  Genç Dinamik: LATE 372, PAID 1792, UNPAID 352.
  Kobiye Destek: LATE 392, PAID 1719, UNPAID 360.
  Kurumsal SMS: LATE 368, PAID 1796, UNPAID 403.
  Çalışan GB: LATE 365, PAID 1692, UNPAID 339.
--------------------------------------------------------------------------- */
SELECT
  t.name AS tariff_name,
  ms.payment_status,
  COUNT(*) AS status_count,
  ROUND(
    COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY t.tariff_id),
    2
  ) AS percentage_in_tariff
FROM monthly_stats ms
JOIN customers c
  ON c.customer_id = ms.customer_id
JOIN tariffs t
  ON t.tariff_id = c.tariff_id
GROUP BY t.tariff_id, t.name, ms.payment_status
ORDER BY t.name, ms.payment_status;
