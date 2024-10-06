#! /bin/zsh

#Extract, Transform, Load pour les différentes sources (EVM et BINANCE pour le moment...)
./EVM/ETL_EVM.sh
./BINANCE/ETL_BINANCE.sh

# Execute le process depuis les schémas de mapping pour charger les tables de distribution
cd ${ETL_PATH}/DISTRIBUTION/DISTRIBUTION/
python mapping_distribution_process.py