import os
from sqlalchemy import create_engine, text
import pandas as pd
from dotenv import load_dotenv
load_dotenv()

url = os.getenv('DISTRIBUTION_DB_URL')
wd = os.getenv('working_directory')
engine = create_engine(url, echo=True)


with engine.connect() as conn:

    # Insert usd_price
    usd_price = f"{wd}/DISTRIBUTION/DISTRIBUTION/EXTRACT/files/TokenPricePerTimestamp.csv"
    df_usd_price = pd.read_csv(usd_price)
    df_usd_price.to_sql(con=conn, name="USD_PRICE", if_exists='append', index=False)

    conn.execute(text("call distribution.insert_token();"))
    conn.execute(text("call distribution.insert_source();"))
    conn.execute(text("call distribution.insert_type();"))
    conn.execute(text("call distribution.insert_transaction();"))
    conn.execute(text("commit;"))

    conn.close()
print(conn.closed)