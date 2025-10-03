
  
    
    

    create  table
      "analytics"."staging"."stg_gameweeks__dbt_tmp"
  
    as (
      with 
source as (
    select
        id::int as gameweek,
        is_next::boolean as is_coming_gameweek,
        _dlt_load_id::float as _dlt_load_id
    from "rawdb"."fpl"."events"
)

select * from source
    );
  
  