with 
source as (
    select * exclude(team),
        case when team_abbreviation='NFO' then 'Nottingham Forest' else team end as team
    from "analytics"."staging"."stg_teams"
)

select * from source