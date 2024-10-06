import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
load_dotenv()

url = os.getenv('DISTRIBUTION_DB_URL')
wd = os.getenv('working_directory')
engine = create_engine(url, echo=True)


with engine.connect() as conn:

    conn.execute(text("call distribution.insert_token();"))
    conn.execute(text("call distribution.insert_source();"))
    conn.execute(text("call distribution.insert_type();"))
    conn.execute(text("call distribution.insert_transaction();"))
    conn.execute(text("commit;"))

    conn.close()
print(conn.closed)