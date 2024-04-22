-- List the product lines that contain 'Cars'.
SELECT * 
FROM ClassicModels.ProductLines
WHERE productline LIKE '%car%';

-- 5. Report total payments for october 28,2004
SELECT SUM(amount)
FROM ClassicModels.Payments
WHERE paymentdate = '2004-10-28';

-- Report those payments greater than $100,000.
SELECT *
FROM ClassicModels.Payments
WHERE amount >= 100000;

-- List the products in each product line.
SELECT productname, productline 
FROM ClassicModels.Products
ORDER BY productline;

-- How many products in each product line?
SELECT productline,COUNT(productname) AS 'count of products'  
FROM ClassicModels.Products
GROUP BY productline
ORDER BY COUNT(productname);

-- What is the minimum payment received?
SELECT min(amount)
FROM ClassicModels.Payments
;

SELECT * 
FROM ClassicModels.Payments
WHERE amount = (SELECT min(amount)from PAYMENTS)
;

-- List all payments greater than twice the average payment.
SELECT *
FROM ClassicModels.Payments
WHERE amount > 2* (SELECT AVG(amount)
from PAYMENTS);

-- What is the average percentage markup of the MSRP on buyPrice?

select AVG((MSRP-buyPrice)/MSRP)*100 AS 'Average Percentage Markup'
from products;

-- How many distinct products does ClassicModels sell?
SELECT DISTINCT COUNT(productname)
FROM ClassicModels.PRODUCTS;
##OR##
SELECT count(distinct productName) As 'Distinct Product'
from products;

-- Report the name and city of customers who don't have sales representatives?
SELECT customerName,city, SalesRepEmployeeNumber
FROM ClassicModels.Customers
WHERE salesRepEmployeeNumber is NULL;

-- What are the names of executives with VP or Manager in their title? Use the CONCAT function to combine the employee's first name and last name into a single field for reporting.
SELECT *
FROM ClassicModels.Employees;

SELECT CONCAT(`firstname`,' ',`lastname`) AS employee_name, jobtitle
FROM ClassicModels.Employees
WHERE `jobtitle` LIKE '%VP%' 
OR `jobtitle` LIKE '%Manager%';

-- Which orders have a value greater than $5,000?
SELECT * 
FROM ClassicModels.Orderdetails;

SELECT ordernumber, ROUND(SUM(priceEach*quantityOrdered),2) AS order_value
FROM ClassicModels.Orderdetails
GROUP BY ordernumber
HAVING SUM(priceEach*quantityOrdered) > 5000
ORDER BY SUM(priceEach*quantityOrdered)DESC;



