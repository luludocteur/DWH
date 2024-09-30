import pandas as pd
import os
from sqlalchemy import text

def get_files_from_directory(path):
    """
    Retourne la liste des fullnames des fichiers contenus dans le répertoire path
    """
    files = os.listdir(path)
    full_path_list = []
    for file in files:
        file = path+file
        full_path_list.append(file)
    return full_path_list

def csv_to_df(file):
    """
    Lis le fichier csv et retourne un df
    """
    return pd.read_csv(file, sep=',', quotechar='"', encoding='utf-8')

def delete_all_files_from_dir(path):
    """
    Supprime tous les fichiers d'un repertoire
    """
    full_name_list = get_files_from_directory(path)
    for file in full_name_list:
        if os.path.isfile(file):
            os.remove(file)

def truncate_table(table, conn):
    """
    Execute un ordre de truncate sur la table table en visant le schéma du curseur
    """
    sql = f"delete from {table};"
    print(sql)
    conn.execute(text(sql))
    conn.commit()

