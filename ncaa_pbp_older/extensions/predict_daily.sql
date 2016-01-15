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
       w25				float,
       l25				float,
       w15				float,
       l15				float
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
h.offensive*o.exp_factor*v.defensive/(1.0+h.offensive*o.exp_factor*v.defensive)
  as p

from ncaa.games g
join ncaa_pbp._schedule_factors h
  on (h.year,h.school_id)=(g.year,g.school_id)
join ncaa_pbp._schedule_factors v
  on (v.year,v.school_id)=(g.year,g.opponent_id)
join ncaa.schools_divisions hd
  on (hd.year,hd.school_id)=(h.year,h.school_id)
join ncaa.schools_divisions vd
  on (vd.year,vd.school_id)=(v.year,v.school_id)
join ncaa_pbp._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_pbp._factors d
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
'D'||hd.div_id as hd,
vd.school_name as away,
'D'||vd.div_id as vd,
h.offensive*v.defensive/(1.0+h.offensive*v.defensive) as p

from ncaa.games g
join ncaa_pbp._schedule_factors h
  on (h.year,h.school_id)=(g.year,g.school_id)
join ncaa_pbp._schedule_factors v
  on (v.year,v.school_id)=(g.year,g.opponent_id)
join ncaa.schools_divisions hd
  on (hd.year,hd.school_id)=(h.year,h.school_id)
join ncaa.schools_divisions vd
  on (vd.year,vd.school_id)=(v.year,v.school_id)
--join set_probability(25, pr.p) sp25 on TRUE
--join set_probability(15, pr.p) sp15 on TRUE
where
not(g.game_date='')
and g.game_date::date = current_date-1
and g.location='Neutral'
and (g.school_id < g.opponent_id)
--order by date,home asc
);

update predict
set w25=set_probability(25, predict.p);

update predict
set l25=1-w25;

update predict
set w15=set_probability(15, predict.p);

update predict
set l15=1-w15;

select
game_date as date,
site,
home,
hd,
away,
vd,
(w25^3)::numeric(4,3) as w3,
(3*w25^3*l25)::numeric(4,3) as w4,
(6*w25^2*l25^2*w15)::numeric(4,3) as w5,
(w25^3+3*w25^3*l25+6*w25^2*l25^2*w15)::numeric(4,3) as win,
(1-(w25^3+3*w25^3*l25+6*w25^2*l25^2*w15))::numeric(4,3) as lose
from predict
order by date,home asc;

select
game_date as date,
site,
home,
hd,
away,
vd,
(l25^3)::numeric(4,3) as l3,
(3*l25^3*w25)::numeric(4,3) as l4,
(6*l25^2*w25^2*l15)::numeric(4,3) as l5,
(
3*(w25^3+3*w25^3*l25+6*w25^2*l25^2*w15)+
2*(6*l25^2*w25^2*l15)+
1*(3*l25^3*w25)+
0*(l25^3)
)::numeric(4,3) as e_ws,

(
3*(l25^3+3*l25^3*w25+6*l25^2*w25^2*l15)+
2*(6*w25^2*l25^2*w15)+
1*(3*w25^3*l25)+
0*(w25^3)
)::numeric(4,3) as e_ls

from predict
order by date,home asc;

copy (

select
game_date as date,
site,
home,
hd,
away,
vd,
(w25^3)::numeric(4,3) as w3,
(3*w25^3*l25)::numeric(4,3) as w4,
(6*w25^2*l25^2*w15)::numeric(4,3) as w5,
(w25^3+3*w25^3*l25+6*w25^2*l25^2*w15)::numeric(4,3) as win,
(1-(w25^3+3*w25^3*l25+6*w25^2*l25^2*w15))::numeric(4,3) as lose,

(l25^3)::numeric(4,3) as l3,
(3*l25^3*w25)::numeric(4,3) as l4,
(6*l25^2*w25^2*l15)::numeric(4,3) as l5,
(
3*(w25^3+3*w25^3*l25+6*w25^2*l25^2*w15)+
2*(6*l25^2*w25^2*l15)+
1*(3*l25^3*w25)+
0*(l25^3)
)::numeric(4,3) as e_ws,

(
3*(l25^3+3*l25^3*w25+6*l25^2*w25^2*l15)+
2*(6*w25^2*l25^2*w15)+
1*(3*w25^3*l25)+
0*(w25^3)
)::numeric(4,3) as e_ls

from predict
order by date,home asc

) to '/tmp/predict_daily.csv' csv header;

commit;
