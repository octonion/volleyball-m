begin;

create temporary table r (
       rk	 serial,
       school 	 text,
       school_id integer,
       div_id	 integer,
       year	 integer,
       str	 float,
       ofs	 float,
       dfs	 float,
       sos	 float
);

insert into r
(school,school_id,div_id,year,str,ofs,dfs,sos)
(
select
--coalesce(sd.school_name,sf.school_id::text),
t.team_name,
sf.school_id,
t.division as div_id,
sf.year,
(sf.strength*o.exp_factor/d.exp_factor) as str,
(offensive*o.exp_factor) as ofs,
(defensive*d.exp_factor) as dfs,
schedule_strength as sos
from ncaa_pbp._schedule_factors sf
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(sf.school_id,sf.year)
--join ncaa_pbp.teams sd
--  on (sd.school_id,sd.year)=(sf.school_id,sf.year)
join ncaa_pbp._factors o
  on (o.parameter,o.level::integer)=('o_div',t.division)
join ncaa_pbp._factors d
  on (d.parameter,d.level::integer)=('d_div',t.division)
where sf.year in (2016)
order by str desc);

select
rk,
school,
'D'||div_id as div,
str::numeric(4,3),
ofs::numeric(4,3),
dfs::numeric(4,3),
sos::numeric(4,3)
from r
order by rk asc;

copy
(
select
rk,
school,
'D'||div_id as div,
str::numeric(4,3),
ofs::numeric(4,3),
dfs::numeric(4,3),
sos::numeric(4,3)
from r
order by rk asc
) to '/tmp/current_ranking.csv' csv header;

commit;
