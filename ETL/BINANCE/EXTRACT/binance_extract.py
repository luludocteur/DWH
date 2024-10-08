import os
import sys
import pandas as pd
import time
from datetime import datetime
import math
import requests
import json
from dotenv import load_dotenv
load_dotenv()

ETL_folder_relative = os.path.dirname(os.getenv('working_directory'))
sys.path.append(ETL_folder_relative)
from ETL.utility import delete_all_files_from_dir

binance_apikey = os.getenv('binance_apikey')
binance_secret = os.getenv('binance_secret')
now = int(time.time()*1000) #UNIX timestamp milliseconds
wd = os.getenv('working_directory')
account_creation_timestamp = os.getenv('account_creation_timestamp')


def create_signature(args):
    import hmac
    import hashlib

    secret_key = bytes(binance_secret, 'utf-8')
    payload = '&'.join([f'{param}={value}' for param, value in args.items()])
    payload = bytes(payload, 'utf-8')
    digest = hmac.new(secret_key, payload, hashlib.sha256)
    return digest.hexdigest()


def create_response(endpoint, SecurityType, args=None):
    """
    Définit la fonction de vérification
    Construit la réponse API de binance en fonction du SecurityType
    Check si la réponse est valide et la retourne, permet de gérer les différentes réponses
    """

    def check_response(response):
        """
        Fonction qui vérifie le status de la réponse
        """
        if response.status_code == 200:
            return response
        else:
            print(response.status_code)
            print(response.headers)
            
            if response.status_code == 429:
                raise Exception("Erreur 429")
            
            if response.status_code == 400:
                pass
    
    BASE_URL = "https://api.binance.com"
    URL = BASE_URL + endpoint
    headers = {
            'X-MBX-APIKEY' : binance_apikey,
        }

    if SecurityType == 'NONE':
        
        response = requests.get(
            URL,
            params=args
        )
    
    elif SecurityType in ('TRADE', 'USER_DATA', 'MARGIN'):
    
        if args is None:
            args = {}

        timestamp = int(time.time()*1000) #UNIX timestamp milliseconds
        args['timestamp'] = timestamp
        signature = create_signature(args)
        args['signature'] = signature
        response = requests.get(
            URL,
            headers=headers,
            params=args
        )
        
    
    elif SecurityType in ('MARKET_DATA', 'USER_STREAM'):
        pass

    else:
        raise Exception(f'Security Type inconnu:{SecurityType}')
    
    return check_response(response)

def extract_CoinsInformations():
    
    """
    Extrait les informations de tous les coins disponibles au dépot et au retrait.
    Donne les informations sur les différentes chaines disponibles pour chaque token.
    """
    response = create_response('/sapi/v1/capital/config/getall', 'USER_DATA')
    with open(f'{wd}/BINANCE/EXTRACT/raw_files/CoinsInfos.json', 'w') as file:
            json.dump(response.json(), file, indent=3)


def extract_ExchangeInfo():

    """
    Appelle le endpoint "/api/v3/exchangeInfo"
    Stock le fichier de réponse dans raw_files/ExchangeInfo.json
    Retourne le df de l'ensemble des paires disponibles sur BINANCE avec base et quote asset
    """
    response = create_response("/api/v3/exchangeInfo", 'NONE')
    responsejson = response.json()
    with open(f'{wd}/BINANCE/EXTRACT/raw_files/ExchangeInfo.json', 'w') as file:
        json.dump(responsejson, file, indent=3)
    df = pd.DataFrame(responsejson['symbols'])
    df.drop(['permissions', 'orderTypes', 'filters', 'permissionSets', 'defaultSelfTradePreventionMode',
        'allowedSelfTradePreventionModes','isMarginTradingAllowed', 'isSpotTradingAllowed', 'cancelReplaceAllowed',
        'allowTrailingStop', 'quoteOrderQtyMarketAllowed', 'otoAllowed', 'ocoAllowed', 'icebergAllowed',
        'baseCommissionPrecision', 'quoteCommissionPrecision', 'quoteAssetPrecision', 'quotePrecision', 'baseAssetPrecision', 'status'], inplace=True, axis=1)
    
    return df


def extract_myTrades(df):
    """
    Défini un générateur des symbols disponible sur Binance
    Défini une fonction retournant la liste des Trades pour un symbol
    Boucle sur les symbols, check si le df n'est pas vide, save les df non vides et un df concaténé.
    """

    def generator_symbol():
        for symbol in df['symbol'].to_list():
            yield symbol

    def extract_myTrades_for_symbol(symbol):
        response = create_response("/api/v3/myTrades", 'USER_DATA', {'symbol':symbol, 'recvWindow':60000})
        return pd.DataFrame(response.json())

    gen = generator_symbol()
    df_myTrades = pd.DataFrame()

    for symbol in gen:
        
        df = extract_myTrades_for_symbol(symbol)

        if df.shape != (0,0):
            df.index.name = 'index'
            df.to_csv(f'{wd}/BINANCE/EXTRACT/raw_files/myTrades/myTrades_{symbol}.csv', index=True)
            df_myTrades = pd.concat([df_myTrades, df], ignore_index=True)
        else:
            continue

    df_myTrades.reset_index(inplace=True, drop=True)
    df_myTrades.index.name = 'index'
    df_myTrades.to_csv(f'{wd}/BINANCE/EXTRACT/files/myTrades.csv',index=True)
    
    return df_myTrades


def generator_modulo_day(days):
    """
    Générateur d'une liste de couple startTime endTime entrecoupée d'un nombre de jour days
    nb de minisecondes dans un intervalle: ms_interval=int(60*60*24*days*1000)
    nb d'intervalle entre la création du compte et maintenant: nb_interval = (fin-début)/ms_interval
    """
    début = int(account_creation_timestamp)*1000
    fin = now
    ms_interval = int(60*60*24*days*1000)
    nb_interval = math.ceil((fin-début)/ms_interval)
    for i in range(0,nb_interval):
        startTime=début+i*ms_interval
        endTime=startTime+ms_interval
        
        if endTime>fin:
            endTime = fin
        
        yield startTime, endTime


def extract_ConvertHistory():
    """
    Extrait l'ensemble des transactions du Convert depuis la création du compte par tranche de 30 jours
    Si le dataframe n'est pas vide, on save le df de la période et on concatène dans un grand dataframe
    On save le grand dataframe en csv
    """
    gen_date_30 = generator_modulo_day(30)
    df_convert = pd.DataFrame()

    for start, end in gen_date_30:
        response = create_response('/sapi/v1/convert/tradeFlow', 'USER_DATA', {'startTime':start,'endTime':end, 'recvWindow':60000})
        df = pd.DataFrame(response.json())

        if df.shape[0] != 0:
            df.reset_index(inplace=True)
            df_list = pd.json_normalize(df['list'])
            df_list['index'] = df.apply(lambda row: row['index'], axis=1)
            df = pd.merge(df[['index', 'startTime', 'endTime', 'limit', 'moreData']], df_list, on='index', how='inner')
            df.to_csv(f'{wd}/BINANCE/EXTRACT/raw_files/ConvertTrade/ConvertTrade_{start}_{end}.csv', index=True)
            df_convert = pd.concat([df_convert, df], ignore_index=True)

        else:
            continue

    df_convert.reset_index(inplace=True, drop=True)
    df_convert.to_csv(f'{wd}/BINANCE/EXTRACT/files/ConvertTradeHistory.csv', index=False)


def extract_fiat_deposit_withdraw(isWithdraw):
    """
    Extrait l'ensemble des deposit fiat depuis la création du compte
    flag == 0 -> withdraw
    flag == 1 -> deposit
    """
    response = create_response("/sapi/v1/fiat/orders", 'USER_DATA', {'transactionType':isWithdraw, 'beginTime':int(account_creation_timestamp)*1000, 'endTime':now})
    df = pd.DataFrame(response.json())
    df.reset_index(inplace=True)
    df_data = pd.json_normalize(df['data'])
    df_data['index'] = df.apply(lambda row: row['index'], axis=1)
    df = pd.merge(df[['index', 'code', 'message', 'total', 'success']], df_data, on='index', how='inner')
    df.index.name = 'index'
    if isWithdraw == 0:
        df.to_csv(f'{wd}/BINANCE/EXTRACT/raw_files/Fiat/FiatDeposit.csv', index=False)
    elif isWithdraw == 1:
        df.to_csv(f'{wd}/BINANCE/EXTRACT/raw_files/Fiat/FiatWithdraw.csv', index=False)
    else :
        raise Exception("Ni 1 Ni 0")
    
def extract_fiat_payment(isSell):
    """
    """
    gen_date_30 = generator_modulo_day(30)
    df_payment = pd.DataFrame()

    for start, end in gen_date_30:
        response = create_response("/sapi/v1/fiat/payments", 'USER_DATA', {'transactionType':isSell, 'beginTime':start, 'endTime':end})
        reponse_json = response.json()
        if 'data' in reponse_json:
            df = pd.DataFrame(reponse_json['data'])
            df_payment = pd.concat([df_payment, df], ignore_index=True)
    if isSell == 0:
        df_payment.to_csv(f'{wd}/BINANCE/EXTRACT/raw_files/FiatPayment/FiatPaymentBuy.csv', index=False)
    elif isSell == 1:
        df_payment.to_csv(f'{wd}/BINANCE/EXTRACT/raw_files/FiatPayment/FiatPaymentSell.csv', index=False)
    else :
        raise Exception("Ni 1 Ni 0")

    
def extract_coins_deposit_withdraw():
    """
    
    """
    def extract_coins_deposit(startTime, endTime, df_deposit):
        """
        
        """
        response_deposit = create_response("/sapi/v1/capital/deposit/hisrec", 'USER_DATA', {'status': 1, 'startTime' : startTime, 'endTime': endTime})
        response_json = response_deposit.json()
        if response_json != []:
            df = pd.DataFrame(response_json)
            df.index.name = 'index'
            df.to_csv(f'{wd}/BINANCE/EXTRACT/raw_files/CoinDepositWithdraw/coin_deposit_{startTime}_{endTime}.csv', index=True)
            df_deposit = pd.concat([df_deposit, df], ignore_index=True)
            df_deposit.index.name = 'index'

        return df_deposit

    def extract_coins_withdraw(startTime, endTime, df_withdraw):
        """
        
        """
        response_withdraw = create_response("/sapi/v1/capital/withdraw/history", 'USER_DATA', {'status': 6, 'startTime' : startTime, 'endTime': endTime})
        response_json = response_withdraw.json()
        if response_json != []:
            df = pd.DataFrame(response_json)
            df.index.name = 'index'
            df.to_csv(f'{wd}/BINANCE/EXTRACT/raw_files/CoinDepositWithdraw/coin_withdraw_{startTime}_{endTime}.csv', index=True)
            df_withdraw = pd.concat([df_withdraw, df], ignore_index=True)
            df_withdraw.index.name = 'index'

        return df_withdraw
        

    gen_date_90 = generator_modulo_day(90)
    df_deposit = pd.DataFrame()
    df_withdraw = pd.DataFrame()

    for startTime, endTime in gen_date_90:
        df_deposit = extract_coins_deposit(startTime, endTime, df_deposit)
        df_withdraw = extract_coins_withdraw(startTime, endTime, df_withdraw)

    df_deposit.to_csv(f'{wd}/BINANCE/EXTRACT/files/CoinDeposit.csv', index=False)
    df_withdraw.to_csv(f'{wd}/BINANCE/EXTRACT/files/CoinWithdraw.csv', index=False)

    

def main():
    delete_all_files_from_dir(f"{wd}/BINANCE/EXTRACT/raw_files/ConvertTrade/")
    delete_all_files_from_dir(f"{wd}/BINANCE/EXTRACT/raw_files/FiatPayment/")
    delete_all_files_from_dir(f"{wd}/BINANCE/EXTRACT/raw_files/myTrades/")
    delete_all_files_from_dir(f"{wd}/BINANCE/EXTRACT/raw_files/Fiat/")
    delete_all_files_from_dir(f"{wd}/BINANCE/EXTRACT/raw_files/CoinDepositWithdraw/")
    delete_all_files_from_dir(f"{wd}/BINANCE/EXTRACT/raw_files/")
    delete_all_files_from_dir(f"{wd}/BINANCE/EXTRACT/files/")
    df = extract_ExchangeInfo()
    extract_myTrades(df)
    extract_ConvertHistory()
    extract_fiat_deposit_withdraw(0)
    extract_fiat_deposit_withdraw(1)
    extract_CoinsInformations()
    extract_coins_deposit_withdraw()
    extract_fiat_payment(0)
    extract_fiat_payment(1)

main()

def test():
    pass

#test()