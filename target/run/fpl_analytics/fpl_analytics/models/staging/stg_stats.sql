
  
    
    

    create  table
      "analytics"."staging"."stg_stats__dbt_tmp"
  
    as (
      with 
source as (
    select *
    from "rawdb"."fpl"."element_stats"
)

select * from source
    );
  
  