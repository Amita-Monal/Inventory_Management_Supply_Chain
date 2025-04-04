use mahendra;
desc plugs_electronics_hands_on_lab_data;
select * from plugs_electronics_hands_on_lab_data;

# Checks if the Date column contains null values or not
SELECT * FROM plugs_electronics_hands_on_lab_data WHERE Date IS NULL;

# Converting text datatype to date datatype of date column 
ALTER TABLE plugs_electronics_hands_on_lab_data ADD new_date DATE;
set sql_safe_updates =0;
UPDATE plugs_electronics_hands_on_lab_data
SET new_date = DATE(STR_TO_DATE(Date, '%d-%m-%Y %H:%i:%s'))
WHERE Date IS NOT NULL;

# KPI_1 Total Sales(MTD, QTD, YTD)
# MTD
SELECT SUM(Price*Quantity) AS MTD_Sales
FROM plugs_electronics_hands_on_lab_data
WHERE new_date >= DATE_FORMAT(NOW(), '01-%m-%Y')
AND new_date <= NOW();


# QTD
SELECT SUM(Price*Quantity) AS QTD_Sales
FROM plugs_electronics_hands_on_lab_data
WHERE new_date >= MAKEDATE(YEAR(NOW()), 1) + INTERVAL QUARTER(NOW())*3-3 MONTH
AND new_date <= NOW();

# YTD
SELECT SUM(Price*Quantity) AS YTD_Sales
FROM plugs_electronics_hands_on_lab_data
WHERE new_date >= DATE_FORMAT(NOW(), '01-01-%Y')
AND new_date<= NOW();

# KPI_2 Product wise sales
select `Product Family`, sum(Price* quantity) as Total_sales from plugs_electronics_hands_on_lab_data group by `Product Family`;

# KPI_3 Sales growth
select year(new_date), sum(Price* Quantity) as Total_sales from plugs_electronics_hands_on_lab_data group by year(new_date) order by year(new_date);

SELECT  
    YEAR(new_date) AS year,  
    SUM(Price * Quantity) AS total_sales,  
    LAG(SUM(Price * Quantity)) OVER (ORDER BY YEAR(new_date)) AS prev_year_sales,  
    CASE  
        WHEN LAG(SUM(Price * Quantity)) OVER (ORDER BY YEAR(new_date)) IS NOT NULL  
        THEN Concat(round((SUM(Price * Quantity) - LAG(SUM(Price * Quantity)) OVER (ORDER BY YEAR(new_date))) 
             / LAG(SUM(Price * Quantity)) OVER (ORDER BY YEAR(new_date)) * 100, 2), "%") 
        ELSE NULL  
    END AS sales_growth_percentage  
FROM plugs_electronics_hands_on_lab_data  
GROUP BY YEAR(new_date)  
ORDER BY year;

# Kpi_4 Monthly Sales Trend
select DATE_FORMAT(new_date, '%Y-%m') as yearly_month, sum(Price* Quantity) as Total_sales from plugs_electronics_hands_on_lab_data 
group by DATE_FORMAT(new_date, '%Y-%m') order by DATE_FORMAT(new_date, '%Y-%m');

SELECT  
    DATE_FORMAT(new_date, '%Y-%m') AS month,  
    SUM(Price * Quantity) AS total_sales,  
    LAG(SUM(Price * Quantity)) OVER (ORDER BY DATE_FORMAT(new_date, '%Y-%m')) AS prev_month_sales,  
    CASE  
        WHEN LAG(SUM(Price * Quantity)) OVER (ORDER BY DATE_FORMAT(new_date, '%Y-%m')) IS NOT NULL  
        THEN concat(round((SUM(Price * Quantity) - LAG(SUM(Price * Quantity)) OVER (ORDER BY DATE_FORMAT(new_date, '%Y-%m'))) 
             / LAG(SUM(Price * Quantity)) OVER (ORDER BY DATE_FORMAT(new_date, '%Y-%m')) * 100, 2), "%")
        ELSE NULL  
    END AS sales_growth_percentage  
FROM plugs_electronics_hands_on_lab_data  
GROUP BY DATE_FORMAT(new_date, '%Y-%m')  
ORDER BY month;


# kpi_5 State wise sales
select `Store State` as State, sum(Price * Quantity) as Total_sales from plugs_electronics_hands_on_lab_data group by `Store State`;

# kpi_6 Top 5 store wise sales

select `Store Name`, sum(Price * Quantity) as Total_sales from plugs_electronics_hands_on_lab_data group by `Store Name` order by Total_sales desc limit 5;

# kpi_7 region wise sales
select `Store Region` as Region, sum(Price * Quantity) as Total_sales from plugs_electronics_hands_on_lab_data group by `Store Region`;

# kpi_8 Total Inventory
select sum(`quantity on hand`) as Total_inventory from f_inventory_adjusted;
select `Product Group`, `product line`,`product name`,sum(`quantity on hand`) as Quantity_on_hand 
from f_inventory_adjusted group by `Product Group`,`Product Line`,`Product Name`;

# kpi_9  Inventory value
select `Product Group`, `Product Family`, `quantity on hand` * `cost amount`  as Inventory_cost from f_inventory_adjusted;

select * from scm.`f_sales csv`;
select * from scm.`plugs_electronics_hands_on_lab_data csv`;

# Kpi_10 Purchase method wise Sales
SELECT PM.`Purchase Method`, sum(PL.Price * PL.Quantity) as Total_sales
FROM 
f_sales PM 
left join 
plugs_electronics_hands_on_lab_data PL 
on 
PM.`Cust Key` = PL.`Cust Key`
group by 
PM.`Purchase Method`;



