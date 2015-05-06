begin;

set timezone to 'America/New_York';

create temporary table predict (
       game_date			date,
       site				text,
       home				text,
       away				text,
       h				float,
       v				float,
       hv				float,
       p				float,
       q				float
);

insert into predict
(game_date,site,home,away,h,v,hv,p)
(
select
g.game_date::date as date,
'home' as site,
hd.school_name as home,
vd.school_name as away,
ln(h.offensive),
ln(v.defensive),
h.offensive*v.defensive as hv,
h.offensive*v.defensive/(1.0+h.offensive*v.defensive) as p
from ncaa.games g
join ncaa._schedule_factors h
  on (h.year,h.school_id)=(g.year,g.school_id)
join ncaa._schedule_factors v
  on (v.year,v.school_id)=(g.year,g.opponent_id)
join ncaa.schools_divisions hd
  on (hd.year,hd.school_id)=(h.year,h.school_id)
join ncaa.schools_divisions vd
  on (vd.year,vd.school_id)=(v.year,v.school_id)
join ncaa._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa._factors d
  on (d.parameter,d.level)=('field','defense_home')
where
not(g.game_date='')
and g.game_date::date = current_date-1
and g.location='Home'

union

select
g.game_date::date as date,
'neutral' as site,
hd.school_name as home,
vd.school_name as away,
ln(h.offensive),
ln(v.defensive),
h.offensive*v.defensive as hv,
h.offensive*v.defensive/(1.0+h.offensive*v.defensive) as p

from ncaa.games g
join ncaa._schedule_factors h
  on (h.year,h.school_id)=(g.year,g.school_id)
join ncaa._schedule_factors v
  on (v.year,v.school_id)=(g.year,g.opponent_id)
join ncaa.schools_divisions hd
  on (hd.year,hd.school_id)=(h.year,h.school_id)
join ncaa.schools_divisions vd
  on (vd.year,vd.school_id)=(v.year,v.school_id)
where
not(g.game_date='')
and g.game_date::date = current_date-1
and g.location='Neutral'
and (g.school_id < g.opponent_id)
--order by date,home asc
);

update predict
set q=1-p;

select
game_date as date,
site,
home,
away,
h::numeric(5,3) as h,
v::numeric(5,3) as v,
hv::numeric(5,3) as hv,
p::numeric(4,3) as p,
(p^3)::numeric(4,3) as w3,
(3*p^3*q)::numeric(4,3) as w4,
(6*p^3*q^2)::numeric(4,3) as w5,
(p^3+3*p^3*q+6*p^3*q^2)::numeric(4,3) as win,
(1.0-(p^3+3*p^3*q+6*p^3*q^2))::numeric(4,3) as lose
from predict
order by date,home asc;

select
game_date as date,
site,
home,
away,
(q^3)::numeric(4,3) as l3,
(3*q^3*p)::numeric(4,3) as l4,
(6*q^3*p^2)::numeric(4,3) as l5,
(3*(p^3+3*p^3*q+6*p^3*q^2)+2*(6*q^3*p^2)+1*(3*q^3*p)+0*(q^3))::numeric(4,3)
as e_ws,
(3*(q^3+3*q^3*p+6*q^3*p^2)+2*(6*p^3*q^2)+1*(3*p^3*q)+0*(p^3))::numeric(4,3)
as e_ls
from predict
order by date,home asc;

commit;
