with 
source as (
    select *
    from {{ source("fpl", "element_stats") }}
)

select * from source
