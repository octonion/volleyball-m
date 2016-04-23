begin;

select
r.team_name,p::numeric(4,3)
from ncaa_pbp.rounds r
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(r.school_id,r.year)
where round_id=3
order by p desc;

copy
(
select
r.team_name,p::numeric(4,3)
from ncaa_pbp.rounds r
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(r.school_id,r.year)
where round_id=3
order by p desc
) to '/tmp/champion_p.csv' csv header;

commit;
