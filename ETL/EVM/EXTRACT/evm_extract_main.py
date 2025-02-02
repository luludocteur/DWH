
import os
import sys
from dotenv import load_dotenv
load_dotenv()
from evm_extract import MORALIS_EXTRACT
WD = os.getenv('working_directory')

def main():

    extractor = MORALIS_EXTRACT(
        BASE_URL="https://deep-index.moralis.io/api/v2.2/",
        apikey=os.getenv('moralis_apikey'),
        address=os.getenv('EVM_address')
    )

    fromDate = os.getenv('account_creation_timestamp')
    toDate = '1738501844'

    extractor.save_walletHistoryForChain(fromDate, toDate)

main()