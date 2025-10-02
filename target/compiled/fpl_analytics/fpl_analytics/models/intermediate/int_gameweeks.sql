with 
source as (
    select *
    from "analytics"."staging"."stg_gameweeks"
)

select * from source