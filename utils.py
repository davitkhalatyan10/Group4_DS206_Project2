import pyodbc
import uuid
import configparser
from typing import Optional

def get_db_connection(config_path: str) -> pyodbc.Connection:
    """
    Create a connection to SQL Server using config file
    
    Args:
        config_path (str): Path to config file
    Returns:
        pyodbc.Connection: Database connection object
    """
    config = configparser.ConfigParser()
    config.read(config_path)
    
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={config['sql_server']['host']},{config['sql_server']['port']};"  # Added port here
        f"DATABASE={config['sql_server']['database']};"
        f"UID={config['sql_server']['user']};"
        f"PWD={config['sql_server']['password']}"
    )
    
    return pyodbc.connect(conn_str)

def read_sql_file(file_path: str) -> str:
    """
    Read SQL script from a file
    
    Args:
        file_path (str): Path to SQL file
    Returns:
        str: Content of SQL file
    """
    with open(file_path, 'r') as file:
        return file.read()

