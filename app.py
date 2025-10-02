import duckdb
import streamlit as st
import polars as pl

st.set_page_config(layout="wide")


with duckdb.connect("data/raw.duckdb") as con:
    players = con.sql("select * from fpl.elements").pl()
    teams = con.sql("select * from fpl.teams").pl()
    positions = con.sql("select * from fpl.element_types").pl()

with duckdb.connect("data/analytics.duckdb") as con:
    obt_players = con.sql("select * from core.obt_players").pl()
    options_player = obt_players[["display_name", "team_id", "position_id"]].sort("team_id", "position_id", "display_name")["display_name"].to_list()
    options_team = obt_players[["team", "team_id"]].unique().sort("team_id")["team"].to_list()
    options_position = obt_players[["position", "position_id"]].unique().sort("position_id")["position"].to_list()
    options_cost = [min(obt_players["cost"].unique().to_list()), max(obt_players["cost"].unique().to_list())]
    
    options_availability = obt_players["availability_status"].unique().sort().to_list()
    options_minutes_played = [min(obt_players["minutes_played"].unique().to_list()), max(obt_players["minutes_played"].unique().to_list())]
    options_starts = [min(obt_players["starts"].unique().to_list()), max(obt_players["starts"].unique().to_list())]
    options_total_points = [min(obt_players["total_points"].unique().to_list()), max(obt_players["total_points"].unique().to_list())]
    options_current_form = [min(obt_players["current_form"].unique().to_list()), max(obt_players["current_form"].unique().to_list())]

c1, c2, c3, c4 = st.columns(4)

c1.multiselect("Player(s)", options=options_player, key="selected_player")
c2.multiselect("Team(s)", options=options_team, key="selected_team")
c3.multiselect("Positions(s)", options=options_position, key="selected_position")
c4.slider("Cost", value=options_cost, key="selected_cost")
c1.multiselect("Availability", options=options_availability, key="selected_availability")


with duckdb.connect("data/analytics.duckdb") as con:
    selected_players = con.sql(f"""
        select
            display_name,
            position,
            cost,
            availability_status,
            current_form,
            minutes_played,
            points_per_minute_played
        from core.obt_players
        where
            cost >= {st.session_state["selected_cost"][0]} and cost <= {st.session_state["selected_cost"][1]}
            and display_name in ('{"','".join(st.session_state["selected_player"]) if len(st.session_state["selected_player"])>0 else "','".join(options_player)}')
            and team in ('{"','".join(st.session_state["selected_team"]) if len(st.session_state["selected_team"])>0 else "','".join(options_team)}')
            and position in ('{"','".join(st.session_state["selected_position"]) if len(st.session_state["selected_position"])>0 else "','".join(options_position)}')
            and availability_status in ('{"','".join(st.session_state["selected_availability"]) if len(st.session_state["selected_availability"])>0 else "','".join(options_availability)}')
        """).pl()
    
st.dataframe(selected_players)
