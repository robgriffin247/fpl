import duckdb

if __name__=="__main__":
    with duckdb.connect("data/raw.duckdb") as con:
        print(con.sql("select first_name, second_name, total_points,  from fpl_raw.elements where can_select=false"))
