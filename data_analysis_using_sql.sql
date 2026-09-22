CREATE DATABASE orders;
USE orders;

SELECT * FROM order_table;
USE orders;

-- find top 10 highest revenue generating products
SELECT product_id,ROUND(SUM(sale_price),2) as sales
FROM order_table 
GROUP BY product_id
ORDER BY sales DESC LIMIT 10 ;

-- find top 5 highest selling products in each region 
WITH cte AS (
    SELECT 
        region,
        product_id,
        SUM(sale_price) AS sales
    FROM order_table
    GROUP BY region, product_id
)

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY region
               ORDER BY sales DESC
           ) AS rn
    FROM cte
) AS ranked
WHERE rn <= 5;


-- find month over month growrh comparison for 2022 and 2023 sales eg : year 2022 VS ja 2023
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM order_table
    WHERE YEAR(order_date) IN (2022, 2023)
    GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- for each category which month had highest sales 
WITH cte AS (
    SELECT 
        category,
        DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
        ROUND(SUM(sale_price), 2) AS sales
    FROM order_table
    GROUP BY 
        category,
        DATE_FORMAT(order_date, '%Y%m')
)

SELECT *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY sales DESC
        ) AS rn
    FROM cte
) AS highest
WHERE rn = 1;




-- Which sub-category had the highest growth in 2023 compared to 2022?

WITH cte AS (
    SELECT
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM order_table
    GROUP BY sub_category, YEAR(order_date)
)

, cte2 as(SELECT
    sub_category,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category)
SELECT *,(sales_2023-sales_2022)*100/sales_2022 as sales_of_subcategory
FROM cte2
ORDER BY (sales_2023-sales_2022)*100/sales_2022 desc

