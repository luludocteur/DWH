import os
import sys
import re
import numpy as np
import pandas as pd
from dotenv import load_dotenv
load_dotenv()
ETL_folder_relative = os.path.dirname(os.getenv('working_directory'))
sys.path.append(ETL_folder_relative)
from ETL.utility import get_files_from_directory, delete_all_files_from_dir

wd = os.getenv('working_directory')

def FiatDepositWithdraw():
    """
    Concatène les fichier de deposit et withdraw en fiat
    Ajoute un flag isDeposit pour discriminer les deposit des withdraw
    Save le fichier dans le folder des fichiers finaux
    """
    df_deposit = pd.read_csv(f'{wd}/BINANCE/EXTRACT/raw_files/Fiat/FiatDeposit.csv')
    df_deposit['isDeposit'] = True
    df_deposit['TYPE'] = 'Fiat_Deposit'
    df_withdraw = pd.read_csv(f'{wd}/BINANCE/EXTRACT/raw_files/Fiat/FiatWithdraw.csv')
    df_withdraw['isDeposit'] = False
    df_withdraw['TYPE'] = 'Fiat_Withdraw'

    df_fiat = pd.concat([df_deposit, df_withdraw], ignore_index=True)
    df_fiat['updateTime'] = df_fiat['updateTime'].astype(np.int64)
    df_fiat.drop(['index', 'code', 'message', 'total', 'method', 'status', 'createTime','indicatedAmount'], inplace=True, axis=1)
    df_fiat = df_fiat.reindex(columns=['orderNo', 'updateTime', 'TYPE', 'success', 'fiatCurrency', 'amount','isDeposit', 'totalFee'])
    df_fiat.rename(columns={'orderNo':'ORDER_ID',
                            'updateTime':'TIMESTAMP',
                            'success':'IS_SUCCESS',
                            'fiatCurrency':'FIAT',
                            'amount':'AMOUNT',
                            'isDeposit':'IS_DEPOSIT',
                            'totalFee':'TRANSACTION_FEE'}, inplace=True)
    df_fiat['FIAT'].apply(load_token)
    df_fiat = df_fiat.round({'AMOUNT':3})
    df_fiat.sort_values(by="TIMESTAMP", inplace=True)
    df_fiat['TIMESTAMP'] = pd.to_datetime(df_fiat['TIMESTAMP'], unit="ms")
    df_fiat.to_csv(f'{wd}/BINANCE/TRANSFORM/files/FiatDepositWithdraw.csv', index=False)

def CoinDepositWithdraw():
    """

    """
    def CoinDeposit():
        """
        Drop les colonnes superflues pour permettre la concaténation
        Renomme pour obtenir les mêmes noms de colonnes avec les withdraw
        Ajoute un flag isDeposit pour discriminer les deposit des withdraw
        """

        df_deposit = pd.read_csv(f'{wd}/BINANCE/EXTRACT/files/CoinDeposit.csv')
        df_deposit.drop(['confirmTimes', 'unlockConfirm', 'status', 'transferType', 'walletType', 'addressTag'], axis=1, inplace=True)
        df_deposit.rename(columns={'insertTime':'timestamp'}, inplace=True)
        df_deposit['TYPE'] = 'Coin_Deposit'
        df_deposit['isDeposit'] = True
        return df_deposit
    
    def CoinWithdraw():
        """
        Mets en forme le df pour permettre la concaténation
        Ajoute un flag isDeposit pour discriminer les deposit des withdraw
        """

        df_withdraw = pd.read_csv(f'{wd}/BINANCE/EXTRACT/files/CoinWithdraw.csv')
        df_withdraw.rename(columns={'completeTime':'timestamp'}, inplace=True)
        df_withdraw['timestamp'] = pd.to_datetime(df_withdraw['timestamp']).values.astype(np.int64)//10**6
        df_withdraw['TYPE'] = 'Coin_Withdraw'
        df_withdraw['isDeposit'] = False
        df_withdraw.drop(['status', 'transferType', 'walletType', 'addressTag', 'applyTime', 'info', 'confirmNo', 'txKey'], axis=1, inplace=True)

        return df_withdraw
    
    df_deposit = CoinDeposit()
    df_withdraw = CoinWithdraw()
    df_coins = pd.concat([df_deposit, df_withdraw], ignore_index=True)
    df_coins = df_coins.reindex(columns=['id', 'txId', 'timestamp', 'TYPE', 'isDeposit', 'network', 'coin', 'amount', 'transactionFee', 'address'])
    df_coins.rename(columns={'id':'ID',
                             'txId':'TX_ID',
                             'timestamp':'TIMESTAMP',
                             'isDeposit':'IS_DEPOSIT',
                             'network':'NETWORK',
                             'coin':'COIN',
                             'amount':'AMOUNT',
                             'address':'ADDRESS',
                             'transactionFee': 'TRANSACTION_FEE'}, inplace=True)
    df_coins['COIN'].apply(load_token)
    df_coins = df_coins.round({'AMOUNT':3})
    df_coins.sort_values(by="TIMESTAMP", inplace=True)
    df_coins['TIMESTAMP'] =  pd.to_datetime(df_coins['TIMESTAMP'], unit='ms')
    df_coins.to_csv(f'{wd}/BINANCE/TRANSFORM/files/CoinDepositWithdraw.csv', index=False)

def CoinsInfos():
    """
    """
    df_coinsinfos = pd.read_json(f"{wd}/BINANCE/EXTRACT/raw_files/CoinsInfos.json")
    list_coinsinfos = df_coinsinfos["coin"].tolist()
    list_coinsinfos = list_coinsinfos + ['UST']
    return '|'.join(list_coinsinfos)


def myTradesConvertFiatPaymentTxs():
    """
    Transformer les fichiers ConvertTradeHistory.csv et myTrades.csv pour les mettre au même format
    Structure d'une transaction : ORDER_ID', 'TIMESTAMP', 'FROM_ASSET', 'FROM_QUANTITY', 'FROM_PRICE', 'TO_ASSET', 'TO_QUANTITY', 'TO_PRICE'
    """
    def token_from_to(isBuyer, token1, token2, price, inverseprice, qty, quoteqty):
        """
        Swap les token1, qty, price avec token2, quoteqty, inverseprice en fonction du booléen isBuyer
        """
        if isBuyer:
            return token2, quoteqty, inverseprice, token1, qty, price
        else:
            return token1, qty, price, token2, quoteqty, inverseprice
        
    def split_pairs(pair):
        """
        Utilise un expression regex pour découper la paire et retourner 2 tokens: token1, token2.
        Utilise la variable regex_coinsinfos défini au niveau n+1 (dans la fonction myTradesConvertTxs).
        Retourne None, None s'il n'y a pas de match pour au moins 1 des deux tokens.
        """
        pattern = re.compile(f'^({regex_coinsinfos})({regex_coinsinfos})$')
        match = pattern.match(pair)
        if match:
            return match.groups()[0], match.groups()[1]
        else:
            return None, None

    def myTrades():
        """
        Met en forme le fichier myTrades.csv pour convenir au format commun de transaction avec le fichier ConvertTradeHistory.csv
        """
        df_mytrades = pd.read_csv(f"{wd}/BINANCE/EXTRACT/files/myTrades.csv")

        df_mytrades[['token1', 'token2']] = df_mytrades['symbol'].apply(lambda symbol : pd.Series(split_pairs(symbol)))
        df_mytrades['inverseprice'] = 1/df_mytrades['price']
        df_mytrades[['FROM_ASSET', 'FROM_QUANTITY', 'FROM_PRICE', 'TO_ASSET', 'TO_QUANTITY', 'TO_PRICE']] = df_mytrades.apply(lambda row: pd.Series(token_from_to(row.isBuyer, row.token1,
                                                                                                                                                                  row.token2, row.price,
                                                                                                                                                                  row.inverseprice, row.qty,
                                                                                                                                                                  row.quoteQty)), axis=1)
        df_mytrades.drop(['index', 'id', 'orderListId', 'isMaker', 'isBestMatch', 'symbol', 'token2', 'token1', 'price', 'isBuyer', 'inverseprice', 'quoteQty', 'qty'], inplace=True, axis=1)
        df_mytrades['TYPE'] = 'myTrades'
        df_mytrades.rename(columns={'orderId':"ORDER_ID",
                                    'time':'TIMESTAMP',
                                    'commission':'TRANSACTION_FEE',
                                    'commissionAsset':"FEE_ASSET"}, inplace=True)
        df_mytrades = df_mytrades.reindex(columns=['ORDER_ID', 'TIMESTAMP', 'TYPE', 'FROM_ASSET', 'FROM_QUANTITY', 'FROM_PRICE', 'TO_ASSET', 'TO_QUANTITY', 'TO_PRICE', 'TRANSACTION_FEE', 'FEE_ASSET'])

        return df_mytrades
    
    def Convert():
        """
        index,index,startTime,endTime,limit,moreData,quoteId,orderId,orderStatus,
        fromAsset,fromAmount,toAsset,toAmount,ratio,inverseRatio,createTime,orderType,side

        ORDER_ID', 'TIMESTAMP', 'FROM_ASSET', 'FROM_QUANTITY', 'FROM_PRICE', 'TO_ASSET', 'TO_QUANTITY', 'TO_PRICE'])

        orderId, createTime, fromAsset, fromAmount, ratio, toAsset, toAmount, inverseRatio
        """
        df_convert = pd.read_csv(f"{wd}/BINANCE/EXTRACT/files/ConvertTradeHistory.csv")
        df_convert.drop(['index', 'startTime', 'endTime', 'limit', 'moreData', 'quoteId', 'orderStatus', 'orderType', 'side'], inplace=True, axis=1)
        df_convert['TYPE'] = 'Convert'
        df_convert.rename(columns={'orderId':'ORDER_ID',
                           'createTime':'TIMESTAMP',
                           'fromAsset':'FROM_ASSET',
                           'fromAmount':'FROM_QUANTITY',
                           'ratio':'FROM_PRICE',
                           'toAsset':'TO_ASSET',
                           'toAmount': 'TO_QUANTITY',
                           'inverseRatio':'TO_PRICE'}, inplace=True)
        df_convert = df_convert.reindex(columns=['ORDER_ID', 'TIMESTAMP', 'TYPE', 'FROM_ASSET', 'FROM_QUANTITY', 'FROM_PRICE', 'TO_ASSET', 'TO_QUANTITY', 'TO_PRICE'])

        return df_convert
    
    def FiatPayment():
        """
        
        """
        df_fiatpayment = pd.read_csv(f"{wd}/BINANCE/EXTRACT/raw_files/FiatPayment/FiatPaymentBuy.csv")
        df_fiatpayment['totalFee'] = df_fiatpayment['totalFee'].apply(lambda x: x if x!=0.0 else None)
        df_fiatpayment['updateTime'] = df_fiatpayment['updateTime'].astype(np.int64)
        df_fiatpayment['FEE_ASSET'] = df_fiatpayment.apply(lambda row: row.cryptoCurrency if row.totalFee is None else None, axis=1)
        df_fiatpayment['FROM_PRICE'] = 1/df_fiatpayment['price']
        df_fiatpayment.drop(['status', 'createTime'], axis=1, inplace=True)
        df_fiatpayment.rename(columns={
                            'orderNo' : 'ORDER_ID',
                            'updateTime':'TIMESTAMP',
                           'fiatCurrency':'FROM_ASSET',
                           'sourceAmount':'FROM_QUANTITY',
                           'cryptoCurrency':'TO_ASSET',
                           'paymentMethod':'TYPE',
                           'obtainAmount': 'TO_QUANTITY',
                           'price':'TO_PRICE',
                           'totalFee':'TRANSACTION_FEE'}, inplace=True)
        df_fiatpayment = df_fiatpayment.reindex(columns=['ORDER_ID', 'TIMESTAMP', 'TYPE', 'FROM_ASSET', 'FROM_QUANTITY', 'FROM_PRICE', 'TO_ASSET', 'TO_QUANTITY', 'TO_PRICE', 'TRANSACTION_FEE', 'FEE_ASSET'])
        return df_fiatpayment



    regex_coinsinfos = CoinsInfos()
    df_convert = Convert()
    df_myTrades = myTrades()
    df_fiatpayment = FiatPayment()

    df_tx = pd.concat([df_convert, df_myTrades], ignore_index=True)
    df_tx = pd.concat([df_tx, df_fiatpayment], ignore_index=True).sort_values(by="TIMESTAMP", ignore_index=True)
    df_tx['TIMESTAMP'] = pd.to_datetime(df_tx['TIMESTAMP'], unit='ms')
    df_tx = df_tx.round({'FROM_QUANTITY':3, 'FROM_PRICE': 3, 'TO_QUANTITY':3, 'TO_PRICE':3})
    df_tx['TO_ASSET'].apply(load_token)
    df_tx['FROM_ASSET'].apply(load_token)
    df_tx['FEE_ASSET'].apply(load_token)
    df_tx.to_csv(f'{wd}/BINANCE/TRANSFORM/files/Transactions.csv', index=False)

def load_token(ticker):
    """
    """
    if pd.isna(ticker):
        return None
    elif token_dimension_table.loc[token_dimension_table==ticker].empty:
        token_dimension_table.loc[len(token_dimension_table)] = ticker

def main():
    delete_all_files_from_dir(f"{wd}/BINANCE/TRANSFORM/files/")
    global token_dimension_table
    token_dimension_table = pd.Series(name='TOKEN')
    FiatDepositWithdraw()
    CoinDepositWithdraw()
    myTradesConvertFiatPaymentTxs()
    token_dimension_table.to_csv(f'{wd}/BINANCE/TRANSFORM/files/Tokens.csv', index=False)

main()





def test():
    pass

#test()