/* PROJECT: OAG Medicaid Integrity Analysis
FILE: 03_Analysis_Queries/v_provider_fraud_outliers.sql
AUTHOR: Daniel Rodriguez III
DATE: 1/5/2026
DESCRIPTION: Identifies NPIs with 'Units_Billed' exceeding 3 standard deviations from the mean.
*/
--------------
DATASET: medicaid_analytics
VIEW NAME: v_provider_fraud_outliers
DESCRIPTION: This view identifies NPIs with billing anomalies using Z-Score logic. 
             It serves as the primary data source for the Looker Studio Dashboard.
*/

CREATE OR REPLACE VIEW `driiiportfolio.medicaid_analytics.v_provider_fraud_outliers` AS

WITH PeerBenchmarks AS (
    SELECT 
        Procedure_Code,
        AVG(Units_Billed) AS avg_units_statewide,
        STDDEV(Units_Billed) AS stddev_units_statewide,
        COUNT(Claim_ID) AS total_claims_in_code
    FROM `driiiportfolio.medicaid_analytics.claims_raw`
    GROUP BY Procedure_Code
),

ProviderPerformance AS (
    SELECT 
        NPI,
        Procedure_Code,
        Program_Type,
        Provider_County,
        COUNT(Claim_ID) AS provider_claim_count,
        SUM(Units_Billed) AS total_units_billed,
        AVG(Units_Billed) AS avg_units_per_claim,
        SUM(Amount_Paid) AS total_reimbursement
    FROM `driiiportfolio.medicaid_analytics.claims_raw`
    GROUP BY NPI, Procedure_Code, Program_Type, Provider_County
),

FinalAnalysis AS (
    SELECT 
        p.NPI,
        p.Procedure_Code,
        p.Program_Type,
        p.Provider_County,
        p.provider_claim_count,
        ROUND(p.avg_units_per_claim, 2) AS avg_units,
        ROUND(b.avg_units_statewide, 2) AS peer_avg,
        -- Calculate Z-Score
        ROUND((p.avg_units_per_claim - b.avg_units_statewide) / NULLIF(b.stddev_units_statewide, 0), 2) AS z_score,
        p.total_reimbursement
    FROM ProviderPerformance p
    JOIN PeerBenchmarks b ON p.Procedure_Code = b.Procedure_Code
    WHERE b.total_claims_in_code > 10 
)

SELECT * FROM FinalAnalysis 
WHERE z_score > 2.5; -- Filtering for significant outliers for the dashboard
