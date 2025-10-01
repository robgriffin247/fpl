import duckdb
import streamlit as st

st.set_page_config(layout="wide")

with duckdb.connect("data/analytics.duckdb") as con:
    stg_players = con.sql("select * from intermediate.int_players").pl()

st.dataframe(stg_players)