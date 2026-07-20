USE SupplyChainCarbonDB;


GO
/*
===============================================================================
BUSINESS ANALYSIS: SUPPLY CHAIN GHG EMISSIONS
===============================================================================
Objective: Identify high‑emitting industries, understand distribution,
and classify emission levels for targeted reduction strategies.

Data Source: silver.vw_SupplyChainGHG_Clean
- Industry       : NAICS title (e.g., 'Cement Manufacturing')
- Emission_With_Margins : kg CO₂e per 2021 USD (purchaser price)
===============================================================================
*/
-- ============================================================================
-- 1. TOP 10 HIGHEST EMITTERS
-- ============================================================================
SELECT   TOP (10) Industry,
                  Emission_With_Margins
FROM     silver.vw_SupplyChainGHG_Clean
ORDER BY Emission_With_Margins DESC;

-- Insight: These are the sectors with the largest carbon footprint per dollar.
--           Typically heavy industry (cement, mining, waste treatment).
-- ============================================================================
-- 2. TOP 10 LOWEST EMITTERS
-- ============================================================================
SELECT   TOP (10) Industry,
                  Emission_With_Margins
FROM     silver.vw_SupplyChainGHG_Clean
ORDER BY Emission_With_Margins ASC;

-- Insight: These are the most carbon‑efficient industries per dollar.
--           Could be service sectors or highly efficient manufacturing.
-- ============================================================================
-- 3. OVERALL DISTRIBUTION STATISTICS
-- ============================================================================

WITH SummaryStats AS (
    SELECT
        COUNT(*) AS Total_Industries,
        MIN(Emission_With_Margins) AS Min_Emission,
        MAX(Emission_With_Margins) AS Max_Emission,
        AVG(Emission_With_Margins) AS Avg_Emission,
        STDEV(Emission_With_Margins) AS Std_Deviation
    FROM silver.vw_SupplyChainGHG_Clean
),
-- 2. Percentiles (also a single row, using DISTINCT to collapse the window result)
Percentiles AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Emission_With_Margins) OVER () AS Q1,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Emission_With_Margins) OVER () AS Median,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Emission_With_Margins) OVER () AS Q3
    FROM silver.vw_SupplyChainGHG_Clean
)
-- 3. Combine both into one row
SELECT
    s.Total_Industries,
    s.Min_Emission,
    s.Max_Emission,
    s.Avg_Emission,
    s.Std_Deviation,
    p.Q1,
    p.Median,
    p.Q3
FROM SummaryStats s
CROSS JOIN Percentiles p;

-- Insight: The median and quartiles reveal skew. If mean > median, data is right‑skewed
--           (a few extreme emitters pull the average up). That would inform our
--           categorisation thresholds.
-- ============================================================================
-- 4. INDUSTRIES ABOVE AVERAGE (with percentile context)
-- ============================================================================
WITH     AvgEmission
AS       (SELECT AVG(Emission_With_Margins) AS AvgVal
          FROM   silver.vw_SupplyChainGHG_Clean)
SELECT   s.Industry,
         s.Emission_With_Margins,
         ROUND(s.Emission_With_Margins - a.AvgVal, 2) AS Above_Avg_Amount
FROM     silver.vw_SupplyChainGHG_Clean AS s CROSS JOIN AvgEmission AS a
WHERE    s.Emission_With_Margins > a.AvgVal
ORDER BY s.Emission_With_Margins DESC;

-- Added "Above_Avg_Amount" for business context.
-- ============================================================================
-- 5. DYNAMIC EMISSION LEVEL CATEGORISATION (Quartile‑based)
-- ============================================================================
-- Instead of hard‑coded thresholds, we use percentiles to create 4 equal‑sized groups.
-- This adapts to the data and ensures each category has roughly the same number of
-- industries – useful for benchmarking.
WITH     Quartiles
AS       (SELECT Industry,
                 Emission_With_Margins,
                 NTILE(4) OVER (ORDER BY Emission_With_Margins) AS Quartile
          FROM   silver.vw_SupplyChainGHG_Clean)
SELECT   Industry,
         Emission_With_Margins,
         CASE Quartile WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END AS Emission_Level
FROM     Quartiles
ORDER BY Emission_With_Margins DESC;
