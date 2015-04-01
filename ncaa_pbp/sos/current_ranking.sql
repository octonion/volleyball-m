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
--sd.div_id as div_id,
null,
sf.year,
(sf.strength) as str,
(offensive) as ofs,
(defensive) as dfs,
schedule_strength as sos
from ncaa_pbp._schedule_factors sf
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(sf.school_id,sf.year)
--join ncaa_pbp.teams sd
--  on (sd.school_id,sd.year)=(sf.school_id,sf.year)
--join ncaa_pbp._factors o
--  on (o.parameter,o.level::integer)=('o_div',sd.div_id)
--join ncaa_pbp._factors d
--  on (d.parameter,d.level::integer)=('d_div',sd.div_id)
where sf.year in (2015)
order by str desc);

select
rk,school,
str::numeric(4,3),
ofs::numeric(4,3),
dfs::numeric(4,3),
sos::numeric(4,3)
from r
order by rk asc;

copy
(
select
rk,school,
str::numeric(4,3),
ofs::numeric(4,3),
dfs::numeric(4,3),
sos::numeric(4,3)
from r
order by rk asc
) to '/tmp/current_ranking.csv' csv header;

commit;
