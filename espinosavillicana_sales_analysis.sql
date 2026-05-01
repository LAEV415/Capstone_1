-- Assigned to analyze the Florida Sales Territory
-- This Territory includes: (City, StoreId)
-- 'Cape Canaveral',	'719'
-- 'Fort Lauderdale',	'720'
-- 'Jacksonville',  	'721'
-- 'Key West',  		'722'
-- 'Lakeland',  		'723'
-- 'Miami',  			'724'
-- 'Naples',  			'725'
-- 'Orlando',  			'726'
-- 'Sebring',  			'727'
-- 'Tallahassee', 		'728'
-- 'Tampa', 			'729'

USE sample_sales;

-- What is total revenue overall for sales in the assigned territory, plus the start date and end date
-- that tell you what period the data covers?

-- We're able to see the transactions start from the start of 2022 to the end of 2025 (4yr period) with the total revenue overall being 3,930,187.55
SELECT SUM(Sale_Amount) TotalRevenue, min(Transaction_Date) StartDate, max(Transaction_Date) EndDate
FROM store_sales
WHERE Store_ID BETWEEN 719 AND 729;

-- What is the month by month revenue breakdown for the sales territory?

SELECT SUM(Sale_Amount) TotalRevenue, DATE_FORMAT(Transaction_Date, '%Y-%m') AS YearMonth
FROM store_sales
WHERE Store_ID BETWEEN 719 AND 729
GROUP BY YearMonth;

-- Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
 
 -- Florida belongs to the South Region
 -- States in South Region are Texas and South Carolina
 -- We compare Florida to the rest of the region by seeing how much Total Revenue they both bring

WITH RevenueData AS (
    SELECT SUM(
		CASE	-- Sum only the Florida stores 
            WHEN Store_ID BETWEEN 719 AND 729 THEN Sale_Amount 
            ELSE 0 
        END) AS FloridaTotalRevenue, 
        
	SUM(
		CASE	-- Sum only the rest of the South stores
            WHEN Store_ID IN (852, 853) OR (Store_ID BETWEEN 901 AND 911) 
            THEN Sale_Amount 
            ELSE null 
        END) AS SouthTotalRevWithoutFlorida,
        
	DATE_FORMAT(Transaction_Date, '%Y') AS Years
    FROM store_sales
    WHERE Store_ID BETWEEN 719 AND 729	-- Filter for ALL the stores we care about before doing the math
       OR Store_ID IN (852, 853) 
       OR Store_ID BETWEEN 901 AND 911
    GROUP BY Years
)
SELECT FloridaTotalRevenue, SouthTotalRevWithoutFlorida, (FloridaTotalRevenue + SouthTotalRevWithoutFlorida) TotalSouthRevenue, 
	(FloridaTotalRevenue / (FloridaTotalRevenue + SouthTotalRevWithoutFlorida)) FloridaContributionRatio,
    Years
FROM RevenueData;

-- What is the number of transactions per month and average transaction size by product category
-- for the sales territory?
WITH TransactionData AS (
	SELECT Count(id) NumOfTransactions, DATE_FORMAT(Transaction_Date, '%Y-%m') AS YearMonth, avg(Sale_Amount) AvgTransaction, Category
	FROM store_sales ss
	JOIN products p
	JOIN inventory_categories ic
	ON p.Categoryid = ic.Categoryid
	ON ss.Prod_NUm = p.ProdNum
	WHERE Store_ID BETWEEN 719 AND 729
	GROUP BY YearMonth, Category
	ORDER BY YearMonth
)
SELECT YearMonth, Category, Round(AvgTransaction,2) AvgPerTransaction, NumOfTransactions, (
	SELECT SUM(NumOfTransactions)
    FROM TransactionData TDI
    WHERE TDI.YearMonth = TDO.YearMonth
    ) AS OutOfStoreTotalForMonth
FROM TransactionData TDO
ORDER BY YearMonth, NumOfTransactions DESC;

-- Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
-- ranking of online sales performance by state within an online sales territory?

-- With the query below we can see how every store performed in sales per year with their yearly contribution percentage.
-- We include the Territory's All Time Complete Revenue for comparison and have the store's all time contribution ratio
-- to more clearly see which store performed better overall. Store Contribution Ratio per year allows us to diagnose the
-- store's individual performance by analyzing improvement/regressions over years.
WITH StoresData AS (
	SELECT Store_ID, DATE_FORMAT(Transaction_Date, '%Y') Years, Sum(Sale_Amount) TotalStoreRevenue, StoreLocation Location,
        -- Select Subqueries
			(
			SELECT Sum(Sale_Amount)
			FROM store_sales
			WHERE Store_ID BETWEEN 719 AND 729
			) TerritoryAllTimeTotal,
            
            (
            SELECT Sum(Sale_Amount)
            FROM store_sales ssi2
            WHERE ssi2.Store_ID = ssi.Store_ID
            ) AS StoreAllTimeTotal
            
	FROM store_sales ssi
    JOIN store_locations sl
    ON ssi.Store_ID = sl.StoreId
	WHERE Store_ID BETWEEN 719 AND 729
	GROUP BY Store_ID, Years
	ORDER BY Store_ID
)
SELECT Store_ID, Location, Years, TotalStoreRevenue,
	(TotalStoreRevenue / TerritoryAllTimeTotal) StoreContributionRatio,
    TerritoryAllTimeTotal, (StoreAllTimeTotal/TerritoryAllTimeTotal) StoreAllTimeContributionRatio
FROM StoresData;

-- What is your recommendation for where to focus sales attention in the next quarter?

-- Over a 4 year period, We have seen consistent growth in revenue from all stores in our territory.
-- Collectively, these stores have contributed to almost half of our complete South region's revenue.
-- Considering every store improves each following year, we should focus in the next quarter on the
-- store that has contributed the least in all time over the years and that would be store 719 located
-- in Cape Canaveral.

