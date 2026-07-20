USE SupplyChainCarbonDB;
GO

-- ================================================================
-- STEP 1: TRANSFER TABLE TO BRONZE LAYER
-- ================================================================
-- Design decision: Moving the raw table out of 'dbo' into 'bronze'
-- explicitly marks it as source‑adjacent and immutable. Any future
-- reprocessing starts from this exact snapshot.
-- ================================================================

ALTER SCHEMA bronze TRANSFER dbo.SupplyChainGHG;
GO

-- ================================================================
-- STEP 2: BRONZE DATA VALIDATION SUITE
-- ================================================================
-- These checks run immediately after transfer to catch issues
-- before we invest time in Silver‑layer cleansing.
-- ================================================================

-- 2.1 – VISUAL SPOT CHECK
--      Human‑readable preview of the raw data. Always sort by PK
--      for deterministic behaviour.

SELECT TOP (10)
    _2017_NAICS_Code,
    _2017_NAICS_Title,
    GHG,
    Unit,
    Supply_Chain_Emission_Factors_without_Margins,
    Margins_of_Supply_Chain_Emission_Factors,
    Supply_Chain_Emission_Factors_with_Margins,
    Reference_USEEIO_Code
FROM bronze.SupplyChainGHG
ORDER BY _2017_NAICS_Code;
GO