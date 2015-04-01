begin;

create temporary table r (
       school_id	 integer,
       div	 	 integer,
       year	 	 integer,
--       str	 	 float
       ofs	 	 float,
       dfs	 	 float
--       sos	 	 float
);

insert into r
(school_id,div,year,ofs,dfs)
(
select
t.school_id,
t.div_id as div,
sf.year,
--(sf.strength*o.exp_factor/d.exp_factor)::numeric(9,3) as str,
(offensive*o.exp_factor)::numeric(9,3) as ofs,
(defensive*d.exp_factor)::numeric(9,3) as dfs
--schedule_strength::numeric(9,3) as sos
from ncaa_pbp._schedule_factors sf
left outer join ncaa_pbp.schools_divisions t
  on (t.school_id,t.year)=(sf.school_id,sf.year)
left outer join ncaa_pbp._factors o
  on (o.parameter,o.level)=('o_div',length(t.division)::text)
left outer join ncaa_pbp._factors d
  on (d.parameter,d.level)=('d_div',length(t.division)::text)
where sf.year in (2015)
and t.school_id is not null
order by ofs desc);

select
year,
--exp(avg(log(str)))::numeric(9,3) as str,
exp(avg(log(ofs)))::numeric(9,3) as ofs,
exp(-avg(log(dfs)))::numeric(9,3) as dfs,
--exp(avg(log(sos)))::numeric(9,3) as sos,
count(*) as n
from r
group by year
order by year asc;

select
year,
div,
--exp(avg(log(str)))::numeric(9,3) as str,
exp(avg(log(ofs)))::numeric(9,3) as ofs,
exp(-avg(log(dfs)))::numeric(9,3) as dfs,
--exp(avg(log(sos)))::numeric(9,3) as sos,
count(*) as n
from r
where div is not null
group by year,div
order by year asc,str desc;

select * from r
where div is null
and year=2015;

commit;
