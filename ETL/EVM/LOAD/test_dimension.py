import pandas as pd
import os 
import sys
import numpy as np 
from dotenv import load_dotenv
load_dotenv()
wd = os.getenv('working_directory')
ETL_folder_relative = os.path.dirname(wd)
sys.path.append(ETL_folder_relative)
from ETL.utility import get_files_from_directory, csv_to_df

files = get_files_from_directory(f"{wd}/EVM/TRANSFORM/files/")

dim_df = pd.DataFrame(columns=['Table', 'Champ', 'Longueur_max'])

for file in files:
    if file.split('.')[-1] == 'csv':
        df = csv_to_df(file)
        mesurer = np.vectorize(len)
        df_mesurer = mesurer(df.values.astype(str)).max(axis=0)
        for i, col in enumerate(df.columns):
            dim_df = pd.concat([dim_df, pd.DataFrame({'Table': [file.split('/')[-1],],
                                                    'Champ':[col,], 'Longueur_max': [df_mesurer[i],]})])

print(dim_df.to_string())