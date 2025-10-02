with 
source as (
    select
        id::int as team_id,
        name::varchar as team,
        short_name::varchar as team_abbreviation,
        strength::int as team_strength_score,
        strength_attack_home::int as team_strength_home_attack,
        strength_defence_home::int as team_strength_home_defence,
        strength_attack_away::int as team_strength_away_attack,
        strength_defence_away::int as team_strength_away_defence
    from {{ source("raw", "teams") }}
)

select * from source
