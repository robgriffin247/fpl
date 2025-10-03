with 
source as (
    select * exclude(team),
        replace(team, '''','') as team,
    from "analytics"."staging"."stg_teams"
)

select * from source