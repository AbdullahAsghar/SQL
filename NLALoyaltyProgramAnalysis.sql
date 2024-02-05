--Dataset taken from: Maven Analytics.
--Dataset Link: https://mavenanalytics.io/data-playground?dataStructure=2lXwWbWANQgI727tVx3DRC
--Analysis Areas: 

--Case Study Questions:

--1. What impact did the campaign have on loyalty program memberships?

--Solution 1: This query segregates all enrollments based on their type i.e. standard or promotional, and gives a count of all of them.
			--Results show that enrollments during Feb - Apr 2018 increased due to promotional campaign.

SELECT
    enrollment_year,
    enrollment_month,
    SUM(CASE WHEN enrollment_type = 'Standard' THEN 1 ELSE 0 END) AS standard_enrollments,
    SUM(CASE WHEN enrollment_type = '2018 Promotion' THEN 1 ELSE 0 END) AS promotion_enrollments
FROM
    loyaltyhistory
GROUP BY
    enrollment_year, enrollment_month
ORDER BY
    enrollment_year ASC, enrollment_month ASC;

--Solution 2: ChatGPT's assistance taken. A CTE first calculates the quarter-wise enrollments, and the resuts are then further linked to the main query using LAG function to find out QoQ %age change between the enrollments.
			--Results show that a 35% uptake in enrollments was observed during the campaign months.

WITH K AS (
    SELECT
        enrollment_year AS Year,
        enrollment_month AS Month,
        (MONTH(DateFromParts(enrollment_year, enrollment_month, 1)) + 2) / 3 AS Quarter,
        COUNT(loyalty_number) AS Enrollments
    FROM
        loyaltyhistory
    GROUP BY
        enrollment_year, enrollment_month
)

SELECT
    k.year AS year,
    k.quarter AS quarter,
    SUM(k.enrollments) AS enrollments,
	ROUND (100 * (SUM(k.enrollments) - LAG(SUM(k.enrollments)) OVER (ORDER BY k.year, k.quarter)) / LAG(SUM(k.enrollments)) OVER (ORDER BY k.year, k.quarter) , 2) AS percentage_change
FROM
   k
GROUP BY
    k.quarter, k.year
ORDER BY
    k.year, k.quarter;

--2. Was the campaign adoption more successful for certain demographics of loyalty members?

--GENDER-WISE ANALYSIS.
--Solution: I first analyzed all enrollments gender-wise, and calculated the %age split MoM. Even with campaign, there wasn't any significant impact on enrollments gender-wise, with a constant average 50%-50% split in enrollments between male and female.
		  --This means that for every 100 enrollments each month, 50 males and 50 females signed up for membership.

SELECT
    enrollment_year AS Year,
    enrollment_month AS Month,
	COUNT(loyalty_number) AS Total_Ennrollments,
    100 * SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS Male_Enrollments_Percentage,
	100 * SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS Female_Enrollments_Percentage
FROM
    loyaltyhistory
GROUP BY
    enrollment_year, enrollment_month
ORDER BY
	Year ASC, Month ASC

--EDUCATION-WISE ANALYSIS.
--Solution: Basic query structure, with a MoM %age split of all enrollments education-level wise.
		  --Even with campaign, there wasn't any significant impact on enrollments if data is observed educational demographic wise. Similar %age contribution across all months.

SELECT
    enrollment_year AS Year,
    enrollment_month AS Month,
	COUNT(loyalty_number) AS Total_Ennrollments,
    100 * SUM(CASE WHEN Education = 'High School or Below' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS High_School_or_below,
	100 * SUM(CASE WHEN Education = 'College' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS College,
	100 * SUM(CASE WHEN Education = 'Bachelor' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS Bachelor,
	100 * SUM(CASE WHEN Education = 'Master' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS Master,
	100 * SUM(CASE WHEN Education = 'Doctor' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS Doctor
FROM
    loyaltyhistory
WHERE
	enrollment_year IN (2017, 2018)
GROUP BY
    enrollment_year, enrollment_month
ORDER BY
	Year ASC, Month ASC

--SALARY-WISE.
--Solution: Selected the data for only 2017-18 to simplify analysis. Removing the ~26% records with salaries as NULL. However, the campaign didn't have any significant impact on enrollments when we see the members with respect to the demographic of salary.

WITH k AS
(
    SELECT
        loyalty_number,
        enrollment_year,
        enrollment_month,
        salary,
        CASE
            WHEN salary IS NULL THEN 'Not Mentioned'
            WHEN salary <= 100000 THEN '< 100K'
            WHEN salary > 100000 AND salary <= 200000 THEN '100K - 200K'
            WHEN salary > 200000 AND salary <= 300000 THEN '200K - 300K'
            WHEN salary > 300000 AND salary <= 400000 THEN '300K - 400K'
            WHEN salary >= 400000 THEN '> 400K'
            ELSE 'Very High'
        END AS sb
    FROM
        loyaltyhistory
)
SELECT
    k.enrollment_year,
    k.enrollment_month,
    100.0 * SUM(CASE WHEN k.sb = 'Not Mentioned' THEN 1 ELSE 0 END) / COUNT(loyalty_number) AS 'not_mentioned',
    100.0 * SUM(CASE WHEN k.sb = '< 100K' THEN 1 ELSE 0 END) / COUNT(loyalty_number) AS 'lt_100k',
    100.0 * SUM(CASE WHEN k.sb = '100K - 200K' THEN 1 ELSE 0 END) / COUNT(loyalty_number) AS '100k_200k',
    100.0 * SUM(CASE WHEN k.sb = '200K - 300K' THEN 1 ELSE 0 END) / COUNT(loyalty_number) AS '200k_300k',
    100.0 * SUM(CASE WHEN k.sb = '300K - 400K' THEN 1 ELSE 0 END) / COUNT(loyalty_number) AS '300k_400k',
    100.0 * SUM(CASE WHEN k.sb = '> 400K' THEN 1 ELSE 0 END) / COUNT(loyalty_number) AS 'gt_400k'
FROM
    k
WHERE
    k.enrollment_year IN (2017, 2018)
GROUP BY
    k.enrollment_month, k.enrollment_year
ORDER BY
    k.enrollment_year ASC, k.enrollment_month ASC;

--MARITAL STATUS-WISE.
--Solution: No significant impact seen as such in enrollments in campaign months.

SELECT
    enrollment_year AS Year,
    enrollment_month AS Month,
	COUNT(loyalty_number) AS Total_Ennrollments,
    100. * SUM(CASE WHEN Marital_Status = 'Single' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS Single_Enrollments,
	100. * SUM(CASE WHEN Marital_Status = 'Married' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS Married_Enrollments,
	100. * SUM(CASE WHEN Marital_Status = 'Divorced' THEN 1 ELSE 0 END) / COUNT (loyalty_number) AS Divorced_Enrollments
FROM
    loyaltyhistory
WHERE
	enrollment_year IN (2017, 2018)
GROUP BY
    enrollment_year, enrollment_month
ORDER BY
	Year ASC, Month ASC

--3. What impact did the campaign have on booked flights during summer?

--FLIGHTS BOOKED DURING CAMPAIGN MONTHS.
--Solution: A basic query with RANK function gave me the total flights booked each month in 2017-18 ranked, and from there, it is clearly visible that the flights booked by the members were at an all-time high during summer (June - August).

SELECT
	Year,
	Month,
	SUM (Total_Flights) as Total_Flights_Booked,
	RANK () OVER (ORDER BY SUM (Total_Flights) DESC) AS Rank
FROM
	flightactivity
GROUP BY
	Month, Year;

--BOOKED FLIGHTS BY THE CAMPAIGN ENROLLED MEMBERS.
--Solution: Created a CTE first to get the enrollment type of all members against their flight activity. From their, I obtained the contribution of standard and promotional enrollments in total flights booked during 2018,
		  --where it is clearly visible that enrollments through promotion contributed to an average, 22% of flights booked during Jun-Aug.

WITH k AS 
(
    SELECT
        a.loyalty_number,
        a.year,
        a.month,
        a.total_flights,
        b.enrollment_type
    FROM
        flightactivity AS a
    JOIN
        loyaltyhistory AS b
    ON
        a.loyalty_number = b.loyalty_number
)

SELECT
    k.year,
    k.month,
    SUM(k.total_flights) AS total_flights,
    SUM(CASE WHEN k.enrollment_type = 'Standard' THEN k.total_flights ELSE 0 END) AS standard_enrollments,
    SUM(CASE WHEN k.enrollment_type = '2018 Promotion' THEN k.total_flights ELSE 0 END) AS promotion_enrollments,
	NULLIF(100 * SUM(CASE WHEN k.enrollment_type = 'Standard' THEN k.total_flights ELSE 0 END) / SUM(k.total_flights), 0) AS standard_contribution,
	NULLIF(100 * SUM(CASE WHEN k.enrollment_type = '2018 Promotion' THEN k.total_flights ELSE 0 END) / SUM(k.total_flights),0) AS promotion_contribution
FROM
    k
WHERE
    k.year = 2018
GROUP BY
    k.year,
	k.month
ORDER BY
	k.month ASC;

--Customer Flight Activity:
--a. Find the Loyalty Numbers of customers who redeemed the highest dollar amount worth of points in a specific month and year.
--Solution: First, I created a CTE to rank all dollar amount worth of points redeemed. I used DENSE_RANK function to return consecutive rans in case of same redemption values. After that, I created a main query to obtain only the top 3 ranks along with an additional condition: not to return any rank if the redemption value is '0', since many customers didn't redeem their points.

WITH RankedPoints AS (
  SELECT
    loyalty_number,
    month,
    year,
    dollar_cost_points_redeemed,
    DENSE_RANK() OVER (PARTITION BY loyalty_number ORDER BY dollar_cost_points_redeemed DESC) AS rank
  FROM
    flightactivity
)
SELECT
  loyalty_number,
  month,
  year,
  dollar_cost_points_redeemed,
  rank
FROM
  RankedPoints
WHERE
  rank IN (1, 2, 3) AND dollar_cost_points_redeemed <> 0;
   
--b. Calculate the average distance traveled by customers who have a loyalty card status of 'Aurora'.
--Solution: I first created a CTE to find out the total flights and distance travelled by each customer, and joined it with the other table to extract the card statuses of each customer. After that, I created a main query to find out the average distance flown by each customer, provided that the total flights should not be equal to zero, otherwise it would return NULL in the calculation, along with the condition that the card status should be 'Aurora'. 

WITH x AS
(
    SELECT
        a.loyalty_number,
        SUM(a.total_flights) AS totalflights,
        SUM(a.distance) AS distanceflown,
        b.loyalty_card
    FROM
        flightactivity AS a
    JOIN loyaltyhistory AS b ON a.loyalty_number = b.loyalty_number
    GROUP BY
        a.loyalty_number, b.loyalty_card
)
SELECT
    x.loyalty_number,
    x.loyalty_card,
    x.totalflights,
    x.distanceflown,
    CASE WHEN x.totalflights <> 0 THEN x.distanceflown / x.totalflights ELSE NULL END AS avgdistanceflown
FROM
    x
WHERE
    x.loyalty_card = 'Aurora'
ORDER BY
	x.distanceflown DESC, x.totalflights DESC;

--c. Identify the Loyalty Numbers of customers who booked flights in all months of a given year.
--Solution: Basic query structue, with WHERE condition specifying to select only those customers having flights more than 0, and HAVING condition to select those customers whose records can be found for all months i.e. 12.

SELECT
    loyalty_number,
    year, 
	month
FROM
    flightactivity
WHERE
    total_flights <> 0
GROUP BY
    loyalty_number, year, month
HAVING
    COUNT(DISTINCT month) = 12;

--Customer Loyalty History:
--a. Find the Loyalty Numbers of customers who canceled their membership within the first six months of enrolling.
--Solution: ChatGPT' assistance taken. Basic query structure, with WHERE clause added with first condition segregating data if cancellation and enrollment years are same. The next condition filters data if the cancellation and enrolment years are not same.

SELECT
    loyalty_number,
    enrollment_year,
    enrollment_month,
    cancellation_year,
    cancellation_month
FROM
    loyaltyhistory
WHERE
    (
        cancellation_year = enrollment_year AND
        cancellation_month >= enrollment_month AND
        cancellation_month - enrollment_month <= 6
    ) OR (
        cancellation_year = enrollment_year + 1 AND
        cancellation_month < enrollment_month AND
        12 - enrollment_month + cancellation_month <= 6
    );
	   
--b. Identify the city with the highest average annual income among customers with a 'Master' education level.
--Solution: I first created a CTE to group all average salaries according to education levels and cities, and applied WHERE condition to only call back records with 'Master' as their education. In the main query, I used the TOP operator with ORDER BY to find out the city with highest average salary with 'Master' education.

WITH x AS (
    SELECT
        city,
        AVG(salary) AS avgsalary
    FROM
        loyaltyhistory
    WHERE
        education = 'Master'
    GROUP BY
        education, city
)
SELECT TOP 1
    x.city,
    x.avgsalary
FROM
    x
ORDER BY
    x.avgsalary DESC;

--Combining Data:
--a. Retrieve the Loyalty Numbers and enrollment details of customers who booked flights in a specific year but have not canceled their membership.
--Solution: I first created a CTE to extract the sum of all flights taken by each customer. I joined it with the 'loyaltyhistory' table to find out the enrollment details of each customer, with a WHERE condition filtering data having no cancellation date.

WITH a AS (
    SELECT
        loyalty_number,
        SUM(total_flights) AS totalflights
    FROM
        flightactivity
    GROUP BY
        loyalty_number
)

SELECT
    h.loyalty_number,
    h.enrollment_type,
    h.enrollment_year,
    h.enrollment_month,
    a.totalflights
FROM
    loyaltyhistory AS h
JOIN
    a ON h.loyalty_number = a.loyalty_number
WHERE
    h.cancellation_year IS NULL AND h.cancellation_month IS NULL
ORDER BY
    a.totalflights DESC;

--b. Calculate the total CLV for customers who redeemed points in a specific province.
--Solution: A CTE is created first which groups the sum of redeemed points against each loyalty number. This also gives us those loyalty numbers who never redeemed a single point. A main query is joined with this one, which extracts the total CLV of all of those customers who had atleast 1 point redeemed.
WITH k AS (
    SELECT
        loyalty_number,
        SUM(points_redeemed) AS ptsredeemed
    FROM
        flightactivity
    GROUP BY
        loyalty_number
)

SELECT
    l.province,
    SUM(l.clv) AS total_clv
FROM
    loyaltyhistory AS l
JOIN
    k ON l.loyalty_number = k.loyalty_number
WHERE
	k.ptsredeemed > 0
GROUP BY
    l.province;
	
--c. Find the Loyalty Numbers of customers who booked the highest number of flights in a specific city.
--Solution: A CTE is created first to join the two tables together to get the sum of all flights grouped against each loyalty number and its respective city. Each record is also ranked, partitioned by city. From there, main query fetches only the highest flight bookers in each city.

WITH cte AS (
    SELECT
        a.loyalty_number,
        SUM(a.total_flights) AS totalflights,
        b.city,
        DENSE_RANK() OVER (PARTITION BY b.city ORDER BY SUM(a.total_flights) DESC) AS rank
    FROM
        flightactivity AS a
    JOIN
        loyaltyhistory AS b ON a.loyalty_number = b.loyalty_number
    GROUP BY
        a.loyalty_number, b.city
)

SELECT
    cte.*
FROM
    cte
WHERE
    cte.rank IN (1);

