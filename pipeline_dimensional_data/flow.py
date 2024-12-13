import traceback
from utils import get_uuid
from . import tasks
from c_logging import get_dimensional_logger


class DimensionalDataFlow:
    def __init__(self):
        self.execution_uuid = get_uuid()
        self.logger = get_dimensional_logger(self.execution_uuid)


    def exec(self, start_date, end_date):
        try:
            self.logger.info("Starting Dimensional Data Flow execution.")

            connection, cursor = tasks.connect_db_create_cursor('sql_server_config.cfg', 'ORDER_DDS')

            result = tasks.create_database(connection, cursor, self.execution_uuid)
            if not result.get('success'):
                raise Exception(f"Create Database Failed: {result.get('error')}")

            result = tasks.create_tables(connection, cursor,
                                         execution_uuid=self.execution_uuid)
            if not result.get('success'):
                raise Exception(f"Create Tables Failed: {result.get('error')}")

            staging_tables = ['Categories', 'Customers', 'Employees', 'Products', 'Region', 'Shippers', 'Suppliers',
                              'Territories', 'Orders','OrderDetails']

            for staging_table in staging_tables:
                result = tasks.insert_into_staging(connection, cursor, staging_table, self.execution_uuid)
                if not result.get('success'):
                    raise Exception(f"Insertion into Staging Tables Failed: {result.get('error')}")

            tables = ['dim_categories', 'dim_customers', 'dim_employees', 'dim_products',
                                'dim_region', 'dim_shippers', 'dim_suppliers', 'dim_territories', 'fact_orders', 'fact_error']
            for table in tables:
                result = tasks.insert_into_table(
                    connection=connection,
                    cursor=cursor,
                    table_name=table,
                    db="ORDER_DDS",
                    schema="dbo",
                    start_date=start_date,
                    end_date=end_date,
                    execution_uuid=self.execution_uuid
                )
            if not result.get('success'):
                raise Exception(f"Ingest Dimension Tables Failed: {result.get('error')}")

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