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

					-- Viewing all sales info from stores in territory
					-- SELECT *
					-- FROM store_sales
					-- WHERE Store_ID BETWEEN 719 AND 729
					-- ORDER BY Transaction_Date;

-- We're able to see the transactions start from the start of 2022 to the end of 2025 (3yr period) with the total revenue overall being 3,930,187.55
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
 -- Can use a CTE to calc ratio

WITH RevenueData AS (
SELECT SUM(Sale_Amount) FloridaTotalRevenue, (
	SELECT Sum(Sale_Amount)  
    FROM store_sales 
    WHERE Store_ID IN (852, 853) OR (Store_ID BETWEEN 901 AND 911)
    ) AS SouthTotalRevWithoutFlorida
FROM store_sales
WHERE Store_ID BETWEEN 719 AND 729
)
SELECT FloridaTotalRevenue, SouthTotalRevWithoutFlorida, (FloridaTotalRevenue + SouthTotalRevWithoutFlorida) TotalSouthRevenue, 
	(FloridaTotalRevenue / (FloridaTotalRevenue + SouthTotalRevWithoutFlorida)) FloridaContributionRatio
FROM RevenueData;



