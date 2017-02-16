select
avg(tp)::numeric(4,1) as ppg,
(avg(tp*f.exp_factor^2)-avg(tp))::numeric(4,2) as ha
from (
select
game_id,sum(ps) as tp
from
(
select
p.game_id,
unnest(p.period_scores) as ps
from ncaa_pbp.periods p
join ncaa_pbp.team_schedules ts
on (ts.game_id)=(p.game_id)
where
    p.team_id is not null
and ts.year=2016
and ts.home_game
and not(ts.neutral_site)
) t
group by game_id
) m
join ncaa_pbp._factors f
on (f.parameter,f.level)=('field','offense_home');
