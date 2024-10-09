import os
import sys
import pandas as pd
import numpy as np
import requests
from datetime import datetime
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
            "ts":str(row['timestamp'])
        }

        response = create_response("data/pricehistorical", args=params)

        if response.status_code==200:
            data = response.json()
            if row['TOKEN'] in data:
                return data.get(row['TOKEN']).get('USD')
            else :
                print(data)
        else:
            print("C'est laa merde")
            return None

    token_per_timestamp = request_distribution("""select 
                                        timestamp,
                                        case 
                                        when tx.id_token is not null then tok.token
                                        else ftok.token
                                        end as TOKEN
                                        from distribution.transaction tx
                                        left join distribution.token tok
                                        on tok.id_token=tx.id_token
                                        left join distribution.token ftok
                                        on ftok.id_token=tx.token_fee;""")
    token_per_timestamp['timestamp'] = np.int64(token_per_timestamp['timestamp'])//10**9
    token_per_timestamp['price'] =  token_per_timestamp.apply(get_price, axis=1)
    token_per_timestamp.to_csv(f'{wd}/DISTRIBUTION/DISTRIBUTION/EXTRACT/file/TokenPricePerTimestamp.csv', index=False)


get_USD_price()






# response = create_response("data/pricehistorical", args={"api_key":crypto_compare_apikey,
#                                                          "fsym":"BTC", 
#                                                          "tsyms":"USD", 
#                                                          "ts":"1728489911"})
# print(response.status_code)
# print(response.json())


