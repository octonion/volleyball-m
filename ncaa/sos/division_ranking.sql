begin;

create temporary table r (
       school_id	 integer,
       div	 	 integer,
       year	 	 integer,
       str	 	 float,
       ofs	 	 float,
       dfs	 	 float,
       sos	 	 float
);

insert into r
(school_id,div,year,str,ofs,dfs,sos)
(
select
t.school_id,
t.div_id as div,
sf.year,
ln(sf.strength)+ln(o.exp_factor)-ln(d.exp_factor) as str,
ln(offensive)+ln(o.exp_factor) as ofs,
ln(defensive)+ln(d.exp_factor) as dfs,
ln(schedule_strength) as sos
--(sf.strength*o.exp_factor/d.exp_factor)::numeric(9,3) as str,
--(offensive*o.exp_factor)::numeric(9,3) as ofs,
--(defensive*d.exp_factor)::numeric(9,3) as dfs
--schedule_strength::numeric(9,3) as sos
from ncaa._schedule_factors sf
left outer join ncaa.schools_divisions t
  on (t.school_id,t.year)=(sf.school_id,sf.year)
left outer join ncaa._factors o
  on (o.parameter,o.level)=('o_div',length(t.division)::text)
left outer join ncaa._factors d
  on (d.parameter,d.level)=('d_div',length(t.division)::text)
where sf.year in (2015)
and t.school_id is not null
order by ofs desc);

select
year,
avg(str)::numeric(5,3) as str,
avg(ofs)::numeric(5,3) as ofs,
avg(dfs)::numeric(5,3) as dfs,
avg(sos)::numeric(5,3) as sos,
count(*) as n
from r
group by year
order by year asc;

select
year,
div,
avg(str)::numeric(5,3) as str,
avg(ofs)::numeric(5,3) as ofs,
avg(dfs)::numeric(5,3) as dfs,
avg(sos)::numeric(5,3) as sos,
count(*) as n
from r
where div is not null
group by year,div
order by year asc,str desc;

select * from r
where div is null
and year=2015;

commit;
