
  
    
    

    create  table
      "analytics"."intermediate"."int_positions__dbt_tmp"
  
    as (
      with 
source as (
    select *
    from "analytics"."staging"."stg_positions"
)

select * from source
    );
  
  