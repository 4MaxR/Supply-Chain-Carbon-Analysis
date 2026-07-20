USE SupplyChainCarbonDB;
GO

-- =============================================
-- 1. DUPLICATE NAICS CODES
--    (NAICS should be unique – this catches import errors)
-- =============================================

SELECT
     s.NAICS_Code ,
    COUNT(*) AS DuplicateCount
FROM silver.vw_SupplyChainGHG_Clean s
GROUP BY s.NAICS_Code
HAVING COUNT(*) > 1;
GO

-- =============================================
-- 2. NULL CHECKS ON CRITICAL COLUMNS
--    (Fixes: removed non-existent 'GHG' and 'Unit', 
--     replaced with actual column names)
-- =============================================

SELECT
    SUM(CASE WHEN s.NAICS_Code IS NULL THEN 1 ELSE 0 END) AS TitleNulls,
    SUM(CASE WHEN s.GHG IS NULL THEN 1 ELSE 0 END) AS GHGNulls,
    SUM(CASE WHEN s.Unit IS NULL THEN 1 ELSE 0 END) AS UnitNulls,
    SUM(CASE WHEN s.Emission_Without_Margins IS NULL THEN 1 ELSE 0 END) AS WithoutMarginsNulls,
    SUM(CASE WHEN s.Margin_Emission IS NULL THEN 1 ELSE 0 END) AS MarginNulls,
    SUM(CASE WHEN s.Emission_With_Margins IS NULL THEN 1 ELSE 0 END) AS WithMarginsNulls
FROM silver.vw_SupplyChainGHG_Clean s;
GO

-- =============================================
-- 3. DISTINCT GHG / UNITS
--    (Uses the actual combined column)
-- =============================================

SELECT DISTINCT GHG
FROM silver.vw_SupplyChainGHG_Clean;
GO

SELECT DISTINCT Unit
FROM silver.vw_SupplyChainGHG_Clean;
GO

-- =============================================
-- 4. OUTLIER CHECK: NEGATIVE EMISSION FACTORS
--    (Negative CO₂e per dollar makes no sense)
-- =============================================

SELECT *
FROM silver.vw_SupplyChainGHG_Clean s
WHERE s.Emission_With_Margins < 0 OR s.Emission_Without_Margins < 0;
GO

-- =============================================
-- 5. BASIC STATISTICS + RANGE CHECK
--    (Added STDEV for spread, and margin calculation)
-- =============================================

SELECT
    MIN(s.Emission_With_Margins) AS MinEmission,
    MAX(s.Emission_With_Margins) AS MaxEmission,
    AVG(s.Emission_With_Margins) AS AvgEmission,
    STDEV(s.Emission_With_Margins) AS StdDevEmission
FROM silver.vw_SupplyChainGHG_Clean s;