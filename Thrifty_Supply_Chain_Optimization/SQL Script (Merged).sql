## This Script contains all queries related to Problem 1.

## The folowing query merges a few tables to find out the order creation date of each order and fulfillment of each order line item. It also takes a look at the country in which the seller is present along with the country in which delivery is scheduled.

SELECT
    a.id AS order_line_id,
    a.order_id AS order_id,
    DATE(c.created_at) AS order_creation_date,
    c.shipping_address_country,
    a.fulfillment_status AS orderline_status,
    a.name,
    a.price,
    a.quantity,
    a.vendor,
    b.status AS fulfillment_status,
    DATE(b.created_at) AS fulfillment_date,
    d.country AS seller_country
FROM  
    dogwood-baton-345622.data_analyst_assignment.order_line AS a
LEFT JOIN 
    dogwood-baton-345622.data_analyst_assignment.fulfillment AS b
ON 
    a.id = b.order_line_id
LEFT JOIN 
    dogwood-baton-345622.data_analyst_assignment.order AS c
ON 
    a.order_id = c.id
LEFT JOIN 
    dogwood-baton-345622.data_analyst_assignment.vendor_countries AS d
ON 
    a.vendor = d.supplier;

## This query extracts all order line items and complaints registered against them by customers.

SELECT 
    custom_order_line_item_id, 
    custom_issue_type_level_2,
    custom_issue_type_level_3
FROM 
    dogwood-baton-345622.data_analyst_assignment.zendesk_ticket
WHERE
    custom_order_line_item_id IS NOT NULL

  --------------------------------------------------------------------------------

## This Script contains all SQL queries related to Problem 2.

## This query will be used to find out the total revenue against new product uploads in each month.

WITH Revenue AS (
  SELECT
    EXTRACT(YEAR FROM created_at) AS Year,
    EXTRACT(MONTH FROM created_at) AS Month_Number,
    ROUND(SUM(total_price),0) AS revenue
  FROM
    dogwood-baton-345622.data_analyst_assignment.order
  WHERE
    financial_status IN ('paid', 'partially_refunded')
  GROUP BY
    Year, Month_Number
),
Products AS (
  SELECT
    EXTRACT(YEAR FROM upload_date) AS Year,
    EXTRACT(MONTH FROM upload_date) AS Month_Number,
    COUNT(id) AS uploaded_products
  FROM
    dogwood-baton-345622.data_analyst_assignment.product_table
  GROUP BY
    Year, Month_Number
)
SELECT
  R.Year,
  R.Month_Number,
  FORMAT_DATE('%B', DATE_TRUNC(DATE(P.Year, P.Month_Number, 1), MONTH)) AS Month_Name,
  R.revenue,
  P.uploaded_products
FROM
  Revenue R
JOIN
  Products P
ON
  R.Year = P.Year AND R.Month_Number = P.Month_Number
ORDER BY
  R.Year, R.Month_Number;

## This query is to find out the order count, total revenue, and average order value (AOV) throughout the whole duration.

SELECT
  EXTRACT(YEAR FROM created_at) AS year,
  EXTRACT(MONTH FROM created_at) AS month,
  COUNT(id) AS count_orders,
  ROUND(SUM(total_price), 0) AS total_rev,
  ROUND(SUM(total_price) / COUNT(id), 0) AS AOV
FROM
  dogwood-baton-345622.data_analyst_assignment.order
WHERE
  financial_status IN ('paid', 'partially_refunded')
GROUP BY
  year, month
ORDER BY
  year, month;

## This query will now be used to find out the vendor-wise sales from July 2023 till January 2024.

WITH cte AS (
    SELECT
        b.created_at,
        a.id,
        a.order_id,
        a.fulfillment_status,
        a.name,
        (a.price * a.quantity) AS revenue,
        a.vendor
    FROM
        dogwood-baton-345622.data_analyst_assignment.order_line AS a
    LEFT JOIN
        dogwood-baton-345622.data_analyst_assignment.order AS b ON a.order_id = b.id
)
SELECT
    vendor,
    SUM(CASE WHEN EXTRACT(MONTH FROM created_at) = 7 AND EXTRACT(YEAR FROM created_at) = 2023 THEN revenue ELSE NULL END) AS July_2023,
    SUM(CASE WHEN EXTRACT(MONTH FROM created_at) = 8 AND EXTRACT(YEAR FROM created_at) = 2023 THEN revenue ELSE NULL END) AS August_2023,
    SUM(CASE WHEN EXTRACT(MONTH FROM created_at) = 9 AND EXTRACT(YEAR FROM created_at) = 2023 THEN revenue ELSE NULL END) AS September_2023,
    SUM(CASE WHEN EXTRACT(MONTH FROM created_at) = 10 AND EXTRACT(YEAR FROM created_at) = 2023 THEN revenue ELSE NULL END) AS October_2023,
    SUM(CASE WHEN EXTRACT(MONTH FROM created_at) = 11 AND EXTRACT(YEAR FROM created_at) = 2023 THEN revenue ELSE NULL END) AS November_2023,
    SUM(CASE WHEN EXTRACT(MONTH FROM created_at) = 12 AND EXTRACT(YEAR FROM created_at) = 2023 THEN revenue ELSE NULL END) AS December_2023,
    SUM(CASE WHEN EXTRACT(MONTH FROM created_at) = 1 AND EXTRACT(YEAR FROM created_at) = 2024 THEN revenue ELSE NULL END) AS January_2024
FROM
    cte
WHERE
    fulfillment_status = 'fulfilled'
GROUP BY
    vendor;

## This query will be used to find out the total revenue and total qty ordered of all products, and segregate them into products with zero revenue and products with some revenue.

SELECT
  Selling_Category,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 1 THEN 1 ELSE 0 END) AS January_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 2 THEN 1 ELSE 0 END) AS February_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 3 THEN 1 ELSE 0 END) AS March_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 4 THEN 1 ELSE 0 END) AS April_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 5 THEN 1 ELSE 0 END) AS May_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 6 THEN 1 ELSE 0 END) AS June_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 7 THEN 1 ELSE 0 END) AS July_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 8 THEN 1 ELSE 0 END) AS August_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 9 THEN 1 ELSE 0 END) AS September_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 10 THEN 1 ELSE 0 END) AS October_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 11 THEN 1 ELSE 0 END) AS November_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2023 AND EXTRACT(MONTH FROM upload_date) = 12 THEN 1 ELSE 0 END) AS December_2023,
  SUM(CASE WHEN EXTRACT(YEAR FROM upload_date) = 2024 AND EXTRACT(MONTH FROM upload_date) = 1 THEN 1 ELSE 0 END) AS January_2024
FROM (
  SELECT
    CASE
      WHEN lowest_sold_value IS NULL OR lowest_sold_value = 0 THEN '0_Sold_Products'
      ELSE 'Selling_Products'
    END AS Selling_Category,
    upload_date
  FROM
    dogwood-baton-345622.data_analyst_assignment.product_table
) AS subquery
WHERE
  (EXTRACT(YEAR FROM upload_date) BETWEEN 2023 AND 2024)
GROUP BY
  Selling_Category;

## The following queries will now try to figure out why exactly are the products that are uploaded each month don't have any contribution in monthly sales.

## 1. Products with zero sales had lower number of offers placed on them.

SELECT
    title,
    EXTRACT(YEAR FROM upload_date) AS year,
    EXTRACT(MONTH FROM upload_date) AS month,
    shipping_to_eu,
    shipping_to_gb,
    shipping_to_us,
    shipping_to_international
FROM
    dogwood-baton-345622.data_analyst_assignment.product_table
WHERE
    lowest_sold_value != 0 OR lowest_sold_value IS NOT NULL;

## 2. The following query finds out if the shipping fees is enabled for the prodcuts with no sales and with non-zero sales also.

SELECT
    title,
    EXTRACT(YEAR FROM upload_date) AS year,
    EXTRACT(MONTH FROM upload_date) AS month,
    lowest_sold_value,
    CASE WHEN shipping_to_eu = 0 OR shipping_to_eu IS NULL THEN 'False' ELSE 'True' END AS eu,
    CASE WHEN shipping_to_gb = 0 OR shipping_to_gb IS NULL THEN 'False' ELSE 'True' END AS gb,
    CASE WHEN shipping_to_us = 0 OR shipping_to_us IS NULL THEN 'False' ELSE 'True' END AS us,
    CASE WHEN shipping_to_international = 0 OR shipping_to_international IS NULL THEN 'False' ELSE 'True' END AS intl
FROM
    dogwood-baton-345622.data_analyst_assignment.product_table
WHERE
    lowest_sold_value = 0 OR lowest_sold_value IS NULL;

## The following two queries will now focus on the distribution of sellers who uploaded performing products vs. zero_revenue products.

## 1. The following query will first figure out the sellers with products having some revenue generated from July 2023 - January 2024.

SELECT
    vendor, 
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 7 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS July_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 8 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS August_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 9 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS September_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 10 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS October_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 11 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS November_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 12 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS December_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 1 AND EXTRACT(YEAR FROM upload_date) = 2024 THEN id ELSE NULL END) AS January_2024
FROM
    dogwood-baton-345622.data_analyst_assignment.product_table
WHERE 
    lowest_sold_value <> 0 OR lowest_sold_value IS NOT NULL
GROUP BY 
    vendor;

## 2. The following query will now figure out the sellers with products having zero revenue generated from July 2023 - January 2024.

SELECT
    vendor, 
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 7 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS July_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 8 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS August_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 9 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS September_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 10 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS October_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 11 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS November_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 12 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS December_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 1 AND EXTRACT(YEAR FROM upload_date) = 2024 THEN id ELSE NULL END) AS January_2024
FROM
    dogwood-baton-345622.data_analyst_assignment.product_table
WHERE 
    lowest_sold_value = 0 OR lowest_sold_value IS NULL
GROUP BY 
    vendor;

## The following queries now tells us the distribution of product uploads with respect to their activation status during July 2023 - January 2024.

## 1. This query does this for products with zero revenue generated.

SELECT
    status, 
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 7 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS July_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 8 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS August_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 9 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS September_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 10 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS October_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 11 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS November_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 12 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS December_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 1 AND EXTRACT(YEAR FROM upload_date) = 2024 THEN id ELSE NULL END) AS January_2024
FROM
    dogwood-baton-345622.data_analyst_assignment.product_table
WHERE 
    lowest_sold_value = 0 OR lowest_sold_value IS NULL
GROUP BY 
    status;

## 2. This query does the same for products that generated some revenue.

SELECT
    status, 
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 7 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS July_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 8 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS August_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 9 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS September_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 10 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS October_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 11 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS November_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 12 AND EXTRACT(YEAR FROM upload_date) = 2023 THEN id ELSE NULL END) AS December_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM upload_date) = 1 AND EXTRACT(YEAR FROM upload_date) = 2024 THEN id ELSE NULL END) AS January_2024
FROM
    dogwood-baton-345622.data_analyst_assignment.product_table
WHERE 
    lowest_sold_value <> 0 OR lowest_sold_value IS NOT NULL
GROUP BY 
    status;

## This query focuses on Zendesk tickets to find out what is the distribution of issues in July-Jan 2024.

SELECT
    custom_issue_type,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 7 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS July_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 8 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS August_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 9 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS September_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 10 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS October_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 11 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS November_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 12 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS December_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 1 AND EXTRACT(YEAR FROM created_at) = 2024 THEN custom_order_line_item_id ELSE NULL END) AS January_2024
FROM
    dogwood-baton-345622.data_analyst_assignment.zendesk_ticket
GROUP BY 
    custom_issue_type;

## This query further digs deep into the type of issues.

SELECT
    custom_issue_type,
    custom_issue_type_level_2,
    custom_issue_type_level_3,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 7 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS July_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 8 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS August_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 9 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS September_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 10 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS October_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 11 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS November_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 12 AND EXTRACT(YEAR FROM created_at) = 2023 THEN custom_order_line_item_id ELSE NULL END) AS December_2023,
    COUNT(CASE WHEN EXTRACT(MONTH FROM created_at) = 1 AND EXTRACT(YEAR FROM created_at) = 2024 THEN custom_order_line_item_id ELSE NULL END) AS January_2024
FROM
    dogwood-baton-345622.data_analyst_assignment.zendesk_ticket
GROUP BY 
    custom_issue_type, custom_issue_type_level_2, custom_issue_type_level_3;

## This query finds out the refund amount in July 2023 - Jan 2024.

SELECT
    EXTRACT(YEAR FROM created_at) AS year,
    EXTRACT(MONTH FROM created_at) AS month,
    *
FROM
    dogwood-baton-345622.data_analyst_assignment.zendesk_ticket;
