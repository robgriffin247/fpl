with 
source as (
    select
        id::int as position_id,
        plural_name_short::varchar as position,
        squad_select::int as max_selectable,
        squad_min_play::int as min_playable,
        squad_max_play::int as max_playable,
    from {{ source("fpl", "element_types") }}
)

select * from source
