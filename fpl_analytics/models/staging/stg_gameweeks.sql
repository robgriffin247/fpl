with 
source as (
    select
        id::int as gameweek
    from {{ source("raw", "events") }}
)

select * from source
