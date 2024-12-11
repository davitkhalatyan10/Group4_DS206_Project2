from .config import SQL_SERVER_CONFIG_FILE
import pyodbc
from utils import load_query, get_sql_config, get_uuid
from custom_logging import dimensional_logger
import os
import traceback


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



def create_tables(connection, cursor, db, schema, execution_uuid):
    try:
        # Create the tables
        create_table_script = load_query("infrastructure_initiation", "dimensional_db_table_creation.sql").format(db=db, schema=schema)
        
        connection.autocommit = False
        cursor.execute(create_table_script)
        connection.commit()
        
        # Log the creation of the tables
        dimensional_logger.info(
            msg=f"The tables in the database {db}.{schema} have been created.",
            extra={"execution_uuid": execution_uuid}
        )
        
        return {'success': True}
    except Exception as e:
        connection.rollback()
        
        dimensional_logger.error(
            msg=f"Failed to create tables in the database {db}.{schema}.",
            extra={"execution_uuid": execution_uuid, "error": str(e)}
        )
        
        return {'success': False, 'error': str(e)}
    finally:
        connection.autocommit = True



def insert_into_fact_table(connection, cursor, table_name, src_db, src_schema, dst_db, dst_schema, start_date, end_date, execution_uuid):
    try:
        insert_script_filename = f"update_{table_name}.sql"
        insert_into_fact_table_script = load_query("pipeline_dimensional_data/queries", insert_script_filename).format(
            src_db=src_db,
            src_schema=src_schema,
            dst_db=dst_db,
            dst_schema=dst_schema,
            start_date=start_date,
            end_date=end_date
        )
        
        connection.autocommit = False
        cursor.execute(insert_into_fact_table_script)
        connection.commit()
        
        dimensional_logger.info(
            msg=f"Data has been inserted into/updated the {dst_db}.{dst_schema}.{table_name} table from {src_db}.{src_schema}.",
            extra={"execution_uuid": execution_uuid}
        )
        
        return {'success': True}
    except Exception as e:
        connection.rollback()
        
        dimensional_logger.error(
            msg=f"Failed to insert data into/updated the {dst_db}.{dst_schema}.{table_name} table. Error: {str(e)}",
            extra={"execution_uuid": execution_uuid}
        )
        dimensional_logger.debug(
            msg="Traceback: " + traceback.format_exc(),
            extra={"execution_uuid": execution_uuid}
        )
        
        return {'success': False, 'error': str(e)}
    finally:
        connection.autocommit = True
