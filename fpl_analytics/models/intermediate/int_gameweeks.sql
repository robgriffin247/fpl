with 
source as (
    select *
    from {{ ref("stg_gameweeks") }}
)

select * from source
