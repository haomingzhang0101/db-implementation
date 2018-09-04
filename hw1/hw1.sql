DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM master
  WHERE weight > 300 
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM master
  WHERE namefirst LIKE '% %'
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM master
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM master
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT M.namefirst, M.namelast, HOF.playerid, HOF.yearid
  FROM halloffame HOF
  INNER JOIN master M
  ON HOF.playerid = M.playerid
  WHERE HOF.inducted = 'Y'
  ORDER BY HOF.yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT M.namefirst, M.namelast, HOF.playerid, CP.schoolid, HOF.yearid
  FROM halloffame HOF
  INNER JOIN master M ON HOF.playerid = M.playerid
  INNER JOIN collegeplaying CP ON HOF.playerid = CP.playerid
  INNER JOIN schools S ON CP.schoolid = S.schoolid
  WHERE HOF.inducted = 'Y' AND S.schoolstate = 'CA' 
  ORDER BY HOF.yearid DESC, CP.schoolid ASC, HOF.playerid ASC

;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT HOF.playerid, M.namefirst, M.namelast, CP.schoolid
  FROM halloffame HOF 
  INNER JOIN master M ON HOF.playerid = M.playerid
  LEFT JOIN collegeplaying CP ON HOF.playerid = CP.playerid
  WHERE HOF.inducted = 'Y'
  ORDER BY HOF.playerid DESC, CP.schoolid ASC
 
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT B.playerid, M.namefirst, M.namelast, B.yearid, (B.h + B.h2b + 2*B.h3b + 3*B.hr)::float/B.ab AS slg
  FROM batting B
  INNER JOIN master M ON M.playerid = B.playerid
  WHERE B.ab > 50
  ORDER BY slg DESC, B.yearid ASC, B.playerid ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT M.playerid, M.namefirst, M.namelast, T.lslg
  FROM master M
  INNER JOIN (SELECT playerid, SUM(H + H2B + 2*H3B + 3*HR)::float/SUM(AB) AS lslg
              FROM batting
              GROUP BY playerid
              HAVING SUM(AB) > 50
              ORDER BY lslg DESC, playerid ASC
              LIMIT 10)T
  ON M.playerid = T.playerid
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT M.namefirst, M.namelast, T2.lslg2
  FROM master M 
  INNER JOIN (SELECT playerid, SUM(H + H2B + 2*H3B + 3*HR)::float/SUM(AB) AS lslg2
              FROM batting
              GROUP BY playerid
              HAVING SUM(AB) > 50)T2 ON M.playerid = T2.playerid 
  INNER JOIN (SELECT SUM(H + H2B + 2*H3B + 3*HR)::float/SUM(AB) AS lslg1
              FROM batting
              WHERE playerid = 'mayswi01'
              GROUP BY playerid)T1 ON T2.lslg2 > T1.lslg1
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary), STDDEV(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT T2.binid, T2.binid * (T3.max - T3.min)/10 + T3.min,
         (T2.binid + 1) * (T3.max - T3.min)/10 + T3.min, T2.count
  FROM(SELECT 
       CASE WHEN salary = T1.max THEN 9 ELSE FLOOR((salary-T1.min)/T1.interval) END AS binid, COUNT(*) AS count
       FROM salaries, 
       (SELECT min, max, (max-min)/10 AS interval FROM q4i WHERE yearid=2016)T1
       WHERE yearid = 2016
       GROUP BY binid) T2,
       (SELECT max, min FROM q4i WHERE yearid=2016) T3
  ORDER BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT T2.yearid, T2.min - T1.min, T2.max - T1.max, T2.avg - T1.avg 
  FROM q4i T1, q4i T2
  WHERE T2.yearid - T1.yearid = 1
  ORDER BY T2.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT S.playerid, M.namefirst, M.namelast, T.maxsalary, T.yearid
  FROM salaries S
  INNER JOIN (SELECT yearid, MAX(salary) AS maxsalary 
              FROM salaries GROUP BY yearid HAVING yearid=2001 OR yearid=2000) T
  ON T.yearid = S.yearid AND T.maxsalary = S.salary
  INNER JOIN master M ON M.playerid = S.playerid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT ALS.teamid, MAX(S.salary) - MIN(S.salary)
  FROM allstarfull ALS
  INNER JOIN salaries S ON S.playerid = ALS.playerid AND S.yearid = ALS.yearid
  WHERE ALS.yearid = 2016
  GROUP BY ALS.teamid
  ORDER BY ALS.teamid  
;

