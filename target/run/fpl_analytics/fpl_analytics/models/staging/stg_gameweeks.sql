
  
    
    

    create  table
      "analytics"."staging"."stg_gameweeks__dbt_tmp"
  
    as (
      with 
source as (
    select
        id::int as gameweek
    from "rawdb"."fpl"."events"
)

select * from source
    );
  
  