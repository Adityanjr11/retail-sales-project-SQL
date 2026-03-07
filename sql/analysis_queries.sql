-- Top 10 products by Revenue
Select
Description,
Sum(Revenue) as total_sales
from clean_retail
group by Description
Order by total_sales Desc
limit 5;

-- Revenue by country
Select 
Country,
Sum(Revenue) as Revenue
from clean_retail
group by Country
Order by Revenue Desc;


-- Monthly Revenue Trend
Select
	date_format(InvoiceDate, '%Y-%m') as Month,
    Sum(Revenue) as revenue
    from clean_retail
    Group by month
    order by month;