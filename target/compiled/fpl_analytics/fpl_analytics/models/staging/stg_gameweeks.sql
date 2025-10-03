with 
source as (
    select
        id::int as gameweek,
        is_next as is_coming_gameweek,
    from "rawdb"."fpl"."events"
)

select * from source