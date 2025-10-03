with 
fixtures as (
    select *
    from "analytics"."intermediate"."int_fixtures"
),

teams as (
    select * from "analytics"."intermediate"."int_teams"
),

joined_own_strength as (
    select
        fixtures.*,
        teams.team_strength_score as team_strength,
        case when home then teams.team_strength_home_attack else teams.team_strength_away_attack end as team_attack_strength,
        case when home then teams.team_strength_home_defence else teams.team_strength_away_defence end as team_defence_strength,
    from fixtures left join teams using(team_abbreviation)
),

joined_opponent_strength as (
    select
        joined_own_strength.*,
        teams.team_strength_score as opponent_strength,
        case when home then teams.team_strength_away_attack else teams.team_strength_home_attack end as opponent_attack_strength,
        case when home then teams.team_strength_away_defence else teams.team_strength_home_defence end as opponent_defence_strength,
    from joined_own_strength left join teams on joined_own_strength.opponent_abbreviation=teams.team_abbreviation
),

add_bias as (
    select
        gameweek,
        home,
        team_abbreviation, 
        opponent_abbreviation, 
        --team_strength - opponent_strength as strength_bias,
        team_attack_strength - opponent_defence_strength as attacking_bias,
        team_defence_strength - opponent_attack_strength as defending_bias,
    from joined_opponent_strength
)

select * from add_bias