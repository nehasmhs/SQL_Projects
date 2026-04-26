USE maven_advanced_sql;
-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
SELECT * FROM schools;
SELECT * FROM school_details;

-- 2. In each decade, how many schools were there that produced players?
WITH sc AS (SELECT FLOOR(yearID/10)*10 AS decade,s.schoolID
			FROM schools s
			JOIN school_details sd ON s.schoolID = sd.schoolID)
 
SELECT decade, COUNT(DISTINCT schoolID) AS num_schools
FROM sc
GROUP BY decade 
ORDER BY decade ASC;

-- 3. What are the names of the top 5 schools that produced the most players?

WITH sp AS 
(SELECT schoolID , COUNT(DISTINCT playerID) AS num_players
FROM schools s 
GROUP BY schoolID
ORDER BY num_players DESC
LIMIT 5)

SELECT sp.schoolID,sd.name_full AS school_name,sp.num_players
FROM sp LEFT JOIN school_details sd ON sp.schoolID = sd.schoolID;


-- 4. For each decade, what were the names of the top 3 schools that produced the most players?

WITH sp AS 
(SELECT FLOOR(yearID/10)*10 AS decade,schoolID, COUNT(DISTINCT playerID) AS num_players
FROM schools s 
GROUP BY decade,schoolID
ORDER BY num_players DESC),

	sl AS (SELECT decade , sd.name_full AS school_name,sp.num_players,
		ROW_NUMBER() OVER ( PARTITION BY decade ORDER BY num_players DESC) AS player_rank
		FROM sp LEFT JOIN school_details sd ON sp.schoolID = sd.schoolID
		ORDER BY decade)
        
SELECT decade, school_name, num_players 
FROM sl
WHERE player_rank <=3
ORDER BY decade DESC,num_players DESC;

-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
SELECT * FROM salaries;

-- 2. Return the top 20% of teams in terms of average annual spending
WITH ts AS (SELECT yearID,teamID, SUM(salary) As total_spend
		FROM salaries
		GROUP BY teamID,yearID
		ORDER BY teamID,yearID),

	ans AS (SELECT teamID, AVG(total_spend) AS avg_annual_spend,
		 NTILE(5) OVER (ORDER BY AVG(total_spend) DESC) AS percentile
		FROM ts
		GROUP BY teamID)
        
SELECT teamID,ROUND(avg_annual_spend/1000000,1) AS avg_spend_in_millions
FROM ans
WHERE percentile = 1;

-- 3. For each team, show the cumulative sum of spending over the years
WITH ts AS 	(SELECT yearID,teamID, SUM(salary) As total_spend
		FROM salaries
		GROUP BY teamID,yearID
		ORDER BY teamID,yearID)
        
SELECT teamID,yearID,ROUND(SUM(total_spend) OVER (PARTITION BY teamID ORDER BY yearID)/1000000,1) AS cum_sum_inmillions
FROM ts
GROUP BY teamID,yearID;

-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
WITH ts AS 	(SELECT yearID,teamID, SUM(salary) As total_spend
		FROM salaries
		GROUP BY teamID,yearID
		ORDER BY teamID,yearID),
 sm AS(	SELECT teamID,yearID,SUM(total_spend) OVER (PARTITION BY teamID ORDER BY yearID) AS cum_sum
			FROM ts
			GROUP BY teamID,yearID),
    
	bs AS (SELECT teamID, yearID, cum_sum 
		FROM sm
		WHERE cum_sum > 1000000000),
        
	rn AS(SELECT teamID, yearID, cum_sum, ROW_NUMBER() OVER (PARTITION BY teamID ORDER BY cum_sum) AS rn
		FROM bs)
        
SELECT teamID, yearID, ROUND(cum_sum/1000000000,2) AS cum_sum_inbiilions
FROM rn 
WHERE rn =1;

-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
SELECT * 
FROM players;

SELECT COUNT(DISTINCT playerID) AS total_players
FROM players;

-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.

SELECT nameGiven, CAST(CONCAT(birthYear,'-',birthMonth,'-',birthDay)AS DATE) AS birthday,debut,finalGame,
					timestampdiff(year,CAST(CONCAT(birthYear,'-',birthMonth,'-',birthDay)AS DATE),debut) AS first_game_age,
                    TIMESTAMPDIFF(year,CAST(CONCAT(birthYear,'-',birthMonth,'-',birthDay)AS DATE),finalGame) AS final_game_age,
                    TIMESTAMPDIFF(YEAR,debut,finalGame)AS career_length
FROM players
ORDER BY career_length DESC;

-- 3. What team did each player play on for their starting and ending years?
SELECT nameGiven,
s.yearID AS playing_startingyear,s.teamID AS starting_team,e.yearID AS playing_endingyear,e.teamID AS ending_team
FROM players p 
INNER JOIN salaries s on p.playerID = s.playerID AND YEAR(debut) = s.yearID
INNER JOIN salaries e on p.playerID = e.playerID AND YEAR(finalGame) = e.yearID
ORDER BY nameGiven;

-- 4. How many players started and ended on the same team and also played for over a decade?
with pd AS(	SELECT nameGiven,
		s.yearID AS playing_startingyear,s.teamID AS starting_team,e.yearID AS playing_endingyear,e.teamID AS ending_team
		FROM players p 
		INNER JOIN salaries s on p.playerID = s.playerID AND YEAR(debut) = s.yearID
		INNER JOIN salaries e on p.playerID = e.playerID AND YEAR(finalGame) = e.yearID
		WHERE s.teamID = e.teamID AND (e.yearID - s.yearID) >10)
        
SELECT COUNT(*) AS decade_total_player
FROM pd;


-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table

SELECT * 
FROM players;

-- 2. Which players have the same birthday?

WITH bn AS	(SELECT CAST(CONCAT(birthYear,'-',birthMonth,'-',birthDay) AS DATE) AS birthdate,nameGiven
		FROM players)
        
SELECT birthdate, GROUP_CONCAT(nameGiven SEPARATOR ', ') AS players
FROM bn
WHERE  YEAR(birthdate) BETWEEN 1980 AND 1990
GROUP BY birthdate
ORDER BY birthdate;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
SELECT * FROM players;

SELECT s.teamID , ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END)/COUNT(p.playerID)*100,1) as bats_right,
							         ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END)/COUNT(p.playerID)*100,1) as bats_left,
							         ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END)/COUNT(p.playerID)*100,1) as bats_both
FROM  salaries s
LEFT JOIN players p ON s.playerID = p.playerID
GROUP BY teamID;

-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?

SELECT * FROM players;

WITH de AS(	SELECT AVG(height) AS avg_height, AVG(weight)AS avg_weight, FLOOR(YEAR(debut)/10)*10 AS decade
	FROM players
	WHERE debut IS NOT NULL
	GROUP BY decade)

SELECT decade, avg_height - LAG(avg_height)OVER( ORDER BY decade) AS height_diff,
avg_weight - LAG(avg_weight)OVER( ORDER BY decade) AS weight_diff
FROM de;



