USE SupplyChainCarbonDB;
GO

-- ============================================================
-- SCHEMA SETUP: MEDALLION ARCHITECTURE (Bronze → Silver → Gold)
-- ============================================================
-- Purpose:
--   Establish the three‑layer data architecture commonly used
--   in modern data lakes / warehouses. Each layer serves a
--   distinct role in the data transformation pipeline.
--
--   • Bronze  – Raw, unmodified data as ingested from source
--               systems. Preserves original format for audit
--               and reprocessing.
--   • Silver  – Cleaned, conformed, and deduplicated data.
--               Business‑friendly but still atomic / denormalised.
--   • Gold    – Aggregated, modelled, and optimised for 
--               analytics, reporting, and ML features.
--
-- Execution safety:
--   Each CREATE SCHEMA is wrapped with existence check to
--   avoid errors if this script is re‑run. Dynamic SQL
--   is required because CREATE SCHEMA cannot be parametrised.
-- ============================================================

-- 1. BRONZE SCHEMA : Raw ingestion layer
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO

-- 2. SILVER SCHEMA : Cleaned / conformed layer
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');
GO

-- 3. GOLD SCHEMA : Aggregated / reporting layer
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');

