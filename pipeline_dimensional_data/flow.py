import traceback
from utils import get_uuid
from . import tasks
from .config import TABLE_NAMES
from logging import get_dimensional_logger


class DimensionalDataFlow:
    def __init__(self):
        self.execution_uuid = get_uuid()
        self.logger = get_dimensional_logger(self.execution_uuid)


    def exec(self, start_date, end_date):
        try:
            self.logger.info("Starting Dimensional Data Flow execution.")

            connection, cursor = tasks.connect_db_create_cursor()

            result = tasks.create_database(connection, cursor, self.execution_uuid)
            if not result.get('success'):
                raise Exception(f"Create Database Failed: {result.get('error')}")

            db_name = "ORDER_DDS"
            schema_name = "dbo"
            result = tasks.create_tables(connection, cursor, db=db_name, schema=schema_name,
                                         execution_uuid=self.execution_uuid)
            if not result.get('success'):
                raise Exception(f"Create Tables Failed: {result.get('error')}")

            dimension_tables = ['DimCategories', 'DimCustomers', 'DimEmployees', 'DimProducts',
                                'DimRegion', 'DimShippers', 'DimSuppliers', 'DimTerritories']
            result = tasks.ingest_multiple_tables(
                connection=connection,
                cursor=cursor,
                tables=dimension_tables,
                src_db="StagingDB",
                src_schema="staging",
                dst_db=db_name,
                dst_schema=schema_name,
                execution_uuid=self.execution_uuid
            )
            if not result.get('success'):
                raise Exception(f"Ingest Dimension Tables Failed: {result.get('error')}")

            fact_tables = ['FactOrders']
            for table in fact_tables:
                result = tasks.insert_into_fact_table(
                    connection=connection,
                    cursor=cursor,
                    table_name=table,
                    src_db="StagingDB",
                    src_schema="staging",
                    dst_db=db_name,
                    dst_schema=schema_name,
                    start_date=start_date,
                    end_date=end_date,
                    execution_uuid=self.execution_uuid
                )
                if not result.get('success'):
                    raise Exception(f"Ingest Fact Table '{table}' Failed: {result.get('error')}")

            self.logger.info("Dimensional Data Flow executed successfully.")

        except Exception as e:
            self.logger.error(f"Dimensional Data Flow execution failed: {str(e)}")
            self.logger.debug(f"Traceback: {traceback.format_exc()}")
        finally:
            try:
                cursor.close()
                connection.close()
                self.logger.info("Database connection closed.")
            except Exception as e:
                self.logger.error(f"Error closing database connection: {str(e)}")