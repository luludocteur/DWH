import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
load_dotenv()

url = os.getenv('MAPPING_BINANCE_DB_URL')
wd = os.getenv('working_directory')
engine = create_engine(url, echo=True)


with engine.connect() as conn:

    conn.execute(text("call mapping_binance.insert_type();"))
    conn.execute(text("call mapping_binance.insert_source();"))
    conn.execute(text("call mapping_binance.insert_token();"))
    conn.execute(text("SET SQL_SAFE_UPDATES = 0;"))
    conn.execute(text("delete from mapping_binance.transaction;"))
    conn.execute(text("SET SQL_SAFE_UPDATES = 1;"))
    conn.execute(text("call mapping_binance.INSERT_COIN_DEPOSIT_WITHDRAW();"))
    conn.execute(text("call mapping_binance.INSERT_FIAT_DEPOSIT_WITHDRAW();"))
    conn.execute(text("call mapping_binance.INSERT_R_TRANSACTION();"))
    conn.execute(text("call mapping_binance.INSERT_TRANSACTION();"))

    conn.close()
print(conn.closed)