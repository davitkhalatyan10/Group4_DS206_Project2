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

def execute_sql(connection: pyodbc.Connection, sql_script: str, params: Optional[dict] = None) -> bool:
    """
    Execute SQL script with optional parameters
    
    Args:
        connection: Database connection
        sql_script: SQL script to execute
        params: Optional parameters for SQL script
    Returns:
        bool: True if successful, False if failed
    """
    try:
        cursor = connection.cursor()
        
        if params:
            # Replace parameters in SQL script
            for key, value in params.items():
                sql_script = sql_script.replace(f"${key}$", str(value))
        
        cursor.execute(sql_script)
        connection.commit()
        cursor.close()
        return True
        
    except Exception as e:
        print(f"Error executing SQL: {str(e)}")
        connection.rollback()
        return False