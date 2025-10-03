import duckdb
import streamlit as st
import polars as pl
import emoji

st.set_page_config(layout="wide")

# with duckdb.connect("data/raw.duckdb") as con:
#     players = con.sql("select * from fpl.elements").pl()
#     teams = con.sql("select * from fpl.teams").pl()
#     positions = con.sql("select * from fpl.element_types").pl()
#     fixtures = con.sql("select * from football_data.fixtures").pl()

with duckdb.connect("data/analytics.duckdb") as con:
    obt_players = con.sql("select * from core.obt_players").pl()
    options_position = obt_players[["position", "position_id"]].unique().sort("position_id")["position"].to_list()
    options_availability = obt_players["availability_status"].unique().sort().to_list()
    options_minutes_per_gameweek = [min(obt_players["minutes_played_per_gameweek"].unique().to_list()), max(obt_players["minutes_played_per_gameweek"].unique().to_list())]


options_metrics = {
    # "Form":"current_form",
    "Points":"total_points",
    "Points/90":"points_per_90",
    "Points/GW":"points_per_gameweek",
    "Points/£M":"points_per_million",
    "Starts":"starts",
    "Dreamteam Apps":"dreamteam_appearances",
    "Goals":"goals_scored",
    "Goals/90":"goals_scored_per_90",
    "xG":"expected_goals_scored",
    "G/xG":"goals_scored_xdifferential",
    "Assists":"goals_assisted",
    "Assists/90":"goals_assisted_per_90",
    "xA":"expected_goals_assisted",
    "A/xA":"goals_assisted_xdifferential",
    "Attacking Prospects":"attacking_biases_value",
    "Defending Prospects":"defending_biases_value",
    }

c1, c2, c3, c4 = st.columns(4, gap="large")

c1.selectbox("Positions(s)", index=3, options=options_position, key="selected_position")
c2.multiselect("Availability", options=options_availability, key="selected_availability", default="Available")
c3.slider("Minutes/Gameweek", value=options_minutes_per_gameweek, key="selected_minutes_per_gameweek", step=1, max_value=90)
c4.selectbox("Metric", options=options_metrics.keys(), key="selected_metric")

with duckdb.connect("data/analytics.duckdb") as con:
    selected_players = con.sql(f"""
        with 
        source as (
            select *
            from core.obt_players
            where
                position = '{st.session_state["selected_position"]}'
                and availability_status in ('{"','".join(st.session_state["selected_availability"]) if len(st.session_state["selected_availability"])>0 else "','".join(options_availability)}')
                and minutes_played_per_gameweek >= {st.session_state["selected_minutes_per_gameweek"][0]} and cost <= {st.session_state["selected_minutes_per_gameweek"][1]}
                and {options_metrics.get(st.session_state["selected_metric"])} is not null
        )
        select * from source order by cost_category, {options_metrics.get(st.session_state["selected_metric"])} desc
        """).pl()

budget_players = selected_players.filter(pl.col("cost_category")=="Budget")#.head(5)
midrange_players = selected_players.filter(pl.col("cost_category")=="Mid-Range")#.head(5) 
premium_players = selected_players.filter(pl.col("cost_category")=="Premium")#.head(5)

st.markdown("-----")
def display_players(df):
    df = df.with_columns(
        pl.col("biases").map_elements(lambda x: emoji.emojize(x, language="alias"))
    )
    output = st.dataframe(df[["display_name", "cost", "current_form", "minutes_played_per_gameweek", "biases", options_metrics.get(st.session_state["selected_metric"])]], column_config={
        "display_name": st.column_config.TextColumn("Player", width="medium"),
        "team_abbreviation": st.column_config.TextColumn("Team", width="small"),
        "biases": st.column_config.TextColumn("Def/Att Prospects"),
        "cost": st.column_config.NumberColumn("Cost", format="£%.1fM", width="small"),
        "current_form": st.column_config.NumberColumn("Form", format="%.1f", width="small"),
        "total_points": st.column_config.NumberColumn("Pts", format="%.0f", width="small"),
        "points_per_90": st.column_config.NumberColumn("Pts/90", format="%.2f", width="small"),
        "points_per_gameweek": st.column_config.NumberColumn("Pts/GW", format="%.2f", width="small"),
        "points_per_million": st.column_config.NumberColumn("Pts/£M", format="%.2f", width="small"),
        "minutes_played": st.column_config.NumberColumn("Mins", format="%.0f", width="small"),
        "minutes_played_per_gameweek": st.column_config.NumberColumn("Mins/GW", format="%.1f", width="small"),
        "starts": st.column_config.NumberColumn("Starts", format="%.0f", width="small"),
        "dreamteam_appearances": st.column_config.NumberColumn("Apps", format="%.0f", width="small"),
        "goals_scored": st.column_config.NumberColumn("G", format="%.0f", width="small"),
        "goals_scored_per_90": st.column_config.NumberColumn("G/90", format="%.2f", width="small"),
        "expected_goals_scored": st.column_config.NumberColumn("xG", format="%.2f", width="small"),
        "goals_scored_xdifferential": st.column_config.NumberColumn("G/xG", format="%.2f", width="small"),
        "goals_assisted": st.column_config.NumberColumn("A", format="%.0f", width="small"),
        "goals_assisted_per_90": st.column_config.NumberColumn("A/90", format="%.2f", width="small"),
        "expected_goals_assisted": st.column_config.NumberColumn("xA", format="%.2f", width="small"),
        "goals_assisted_xdifferential": st.column_config.NumberColumn("A/xA", format="%.2f", width="small"),
        "attacking_biases_value": st.column_config.NumberColumn("Prospects", format="%.1f", width="small"),
        "defending_biases_value": st.column_config.NumberColumn("Prospects", format="%.1f", width="small"),
     })

c1, c2, c3 = st.columns(3)

with c1:
    st.markdown("##### Budget Players")
    display_players(budget_players)
with c2:
    st.markdown("##### Mid-Range Players")
    display_players(midrange_players)
with c3:
    st.markdown("##### Premium Players")
    display_players(premium_players)