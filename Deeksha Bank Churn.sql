CREATE DATABASE bank_churn_analysis;
USE bank_churn_analysis;

USE bank_churn_analysis;

SHOW TABLES;

DESCRIBE bank_churn;

USE bank_churn_analysis;

SHOW TABLES;

-- Q1 --
USE bank_churn_analysis;
SELECT
    g.GeographyLocation,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(b.Balance), 2) AS Average_Balance,
    ROUND(SUM(b.Balance), 2) AS Total_Balance
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
JOIN geography g
    ON c.GeographyID = g.GeographyID
GROUP BY g.GeographyLocation
ORDER BY Average_Balance DESC;

-- Q2 --
USE bank_churn_analysis;
SELECT
    CustomerId,
    Surname,
    EstimatedSalary,
    `Bank DOJ`
FROM customerinfo
WHERE STR_TO_DATE(`Bank DOJ`, '%Y-%m-%d') >=
      DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
ORDER BY EstimatedSalary DESC
LIMIT 5;

-- q3 --
USE bank_churn_analysis;
SELECT
    COUNT(*) AS Total_CreditCard_Customers,
    ROUND(AVG(NumOfProducts), 2) AS Average_Number_Of_Products
FROM bank_churn
WHERE HasCrCard = 1;

-- q5 --
USE bank_churn_analysis;
SELECT
    CASE
        WHEN Exited = 1 THEN 'Exited'
        WHEN Exited = 0 THEN 'Retained'
    END AS Customer_Status,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(CreditScore), 2) AS Average_Credit_Score
FROM bank_churn
WHERE Exited IN (0, 1)
GROUP BY Exited
ORDER BY Exited DESC;

-- q6 --
USE bank_churn_analysis;
SELECT
    g.GenderCategory,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(c.EstimatedSalary), 2) AS Average_Estimated_Salary,
    SUM(b.IsActiveMember) AS Active_Customers,
    ROUND(
        SUM(b.IsActiveMember) * 100.0 / COUNT(*), 2
    ) AS Active_Customer_Percentage
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
JOIN gender g
    ON c.GenderID = g.GenderID
GROUP BY g.GenderID, g.GenderCategory
ORDER BY Average_Estimated_Salary DESC;

-- q7 --
USE bank_churn_analysis;
SELECT
    CASE
        WHEN CreditScore < 580 THEN 'Low (<580)'
        WHEN CreditScore < 670 THEN 'Fair (580-669)'
        WHEN CreditScore < 740 THEN 'Good (670-739)'
        WHEN CreditScore < 800 THEN 'Very Good (740-799)'
        ELSE 'Excellent (800+)'
    END AS Credit_Score_Segment,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Exited_Customers,
    ROUND(
        SUM(Exited) * 100.0 / COUNT(*), 2
    ) AS Exit_Rate_Percent
FROM bank_churn
WHERE CreditScore IS NOT NULL
  AND Exited IN (0, 1)
GROUP BY Credit_Score_Segment
ORDER BY Exit_Rate_Percent DESC;

-- q8 --
USE bank_churn_analysis;
SELECT
    g.GeographyLocation,
    COUNT(*) AS Active_Customers_Tenure_Over_5
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
JOIN geography g
    ON c.GeographyID = g.GeographyID
WHERE b.Tenure > 5
  AND b.IsActiveMember = 1
GROUP BY g.GeographyID, g.GeographyLocation
ORDER BY Active_Customers_Tenure_Over_5 DESC;

-- q9 --
USE bank_churn_analysis;
SELECT
    CASE
        WHEN HasCrCard = 1 THEN 'Has Credit Card'
        WHEN HasCrCard = 0 THEN 'No Credit Card'
    END AS Credit_Card_Status,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Exited_Customers,
    ROUND(
        SUM(Exited) * 100.0 / COUNT(*), 2
    ) AS Churn_Rate_Percent
FROM bank_churn
WHERE HasCrCard IN (0, 1)
  AND Exited IN (0, 1)
GROUP BY HasCrCard
ORDER BY Churn_Rate_Percent DESC;

-- q10 --
USE bank_churn_analysis;
SELECT
    NumOfProducts,
    COUNT(*) AS Exited_Customers
FROM bank_churn
WHERE Exited = 1
  AND NumOfProducts IS NOT NULL
GROUP BY NumOfProducts
ORDER BY Exited_Customers DESC
LIMIT 1;

-- q12 --
USE bank_churn_analysis;
SELECT
    NumOfProducts,
    COUNT(*) AS Exited_Customers,
    ROUND(AVG(Balance), 2) AS Average_Balance,
    ROUND(MIN(Balance), 2) AS Minimum_Balance,
    ROUND(MAX(Balance), 2) AS Maximum_Balance
FROM bank_churn
WHERE Exited = 1
  AND NumOfProducts IS NOT NULL
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

-- q15 --
USE bank_churn_analysis;

SELECT
    GeographyLocation,
    GenderCategory,
    Total_Customers,
    Average_Estimated_Salary,
    RANK() OVER (
        ORDER BY Average_Estimated_Salary DESC
    ) AS Salary_Rank
FROM (
    SELECT
        g.GeographyLocation,
        gen.GenderCategory,
        COUNT(*) AS Total_Customers,
        ROUND(AVG(c.EstimatedSalary), 2)
            AS Average_Estimated_Salary
    FROM customerinfo c
    JOIN gender gen
        ON c.GenderID = gen.GenderID
    JOIN geography g
        ON c.GeographyID = g.GeographyID
    GROUP BY
        g.GeographyLocation,
        gen.GenderCategory
) AS SalarySummary
ORDER BY Salary_Rank;

-- q16 --

USE bank_churn_analysis;
SELECT
    CASE
        WHEN c.Age >= 18 AND c.Age < 30 THEN '18-29'
        WHEN c.Age >= 30 AND c.Age < 50 THEN '30-49'
        WHEN c.Age >= 50 THEN '50+'
        ELSE 'Below 18'
    END AS Age_Group,
    COUNT(*) AS Total_Exited_Customers,
    ROUND(AVG(b.Tenure), 2) AS Average_Tenure
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
WHERE b.Exited = 1
GROUP BY Age_Group
HAVING Age_Group <> 'Below 18'
ORDER BY Average_Tenure DESC;

-- q19 --

USE bank_churn_analysis;
SELECT Credit_Score_Segment,
    Churned_Customers,
    RANK() OVER (
        ORDER BY Churned_Customers DESC
    ) AS Churn_Rank
FROM (SELECT
        CASE
            WHEN CreditScore < 580 THEN 'Poor (<580)'
            WHEN CreditScore < 670 THEN 'Fair (580-669)'
            WHEN CreditScore < 740 THEN 'Good (670-739)'
            WHEN CreditScore < 800 THEN 'Very Good (740-799)'
            ELSE 'Excellent (800+)'
        END AS Credit_Score_Segment,
        COUNT(*) AS Churned_Customers
    FROM bank_churn
    WHERE Exited = 1
    GROUP BY Credit_Score_Segment
) AS ChurnSummary
ORDER BY Churn_Rank;

-- q20 --

USE bank_churn_analysis;
WITH AgeGroupCounts AS (
    SELECT
        CASE
            WHEN c.Age >= 18 AND c.Age < 30 THEN '18-29'
            WHEN c.Age >= 30 AND c.Age < 50 THEN '30-49'
            WHEN c.Age >= 50 THEN '50+'
            ELSE 'Below 18'
        END AS Age_Group,
        COUNT(*) AS Credit_Card_Holders
    FROM bank_churn b
    JOIN customerinfo c
        ON b.CustomerId = c.CustomerId
    WHERE b.HasCrCard = 1
    GROUP BY Age_Group ),
AgeGroupComparison AS (
    SELECT
        Age_Group,
        Credit_Card_Holders,
        ROUND(AVG(Credit_Card_Holders) OVER (), 2)
            AS Average_Holders_Per_Age_Group
    FROM AgeGroupCounts
    WHERE Age_Group <> 'Below 18' )
SELECT
    Age_Group,
    Credit_Card_Holders,
    Average_Holders_Per_Age_Group,
    CASE
        WHEN Credit_Card_Holders < Average_Holders_Per_Age_Group
            THEN 'Below Average'
        ELSE 'Average or Above Average'
    END AS Comparison
FROM AgeGroupComparison
ORDER BY Credit_Card_Holders DESC;

-- q21 --

USE bank_churn_analysis;
SELECT
    GeographyLocation,
    Churned_Customers,
    Average_Balance,
    RANK() OVER (
        ORDER BY Churned_Customers DESC
    ) AS Churn_Rank
FROM ( SELECT
        g.GeographyLocation,
        COUNT(*) AS Churned_Customers,
        ROUND(AVG(b.Balance), 2) AS Average_Balance
    FROM bank_churn b
    JOIN customerinfo c
        ON b.CustomerId = c.CustomerId
    JOIN geography g
        ON c.GeographyID = g.GeographyID
    WHERE b.Exited = 1
    GROUP BY g.GeographyLocation
) AS LocationSummary
ORDER BY Churn_Rank;

-- q22 --

USE bank_churn_analysis;
SELECT
    CustomerId,
    Surname,
    CONCAT(CustomerId, '_', Surname) AS CustomerID_Surname
FROM customerinfo;

-- q23 --

USE bank_churn_analysis;

ALTER TABLE bank_churn
ADD COLUMN ExitCategory TEXT;

UPDATE bank_churn
SET ExitCategory = (
    SELECT ExitCategory
    FROM exitcustomer
    LIMIT 1
)
WHERE Exited = 1;

-- 25 --

USE bank_churn_analysis;
SELECT
    c.CustomerId,
    c.Surname,
    (
        SELECT b.IsActiveMember
        FROM bank_churn b
        WHERE b.CustomerId = c.CustomerId
    ) AS IsActiveMember
FROM customerinfo c
WHERE c.Surname LIKE '%on';

-- subjectie --
-- q1 --

USE bank_churn_analysis;

SELECT
    CASE
        WHEN Tenure <= 2 THEN 'New Customers'
        ELSE 'Long-Term Customers'
    END AS Customer_Group,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(Balance), 2) AS Average_Balance,
    ROUND(AVG(NumOfProducts), 2) AS Average_Products,
    ROUND(
        AVG(IsActiveMember) * 100, 2
    ) AS Active_Customer_Percentage
FROM bank_churn
GROUP BY Customer_Group
ORDER BY Customer_Group;

-- q2 --
USE bank_churn_analysis;
SELECT
    NumOfProducts,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)
        AS Churned_Customers,
    ROUND(
        100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS Churn_Rate_Percentage
FROM bank_churn
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

-- q3 --

USE bank_churn_analysis;
SELECT
    g.GeographyLocation,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN b.IsActiveMember = 1
        THEN 1 ELSE 0 END) AS Active_Customers,
    ROUND(
        100.0 * SUM(CASE WHEN b.IsActiveMember = 1
            THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS Active_Rate_Percentage,
    SUM(CASE WHEN b.Exited = 1
        THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(
        100.0 * SUM(CASE WHEN b.Exited = 1
            THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS Churn_Rate_Percentage,
    ROUND(AVG(b.Balance), 2) AS Average_Balance
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
JOIN geography g
    ON c.GeographyID = g.GeographyID
GROUP BY g.GeographyLocation
ORDER BY Churn_Rate_Percentage DESC;

-- q4 --
USE bank_churn_analysis;
SELECT
    g.GeographyLocation,
    CASE
        WHEN c.Age < 30 THEN '18-29'
        WHEN c.Age < 50 THEN '30-49'
        ELSE '50+'
    END AS Age_Group,
    gen.GenderCategory,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END)
        AS Churned_Customers,
    ROUND(
        100.0 * SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS Churn_Rate_Percentage,
    ROUND(AVG(b.Balance), 2) AS Average_Balance
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
JOIN gender gen
    ON c.GenderID = gen.GenderID
JOIN geography g
    ON c.GeographyID = g.GeographyID
GROUP BY
    g.GeographyLocation,
    Age_Group,
    gen.GenderCategory
ORDER BY Churn_Rate_Percentage DESC;

-- q5 --

USE bank_churn_analysis;

SELECT
    g.GeographyLocation,
    CASE
        WHEN c.Age < 30 THEN '18-29'
        WHEN c.Age < 50 THEN '30-49'
        ELSE '50+'
    END AS Age_Group,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(b.Tenure), 2) AS Average_Tenure,
    ROUND(AVG(b.Balance), 2) AS Average_Balance,
    ROUND(AVG(b.NumOfProducts), 2) AS Average_Products,
    ROUND(
        100.0 * SUM(CASE WHEN b.Exited = 1
            THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS Churn_Rate_Percentage
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
JOIN geography g
    ON c.GeographyID = g.GeographyID
GROUP BY
    g.GeographyLocation,
    Age_Group
ORDER BY
    g.GeographyLocation,
    Age_Group;
    
    -- q6 --

USE bank_churn_analysis;

SELECT
    DATE_FORMAT(
        STR_TO_DATE(c.`Bank DOJ`, '%d-%m-%Y'),
        '%Y-%m'
    ) AS Joining_Month,
    COUNT(*) AS New_Customers,
    SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END)
        AS Churned_Customers,
    ROUND(
        100.0 * SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS Churn_Rate_Percentage
FROM customerinfo c
JOIN bank_churn b
    ON c.CustomerId = b.CustomerId
WHERE c.`Bank DOJ` IS NOT NULL
  AND STR_TO_DATE(c.`Bank DOJ`, '%d-%m-%Y') IS NOT NULL
GROUP BY Joining_Month
ORDER BY Joining_Month;

-- q7 --

USE bank_churn_analysis;
SELECT
    b.Exited,
    CASE
        WHEN c.Age < 30 THEN '18-29'
        WHEN c.Age < 50 THEN '30-49'
        ELSE '50+'
    END AS Age_Group,
    gen.GenderCategory,
    g.GeographyLocation,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(b.CreditScore), 2) AS Average_Credit_Score,
    ROUND(AVG(b.Balance), 2) AS Average_Balance,
    ROUND(AVG(b.Tenure), 2) AS Average_Tenure,
    ROUND(AVG(b.NumOfProducts), 2) AS Average_Products
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
JOIN gender gen
    ON c.GenderID = gen.GenderID
JOIN geography g
    ON c.GeographyID = g.GeographyID
GROUP BY
    b.Exited,
    Age_Group,
    gen.GenderCategory,
    g.GeographyLocation
ORDER BY
    b.Exited DESC,
    Total_Customers DESC;

-- q8 --

USE bank_churn_analysis;
SELECT
    Exited,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(Tenure), 2) AS Average_Tenure,
    ROUND(AVG(NumOfProducts), 2) AS Average_Products,
    ROUND(AVG(IsActiveMember) * 100, 2)
        AS Active_Member_Percentage,
    ROUND(AVG(c.EstimatedSalary), 2)
        AS Average_Estimated_Salary
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
GROUP BY Exited
ORDER BY Exited;

-- q9 --

USE bank_churn_analysis;

SELECT
    CASE
        WHEN c.Age < 30 THEN '18-29'
        WHEN c.Age < 50 THEN '30-49'
        ELSE '50+'
    END AS Age_Group,
    gen.GenderCategory,
    g.GeographyLocation,
    b.IsActiveMember,
    b.Exited,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(b.Balance), 2) AS Average_Balance,
    ROUND(AVG(b.NumOfProducts), 2) AS Average_Products
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
JOIN gender gen
    ON c.GenderID = gen.GenderID
JOIN geography g
    ON c.GeographyID = g.GeographyID
GROUP BY
    Age_Group,
    gen.GenderCategory,
    g.GeographyLocation,
    b.IsActiveMember,
    b.Exited
ORDER BY Total_Customers DESC;

-- q10 --
USE bank_churn_analysis;

SELECT
    HasCrCard,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)
        AS Churned_Customers,
    ROUND(
        100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS Churn_Rate_Percentage
FROM bank_churn
GROUP BY HasCrCard
ORDER BY HasCrCard;

-- q11 --
USE bank_churn_analysis;

SELECT
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)
        AS Exited_Customers,
    ROUND(AVG(Exited) * 100, 2)
        AS Overall_Churn_Rate_Percentage
FROM bank_churn;
--
SELECT
    YEAR(STR_TO_DATE(c.`Bank DOJ`, '%d-%m-%Y'))
        AS Joining_Year,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END)
        AS Exited_Customers,
    ROUND(AVG(b.Exited) * 100, 2)
        AS Churn_Rate_Percentage
FROM customerinfo c
JOIN bank_churn b
    ON c.CustomerId = b.CustomerId
WHERE STR_TO_DATE(c.`Bank DOJ`, '%d-%m-%Y') IS NOT NULL
GROUP BY Joining_Year
ORDER BY Joining_Year;

-- q14 --
USE bank_churn_analysis;

ALTER TABLE bank_churn
RENAME COLUMN HasCrCard TO Has_creditcard;

describe bank_churn;

