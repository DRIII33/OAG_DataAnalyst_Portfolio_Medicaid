#INSTALL PACKAGES
!pip install pandas datetime

------------------
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Configuration for OAG-relevant data
NUM_RECORDS = 10000
PROJECT_ID = "driiiportfolio"

def generate_medicaid_data():
    np.random.seed(42)
    
    # Generate NPIs (10-digit National Provider Identifiers)
    npis = [f"1{np.random.randint(100000000, 999999999)}" for _ in range(100)]
    
    # Common Medicaid Procedure Codes (CPT)
    proc_codes = ['99213', '99214', '90837', '97110', 'H0004']
    program_types = ['STAR', 'STAR+PLUS', 'CHIP', 'Fee-for-Service']
    
    data = {
        'Claim_ID': range(100001, 100001 + NUM_RECORDS),
        'NPI': [np.random.choice(npis) for _ in range(NUM_RECORDS)],
        'Service_Date': [datetime(2025, 1, 1) + timedelta(days=np.random.randint(0, 360)) for _ in range(NUM_RECORDS)],
        'Procedure_Code': [np.random.choice(proc_codes) for _ in range(NUM_RECORDS)],
        'Program_Type': [np.random.choice(program_types) for _ in range(NUM_RECORDS)],
        'Units_Billed': np.random.randint(1, 15, size=NUM_RECORDS),
        'Amount_Paid': np.random.uniform(50.0, 500.0, size=NUM_RECORDS),
        'Provider_County': [np.random.choice(['Travis', 'Harris', 'Dallas', 'Bexar', 'El Paso']) for _ in range(NUM_RECORDS)]
    }
    
    df = pd.DataFrame(data)
    
    # Inject "Fraudulent" Outliers (The "Business Problem")
    # One provider billing 5x the average units for Procedure 90837
    fraud_mask = (df['NPI'] == npis[0])
    df.loc[fraud_mask, 'Units_Billed'] = df.loc[fraud_mask, 'Units_Billed'] * 5
    df.loc[fraud_mask, 'Amount_Paid'] = df.loc[fraud_mask, 'Amount_Paid'] * 4
    
    return df

if __name__ == "__main__":
    medicaid_df = generate_medicaid_data()
    medicaid_df.to_csv('tx_medicaid_claims_2025.csv', index=False)
    print("Synthetic Medicaid Data Generated Successfully.")
