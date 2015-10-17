begin;

select
r.year,
t.division as tdiv,
o.division as odiv,
sum(case when r.team_won then 1 else 0 end) as won,
sum(case when not(r.team_won) then 1 else 0 end) as lost,
count(*)
from ncaa_pbp.team_schedules r
left join ncaa_pbp.teams t
  on (t.team_id,t.year)=(r.team_id,r.year)
left join ncaa_pbp.teams o
  on (o.team_id,o.year)=(r.opponent_id,r.year)
where
    t.division<=o.division
and r.year between 2012 and 2015
and r.team_won is not null
group by r.year,t.division,o.division
order by r.year,t.division,o.division;

commit;
