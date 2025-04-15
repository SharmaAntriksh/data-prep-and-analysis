-- Solution 1

;WITH DistinctTeams AS ( 
	SELECT Team = Team_1 FROM icc_world_cup
	UNION
	SELECT Team = Team_2 FROM icc_world_cup
),
Result AS ( 
	SELECT Team, 
		MatchesPlayed = (
			SELECT COUNT(*)
			FROM (
				SELECT Team = Team_1 FROM icc_world_cup
				UNION ALL
				SELECT Team = Team_2 FROM icc_world_cup
			) AS A2
			WHERE A1.Team = A2.Team
		),
		Wins = (
			SELECT COUNT(*) 
			FROM icc_world_cup AS A2
			WHERE A2.Winner = A1.Team
		),
		Loss = ( 
			SELECT COUNT(*) 
			FROM icc_world_cup AS A2
			WHERE (A2.Team_1 = A1.Team OR A2.Team_2 = A1.Team) AND A2.Winner <> A1.Team
		)
	FROM DistinctTeams AS A1
)

SELECT * 
FROM Result
ORDER BY MatchesPlayed DESC, Wins DESC


-- Solution 2

;WITH Temp AS (
	SELECT Team_1 AS Team, 
		CASE WHEN Team_1 = Winner THEN 1 ELSE 0 END AS Win,
		CASE WHEN Team_1 <> Winner THEN 1 ELSE 0 END AS Loss
	FROM icc_world_cup
	UNION ALL
	SELECT Team_2 AS Team, 
		CASE WHEN Team_2 = Winner THEN 1 ELSE 0 END AS Win,
		CASE WHEN Team_2 <> Winner THEN 1 ELSE 0 END AS Loss
	FROM icc_world_cup
)

SELECT  Team, 
		COUNT(*) AS MatchesPlayed, 
		SUM(Win) AS Wins, 
		SUM(Loss) AS Losses
FROM Temp 
GROUP BY Team
ORDER BY MatchesPlayed DESC, Wins DESC