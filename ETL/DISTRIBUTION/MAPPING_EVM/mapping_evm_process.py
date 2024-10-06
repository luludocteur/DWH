import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
load_dotenv()

url = os.getenv('MAPPING_EVM_DB_URL')
wd = os.getenv('working_directory')
engine = create_engine(url, echo=True)


with engine.connect() as conn:

    conn.execute(text("call mapping_evm.insert_token();"))
    conn.execute(text("call mapping_evm.insert_source();"))
    conn.execute(text("call mapping_evm.insert_type();"))
    conn.execute(text("SET SQL_SAFE_UPDATES = 0;"))
    conn.execute(text("delete from mapping_evm.transactions;"))
    conn.execute(text("SET SQL_SAFE_UPDATES = 1;"))
    conn.execute(text("call mapping_evm.insert_log_transfer();"))
    conn.execute(text("call mapping_evm.INSERT_LOG_MINT();"))
    conn.execute(text("call mapping_evm.INSERT_TRANSACTIONS();"))
    conn.execute(text("commit;"))

    conn.close()
print(conn.closed)