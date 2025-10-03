with 
source as (
    select * from {{ ref("stg_players") }}
),

gameweek as (
    select gameweek-1 as gameweeks_played from {{ ref("int_gameweeks") }} where is_coming_gameweek
),

derive as (
    select
        player_id,
        replace(display_name, '''','') as display_name,
        team_id, 
        position_id,
        cost/10 as cost,
        coalesce(availability_next_gameweek, 100) as availability,
        availability_code,
        case availability_code
            when 'a' then 'Available'
            when 'i' then 'Injured'
            when 'd' then 'Doubtful (' || coalesce(availability_next_gameweek, 100)::varchar || '%)'
            when 's' then 'Suspended'
            else null end as availability_status,
        availability_details,
        starts,
        coalesce(minutes_played, 0) as minutes_played,
        cast(coalesce(minutes_played, 0)/(select gameweeks_played from gameweek) as int) as minutes_played_per_gameweek,
        total_points,
        gameweek_points,
        coalesce(total_points/(select gameweeks_played from gameweek), 0) as points_per_gameweek,
        coalesce(total_points / minutes_played * 90, 0) as points_per_90,
        total_points / (cost / 10) as points_per_million,
        current_form,
        current_dreamteam,
        dreamteam_appearances,
        influence,
        creativity,
        threat,
        -- ict_index,
        selection_rate,
        -- gameweek_transfers_in,
        -- gameweek_transfers_out,
        -- gameweek_transfers_in-gameweek_transfers_out as gameweek_net_transfers,
        
        goals_scored,
        goals_scored / minutes_played * 90 as goals_scored_per_90,
        goals_scored / (select gameweeks_played from gameweek) as goals_scored_per_gameweek,
        expected_goals_scored,
        expected_goals_scored / minutes_played * 90 as expected_goals_scored_per_90,
        expected_goals_scored/(select gameweeks_played from gameweek) as expected_goals_scored_per_gameweek,
        goals_scored / expected_goals_scored as goals_scored_xdifferential,
        
        goals_assisted,
        goals_assisted / minutes_played * 90 as goals_assisted_per_90,
        goals_assisted/(select gameweeks_played from gameweek) as goals_assisted_per_gameweek,
        expected_goals_assisted,
        expected_goals_assisted / minutes_played * 90 as expected_goals_assisted_per_90,
        expected_goals_assisted/(select gameweeks_played from gameweek) as expected_goals_assisted_per_gameweek,
        goals_assisted / expected_goals_assisted as goals_assisted_xdifferential,
        
        goals_scored + goals_assisted as goal_contributions,
        expected_goals_scored + expected_goals_assisted as expected_goal_contributions,
        (goals_scored + goals_assisted) / (expected_goals_scored + expected_goals_assisted) as expected_goal_contributions_xdifferential,
        
        goals_conceded,
        expected_goals_conceded,
        clearances_blocks_interceptions,
        recoveries,
        tackles,
        own_goals,
        saves_made,
        clean_sheets,
        penalties_saved,
        yellow_cards,
        red_cards,
        bonus_points,
        bonus_points_system,
        team_penalty_takers_rank,
        penalties_missed,
    from source
),

add_cost_category as (
    select *,
        ntile(5) over (partition by position_id order by cost) as cost_category 
    from derive
),

convert_cost_category as (
    select * exclude(cost_category),
        case cost_category when 1 then 'Budget' when 2 then 'Budget' when 3 then 'Mid-Range' when 4 then 'Mid-Range' when 5 then 'Premium' else null end as cost_category 
    from add_cost_category
),

coalesce_nulls as (
    select 
        * exclude(
            points_per_90, 
            goals_scored_per_90, goals_scored_xdifferential, expected_goals_scored_per_90,
            goals_assisted_per_90, goals_assisted_xdifferential, expected_goals_assisted_per_90
            ),
        case when minutes_played>0 then points_per_90 else 0 end as points_per_90,
        case when minutes_played>0 then goals_scored_per_90 else 0 end as goals_scored_per_90,
        case when minutes_played>0 then goals_scored_xdifferential else 0 end as goals_scored_xdifferential,
        case when minutes_played>0 then expected_goals_scored_per_90 else 0 end as expected_goals_scored_per_90,
        case when minutes_played>0 then goals_assisted_per_90 else 0 end as goals_assisted_per_90,
        case when minutes_played>0 then goals_assisted_xdifferential else 0 end as goals_assisted_xdifferential,
        case when minutes_played>0 then expected_goals_assisted_per_90 else 0 end as expected_goals_assisted_per_90,
    from convert_cost_category
)




select * from coalesce_nulls
