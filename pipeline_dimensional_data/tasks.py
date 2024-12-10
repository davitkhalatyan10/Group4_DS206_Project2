import os
from typing import Dict, Any, List
from utils import get_db_connection, read_sql_file, execute_sql

class PipelineError(Exception):
    """Custom exception for pipeline errors"""
    pass

def update_dimension_table(
    config_path: str,
    dimension_name: str,
    prereq_status: Dict[str, bool] = None
) -> Dict[str, bool]:
    """
    Update a specific dimension table using the corresponding SQL script
    
    Args:
        config_path: Path to database config file
        dimension_name: Name of the dimension (e.g., 'categories', 'customers')
        prereq_status: Dictionary containing status of prerequisite tasks
        
    Returns:
        Dict with success status
    """
    # Check prerequisites if provided
    if prereq_status and not all(prereq_status.values()):
        return {'success': False}

    try:
        # Get database connection
        conn = get_db_connection(config_path)
        
        # Construct SQL file path
        sql_file = f"pipeline_dimensional_data/queries/update_dim_{dimension_name}.sql"
        
        # Read and execute SQL
        sql_script = read_sql_file(sql_file)
        params = {
            'database': 'ORDER_DDS',
            'schema': 'dbo',
            'table': f'Dim{dimension_name.capitalize()}'
        }
        
        success = execute_sql(conn, sql_script, params)
        conn.close()
        
        return {'success': success}
        
    except Exception as e:
        raise PipelineError(f"Error updating dimension {dimension_name}: {str(e)}")

def update_fact_table(
    config_path: str,
    start_date: str,
    end_date: str,
    prereq_status: Dict[str, bool]
) -> Dict[str, bool]:
    """
    Update fact table with data from the specified date range
    
    Args:
        config_path: Path to database config file
        start_date: Start date for data ingestion
        end_date: End date for data ingestion
        prereq_status: Dictionary containing status of prerequisite tasks
        
    Returns:
        Dict with success status
    """
    # Check if all dimension updates were successful
    if not all(prereq_status.values()):
        return {'success': False}

    try:
        conn = get_db_connection(config_path)
        
        # Update main fact table
        fact_sql = read_sql_file('pipeline_dimensional_data/queries/update_fact_orders.sql')
        fact_params = {
            'database': 'ORDER_DDS',
            'schema': 'dbo',
            'table': 'FactOrders',
            'start_date': start_date,
            'end_date': end_date
        }
        
        success = execute_sql(conn, fact_sql, fact_params)
        
        # If main fact update successful, process error records
        if success:
            error_sql = read_sql_file('pipeline_dimensional_data/queries/update_fact_error.sql')
            error_success = execute_sql(conn, error_sql, fact_params)
            success = error_success
            
        conn.close()
        return {'success': success}
        
    except Exception as e:
        raise PipelineError(f"Error updating fact table: {str(e)}")

def process_all_dimensions(
    config_path: str,
    dimensions: List[str]
) -> Dict[str, bool]:
    """
    Process all dimension tables in sequence
    
    Args:
        config_path: Path to database config file
        dimensions: List of dimension names to process
        
    Returns:
        Dict containing success status for each dimension
    """
    results = {}
    
    for dim in dimensions:
        # Each dimension depends on previous dimensions' success
        result = update_dimension_table(config_path, dim, results)
        results[dim] = result['success']
        
        # If any dimension fails, stop processing
        if not result['success']:
            break
            
    return results

def run_full_pipeline(
    config_path: str,
    start_date: str,
    end_date: str
) -> Dict[str, bool]:
    """
    Run the complete pipeline including dimensions and fact tables
    
    Args:
        config_path: Path to database config file
        start_date: Start date for fact data
        end_date: End date for fact data
        
    Returns:
        Dict with overall pipeline success status
    """
    try:
        # List of dimensions in processing order
        dimensions = [
            'categories',
            'customers',
            'employees',
            'products',
            'region',
            'shippers',
            'suppliers',
            'territories'
        ]
        
        # Process all dimensions
        dim_results = process_all_dimensions(config_path, dimensions)
        
        # Process fact table if dimensions successful
        if all(dim_results.values()):
            fact_result = update_fact_table(config_path, start_date, end_date, dim_results)
            return {'success': fact_result['success']}
        
        return {'success': False}
        
    except PipelineError as e:
        print(f"Pipeline error: {str(e)}")
        return {'success': False}