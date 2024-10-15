import os
import sys
import pandas as pd
import numpy as np
import requests
import time
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
load_dotenv()
wd = os.getenv('working_directory')
ETL_folder_relative = os.path.dirname(wd)
sys.path.append(ETL_folder_relative)
from ETL.utility import delete_all_files_from_dir

crypto_compare_apikey = os.getenv('crypto_compare_apikey')
distribution_url = os.getenv('DISTRIBUTION_DB_URL')
distribution_engine = create_engine(distribution_url, echo=True)

def create_response(endpoint, args=None):
    """
    https://min-api.cryptocompare.com/data/pricehistorical
    ?fsym=BTC&tsyms=USD&ts=1452680400
    """
    BASE_URL = "https://min-api.cryptocompare.com/"
    URL = BASE_URL + endpoint


    response = requests.get(URL, params=args)
    return response

def request_distribution(request):
    """
    """
    response = pd.read_sql_query(request, con=distribution_engine)
    return response

def get_USD_price():
    """
    """

    def get_price(row):
        """
        """
        params = {
            "api_key":crypto_compare_apikey,
            "fsym":row['TOKEN'], 
            "tsyms":"USD", 
            "ts":str(row['TIMESTAMP'])
        }

        response = create_response("data/pricehistorical", args=params)

        if response.status_code==200:
            data = response.json()
            if row['TOKEN'].upper() in data:
                return data.get(row['TOKEN'].upper()).get('USD')
            else :
                return 0 
        else:
            print("C'est laa merde")
            return None

    token_per_timestamp = request_distribution("""select * from (
                                                select distinct
                                                timestamp as TIMESTAMP,
                                                case 
                                                when tx.id_token is not null then tok.token
                                                else ftok.token
                                                end as TOKEN
                                                from (
                                                select * from mapping_binance.transaction
                                                union
                                                select transaction_id, timestamp, id_type, id_source, id_token, amount, fee, token_fee from mapping_evm.transactions) as tx
                                                left join distribution.token tok
                                                on tok.id_token=tx.id_token
                                                left join distribution.token ftok
                                                on ftok.id_token=tx.token_fee) as base
                                                where (base.timestamp, base.token) not in (select timestamp, token from distribution.usd_price);""")
    
    if not token_per_timestamp.empty:
        token_per_timestamp['TIMESTAMP'] = np.int64(token_per_timestamp['TIMESTAMP'])//10**9
        token_per_timestamp['USD_PRICE'] =  token_per_timestamp.apply(get_price, axis=1)
        token_per_timestamp['TIMESTAMP'] = pd.to_datetime(token_per_timestamp['TIMESTAMP'], unit='s')
        now = int(time.time()*1000)
        os.rename(f'{wd}/DISTRIBUTION/DISTRIBUTION/EXTRACT/files/TokenPricePerTimestamp.csv', f'{wd}/DISTRIBUTION/DISTRIBUTION/EXTRACT/files/TokenPricePerTimestamp_{now}.csv')
        token_per_timestamp.to_csv(f'{wd}/DISTRIBUTION/DISTRIBUTION/EXTRACT/files/TokenPricePerTimestamp.csv', index=False)
    else :
        print('Pas de nouveau prix à requeter')

def main():
    get_USD_price()


main()