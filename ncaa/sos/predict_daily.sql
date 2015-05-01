begin;

set timezone to 'America/New_York';

create temporary table predict (
       game_date			date,
       site				text,
       home				text,
       hd				text,
       away				text,
       vd				text,
       p				float,
       q				float
);

insert into predict
(game_date,site,home,hd,away,vd,p)
(
select
g.game_date::date as date,
'home' as site,
hd.school_name as home,
'D'||hd.div_id as hd,
vd.school_name as away,
'D'||vd.div_id as vd,
hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor/
(1.0+hdof.exp_factor*h.offensive*o.exp_factor*v.defensive*vddf.exp_factor)
  as p

from ncaa.games g
join ncaa._schedule_factors h
  on (h.year,h.school_id)=(g.year,g.school_id)
join ncaa._schedule_factors v
  on (v.year,v.school_id)=(g.year,g.opponent_id)
join ncaa.schools_divisions hd
  on (hd.year,hd.school_id)=(h.year,h.school_id)
join ncaa._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa.schools_divisions vd
  on (vd.year,vd.school_id)=(v.year,v.school_id)
join ncaa._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa._factors d
  on (d.parameter,d.level)=('field','defense_home')
where
not(g.game_date='')
and g.game_date::date = current_date
and g.location='Home'

union

select
g.game_date::date as date,
'neutral' as site,
hd.school_name as home,
'D'||hd.div_id as hd,
vd.school_name as away,
'D'||vd.div_id as vd,
hdof.exp_factor*h.offensive*v.defensive*vddf.exp_factor/
(1.0+hdof.exp_factor*h.offensive*v.defensive*vddf.exp_factor) as p

from ncaa.games g
join ncaa._schedule_factors h
  on (h.year,h.school_id)=(g.year,g.school_id)
join ncaa._schedule_factors v
  on (v.year,v.school_id)=(g.year,g.opponent_id)
join ncaa.schools_divisions hd
  on (hd.year,hd.school_id)=(h.year,h.school_id)
join ncaa._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa.schools_divisions vd
  on (vd.year,vd.school_id)=(v.year,v.school_id)
join ncaa._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
where
not(g.game_date='')
and g.game_date::date = current_date
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
hd,
away,
vd,
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
hd,
away,
vd,
(q^3)::numeric(4,3) as l3,
(3*q^3*p)::numeric(4,3) as l4,
(6*q^3*p^2)::numeric(4,3) as l5,
(3*(p^3+3*p^3*q+6*p^3*q^2)+2*(6*q^3*p^2)+1*(3*q^3*p)+0*(q^3))::numeric(4,3)
as e_ws,
(3*(q^3+3*q^3*p+6*q^3*p^2)+2*(6*p^3*q^2)+1*(3*p^3*q)+0*(p^3))::numeric(4,3)
as e_ls
from predict
order by date,home asc;

copy
(
select
game_date as date,
site,
home,
hd,
away,
vd,
(p^3)::numeric(4,3) as w3,
(3*p^3*q)::numeric(4,3) as w4,
(6*p^3*q^2)::numeric(4,3) as w5,
(q^3)::numeric(4,3) as l3,
(3*q^3*p)::numeric(4,3) as l4,
(6*q^3*p^2)::numeric(4,3) as l5,
(p^3+3*p^3*q+6*p^3*q^2)::numeric(4,3) as win,
(1.0-(p^3+3*p^3*q+6*p^3*q^2))::numeric(4,3) as lose,
(3*(p^3+3*p^3*q+6*p^3*q^2)+2*(6*q^3*p^2)+1*(3*q^3*p)+0*(q^3))::numeric(4,3)
as e_ws,
(3*(q^3+3*q^3*p+6*q^3*p^2)+2*(6*p^3*q^2)+1*(3*p^3*q)+0*(p^3))::numeric(4,3)
as e_ls
from predict
order by date,home asc
)
to '/tmp/predict_daily.csv' csv header;

commit;
