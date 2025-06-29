USE TestDB
GO

DROP TABLE IF EXISTS ProjectBudgetActual
GO

CREATE TABLE ProjectBudgetActual (
    Column1 VARCHAR(50),
    Column2 VARCHAR(50),
    Column3 VARCHAR(50),
    Column4 VARCHAR(50),
    Column5 VARCHAR(50),
    Column6 VARCHAR(50)
);

INSERT INTO ProjectBudgetActual
VALUES
	('Factory - A', NULL, 'Q1', 'Q2', 'Q3', 'Q4'),
	('Project 1', 'Budget', '358', '697', '954', '681'),
	(NULL, 'Actual', '989', '126', '877', '686'),
	('Project 2', 'Budget', '906', '572', '328', '101'),
	(NULL, 'Actual', '976', '284', '248', '183'),
	('Factory - B', NULL, NULL, NULL, NULL, NULL),
	('Project 1', 'Budget', '473', '513', '385', '418'),
	(NULL, 'Actual', '450', '357', '952', '249'),
	('Project 2', 'Budget', '790', '689', '135', '840'),
	(NULL, 'Actual', '102', '304', '747', '890'),
	('Project 3', 'Budget', '304', '962', '497', '890'),
	(NULL, 'Actual', '597', '883', '634', '163');
GO


WITH A AS ( 
	SELECT 
		*, 
		Rn = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
	FROM ProjectBudgetActual
),
B AS (
	SELECT *,
		G = SUM(CHARINDEX('Factory', [Column1])) OVER(ORDER BY Rn),
		G2 = SUM(CHARINDEX('Project', [Column1])) OVER(ORDER BY Rn)
	FROM A
),
C AS (
	SELECT *, 
		Factory = FIRST_VALUE(RIGHT([Column1], 1)) OVER(PARTITION BY G ORDER BY Rn),
		Project = FIRST_VALUE([Column1]) OVER(PARTITION BY G, G2 ORDER BY Rn)
	FROM B
),
D AS (
	SELECT 
		Factory, 
		Project, 
		[Type] = Column2, 
		Q1 = Column3, 
		Q2 = Column4, 
		Q3 = Column5, 
		Q4 = Column6
	FROM C
	WHERE CHARINDEX('Factory', Project) = 0
),
E AS (
	SELECT 
		Factory, 
		Project, 
		[Type], 
		Val = CONVERT(INT, Val), 
		[Quarter]
	FROM D
	UNPIVOT(
		Val FOR [Quarter] IN (Q1, Q2, Q3, Q4)
	) AS Unpvt
),
F AS (
	SELECT * 
	FROM E
	PIVOT(
		SUM([Val]) FOR [Type] IN (Budget, Actual)
	) AS Pvt
)

SELECT * 
FROM F