with 
source as (
    select         
        gameweek,
        home_goals,
        away_goals,
        home_team_abbreviation,
        away_team_abbreviation,
    from {{ ref("stg_fixtures") }}
),

fix_nfo as (
    select * exclude(home_team_abbreviation, away_team_abbreviation),
        case when home_team_abbreviation='NOT' then 'NFO' else home_team_abbreviation end as home_team_abbreviation,
        case when away_team_abbreviation='NOT' then 'NFO' else away_team_abbreviation end as away_team_abbreviation,
    from source
),

home_fixtures as (
    select 
        gameweek,
        home_team_abbreviation as team_abbreviation,
        away_team_abbreviation as opponent_abbreviation,
        true as home
    from fix_nfo
),

away_fixtures as (
    select 
        gameweek,
        away_team_abbreviation as team_abbreviation,
        home_team_abbreviation as opponent_abbreviation,
        false as home
    from fix_nfo
),

all_fixtures as (
    select * from home_fixtures union all select * from away_fixtures 
)

select * from all_fixtures
