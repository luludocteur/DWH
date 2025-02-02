import os
import sys
import pandas as pd
import matplotlib.pyplot as plt
import time
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
load_dotenv()
wd = os.getenv('working_directory')
ETL_folder_relative = os.path.dirname(wd)
sys.path.append(ETL_folder_relative)

distribution_url = os.getenv('DISTRIBUTION_DB_URL')
distribution_engine = create_engine(distribution_url, echo=True)

def request_distribution(request):
    """
    """
    response = pd.read_sql_query(request, con=distribution_engine)
    return response

evol_token = request_distribution("""select 
                                            base.timestamp,
                                            base.token,
                                            sum(amount) over (partition by base.token order by base.timestamp) as cumul
                                            from (
                                            select id_transaction, timestamp, typ.type, sou.source, tok.token as token, amount, usd_price, fee, ftok.token as tokenfee
                                            from distribution.transaction tx
                                            inner join distribution.type typ
                                            on typ.id_type=tx.id_type
                                            left join distribution.token tok
                                            on tok.id_token=tx.id_token
                                            left join distribution.token ftok
                                            on ftok.id_token=tx.token_fee
                                            inner join distribution.source sou
                                            on sou.id_source=tx.id_source
                                            ) as base
                                            order by base.timestamp, base.token;""")



evol_token['timestamp'] = pd.to_datetime(evol_token['timestamp']).dt.date
evol_token = evol_token.loc[evol_token['token']=='AVAX']
evol_token = evol_token.groupby('timestamp').last()
evol_token.reset_index(inplace=True)
evol_token['timestamp'] = pd.to_datetime(evol_token['timestamp'])
evol_token.set_index('timestamp', inplace=True)
print(evol_token.to_string())
evol_token = evol_token.resample('D').ffill()


plt.plot(evol_token.index, evol_token['cumul'])
plt.show()