begin;

create temporary table r (
       team_id	       	 integer,
       div	 	 text,
       year	 	 integer,
       str	 	 float,
       ofs	 	 float,
       dfs	 	 float,
       sos	 	 float
);

insert into r
(team_id,div,year,str,ofs,dfs,sos)
(
select
t.team_id,
'D' || t.division as div,
sf.year,
(sf.strength*o.exp_factor/d.exp_factor)::numeric(4,3) as str,
(offensive*o.exp_factor)::numeric(4,3) as ofs,
(defensive*d.exp_factor)::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from ncaa_pbp._schedule_factors sf
left outer join ncaa_pbp.teams t
  on (t.team_id,t.year)=(sf.school_id,sf.year)
left outer join ncaa_pbp._factors o
  on (o.parameter,o.level)=('o_div',t.division::text)
left outer join ncaa_pbp._factors d
  on (d.parameter,d.level)=('d_div',t.division::text)
where
TRUE
and t.team_id is not null
order by ofs desc);

select
year,
exp(avg(ln(str)))::numeric(9,3) as str,
exp(avg(ln(ofs)))::numeric(9,3) as ofs,
exp(-avg(ln(dfs)))::numeric(9,3) as dfs,
exp(avg(ln(sos)))::numeric(9,3) as sos,
count(*) as n
from r
group by year
order by year asc;

select
year,
div,
exp(avg(ln(str)))::numeric(9,3) as str,
exp(avg(ln(ofs)))::numeric(9,3) as ofs,
exp(-avg(ln(dfs)))::numeric(9,3) as dfs,
exp(avg(ln(sos)))::numeric(9,3) as sos,
count(*) as n
from r
where div is not null
group by year,div
order by year asc,str desc;

select * from r
where div is null;

commit;
