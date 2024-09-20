#! /bin/zsh

#Exécute le script d'extraction EVM
cd ${ETL_PATH}/BINANCE/EXTRACT/
python binance_extract.py

#Exécute le script de transform EVM
cd ${ETL_PATH}/BINANCE/TRANSFORM/
python binance_transform.py

#Exécute le script de load EVM
cd ${ETL_PATH}/BINANCE/LOAD/
python binance_load.py
