with 
source as (
    select *
    from {{ source("raw", "element_stats") }}
)

select * from source
