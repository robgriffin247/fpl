with 
players as (
    select * from {{ ref("int_players") }}
),

teams as (
    select * from {{ ref("int_teams") }}
),

positions as (
    select * from {{ ref("int_positions") }}
),

gameweeks as (
    select gameweek from core.dim_gameweeks where is_coming_gameweek
),

fixtures as (
    select *, 
        ntile(5) over (order by attacking_bias) as attacking_bias_cat,
        ntile(5) over (order by defending_bias) as defending_bias_cat
    from core.fact_fixtures
),

add_icons as (
    select *,
        case attacking_bias_cat
            when 1 then ':heart:'
            when 2 then ':orange_heart:'
            when 3 then ':yellow_heart:'
            when 4 then ':green_heart:'
            when 5 then ':blue_heart:'
            else ':black_heart:'
            end as attacking_bias_icon,
        case defending_bias_cat
            when 1 then ':heart:'
            when 2 then ':orange_heart:'
            when 3 then ':yellow_heart:'
            when 4 then ':green_heart:'
            when 5 then ':blue_heart:'
            else ':black_heart:'
            end as defending_bias_icon
    from fixtures
),

filter_fixtures as (
    select * from add_icons
    where gameweek >= (select * from gameweeks) and gameweek <= ((select * from gameweeks)+2)
),

aggregate_fixtures as (
    select
        team_abbreviation,
        (sum(attacking_bias) over (partition by team_abbreviation order by gameweek)) / 3 as attacking_biases_value,
        (sum(defending_bias) over (partition by team_abbreviation order by gameweek)) / 3 as defending_biases_value,
        listagg(attacking_bias_icon, '') over (partition by team_abbreviation order by gameweek) as attacking_biases,
        listagg(defending_bias_icon, '') over (partition by team_abbreviation order by gameweek) as defending_biases,
    from filter_fixtures,
    qualify row_number() over (partition by team_abbreviation order by gameweek desc) = 1
),


join_to_players as (
    select
        players.*,
        teams.team,
        teams.team_abbreviation,
        positions.position,
        aggregate_fixtures.attacking_biases_value,
        aggregate_fixtures.defending_biases_value,
        aggregate_fixtures.defending_biases || '/' || aggregate_fixtures.attacking_biases as biases,
    from players 
        left join teams using(team_id)
        left join positions using(position_id)
        left join aggregate_fixtures using(team_abbreviation)
),

select_cols as (
    select
        player_id,
        display_name as player,
        display_name || ' [' || team_abbreviation || ']' as display_name,
        team_id,
        team,
        team_abbreviation,
        attacking_biases_value,
        defending_biases_value,
        biases,
        position_id,
        position,
        cost,
        cost_category,

        availability,
        availability_status,
        availability_details,

        current_form,

        total_points,
        points_per_gameweek,
        points_per_90,
        points_per_million,
        gameweek_points,

        minutes_played,
        minutes_played_per_gameweek,
        starts,

        current_dreamteam,
        dreamteam_appearances,

        goals_scored,
        goals_scored_per_90,
        goals_scored_per_gameweek,
        expected_goals_scored,
        expected_goals_scored_per_90,
        expected_goals_scored_per_gameweek,
        goals_scored_xdifferential,

        goals_assisted,
        goals_assisted_per_90,
        goals_assisted_per_gameweek,
        expected_goals_assisted,
        expected_goals_assisted_per_90,
        expected_goals_assisted_per_gameweek,
        goals_assisted_xdifferential,

    from join_to_players
)

select * from select_cols
