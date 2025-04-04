SELECT *
FROM factors;

SELECT *
FROM product;


SELECT DISTINCT productid, inventoryquantity
FROM sales
GROUP BY productid, inventoryquantity
ORDER BY salesdate DESC;

/* a) What is the total number of units sold per product SKU? */
SELECT
  productid
 ,SUM(inventoryquantity) AS total_units_sold
FROM sales
GROUP BY productid
ORDER BY total_units_sold DESC;


/* b) Which product category had the highest sales volume last month? */
SELECT
  p.productcategory
 ,SUM(s.inventoryquantity) AS sales_volume
FROM product p
JOIN sales s
  ON p.productid = s.productid
WHERE sales_month = 11
AND sales_year = (SELECT
    MAX(sales_year)
  FROM sales)
GROUP BY p.productcategory
ORDER BY sales_volume DESC
LIMIT 1;

/* c) How does the inflation rate correlate with sales volume? */
SELECT 
    s.sales_year, 
    s.sales_month, 
    TO_CHAR(DATE_TRUNC('month', s.salesdate), 'Month') AS month_name, 
    ROUND(AVG(f.inflationrate), 2) AS monthly_inflationrate, 
    ROUND(SUM(s.inventoryquantity),2) AS monthly_inventoryquantity,
    ROUND(CORR(f.inflationrate, s.inventoryquantity)::NUMERIC, 2) AS correlation_values -- Corrected correlation calculation
FROM factors f
JOIN sales s 
    ON f.salesdate = s.salesdate
GROUP BY s.sales_year, s.sales_month, month_name
ORDER BY s.sales_year DESC, s.sales_month DESC;

---------




SELECT 
    s.sales_year, 
    s.sales_month, 
    
    ROUND(AVG(f.inflationrate), 2) AS avg_inflation, 
    ROUND(SUM(s.inventoryquantity),2) AS sales_volume
    
FROM factors f
JOIN sales s 
    ON f.salesdate = s.salesdate
GROUP BY s.sales_year, s.sales_month
ORDER BY s.sales_year DESC, s.sales_month DESC;

/* d) What is the correlation between the inflation rate and sales quantity for all products combined on a monthly basis over the last year?
solution  to this was covered in c).*/
SELECT 
    s.sales_year, 
    s.sales_month, 
    TO_CHAR(DATE_TRUNC('month', s.salesdate), 'Month') AS month_name, 
    ROUND(AVG(f.inflationrate), 2) AS monthly_inflationrate, 
    ROUND(SUM(s.inventoryquantity),2) AS monthly_inventoryquantity,
    ROUND(CORR(f.inflationrate, s.inventoryquantity)::NUMERIC, 2) AS correlation_value
FROM factors f
JOIN sales s 
    ON f.salesdate = s.salesdate
WHERE s.sales_year = 2022 - 1
GROUP BY s.sales_year, s.sales_month, month_name
ORDER BY s.sales_year DESC, s.sales_month DESC;

/*e) Did promotions significantly impact the sales quantity of products?*/
SELECT  
    p.productcategory,
    SUM(CASE WHEN p.promotions = 'Yes' THEN s.inventoryquantity ELSE 0 END) AS sales_with_promotion,
    SUM(CASE WHEN p.promotions = 'No' THEN s.inventoryquantity ELSE 0 END) AS sales_without_promotion
FROM product p
JOIN sales s 
    ON p.productid = s.productid
GROUP BY p.productcategory
ORDER BY sales_with_promotion DESC;




SELECT p.productcategory, ROUND(AVG(s.inventoryquantity), 2) AS avg_sales_without_promotion, p.promotions
FROM sales s
JOIN product p ON p.productid = s.productid
WHERE p.promotions = 'No'
GROUP BY p.productcategory, p.promotions

UNION ALL

SELECT p.productcategory, ROUND(AVG(s.inventoryquantity),2) AS avg_sales_without_promotion, p.promotions
FROM sales s
JOIN product p ON p.productid = s.productid
WHERE p.promotions = 'Yes'
GROUP BY p.productcategory, p.promotions;


/*f) What is the average sales quantity per product category?*/
SELECT p.productcategory, ROUND(AVG(s.inventoryquantity),2) AS avg_sales_quantity
FROM product p
JOIN sales s
ON p.productid = s.productid
GROUP BY p.productcategory
ORDER BY avg_sales_quantity DESC;

/*g) How does the GDP affect the total sales volume?*/

SELECT s.sales_year, ROUND(SUM(f.gdp),2) AS total_gdp, ROUND(SUM(s.inventoryquantity),2) AS total_sales_volume
FROM factors f
JOIN sales s
ON f.salesdate = s.salesdate
GROUP BY s.sales_year
ORDER BY total_sales_volume DESC;

SELECT
  s.sales_year
 ,ROUND(CORR(f.gdp, s.inventoryquantity)::NUMERIC, 2) AS correlation_value
FROM factors f
JOIN sales s
  ON f.salesdate = s.salesdate
GROUP BY s.sales_year
ORDER BY s.sales_year DESC;

/*h) What are the top 10 best-selling product SKUs?*/
SELECT productid, SUM(inventoryquantity) AS units_sold
FROM sales
GROUP BY productid
ORDER BY units_sold DESC
LIMIT 10;

/*i) How do seasonal factors influence sales quantities for different product categories?*/
SELECT 
    p.productcategory, 
    ROUND(AVG(f.seasonalfactor), 2) AS avg_seasonal_factor, 
    ROUND(SUM(s.inventoryquantity), 2) AS total_sales_quantity,
    ROUND(CORR(f.seasonalfactor, s.inventoryquantity)::NUMERIC, 2) AS correlation_value
FROM factors f
JOIN sales s 
    ON f.salesdate = s.salesdate
JOIN product p
    ON s.productid = p.productid
GROUP BY p.productcategory
ORDER BY correlation_value DESC;


/*j) What is the average sales quantity per product category, and how many products within each category were part of a promotion?*/
SELECT p.productcategory, ROUND(AVG(s.inventoryquantity),2) AS avg_sales_quantity,  COUNT(s.productid) AS product_count
FROM product p
JOIN sales s
ON p.productid = s.productid
WHERE p.promotions = 'Yes'
GROUP BY p.productcategory


