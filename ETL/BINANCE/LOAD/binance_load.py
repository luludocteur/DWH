import os
import sys
from sqlalchemy import create_engine
import pandas as pd
from dotenv import load_dotenv
load_dotenv()
wd = os.getenv('working_directory')
ETL_folder_relative = os.path.dirname(wd)
sys.path.append(ETL_folder_relative)

url = os.getenv('BINANCE_DB_URL')
engine = create_engine(url)

#INSERT TOKENS
tokens = f"{wd}/BINANCE/TRANSFORM/files/tokens.csv"
df_tokens = pd.read_csv(tokens)
df_tokens.to_sql(con=engine, name="TOKENS", if_exists='replace', index=False)

#INSERT TRANSACTIONS
transactions = f"{wd}/BINANCE/TRANSFORM/files/transactions.csv"
df_transactions = pd.read_csv(transactions)
df_transactions.to_sql(con=engine, name="TRANSACTIONS", if_exists='replace', index=False)

#INSERT COINS_DEPOSIT_WITHDRAW
CoinsDepositWithdraw = f"{wd}/BINANCE/TRANSFORM/files/transactions.csv"
df_CoinsDepositWithdraw = pd.read_csv(CoinsDepositWithdraw)
df_CoinsDepositWithdraw.to_sql(con=engine, name="COINS_DEPOSIT_WITHDRAW", if_exists='replace', index=False)

#INSERT COINS_DEPOSIT_WITHDRAW
FiatDepositWithdraw = f"{wd}/BINANCE/TRANSFORM/files/transactions.csv"
df_FiatDepositWithdraw = pd.read_csv(FiatDepositWithdraw)
df_FiatDepositWithdraw.to_sql(con=engine, name="FIAT_DEPOSIT_WITHDRAW", if_exists='replace', index=False)