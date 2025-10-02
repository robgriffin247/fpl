with 
source as (
    select
        id::int as gameweek
    from "rawdb"."fpl"."events"
)

select * from source