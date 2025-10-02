
  
    
    

    create  table
      "analytics"."intermediate"."int_players__dbt_tmp"
  
    as (
      with 
source as (
    select * from "analytics"."staging"."stg_players"
),

derive as (
    select
        player_id,
        replace(display_name, '''','') as display_name,
        team_id, 
        position_id,
        cost/10 as cost,
        coalesce(availability_next_gameweek, 100) as availability,
        case availability_code
            when 'a' then 'Available'
            when 'i' then 'Injured'
            when 'd' then 'Doubtful (' || coalesce(availability_next_gameweek, 100)::varchar || '%)'
            when 's' then 'Suspended'
            else null end as availability_status,
        availability_details,
        starts,
        minutes_played,
        total_points,
        gameweek_points,
        points_per_game,
        total_points / minutes_played as points_per_minute_played,
        current_form,
        current_dreamteam,
        dreamteam_appearances,
        influence,
        creativity,
        threat,
        ict_index,
        selection_rate,
        gameweek_transfers_in,
        gameweek_transfers_out,
        gameweek_transfers_in-gameweek_transfers_out as gameweek_net_transfers,
        goals_scored,
        expected_goals_scored,
        goals_scored / expected_goals_scored as goals_scored_differential,
        goals_assisted,
        expected_goals_assisted,
        goals_assisted / expected_goals_assisted as goals_assisted_differential,
        goals_scored + goals_assisted as goal_contributions,
        expected_goals_scored + expected_goals_assisted as expected_goal_contributions,
        (goals_scored + goals_assisted) / (expected_goals_scored + expected_goals_assisted) as expected_goal_contributions_differential,
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
)



select * from derive
    );
  
  