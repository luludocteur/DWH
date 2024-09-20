import os
import sys
import json
import pandas as pd
from dotenv import load_dotenv
load_dotenv()
ETL_folder_relative = os.path.dirname(os.getenv('working_directory'))
sys.path.append(ETL_folder_relative)
from ETL.utility import get_files_from_directory, delete_all_files_from_dir

wd = os.getenv('working_directory')

def df_from_json(file):
    """
    """
    with open(file) as file:
        txs = json.load(file)
    
    blockchain = txs['data']['chain_name']
    df = pd.DataFrame(txs['data']['items'])
    df['blockchain'] = blockchain

    return df

def concat_tx():
    """
    Concatène toutes les transactions de tous les fichiers.
    C'est le point d'entrée de la création des autres dataframes
    """
    path = f"{wd}/EVM/EXTRACT/raw_files/tx/"
    files = get_files_from_directory(path)

    txs_df = pd.DataFrame()
    for file in files:
            print(file.split('/')[-1])
            txs_df = pd.concat([txs_df, df_from_json(file)], ignore_index=True)

    txs_df.to_json(f"{wd}/EVM/TRANSFORM/files/all_txs.json")



def gas_metadatas(df:pd.DataFrame):
    """
    Extrait les gas metadatas du dataframe df (Utilisé dans main())
    Crée la clé d'un enregistrement distinctes dans le dataframe des transactions pour pouvoir faire le lien dans le dwh
    Enregistre le fichier des metadatas dans un csv
    Renvoie le dataframe des transactions sans la colonne metadata pour que cette fonction soit une brique d'un pipeline
    """

    print("Extraction des gas métadonnées")

    #Crée le dataframe en prenant la structure de la colonne gas_metadata
    gas_metadata = pd.json_normalize(df['gas_metadata'])
    #On drop la colonne supports_erc
    gas_metadata.drop("supports_erc", inplace=True, axis=1)
    
    #Ajoute la tx_hash afin de pouvoir lié l'id du gas metadata à la table tx
    gas_metadata['tx_hash'] = df.apply(lambda row: row['tx_hash'], axis=1)

    #On crée une clé primaire pour les combinaisons distinctes
    gas_metadata['id'] = gas_metadata.groupby(['contract_decimals', 'contract_name', 'contract_ticker_symbol', 'contract_address', 'logo_url']).ngroup() + 1
    
    #On ajoute l'id gas metadata dans la table des transactions, on renomme l'id, on drop la colonne metadata
    df = pd.merge(df, gas_metadata[['id', 'tx_hash']], on='tx_hash', how="inner")
    df.rename({'id':'ID_gas_metadata'},inplace=True, axis=1)
    df.drop("gas_metadata", inplace=True, axis=1)

    #On peut maintenant drop la colonne tx_has, garder les enregistrements distincts, on order by id, on place la colonne id en premier
    gas_metadata.drop("tx_hash", inplace=True, axis=1)
    gas_metadata.drop_duplicates(inplace=True, ignore_index=True)
    gas_metadata.sort_values(by='id', inplace=True)
    gas_metadata = gas_metadata.reindex(columns=['id', 'contract_decimals', 'contract_name', 'contract_ticker_symbol', 'contract_address', 'logo_url'])
    gas_metadata.rename(columns={"id":"GAS_ID",
                                 "contract_decimals":"CONTRACT_DECIMALS",
                                 "contract_name":"CONTRACT_NAME",
                                 "contract_ticker_symbol":"CONTRAT_TICKER",
                                 "contract_address":"CONTRACT_ADDRESS",
                                 "logo_url":"LOGO_URL"}, inplace=True)
    
    
    gas_metadata.reset_index(inplace=True, drop=True)
    gas_metadata.to_csv(f'{wd}/EVM/TRANSFORM/files/gas_metadata.csv', index=False)

    print("Fin de l'extraction des gas métadonnées")

    return df

def logs_events(df:pd.DataFrame):
    """
    Retourne les logs du dataframe df (Utilisé dans main())
    Enregistre les txs en csv 
    """

    print("Extraction des logs")
    #On copie le dataframe
    df_logs = df.copy()

    #On supprime les lignes dont les logs sont nulls dans le nv df  
    #puis on créer une liste des dict représentant les logs pour utiliser json_normalise
    df_logs.drop(df_logs.loc[df_logs['log_events'].isna()].index,inplace=True)
    logs_list = [log for transaction in df_logs['log_events'] for log in transaction]
    #On crée un nouveau df logs contenant tous les logs
    logs = pd.json_normalize(logs_list)
    
    #On supprime les logs dont le contrat a des décimales inférieures à 2 (spam token --> inutile et gourmand en mémoire)
    logs = logs[logs['sender_contract_decimals']>1.0]
    
    #On reset l'index après avoir supprimer ces enregistrements et 
    #on drop les colonnes inutiles (raw_log_topics, raw_log_data) car encodées, 
    # ou redondantes (block_signed_at, block_height) par rapport au df des txs
    logs.reset_index(inplace=True, drop=True)
    logs.drop(logs[['block_signed_at','block_height', 'raw_log_topics', 'raw_log_data']], axis=1, inplace=True)

    #On extrait les champs label et url du champ explorers
    df['explorers'] = df.apply(lambda row: row['explorers'][0], axis=1)
    df = pd.concat([df, pd.json_normalize(df['explorers'])], axis=1)

    #On met en forme le dataframe des transactions et on le charge en csv
    df.drop(["log_events", "explorers", "from_address_label", "to_address_label", "label"], inplace=True, axis=1)
    df['value_quote'] = df['value_quote'].round(2)
    df['gas_quote'] = df['gas_quote'].round(4)
    df['gas_quote_rate'] = df['gas_quote_rate'].round(4)
    df.sort_values(by=['block_signed_at'],inplace=True)
    df.reset_index(inplace=True, drop=True)
    df = df.reindex(columns=["blockchain", "block_signed_at", "block_height", "block_hash", "tx_hash", "tx_offset", "successful",
                         "miner_address", "from_address", "to_address", "value", 
                         "value_quote", "pretty_value_quote", "ID_gas_metadata", "gas_offered", "gas_spent", "gas_price", "fees_paid",
                         "gas_quote", "pretty_gas_quote", "gas_quote_rate", "url"])
    df.rename(columns={"blockchain":"BLOCKCHAIN",
                       "block_signed_at":"BLOCK_TIMESTAMP",
                       "block_height":"BLOCK_HEIGHT",
                       "block_hash":"BLOCK_HASH",
                       "tx_hash":"TX_HASH",
                       "tx_offset":"TX_OFFSET",
                       "successful":"SUCCESSFUL",
                       "miner_address":"MINER_ADDRESS",
                       "from_address":"FROM_ADDRESS",
                       "to_address":"TO_ADDRESS",
                       "value":"TX_VALUE",
                       "value_quote":"TX_VALUE_QUOTE",
                       "pretty_value_quote":"PRETTY_VALUE_QUOTE",
                       "ID_gas_metadata":"GAS_ID",
                       "gas_offered":"GAS_OFFERED",
                       "gas_spent":"GAS_SPENT",
                       "gas_price":"GAS_PRICE",
                       "fees_paid":"FEES_PAID",
                       "gas_quote":"GAS_QUOTE",
                       "pretty_gas_quote":"PRETTY_GAS_QUOTE",
                       "gas_quote_rate":"GAS_QUOTE_RATE",
                       "url":"EXPLORER_URL"}, inplace=True)

    df.to_csv(f'{wd}/EVM/TRANSFORM/files/transactions.csv', index=False)

    print("Fin de l'extraction des logs")

    return logs


def tokens(df:pd.DataFrame):
    """
    Le dataframe des logs en entrée
    On extrait les informations sur les tokens liés aux logs par l'adresse du sender (pas besoin de clé)
    On charge le dataframe des tokens en csv
    On retourne le dataframe des logs avec les params à traiter dans la fonction params()
    """

    print("Extraction des tokens")

    df_tokens = df.copy()
    df_tokens = df_tokens[["sender_contract_decimals", "sender_name", "sender_contract_ticker_symbol", 
                           "sender_address", "sender_address_label", "sender_logo_url", "sender_factory_address"]]
    df_tokens['sender_contract_decimals'] = df_tokens['sender_contract_decimals'].astype('int64')
    
    df_tokens.drop_duplicates(inplace=True, ignore_index=True)
    df_tokens.reset_index(inplace=True, drop=True)
    df.drop(["sender_contract_decimals", "sender_name", "sender_contract_ticker_symbol", 
             "sender_address_label", "sender_logo_url", "sender_factory_address", "supports_erc"], inplace=True, axis=1)
    df_tokens.rename(columns={"sender_contract_decimals":"TOKEN_CONTRACT_DECIMALS",
                              "sender_name":"TOKEN_NAME",
                              "sender_contract_ticker_symbol":"TOKEN_TICKER",
                              "sender_address":"TOKEN_ADDRESS",
                              "sender_address_label":"TOKEN_LABEL",
                              "sender_logo_url":"TOKEN_LOGO_URL",
                              "sender_factory_address":"TOKEN_FACTORY_ADDRESS"},inplace=True)
    df_tokens.to_csv(f'{wd}/EVM/TRANSFORM/files/tokens.csv', index=False)

    print("Fin de l'extraction des tokens")

    return df


def params(df:pd.DataFrame):
    """
    A faire
    """

    print("Extraction des paramètres")

    #Crée le df des params, explode pour créer autant de ligne que de params, json_normalize pour créer un champ par clé
    df_param = df[['tx_offset', 'log_offset', 'tx_hash', 'decoded.name', 'decoded.params']]
    df_param = df_param.explode('decoded.params', ignore_index=True)
    df_param = pd.concat([df_param, pd.json_normalize(df_param['decoded.params'])], axis=1)

    #Récupère les enregistrements dont les params sont null pour garder une trace
    #On drop ainsi les champs null, on ne garde que les tx_hash, lx_offset et log_offset
    #On charge ce df en csv

    print("Création de la table de rejet des paramètres")
    df_param_reject = df_param.copy(deep=True)
    df_param_na = pd.isna(df_param_reject['decoded.params'])
    df_param_reject = pd.concat([df_param_reject[df_param_na],df_param.loc[df_param['type']=='uint256[2]']])
    df_param_reject.drop(['decoded.params', 'name','type','indexed','decoded','value'], inplace=True, axis=1)
    df_param_reject.index.name = 'index'
    df_param_reject.to_csv('files/R_params.csv')

    #On drop la colonne decoded.params car elle a etait explode | json_normalize précédemment
    #On drop les lignes en NA
    #On charge en csv
    df_param.drop(['decoded.params', 'decoded'], inplace=True, axis=1)
    df_param.drop(df_param_reject.index, inplace=True)
    df_param_address = df_param.loc[(df_param['type']=='address')| (df_param['type']=='bytes32')]
    df_param.drop(df_param_address.index, inplace=True)
    df_param_address.reset_index(inplace=True)
    df_param.reset_index(inplace=True)
    df_param.index.name = 'index'
    df_param_address.index.name = 'index'
    df_param_address.rename(columns={"index":"PARAM_ID",
                             "tx_offset":"TX_OFFSET",
                             "log_offset":"LOG_OFFSET",
                             "tx_hash":"TX_HASH",
                             "decoded.name":"LOGS_FUNCTION_NAME",
                             "name":"PARAM_NAME",
                             "type":"PARAM_TYPE",
                             "indexed":"INDEXED",
                             "value":"ADDRESS"}, inplace=True)
    df_param.rename(columns={"index":"PARAM_ID",
                             "tx_offset":"TX_OFFSET",
                             "log_offset":"LOG_OFFSET",
                             "tx_hash":"TX_HASH",
                             "decoded.name":"LOGS_FUNCTION_NAME",
                             "name":"PARAM_NAME",
                             "type":"PARAM_TYPE",
                             "indexed":"INDEXED",
                             "value":"VALUE"}, inplace=True)
    
    df_param_address.to_csv(f'{wd}/EVM/TRANSFORM/files/params_address.csv', index=False)
    df_param.to_csv(f'{wd}/EVM/TRANSFORM/files/params_value.csv', index=False)

    print("Fin de l'extraction des paramètres")

    #Drop tous les champs redondants dans le df des params et charge en csv
    df.drop(['decoded.params', 'decoded.name', 'decoded', 'decoded.signature'], inplace=True, axis=1)
    df.rename(columns={"tx_offset":"TX_OFFSET",
                       "log_offset":"LOG_OFFSET",
                       "tx_hash":"TX_HASH",
                       "sender_address":"TOKEN_ADDRESS"}, inplace=True)
    df.to_csv(f'{wd}/EVM/TRANSFORM/files/logs.csv', index=False)

    print("Fin de l'extraction des transactions")




# df = df_from_json("/Users/alexanderlunel/Documents/Crypto/DWH/ETL/EVM/EXTRACT/raw_files/tx/matic-mainnet_tx_0.json")
# df_apres_gas = gas_metadatas(df) #Charge le df des gas en csv et retourne celui des txs à traiter pour logs (tokens et params)
# df_apres_logs = logs_events(df_apres_gas) #Charge le df des txs en csv et retourne celui des logs à traiter pour tokens et params
# df_apres_tokens = tokens(df_apres_logs)
# params(df_apres_tokens)


def main():
    
    """
    Extrait les différents fichiers qui seront intégrés dans la base SQL 
    """
    delete_all_files_from_dir(f"{wd}/EVM/TRANSFORM/files/")
    concat_tx()
    txs = pd.read_json(f'{wd}/EVM/TRANSFORM/files/all_txs.json') #charge le fichier de toutes les txs depuis concat_tx()
    df_apres_gas = gas_metadatas(txs) #Charge le df des gas en csv et retourne celui des txs à traiter pour logs (tokens et params)
    df_apres_logs = logs_events(df_apres_gas) #Charge le df des txs en csv et retourne celui des logs à traiter pour tokens et params
    df_apres_tokens = tokens(df_apres_logs) #Charge le df des tokens en csv et retourne celui des logs à traiter dans la fonction params (dernière étape woula...)
    params(df_apres_tokens) #Charge le df des logs et des params en csv. Charge aussi un df de rejet des params null en csv pour garder une trace des logs en erreur
    
main()
