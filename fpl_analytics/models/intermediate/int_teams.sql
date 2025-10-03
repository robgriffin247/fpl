with 
source as (
    select * exclude(team),
        replace(team, '''','') as team,
    from {{ ref("stg_teams") }}
)

select * from source
