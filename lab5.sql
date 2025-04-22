-- Step 1: Create a View
CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Step 2: Create a Temporary Table
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    c.customer_id,
    SUM(p.amount) AS total_paid
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

-- Step 3: Create a CTE and the Customer Summary Report
WITH customer_summary AS (
    SELECT 
        r.customer_name,
        r.email,
        r.rental_count,
        COALESCE(p.total_paid, 0) AS total_paid
    FROM customer_rental_summary r
    LEFT JOIN customer_payment_summary p ON r.customer_id = p.customer_id
)

-- Final customer summary report
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count > 0 THEN total_paid / rental_count
        ELSE 0
    END AS average_payment_per_rental
FROM customer_summary;