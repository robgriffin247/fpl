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

join_players as (
    select
        players.*,
        teams.team,
        teams.team_abbreviation,
        positions.position
    from players 
        left join teams using(team_id)
        left join positions using(position_id)
)

select * from join_players
