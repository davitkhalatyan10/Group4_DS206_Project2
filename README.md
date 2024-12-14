# Pipeline

This repository implements an ETL pipeline for processing grocery store data. 
The pipeline supports dimensional modeling, handles Slowly Changing Dimensions (SCDs), and prepares data for dashboarding in Power BI.

## Features
- **SQL scripts** for database setup, table creation, and data transformations.
- **Python ETL pipeline** to orchestrate the execution of SQL tasks, load data into dimension and fact tables, and update Slowly Changing Dimensions.
- **Logging** for pipeline monitoring and debugging.
- **Parameterized queries** for flexible updates to dimension and fact tables.

## How to Use

1. **Clone the repository:**
   ```bash
   git clone https://github.com/davitkhalatyan10/Group4_DS206_Project2.git
   cd Group4_DS206_Project2
   
2. Install the requirements

```bash
pip install -r requirements.txt
```
3. Run the project

```bash
python main.py
```
