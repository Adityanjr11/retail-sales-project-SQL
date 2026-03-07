import pandas as pd
import mysql.connector
import numpy as np

# ---------- Load Excel ----------
df = pd.read_excel("Online Retail.xlsx")

# Replace NaN with None so MySQL accepts NULL
df = df.replace({np.nan: None})

# ---------- Connect to MySQL ----------
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="root",   # replace with your mysql password
    database="sales_db"
)

cursor = conn.cursor()

# ---------- Create Table ----------
create_table_query = """
CREATE TABLE IF NOT EXISTS raw_retail (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice FLOAT,
    CustomerID FLOAT,
    Country VARCHAR(100)
)
"""

cursor.execute(create_table_query)

# ---------- Prepare Insert Query ----------
insert_query = """
INSERT INTO raw_retail (
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
)
VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
"""

# Convert dataframe rows → tuples
data = [tuple(row) for row in df.to_numpy()]

# ---------- Insert Data ----------
cursor.executemany(insert_query, data)

# Commit changes
conn.commit()

print("Data ingestion completed.")

# ---------- Verify Row Count ----------
cursor.execute("SELECT COUNT(*) FROM raw_retail")
result = cursor.fetchone()

print("Total rows in table:", result[0])

# ---------- Close Connection ----------
cursor.close()
conn.close()