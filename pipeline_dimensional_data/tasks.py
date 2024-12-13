import pyodbc
from utils import load_query, get_sql_config, get_uuid
from c_logging import get_dimensional_logger, ExecutionLoggerAdapter
import os
import pandas as pd
import traceback

dimensional_logger = get_dimensional_logger(get_uuid())
def connect_db_create_cursor(config_file, config_section):
    try:
        db_conf = get_sql_config(config_file, config_section)
        
        db_conn_str = (
            f"Driver={{{db_conf['Driver']}}};"
            f"Server={db_conf['Server']};"
            f"Database={db_conf['Database']};"
            f"Trusted_Connection={db_conf['Trusted_Connection']};"
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

        connection.autocommit = False
        cursor.execute(create_table_script)
        connection.commit()

        dimensional_logger.info(
            msg=f"The staging tables in the database have been created.",
            extra={"execution_uuid": execution_uuid}
        )

        create_table_script = load_query("infrastructure_initiation", "dimensional_db_table_creation.sql")
        
        connection.autocommit = False
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


def insert_into_staging(connection, execution_uuid):
    excel_data = pd.ExcelFile('../raw_data_source.xlsx')
    for name in excel_data.sheet_names:
        table_name = f'staging_raw_{name}'
        try:
            df = excel_data.parse(name)
            df.to_sql(table_name, con=connection, if_exists='replace', index=False)
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