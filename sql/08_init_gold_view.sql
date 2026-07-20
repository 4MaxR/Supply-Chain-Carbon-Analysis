-- 1. EMISSION SUMMARY with percentiles (optional)
CREATE OR ALTER VIEW gold.vw_EmissionSummary
AS
SELECT
    COUNT(*) AS Total_Industries,
    AVG(Emission_With_Margins) AS Avg_Emission,
    MAX(Emission_With_Margins) AS Max_Emission,
    MIN(Emission_With_Margins) AS Min_Emission,
    STDEV(Emission_With_Margins) AS Std_Deviation
FROM silver.vw_SupplyChainGHG_Clean;
GO

-- 2. INDUSTRY RANKING with average difference
CREATE OR ALTER VIEW gold.vw_IndustryRanking
AS
WITH AvgVal AS (
    SELECT AVG(Emission_With_Margins) AS AvgEmission FROM silver.vw_SupplyChainGHG_Clean
)
SELECT
	s.NAICS_Code,
    s.Industry,
    s.Emission_With_Margins,
    ROUND(s.Emission_With_Margins - a.AvgEmission, 4) AS Diff_From_Avg,
    DENSE_RANK() OVER (ORDER BY s.Emission_With_Margins DESC) AS Emission_Rank
FROM silver.vw_SupplyChainGHG_Clean s
CROSS JOIN AvgVal a;
GO

-- 3. CONTRIBUTION (unchanged, but consider materialising)
CREATE OR ALTER VIEW gold.vw_Contribution
AS
SELECT
	NAICS_Code,
    Industry,
    Emission_With_Margins,
    ROUND(Emission_With_Margins * 100.0 / SUM(Emission_With_Margins) OVER (), 2) AS Contribution_Percent
FROM silver.vw_SupplyChainGHG_Clean;
GO

-- 4. CATEGORIES with business labels
CREATE OR ALTER VIEW gold.vw_EmissionCategories
AS

WITH Ranked AS
(
    SELECT
        NAICS_Code,
        Industry,
        Emission_With_Margins,
        NTILE(4) OVER (ORDER BY Emission_With_Margins DESC) AS Quartile_Number
    FROM silver.vw_SupplyChainGHG_Clean
)

SELECT
    NAICS_Code,
    Industry,
    Emission_With_Margins,
    Quartile_Number,
    CASE Quartile_Number
        WHEN 1 THEN 'Very High'
        WHEN 2 THEN 'High'
        WHEN 3 THEN 'Medium'
        WHEN 4 THEN 'Low'
    END AS Emission_Level
FROM Ranked;
GO

