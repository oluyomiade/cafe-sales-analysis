-- 1. Check the total number of records
SELECT COUNT(*) AS total_rows
FROM cafe_sales_cleaned;


-- 2. Inspect the columns in our dataset
PRAGMA table_info(cafe_sales_cleaned);

-- 3. Preview the first 10 records
SELECT *
FROM cafe_sales_cleaned
LIMIT 10;

-- 4. Check the earliest and latest transaction dates
SELECT
    MIN("Transaction Date") AS earliest_date,
    MAX("Transaction Date") AS latest_date
FROM cafe_sales_cleaned;


-- 5. Calculate total recorded sales
SELECT
    SUM("Total Spent") AS total_sales
FROM cafe_sales_cleaned;


-- 6. Check the completeness of sales totals
SELECT
    COUNT(*) AS total_transactions,
    COUNT("Total Spent") AS transactions_with_totals,
    COUNT(*) - COUNT("Total Spent") AS transactions_missing_totals,
    SUM("Total Spent") AS total_recorded_sales
FROM cafe_sales_cleaned;


-- 7. Find the best-selling items by quantity
SELECT
    Item,
    SUM(Quantity) AS total_quantity_sold
FROM cafe_sales_cleaned
WHERE Item != 'Unknown'
  AND Quantity IS NOT NULL
GROUP BY Item
ORDER BY total_quantity_sold DESC
LIMIT 10;


-- 8. Rank items by total recorded sales
SELECT
    Item,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE Item != 'Unknown'
  AND "Total Spent" IS NOT NULL
GROUP BY Item
ORDER BY total_revenue DESC;

-- 9. Analyse transactions by payment method
SELECT
    "Payment Method",
    COUNT(*) AS total_transactions,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE "Payment Method" != 'Unknown'
  AND "Total Spent" IS NOT NULL
GROUP BY "Payment Method"
ORDER BY total_transactions DESC;

-- 10. Analyse sales by location
SELECT
    Location,
    COUNT(*) AS total_transactions,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE Location != 'Unknown'
  AND "Total Spent" IS NOT NULL
GROUP BY Location
ORDER BY total_revenue DESC;

-- 11. Analyse monthly sales trends
SELECT
    strftime('%Y-%m', "Transaction Date") AS sales_month,
    COUNT(*) AS total_transactions,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE "Transaction Date" IS NOT NULL
  AND "Total Spent" IS NOT NULL
GROUP BY strftime('%Y-%m', "Transaction Date")
ORDER BY sales_month;

-- 12. Calculate average transaction value
SELECT
    ROUND(AVG("Total Spent"), 2) AS average_transaction_value,
    MIN("Total Spent") AS smallest_transaction,
    MAX("Total Spent") AS largest_transaction
FROM cafe_sales_cleaned
WHERE "Total Spent" IS NOT NULL;

-- 13. Revenue by item and payment method
SELECT
    Item,
    "Payment Method",
    COUNT(*) AS total_transactions,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE Item != 'Unknown'
  AND "Payment Method" != 'Unknown'
  AND "Total Spent" IS NOT NULL
GROUP BY Item, "Payment Method"
ORDER BY Item, total_revenue DESC;

-- 14. Average transaction value by item
SELECT
    Item,
    COUNT(*) AS total_transactions,
    ROUND(AVG("Total Spent"), 2) AS average_spent,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE Item != 'Unknown'
  AND "Total Spent" IS NOT NULL
GROUP BY Item
ORDER BY average_spent DESC;

-- 15. Transactions and revenue by day of the week
SELECT
    CASE CAST(strftime('%w', "Transaction Date") AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,
    COUNT(*) AS total_transactions,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE "Transaction Date" IS NOT NULL
  AND "Total Spent" IS NOT NULL
GROUP BY strftime('%w', "Transaction Date")
ORDER BY CAST(strftime('%w', "Transaction Date") AS INTEGER);

-- 16. Quantity sold and revenue by item
SELECT
    Item,
    SUM(Quantity) AS total_quantity_sold,
    SUM("Total Spent") AS total_revenue,
    ROUND(AVG("Total Spent"), 2) AS average_spent
FROM cafe_sales_cleaned
WHERE Item != 'Unknown'
  AND Quantity IS NOT NULL
  AND "Total Spent" IS NOT NULL
GROUP BY Item
ORDER BY total_revenue DESC;

-- 17. Top 3 items by recorded revenue
SELECT
    Item,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE Item != 'Unknown'
  AND "Total Spent" IS NOT NULL
GROUP BY Item
ORDER BY total_revenue DESC
LIMIT 3;

-- 18. Bottom 3 items by recorded revenue
SELECT
    Item,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE Item != 'Unknown'
  AND "Total Spent" IS NOT NULL
GROUP BY Item
ORDER BY total_revenue ASC
LIMIT 3;

-- 19. Average transaction value by payment method
SELECT
    "Payment Method",
    COUNT(*) AS total_transactions,
    ROUND(AVG("Total Spent"), 2) AS average_transaction_value,
    SUM("Total Spent") AS total_revenue
FROM cafe_sales_cleaned
WHERE "Payment Method" != 'Unknown'
  AND "Total Spent" IS NOT NULL
GROUP BY "Payment Method"
ORDER BY average_transaction_value DESC;
