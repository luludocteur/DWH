import os
import sys
import requests
from requests.auth import HTTPBasicAuth
import json
import pandas as pd
from covalent import CovalentClient
from dotenv import load_dotenv
load_dotenv()
ETL_folder_relative = os.path.dirname(os.getenv('working_directory'))
sys.path.append(ETL_folder_relative)
from ETL.utility import delete_all_files_from_dir

address = os.getenv('EVM_address')
covalent_API_KEY = os.getenv('covalent_apikey')
wd = os.getenv('working_directory')


def create_response(endpoint, args=None):

    """
    Constructeur de réponse API en fonction de l'endpoint préconstruit à la main
    On peut aussi utiliser les paramètres de args en option (voir doc covalent)
    """

    BASE_URL = "https://api.covalenthq.com/v1/"
    URL = BASE_URL + endpoint

    
    headers = {
        "accept": "application/json",
    }

    basic = HTTPBasicAuth(covalent_API_KEY, '')
    response = requests.get(URL, headers=headers, auth=basic, params=args)
    return response

def chains(walletAddress):
    """
    Retourne les informations relatives aux blockchains avec lesquelles la walletAdress a interagit
    """
    response = create_response(f"address/{walletAddress}/activity/")
    with open(f'{wd}/EVM/EXTRACT/raw_files/chains.json', 'w') as file:
        json.dump(response.json(), file, indent=3)


def chain_count(chainName, walletAddress):
    """
    Compte le nombre de transactions effectuées sur la chainName
    """
    response = create_response(f"{chainName}/address/{walletAddress}/transactions_summary/")
    count = response.json()["data"]["items"][0]["total_count"]
    with open(f'{wd}/EVM/EXTRACT/raw_files/chains_details/{chainName}_count.json', 'w') as file:
        json.dump(response.json(), file, indent=3)
    return count

def transactions_per_chains(chainName, walletAddress, page):
    response = create_response(f"{chainName}/address/{walletAddress}/transactions_v3/page/{page}/", {"quote-currency":"USD", "block-signed-at-asc":"true"})
    with open(f'{wd}/EVM/EXTRACT/raw_files/tx/{chainName}_tx_{page}.json', 'w') as file:
        json.dump(response.json(), file, indent=3)

def extract_data(walletAddress):
    """
    Extrait les transactions des blockchains chainName par pages (100txs/page)
    """
    
    with open(f'{wd}/EVM/EXTRACT/raw_files/chains.json', 'r') as file:
        chains = json.load(file)

    chains_df = pd.DataFrame(chains['data']['items'])
    chainlist = chains_df['name'].to_list()
    chainlist.remove('gnosis-mainnet')
    chainlist.remove('celo-mainnet')
    chainlist.remove('blast-mainnet')
    chainlist.remove('base-mainnet')
    

    #On enlève gnosis au moins pour le moment, que des fausses transactions et prend bcp de temps à charger
    for chainName in chainlist:
        print(chainName)
        count = chain_count(chainName, walletAddress)
        for i in range(count//100+1):
            transactions_per_chains(chainName, walletAddress, i)


def main():
    delete_all_files_from_dir(f"{wd}/EVM/EXTRACT/raw_files/tx/")
    chains(address)
    extract_data(address)

main()