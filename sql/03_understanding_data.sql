USE SupplyChainCarbonDB;
GO

-- =============================================
-- 1. SAMPLE PREVIEW (Deterministic & Readable)
--    - Avoids '*' for clarity.
--    - Adds ORDER BY to guarantee consistent output.
-- =============================================
SELECT TOP (10)
    2017_NAICS_Code,
    2017_NAICS_Title,
    GHG Unit,
    Supply_Chain_Emission_Factors_without_Margins,
    Supply_Chain_Emission_Factors_with_Margins,
    s.Reference_USEEIO_Code
FROM bronze.SupplyChainGHG s
ORDER BY s._2017_NAICS_Code;  -- ensures your 'top 10' aren't random

-- =============================================
-- 2. ROW COUNT
-- =============================================
SELECT COUNT(*) AS TotalRows
FROM bronze.SupplyChainGHG;

-- =============================================
-- 3. SCHEMA INSPECTION (Fixed SP call)
--    Shows columns, data types, lengths, nullability.
-- =============================================
EXEC sp_help 'bronze.SupplyChainGHG';
GO