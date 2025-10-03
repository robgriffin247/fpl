import duckdb

with duckdb.connect("data/analytics.duckdb") as con:
    players = con.sql("select * from core.obt_players").pl()
    gameweeks = con.sql("select gameweek from core.dim_gameweeks where is_coming_gameweek").pl()
    fixtures = con.sql("select * from core.fact_fixtures").pl()

    prototype = con.sql("""
                        with
                        players as (
                            select * from core.obt_players
                        ),
                        gameweeks as (
                            select gameweek from core.dim_gameweeks where is_coming_gameweek
                        ),
                        fixtures as (
                            select *, 
                                ntile(5) over (order by attacking_bias) as attacking_bias_cat,
                                ntile(5) over (order by defending_bias) as defending_bias_cat
                            from core.fact_fixtures
                        ),

                        add_icons as (
                            select *,
                                case attacking_bias_cat
                                    when 1 then ':heart:'
                                    when 2 then ':orange_heart:'
                                    when 3 then ':yellow_heart:'
                                    when 4 then ':green_heart:'
                                    when 5 then ':blue_heart:'
                                    else ':black_heart:'
                                    end as attacking_bias_icon,
                                case defending_bias_cat
                                    when 1 then ':heart:'
                                    when 2 then ':orange_heart:'
                                    when 3 then ':yellow_heart:'
                                    when 4 then ':green_heart:'
                                    when 5 then ':blue_heart:'
                                    else ':black_heart:'
                                    end as defending_bias_icon
                            from fixtures
                        ),

                        filter_fixtures as (
                            select * from add_icons
                            where gameweek in ((select * from gameweeks), (select * from gameweeks)+1, (select * from gameweeks)+2)
                        ),

                        aggregate_fixtures as (
                            select
                                team_abbreviation,
                                listagg(attacking_bias_icon, '') over (partition by team_abbreviation order by gameweek) as attacking_biases,
                                listagg(defending_bias_icon) over (partition by team_abbreviation order by gameweek) as defending_biases,
                            from filter_fixtures,
                            qualify row_number() over (partition by team_abbreviation order by gameweek desc) = 1
                        )
                        

                        select * from aggregate_fixtures
    """).pl()

print(players)
print(fixtures)
print(gameweeks)
print(prototype)