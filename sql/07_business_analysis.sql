USE SupplyChainCarbonDB;
GO

/*
===============================================================================
EMISSION ANALYSIS – RANKING, CONTRIBUTION & SEGMENTATION
===============================================================================
Purpose: Identify top/bottom emitters, quantify their share of total emissions,
         rank all industries, and segment them into quartiles for targeted
         reduction strategies.

Data Source: silver.vw_SupplyChainGHG_Clean
- Industry               : NAICS title
- Emission_With_Margins  : kg CO₂e per 2021 USD (purchaser price)
===============================================================================
*/

-- ============================================================================
-- 1. TOP 10 HIGHEST EMITTERS (Absolute values)
-- ============================================================================
SELECT TOP (10)
    Industry,
    Emission_With_Margins
FROM silver.vw_SupplyChainGHG_Clean
ORDER BY Emission_With_Margins DESC;
-- Insight: These are the sectors with the largest carbon intensity per dollar.
--           Usually heavy manufacturing, mining, and waste disposal.

-- ============================================================================
-- 2. TOP 10 HIGHEST EMITTERS WITH CONTRIBUTION PERCENTAGE
-- ============================================================================
WITH TotalSum AS (
    SELECT SUM(Emission_With_Margins) AS TotalEmission
    FROM silver.vw_SupplyChainGHG_Clean
)
SELECT TOP (10)
    s.Industry,
    s.Emission_With_Margins,
    ROUND(s.Emission_With_Margins * 100.0 / t.TotalEmission, 2) AS Contribution_Percent,
    -- Optional: cumulative contribution for Pareto analysis
    ROUND(
        SUM(s.Emission_With_Margins) OVER (ORDER BY s.Emission_With_Margins DESC)
        * 100.0 / t.TotalEmission,
        2
    ) AS Cumulative_Percent
FROM silver.vw_SupplyChainGHG_Clean s
CROSS JOIN TotalSum t
ORDER BY s.Emission_With_Margins DESC;
-- Insight: Shows what share of total emissions comes from each top emitter.
--           Cumulative percentage highlights how many industries account for, say, 80% of total.

-- ============================================================================
-- 3. DENSE RANK OF EMISSIONS (All industries)
-- ============================================================================
SELECT
    Industry,
    Emission_With_Margins,
    DENSE_RANK() OVER (ORDER BY Emission_With_Margins DESC) AS Emission_Rank
FROM silver.vw_SupplyChainGHG_Clean
ORDER BY Emission_Rank;
-- Note: DENSE_RANK assigns the same rank to ties and does not skip numbers.
--       Use RANK() if you prefer gaps for ties, or ROW_NUMBER() for unique ranking.

-- ============================================================================
-- 4. QUARTILE SEGMENTATION (Top 25% → Bottom 25%)
-- ============================================================================
WITH QuartileData AS (
    SELECT
        Industry,
        Emission_With_Margins,
        NTILE(4) OVER (ORDER BY Emission_With_Margins DESC) AS Quartile_Number
    FROM silver.vw_SupplyChainGHG_Clean
)
SELECT
    Industry,
    Emission_With_Margins,
    Quartile_Number,
    CASE Quartile_Number
        WHEN 1 THEN 'Top 25% (Very High)'
        WHEN 2 THEN 'Upper Middle (High)'
        WHEN 3 THEN 'Lower Middle (Medium)'
        WHEN 4 THEN 'Bottom 25% (Low)'
    END AS Emission_Quartile
FROM QuartileData
ORDER BY Emission_With_Margins DESC;
-- Insight: Quartiles help compare industries within the same relative band.
--           Useful for setting different reduction targets per group.