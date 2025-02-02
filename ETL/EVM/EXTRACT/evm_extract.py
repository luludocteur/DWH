import os
import sys
import requests
import pandas as pd
import json
from dotenv import load_dotenv
load_dotenv()



class EXTRACT:

    WD = os.getenv('working_directory')

    def __init__(self, BASE_URL, apikey, address):
        
        self.BASE_URL = BASE_URL
        self.address = address
        self.apikey = apikey
        self.chains = ['eth', 'arbitrum', 'avalanche', 'bsc', 'fantom', 'linea', 'polygon', 'moonbeam', 'optimism', 'base']
    
    def get_response(self, callUrl, headers=None, auth=None, params=None):
        """
        Crée une réponse api
        """
        URL = self.BASE_URL + callUrl
        self.response = requests.get(URL, headers=headers, auth=auth, params=params)

    def get_chains(self):
        """
        Ajoute la liste des chains à requeter à self.chains.
        En dur pour le moment
        """
        #self.chains = ['eth', 'arbitrum', 'avalanche', 'bsc', 'fantom', 'linea', 'polygon', 'moonbeam', 'optimism', 'base']


class MORALIS_EXTRACT(EXTRACT):

    def get_page_cursor(self):
        """
        Retourne le curseur de la page de transaction actuellement requetée.
        Permet de savoir si on continue ou non
        """
        return self.response.json().get('cursor', None)

    def get_walletHistoryByChain(self, chain, fromDate, toDate, cursor=None):
        """
        Retourne l'historique de transaction pour une chain
        """
        callUrl=f"wallets/{self.address}/history"
        headers={"accept":"application/json",
                'X-API-Key':self.apikey}
        params={'chain':chain,
                'from_date':fromDate,
                'to_date':toDate,
                'include_internal_transactions':True,
                'ntf_metadata':True,
                'cursor':cursor,
                'order':'ASC'}
        return self.get_response(callUrl, headers=headers, params=params)
    
    def save_walletHistoryForChain(self, fromDate, toDate):
        """
        Retourne l'historique de transactions pour toutes les chaines de self.chains
        """
        for chain in self.chains:
            print(chain)
            n=0
            self.get_walletHistoryByChain(chain, fromDate, toDate)
            with open(f'{self.WD}/EVM/EXTRACT/raw_files/tx/{chain}_tx_{fromDate}_{toDate}_{n}.json', 'w') as file:
                json.dump(self.response.json(), file, indent=3)
            cursor = self.get_page_cursor()
            while cursor is not None:
                n+=1
                self.get_walletHistoryByChain(chain, fromDate, toDate, cursor)
                with open(f'{self.WD}/EVM/EXTRACT/raw_files/tx/{chain}_tx_{fromDate}_{toDate}_{n}.json', 'w') as file:
                    json.dump(self.response.json(), file, indent=3)
                cursor = self.get_page_cursor()







