--DROP TABLE IF EXISTS CageAnimalsRaw
--GO

--CREATE TABLE CageAnimalsRaw (
--    Cage VARCHAR(20),
--    AnimalsAndCount NVARCHAR(MAX)
--);


--INSERT INTO CageAnimalsRaw (Cage, AnimalsAndCount) VALUES
--('Cage10', 'Tiger, Lion-2, Elephant-4, Leopard, Panther'),
--('Cage2', 'Cheetah, Wolf-8'),
--('Cage3', 'Jaguar-2'),
--('Cage12', 'Monkey-3, Giraffe-6, Deer-4'),
--('Cage934', 'Zebra-12, Gorilla-8, Chimpanzee-10');


WITH Split AS (
	SELECT A.Cage, T.[Value], Pos = CHARINDEX('-', T.[Value])
	FROM CageAnimalsRaw AS A
	CROSS APPLY (
		SELECT Value 
		FROM STRING_SPLIT(REPLACE(AnimalsAndCount, ', ', ','), ',')
	) AS T
),
B AS (
	SELECT 
		Cage, 
		Animal = IIF(Pos > 0, LEFT([Value], Pos - 1), [Value]),
		[Count] = CONVERT(INT, IIF(Pos > 0, RIGHT([Value], LEN([Value]) - Pos), 1)),
		CageNumber = CONVERT(INT, SUBSTRING(Cage, PATINDEX('%[0-9]%', Cage), LEN(Cage)))
	FROM Split
),
C AS ( 
	SELECT *,
		N = CONVERT(
				NVARCHAR, 
				ROW_NUMBER() OVER(
					PARTITION BY Cage 
					ORDER BY Animal, (SELECT NULL)
				)
			)
	FROM B
)

SELECT 
	[Cage] = [Cage] + '_' + [N], 
	[Animal], 
	[Count]
FROM C
ORDER BY 
	CageNumber ASC, Animal ASC
