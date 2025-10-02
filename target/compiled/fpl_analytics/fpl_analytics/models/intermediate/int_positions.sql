with 
source as (
    select *
    from "analytics"."staging"."stg_positions"
)

select * from source