import os
import sys
from sqlalchemy import create_engine
import pandas as pd
from dotenv import load_dotenv
load_dotenv()
ETL_folder_relative = os.path.dirname(os.getenv('working_directory'))
sys.path.append(ETL_folder_relative)

url = os.getenv('EVM_DB_URL')
wd = os.getenv('working_directory')
engine = create_engine(url)

#INSERT GAS_METADATA
gas_metadata = f"{wd}/EVM/TRANSFORM/files/gas_metadata.csv"
df_gas_metadata = pd.read_csv(gas_metadata)
df_gas_metadata.to_sql(con=engine, name="GAS_METADATA", if_exists='replace', index=False)

#INSERT TOKENS
tokens = f"{wd}/EVM/TRANSFORM/files/tokens.csv"
df_tokens = pd.read_csv(tokens)
df_tokens.to_sql(con=engine, name="TOKENS", if_exists='replace', index=False)

#INSERT LOGS
logs = f"{wd}/EVM/TRANSFORM/files/logs.csv"
df_logs = pd.read_csv(logs)
df_logs.to_sql(con=engine, name="LOGS", if_exists='replace', index=False)

#INSERT PARAMS ADDRESS
params_address = f"{wd}/EVM/TRANSFORM/files/params_address.csv"
df_params_address = pd.read_csv(params_address)
df_params_address.to_sql(con=engine, name="PARAMS_ADDRESS", if_exists='replace', index=False)

#INSERT PARAMS VALUE
params_value = f"{wd}/EVM/TRANSFORM/files/params_value.csv"
df_params_value = pd.read_csv(params_value)
df_params_value.to_sql(con=engine, name="PARAMS_VALUES", if_exists='replace', index=False)

#INSERT TRANSACTIONS
transactions = f"{wd}/EVM/TRANSFORM/files/transactions.csv"
df_transactions = pd.read_csv(transactions)
df_transactions.to_sql(con=engine, name="TRANSACTIONS", if_exists='replace', index=False)

