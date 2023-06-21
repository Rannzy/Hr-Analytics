SELECT * FROM Hr_dataset

--No. Of Terminated Employees--

SELECT
count(DateofTermination)
FROM Hr_dataset
WHERE Termd = 1

--No. Of Current Employees--

SELECT
count(*)
FROM Hr_dataset
WHERE Termd = 0

--Terminated Employees by Reason--

SELECT 
TermReason,
count(TermReason) AS Count
FROM Hr_dataset
WHERE Termd = 1
GROUP BY TermReason

--Age Distribution of Current Employees--

ALTER TABLE Hr_dataset
ADD Age INT

UPDATE Hr_dataset
SET Age = DATEDIFF(YEAR, DOB, GETDATE());

SELECT 
    CASE 
        WHEN Age < 40 THEN '30-39'
        WHEN Age >= 40 AND Age <= 49 THEN '40-49'
        WHEN Age >= 50 AND Age <= 59 THEN '50-59'
        WHEN Age >= 60 AND Age <= 69 THEN '60-69'
        WHEN Age >= 70 AND Age <= 79 THEN '70-79'
        ELSE '80+'
    END AS Age_Distribution,
    COUNT(*) AS Age_Count
FROM Hr_dataset
WHERE Termd = 0
GROUP BY 
    CASE 
        WHEN Age < 40 THEN '30-39'
        WHEN Age >= 40 AND Age <= 49 THEN '40-49'
        WHEN Age >= 50 AND Age <= 59 THEN '50-59'
        WHEN Age >= 60 AND Age <= 69 THEN '60-69'
        WHEN Age >= 70 AND Age <= 79 THEN '70-79'
        ELSE '80+'
    END
ORDER BY Age_Distribution;

--Diversity Profile--

SELECT
Department,
RaceDesc,
count(RaceDesc) AS Count
FROM Hr_dataset
WHERE Termd=0
GROUP BY Department,RaceDesc
ORDER BY Count

--Gender by Department--

SELECT 
Department,
Sex,
count(Sex) AS Count
FROM Hr_dataset
WHERE Termd=0
GROUP BY Department, Sex
ORDER BY Department


--RELATIONSHIP BETWEEN RECRUITMENT SOURCES AND EMPLOYEES--

SELECT 
    a.RecruitmentSource AS [Recruitment Source],
    a.[Current Employees],
    b.[Terminated Employees],
    c.[Total Employees]
FROM
(
    SELECT
        RecruitmentSource,
        COUNT(RecruitmentSource) AS [Current Employees]
    FROM Hr_dataset
    WHERE Termd = 0
    GROUP BY RecruitmentSource
) a
INNER JOIN
(
    SELECT
        RecruitmentSource,
        COUNT(RecruitmentSource) AS [Terminated Employees]
    FROM Hr_dataset
    WHERE Termd = 1
    GROUP BY RecruitmentSource
) b ON a.RecruitmentSource = b.RecruitmentSource
INNER JOIN
(
    SELECT
        RecruitmentSource,
        COUNT(RecruitmentSource) AS [Total Employees]
    FROM Hr_dataset
    GROUP BY RecruitmentSource
) c ON a.RecruitmentSource = c.RecruitmentSource
ORDER BY [Total Employees];

--Avg length of employment for terminated employees--

SELECT
AVG(DATEDIFF(YEAR, DateofHire,DateofTermination))
FROM Hr_dataset
WHERE DateofTermination IS NOT NULL

--Length of employment for terminated employees--

SELECT
DATEDIFF(YEAR, DateofHire,DateofTermination) AS [No.of Years],
COUNT(*) AS Count
FROM Hr_dataset
WHERE Termd = 1
GROUP BY DATEDIFF(YEAR, DateofHire,DateofTermination)

--Employee Turnover Rate--

SELECT
Department,
COUNT(*) AS [Total count],
SUM(CASE WHEN Termd = 0 THEN 1 ELSE 0 END) AS [Current Employees],
SUM(CASE WHEN Termd = 1 THEN 1 ELSE 0 END) AS [Terminated Employees],
ROUND((SUM(CASE WHEN Termd = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100, 2) AS [Turnover Rate]
FROM Hr_dataset
GROUP BY Department
ORDER BY [Terminated Employees];

--Relationship between employees,managers and employee satisfaction--

SELECT
DISTINCT ManagerName,
COUNT(*) AS [Employee count],
SUM(EmpSatisfaction) AS [Employee satisfaction]
FROM Hr_dataset
WHERE Termd = 0
GROUP BY ManagerName
ORDER BY [Employee satisfaction] DESC

--Pay Ratio--

SELECT
Department,
Sex,
SUM(Salary) AS Salary
FROM Hr_dataset
WHERE Termd = 0
GROUP BY Department,Sex
ORDER BY Department

--Employee Distribution by state--

SELECT
State,
COUNT(State) AS Count
FROM Hr_dataset
WHERE Termd = 0
GROUP BY State

--Employee count change over time--

SELECT 
Year, 
[Total employees], 
[Terminated employees], 
([Total employees]-[Terminated employees]) AS [Net change],
ROUND((([Total employees] - [Terminated employees]) * 1.0 / [Total employees] * 100), 2) AS [Net change percentage]
FROM (
    SELECT 
        YEAR(DateofHire) AS Year, 
        COUNT(*) AS [Total employees], 
        SUM(CASE WHEN Termd = 1 THEN 1 ELSE 0 END) AS [Terminated employees]
    FROM 
        Hr_dataset
    GROUP BY 
        YEAR(DateofHire)
)a
ORDER BY 
Year ASC;

--Absences and late days by department--

SELECT
Department,
SUM(DaysLateLast30) AS [Late Days],
SUM(Absences) AS [Absences]
FROM Hr_dataset
WHERE Termd = 0
GROUP BY Department

--Marital Status--

SELECT
MaritalDesc,
count(MaritalDesc) AS [Marital status]
FROM Hr_dataset
WHERE Termd = 0
GROUP BY MaritalDesc

--Relationship between department and performance score--

SELECT
Department,
PerformanceScore,
COUNT(PerformanceScore) AS [Performance Score]
FROM Hr_dataset
WHERE Termd = 0
GROUP BY Department, PerformanceScore
ORDER BY Department