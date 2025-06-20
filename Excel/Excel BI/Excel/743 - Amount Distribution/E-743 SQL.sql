DROP TABLE IF EXISTS AmountDistribution
GO

CREATE TABLE AmountDistribution (
    Name NVARCHAR(100),
    Months NVARCHAR(50),  -- storing as comma-separated values
    Amount INT
)
GO

INSERT INTO AmountDistribution (Name, Months, Amount) 
	VALUES
		('Carolyn', '1, 3, 10', 90),
		('Aaron', '7', 12),
		('Catherine', '5, 6, 7, 8', 100),
		('Nathan', '2, 9, 12', 24),
		('Donna', '11, 12', 78);
GO

-- Split Months to Rows
WITH A AS ( 
	SELECT 
		[Name],
		[Months] = [Value],
		[Amount] = [Amount] / COUNT(*) OVER(PARTITION BY Name)
	FROM AmountDistribution
	CROSS APPLY (SELECT [value] FROM STRING_SPLIT(REPLACE([Months], ', ', ','), ',')) AS T
),
-- Produce CROSSJOIN of Names and Months
B AS (
	SELECT [Name], [Months]
	FROM (SELECT DISTINCT [Name] FROM A) AS T1
		CROSS JOIN (SELECT [Months] = [Value] FROM GENERATE_SERIES(1, 12)) AS T2
),
-- Join CROSSJOIN and A
C AS (
	SELECT 
		B.[Name], 
		[Amount] = ISNULL(A.[Amount],0),
		[MonthName] = LEFT(DATENAME(MONTH, DATEFROMPARTS(2025, B.[Months], 01)),3)
	FROM B
		LEFT OUTER JOIN A
			ON A.Name = B.Name AND A.Months = B.Months
),
-- Pivot
D AS (
	SELECT * 
	FROM C
	PIVOT (
		SUM([Amount]) FOR [MonthName] IN (Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec)
	) AS PivotTable
),
-- Assign Index to Names in the Original Data
E AS (
	SELECT [Name], Rn = ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) 
	FROM AmountDistribution
),
-- Sort the Names in the Original Order
F AS (
	SELECT D.* 
	FROM D
		INNER JOIN E ON D.Name = E.Name
	ORDER BY E.Rn ASC
	OFFSET 0 ROWS FETCH NEXT 1000 ROWS ONLY
)

SELECT *
FROM F
