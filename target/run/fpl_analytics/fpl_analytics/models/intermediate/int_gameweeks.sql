
  
    
    

    create  table
      "analytics"."intermediate"."int_gameweeks__dbt_tmp"
  
    as (
      with 
source as (
    select *
    from "analytics"."staging"."stg_gameweeks"
)

select * from source
    );
  
  