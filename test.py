import duckdb

with duckdb.connect("data/raw.duckdb") as con:
    print(con.sql("show all tables").pl())