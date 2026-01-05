-- Create Schema in Project: driiiportfolio
CREATE OR REPLACE TABLE `driiiportfolio.medicaid_analytics.claims_raw` (
    Claim_ID INT64,
    NPI STRING,
    Service_Date DATE,
    Procedure_Code STRING,
    Program_Type STRING,
    Units_Billed INT64,
    Amount_Paid FLOAT64,
    Provider_County STRING
);

-- Note: Data was manually loaded into BigQuery (note - field title "NPI"
