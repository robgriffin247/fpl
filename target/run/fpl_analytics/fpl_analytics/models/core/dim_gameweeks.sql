
  
    
    

    create  table
      "analytics"."core"."dim_gameweeks__dbt_tmp"
  
    as (
      with 
source as (
    select *
    from "analytics"."intermediate"."int_gameweeks"
)

select * from source
    );
  
  