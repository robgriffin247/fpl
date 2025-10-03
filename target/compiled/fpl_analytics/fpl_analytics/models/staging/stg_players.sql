with 
source as (
    select *
    from "rawdb"."fpl"."elements"
    where _dlt_load_id = (select max(_dlt_load_id) from "rawdb"."fpl"."elements")
),

remove_non_selectables as (
    select * 
    from source 
    where can_select and not removed
),

select_columns as (
    select
        id::int as player_id,
        first_name::varchar as first_name,
        second_name::varchar as second_name,
        web_name::varchar as display_name,
        team::int as team_id,
        element_type::int as position_id,
        now_cost::int as cost,
        chance_of_playing_this_round::int as availability_this_gameweek,
        chance_of_playing_next_round::int as availability_next_gameweek,
        status::varchar as availability_code,
        news::varchar as availability_details,
        total_points::int as total_points,
        event_points:: int as gameweek_points,
        points_per_game::float as points_per_game,
        form::float as current_form,
        in_dreamteam::boolean as current_dreamteam,
        dreamteam_count::int as dreamteam_appearances,
        influence::float as influence,
        creativity::float as creativity,
        threat::float as threat,
        ict_index::float as ict_index,
        selected_by_percent::float as selection_rate,
        transfers_in_event::int as gameweek_transfers_in,
        transfers_out_event::int as gameweek_transfers_out,
        starts::int as starts,
        minutes::int as minutes_played,
        goals_scored::int as goals_scored,
        expected_goals::float as expected_goals_scored,
        assists::int as goals_assisted,
        expected_assists::float as expected_goals_assisted,
        goals_conceded::int as goals_conceded,
        expected_goals_conceded::float as expected_goals_conceded,
        clearances_blocks_interceptions::int as clearances_blocks_interceptions,
        recoveries::int as recoveries,
        tackles::int as tackles,
        own_goals::int as own_goals,
        saves::int as saves_made,
        clean_sheets::int as clean_sheets,
        penalties_saved::int as penalties_saved,
        yellow_cards::int as yellow_cards,
        red_cards::int as red_cards,
        bonus::int as bonus_points,
        bps::int as bonus_points_system,
        penalties_order::int as team_penalty_takers_rank,
        penalties_missed::int as penalties_missed,
        
    from remove_non_selectables
)

select * from select_columns