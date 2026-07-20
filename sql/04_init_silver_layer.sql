USE SupplyChainCarbonDB;
GO

CREATE OR ALTER VIEW silver.vw_SupplyChainGHG_Clean
AS
SELECT
    _2017_NAICS_Code AS NAICS_Code,
    _2017_NAICS_Title AS Industry,
    GHG,
    Unit,

    Supply_Chain_Emission_Factors_without_Margins
        AS Emission_Without_Margins,

    Margins_of_Supply_Chain_Emission_Factors
        AS Margin_Emission,

    Supply_Chain_Emission_Factors_with_Margins
        AS Emission_With_Margins,

    Reference_USEEIO_Code AS USEEIO_Code

FROM bronze.SupplyChainGHG;
GO

SELECT TOP (10) *
FROM silver.vw_SupplyChainGHG_Clean;