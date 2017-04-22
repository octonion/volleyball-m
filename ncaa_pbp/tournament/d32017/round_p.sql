begin;

select round_id as rd,
r.team_name as name,
p::numeric(4,3) as p
from ncaa_pbp.rounds r
join ncaa_pbp.teams t
 on (t.team_id,t.year)=(r.school_id,r.year)
where TRUE
and p<1.0
order by round_id asc,p desc;

copy
(
select round_id as rd,
r.team_name as name,
p::numeric(4,3) as p
from ncaa_pbp.rounds r
join ncaa_pbp.teams t
 on (t.team_id,t.year)=(r.school_id,r.year)
where TRUE
and p<1.0
order by round_id asc,p desc
)
to '/tmp/round_p.csv' csv header;

commit;
