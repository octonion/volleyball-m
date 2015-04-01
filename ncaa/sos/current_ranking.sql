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
coalesce(sd.school_name,sf.school_id::text),
sf.school_id,
sd.div_id as div_id,
sf.year,
(sf.strength*o.exp_factor/d.exp_factor) as str,
(offensive*o.exp_factor) as ofs,
(defensive*d.exp_factor) as dfs,
schedule_strength as sos
from ncaa._schedule_factors sf
join ncaa.schools_divisions sd
  on (sd.school_id,sd.year)=(sf.school_id,sf.year)
join ncaa._factors o
  on (o.parameter,o.level::integer)=('o_div',sd.div_id)
join ncaa._factors d
  on (d.parameter,d.level::integer)=('d_div',sd.div_id)
where sf.year in (2015)
order by str desc);

select
rk,school,div_id as div,
str::numeric(12,6),
ofs::numeric(12,6),
dfs::numeric(12,6),
sos::numeric(12,6)
from r
order by rk asc;

copy
(
select
rk,school,div_id as div,
str::numeric(12,6),
ofs::numeric(12,6),
dfs::numeric(12,6),
sos::numeric(12,6)
from r
order by rk asc
) to '/tmp/current_ranking.csv' csv header;

commit;
