import os
import urllib
import pandas as pd
from sqlalchemy import create_engine

print("---OLIST ETL PIPELINE START---")

server_name = "Localhost\\SQLEXPRESS"
database_name = "olist_project"

params = urllib.parse.quote_plus(
    "Driver={ODBC Driver 18 for SQL Server};"
    f"SERVER={server_name};"
    f"DATABASE={database_name};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)


connection_string = f"mssql+pyodbc:///?odbc_connect={params}"
engine = create_engine(connection_string)


csv_files = [
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_products_dataset.csv",
    "olist_customers_dataset.csv",
    "olist_order_payments_dataset.csv"
]

folder_path = r"C:\Users\umair khan\Downloads\archive (1)"

for file_name in csv_files:
    full_path = os.path.join(folder_path, file_name)

    try:
        print(f"\n[EXTRACT] Read a data: {file_name}")
        df = pd.read_csv(full_path)
        print(f"Total rows : {len(df)}")

         #Transform
        df = df.dropna(how="all")
        df = df.drop_duplicates()

        #---Small a table name---
        if "orders" in file_name:
            table_name = "orders"
        elif "order_items" in file_name:
            table_name = "item_order"
        elif "products" in file_name:
            table_name = "products"
        elif "customers" in file_name:
            table_name = "customers"
        elif "payments" in file_name:
            table_name = "payments"
        else:
            table_name = file_name.replace(" .csv", "")


        #Load
        df.to_sql(table_name, con=engine, if_exists= "replace", index=False)
        print(f"[LOAD] Success! '{table_name}' table is complete")

    except Exception as e:
        print(f"Error with{file_name}:  {e}")


print("\n---ETL Process completed---")









