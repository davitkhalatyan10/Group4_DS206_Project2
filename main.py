import sys
import argparse
from pipeline_dimensional_data.flow import DimensionalDataFlow

def parse_arguments():
    parser = argparse.ArgumentParser(description="Execute the Dimensional Data Flow Pipeline.")
    parser.add_argument(
        "--start_date",
        type=str,
        required=True,
        help="Start date for data ingestion (format: YYYY-MM-DD)."
    )
    parser.add_argument(
        "--end_date",
        type=str,
        required=True,
        help="End date for data ingestion (format: YYYY-MM-DD)."
    )
    return parser.parse_args()

def main():
    args = parse_arguments()

    from datetime import datetime

    try:
        start_date = datetime.strptime(args.start_date, "%Y-%m-%d").date()
        end_date = datetime.strptime(args.end_date, "%Y-%m-%d").date()
    except ValueError as ve:
        print(f"Error: {ve}")
        sys.exit(1)

    if start_date > end_date:
        print("Error: start_date cannot be after end_date.")
        sys.exit(1)

    data_flow = DimensionalDataFlow()

    data_flow.exec(start_date=str(start_date), end_date=str(end_date))

if __name__ == "__main__":
    main()