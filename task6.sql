/*1-Observe our dataset*/
/*Check the first 5 rows to make sure it imported well*/
SELECT *
FROM orders
LIMIT 5;
/*2-Checking for missing values*/
SELECT *
FROM orders
WHERE "rowid" IS NULL OR "Order ID" IS NULL OR "Order Date" IS NULL OR "Ship Date" IS NULL OR sales IS NULL;
/*It revealed blank this shows that we have no missing values*/
/*3-Checking for duplicate Row*/
SELECT *
FROM orders
WHERE ("rowid", "order ID", "orderdate", "shipdate", "shipmode", "customerid", "customername", "segment", "country", "city", "postalcode", "region", "productid", "category", "sub-category", "productname", "sales", "quantity", "discount", "profit")
IN (
    SELECT "rowid","order id", "orderdate", "shipdate", "shipmode", "customerid", "customername", "segment", "country", "city", "postalcode", "region", "productid", "category", "sub-category", "productname", "sales", "quantity", "discount", "profit"
    FROM orders
    GROUP BY "rowid", "order id", "orderdate", "shipdate", "shipmode", "customerid", "customername", "segment", "country", "city", "postalcode", "region", "productid", "category", "sub-category", "productname", "sales", "quantity", "discount", "profit" 
    HAVING COUNT(*) > 1
)
ORDER BY "rowid", "order id"
/*The query returns an empty table, showing there are no duplicate rows.*/

/*EXPLORATORY DATA ANALYSIS*/

/*1. What is the total sales revenue for all orders in the dataset?*/\
SELECT ROUND(SUM(sales)) AS Total_sales_revenue 
FROM orders
/*The total revenue for all orders is $2,297,201*/

/*2. What is the total profit for all orders in the dataset?*/
SELECT ROUND(SUM(profit)) AS TotalProfit
FROM orders;
/*The Total profit generated from all orders amounts to $286,397*/

/*3. How many orders are in the dataset?*/
SELECT COUNT("Order ID") AS Total_Orders
FROM orders;
/*There are 9994 orders in this dataset.*/

/*4. What is the average discount applied to orders?*/

SELECT ROUND(AVG(discount),2) AS AverageDiscount
FROM orders;
/*The average discount applied across all orders is $0.16.*/
/*5. Which product category has the most orders?*/

SELECT category, COUNT(*) AS NumberOfOrders
FROM orders
GROUP BY Category
ORDER BY NumberOfOrders DESC
LIMIT 1;
/*The Office Supplies category had the most order.*/
/*6. What is the most profitable product?*/

SELECT "product name", ROUND(SUM(profit)) AS TotalProfit
FROM orders
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
/*The product yielding the highest profit is the Cannon Image Class 2200 Advanced Copier, generating a total profit of $25,200.*/
/*7.  Who are the top 5 customers based on their total spending?*/

SELECT "Customer Name" , SUM(sales) AS TotalSpending
FROM orders
GROUP BY "Customer Name"
ORDER BY TotalSpending DESC
LIMIT 5;
/*The Top five Customers based on their total spending are Sean Miller, Tamara Chand, Raymond Buch, Tom Ashbrook, Adrian Barton*/

/* 8-What is the total sales revenue for each region? */
SELECT region, ROUND(SUM(sales)) AS TotalSalesRevenue
FROM orders
GROUP BY region
ORDER BY TotalSalesRevenue DESC;
/*West: The sales revenue generated from the West region amounts to $725,458.
East: The East region contributed $678,781 in sales revenue.
Central: Sales revenue from the Central region reached $501,240.
South: The South region recorded sales revenue totaling $391,722.*/

/9-*Product Category Ranking: Rank product categories by total sales in descending order using window functions.*/
SELECT category, Round(SUM(sales)) AS TotalSales,
 RANK() OVER (ORDER BY SUM(sales) DESC) AS CategoryRank
FROM orders
GROUP BY category
ORDER BY TotalSales DESC;

/* 10- What is the average discount for each product category?*/

SELECT category,ROUND(AVG(discount), 2) AS AverageDiscount
FROM orders
GROUP BY category;

/*On average, Furniture items exhibit the highest discount rate, averaging at $0.17 per item. Office supplies follow closely, offering 
discounts averaging $0.16 per item.Conversely, technology products showcase the lowest average discount rate, standing at $0.13 per item*/

/*11- Identify customers who have made at least five purchases and calculate their average order value.*/

SELECT "customer name", COUNT(*) AS TotalOrders, ROUND(AVG(sales), 2) AS AverageOrderValue
FROM orders
GROUP BY "Customer Name"
HAVING COUNT(*) >= 5
ORDER BY TotalOrders, AverageOrderValue DESC;

/*We got 778 Customers who have made at least five purchases and Mitch Willingham ranks first with average order value as $1751.29*/


/*Find the top 5 customers who have made the highest total sales in each state, along with the product category they mostly purchased.
 Use a Common Table Expression (CTE) to calculate the total sales for each customer in each state, and then retrieve the top 5 customers
 for each state. Additionally, provide the product category that these top customers predominantly bought in each state.*/
WITH CustomerSales AS (
    SELECT 
        "Customer Name",
        state,
        category,
        SUM(sales) AS Total_Sales,
        RANK() OVER (PARTITION BY state ORDER BY SUM(sales) DESC) AS Sales_Rank
    FROM orders
    GROUP BY "Customer Name", state, category
)
SELECT 
    "Customer Name",
    state,
    category AS Predominant_Product_Category,
    Total_Sales,
    Sales_Rank
FROM CustomerSales
WHERE Sales_Rank <= 5
ORDER BY state, Total_Sales DESC;

