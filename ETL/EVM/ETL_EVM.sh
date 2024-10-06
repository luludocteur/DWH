#! /bin/zsh

#Exécute le script d'extraction EVM
cd ${ETL_PATH}/EVM/EXTRACT/
python evm_extract.py

#Exécute le script de transform EVM
cd ${ETL_PATH}/EVM/TRANSFORM/
python evm_transform.py

#Exécute le script de load EVM
cd ${ETL_PATH}/EVM/LOAD/
python evm_load.py

#Exécute le process de mapping de MAPPING_EVM
cd ${ETL_PATH}/DISTRIBUTION/MAPPING_EVM/
python mapping_evm_process.py