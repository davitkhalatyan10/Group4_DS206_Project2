import pyodbc
from utils import load_query, get_sql_config, get_uuid
from c_logging import get_dimensional_logger, ExecutionLoggerAdapter
import os
import pandas as pd
import traceback
import numpy as np
import re

dimensional_logger = get_dimensional_logger(get_uuid())
def connect_db_create_cursor(config_file, config_section):
    try:
        db_conf = get_sql_config(config_file, config_section)
        
        db_conn_str = (
            f"Driver={db_conf['Driver']};"
            f"Server={db_conf['Server']};"
            f"Database={db_conf['Database']};"
            f"Trusted_Connection=yes;"
        )
        
        db_conn = pyodbc.connect(db_conn_str)
        db_cursor = db_conn.cursor()
        
        return db_conn, db_cursor
    except Exception as e:
        dimensional_logger.error(
            msg="Failed to connect to the database.",
            extra={"execution_uuid": "N/A", "error": str(e)}
        )
        raise



def create_database(connection, cursor, execution_uuid):
    try:
        # Create a database
        create_database_script = load_query("infrastructure_initiation", "dimensional_db_creation.sql")
        
        connection.autocommit = False
        cursor.execute(create_database_script)
        connection.commit()
        
        # Log the creation of the database
        dimensional_logger.info(
            msg="The database has been created.",
            extra={"execution_uuid": execution_uuid}
        )
        
        return {'success': True}
    except Exception as e:

        connection.rollback()
        dimensional_logger.error(
            msg="Failed to create the database.",
            extra={"execution_uuid": execution_uuid, "error": str(e)}
        )
        
        return {'success': False, 'error': str(e)}
    finally:
        connection.autocommit = True



def create_tables(connection, cursor, execution_uuid):
    try:
        create_table_script = load_query("infrastructure_initiation", "staging_raw_table_creation.sql")

        cursor.execute(create_table_script)
        connection.commit()

        dimensional_logger.info(
            msg=f"The staging tables in the database have been created.",
            extra={"execution_uuid": execution_uuid}
        )

        create_table_script = load_query("infrastructure_initiation", "dimensional_db_table_creation.sql")

        cursor.execute(create_table_script)
        connection.commit()
        
        # Log the creation of the tables
        dimensional_logger.info(
            msg=f"The dimensional tables in the database have been created.",
            extra={"execution_uuid": execution_uuid}
        )
        
        return {'success': True}
    except Exception as e:
        connection.rollback()
        
        dimensional_logger.error(
            msg=f"Failed to create tables in the database.",
            extra={"execution_uuid": execution_uuid, "error": str(e)}
        )
        
        return {'success': False, 'error': str(e)}
    finally:
        connection.autocommit = True



def insert_into_table(connection, cursor, table_name, db, schema, start_date, end_date, execution_uuid):
    try:
        insert_script_filename = f"update_{table_name}.sql"
        insert_into_fact_table_script = load_query("pipeline_dimensional_data/queries", insert_script_filename).format(
            database_name=db,
            schema=schema,
            start_date=start_date,
            end_date=end_date
        )
        
        connection.autocommit = False
        cursor.execute(insert_into_fact_table_script)
        connection.commit()
        
        dimensional_logger.info(
            msg=f"Data has been inserted into/updated the {db}.{schema}.{table_name} table from {db}.{schema}.",
            extra={"execution_uuid": execution_uuid}
        )
        
        return {'success': True}
    except Exception as e:
        connection.rollback()
        
        dimensional_logger.error(
            msg=f"Failed to insert data into/updated the {db}.{schema}.{table_name} table. Error: {str(e)}",
            extra={"execution_uuid": execution_uuid}
        )
        dimensional_logger.debug(
            msg="Traceback: " + traceback.format_exc(),
            extra={"execution_uuid": execution_uuid}
        )
        
        return {'success': False, 'error': str(e)}
    finally:
        connection.autocommit = True


def insert_into_staging(connection, cursor, table_name, execution_uuid):
    df = pd.read_excel('raw_data_source.xlsx', sheet_name=table_name, header=0)

    # Load the SQL script to insert into a table
    columns = ', '.join(df.columns)
    placeholders = ', '.join(['?'] * len(df.columns))
    sql = f'''INSERT INTO staging_raw_{table_name} ({columns}) VALUES ({placeholders});'''
    if table_name == 'Categories':
        df['Description'] = df['Description'].astype(str)

    if table_name == "Employees":
        df.sort_values(by='ReportsTo', ascending=True, na_position='first', inplace=True)
        df['ReportsTo'] = df['ReportsTo'].astype("Int64")

    for column in df.columns:
        if 'Date' in column:
            df[column] = pd.to_datetime(df[column], format='%Y%m%d').dt.date


    df.replace({np.nan: None, np.inf: None, -np.inf: None}, inplace=True)

    for _, row in df.iterrows():
        try:
            cursor.execute(sql, tuple(row))
            connection.commit()
        except Exception as e:
            connection.rollback()

            dimensional_logger.error(
                msg=f"Failed to insert data into/updated the {table_name} table. Error: {str(e)}",
                extra={"execution_uuid": execution_uuid}
            )
            dimensional_logger.debug(
                msg="Traceback: " + traceback.format_exc(),
                extra={"execution_uuid": execution_uuid}
            )
            return {'success': False, 'error': str(e)}
        finally:
            connection.autocommit = True
    return {'success': True}