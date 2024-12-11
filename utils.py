import configparser
import os
import uuid

def get_sql_config(filename, database):
    cf = configparser.ConfigParser()
    if not os.path.exists(filename):
        raise FileNotFoundError(f"Config file {filename} does not exist.")
    
    cf.read(filename)
    
    if not cf.has_section(database):
        raise configparser.NoSectionError(f"Section '{database}' not found in {filename}.")
    
    try:
        config = {
            "Driver": cf.get(database, "Driver"),
            "Server": cf.get(database, "Server"),
            "Database": cf.get(database, "Database"),
            "Trusted_Connection": cf.getboolean(database, "Trusted_Connection")
        }
    except configparser.NoOptionError as e:
        raise configparser.NoOptionError(f"Missing option in config file: {e}")
    
    return config



def load_query(query_dir, query_name):
    matched_files = [file for file in os.listdir(query_dir) if query_name in file]
    if not matched_files:
        raise FileNotFoundError(f"No file containing '{query_name}' found in directory '{query_dir}'.")
    if len(matched_files) > 1:
        raise FileExistsError(f"Multiple files containing '{query_name}' found in directory '{query_dir}': {matched_files}")
    
    file_path = os.path.join(query_dir, matched_files[0])
    with open(file_path, 'r', encoding='utf-8') as script_file:
        return script_file.read()


def get_uuid():
    return uuid.uuid4()