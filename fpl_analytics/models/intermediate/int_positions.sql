with 
source as (
    select *
    from {{ ref("stg_positions") }}
)

select * from source
