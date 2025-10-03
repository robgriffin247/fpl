with 
source as (
    select *
    from {{ ref("int_gameweeks") }}
)

select * from source
