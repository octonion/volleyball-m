
-- By year

select

r.year,

(sum(
case when ((sft.strength*f.exp_factor)>(sfo.strength/f.exp_factor)
            and r.team_won) then 1
     when ((sft.strength*f.exp_factor)<(sfo.strength/f.exp_factor)
            and not(r.team_won)) then 1
else 0 end)::float/
count(*))::numeric(4,3) as model,

(
sum(
case when r.neutral_site then 0.5
     when r.team_won and (not(r.neutral_site) and r.home_game) then 1
     when not(r.team_won) and (not(r.neutral_site) and not(r.home_game)) then 1
     else 0 end)::float/
count(*)
)::numeric(4,3) as naive,

(
sum(
case when ((sft.strength*f.exp_factor)>(sfo.strength/f.exp_factor)
            and r.team_won) then 1
     when ((sft.strength*f.exp_factor)<(sfo.strength/f.exp_factor)
            and not(r.team_won)) then 1
else 0
end)::float/
count(*)

-

sum(
case when r.neutral_site then 0.5
     when r.team_won and not(r.neutral_site) and r.home_game then 1
     when not(r.team_won) and not(r.neutral_site) and not(r.home_game) then 1
     else 0 end)::float/
count(*)
)::numeric(4,3) as diff,
count(*)
from ncaa_pbp.team_schedules r
join ncaa_pbp.teams t
  on (t.year,t.team_id)=(r.year,r.team_id)
join ncaa_pbp.teams o
  on (o.year,o.team_id)=(r.year,r.opponent_id)
join ncaa_pbp._schedule_factors sft
  on (sft.year,sft.school_id)=(r.year,r.team_id)
join ncaa_pbp._schedule_factors sfo
  on (sfo.year,sfo.school_id)=(r.year,r.opponent_id)
join ncaa_pbp._factors f
  on (f.parameter,f.level)=('field',
  (case when r.neutral_site
          then 'neutral'
  	when (not(r.neutral_site) and r.home_game) then 'offense_home'
        when (not(r.neutral_site) and not(r.home_game)) then 'defense_home'
	end))

where

r.team_won is not null

-- each game once
and r.team_id > r.opponent_id

-- Test March,April
--and extract(month from r.game_date) in (3,4)

-- Ignore neutral games
--and not(r.neutral_site)

-- D1
--and t.division=1
--and o.division=1

and t.division=o.division

group by r.year
order by r.year;

-- By division

select

'D' || t.division as div,

(sum(
case when ((sft.strength*f.exp_factor)>(sfo.strength/f.exp_factor)
            and r.team_score>r.opponent_score) then 1
     when ((sft.strength*f.exp_factor)<(sfo.strength/f.exp_factor)
            and r.team_score<r.opponent_score) then 1
else 0 end)::float/
count(*))::numeric(4,3) as model,

(
sum(
case when r.neutral_site then 0.5
     when r.team_won and not(r.neutral_site) and r.home_game then 1
     when not(r.team_won) and not(r.neutral_site) and not(r.home_game) then 1
     else 0 end)::float/
count(*)
)::numeric(4,3) as naive,

(
sum(
case when ((sft.strength*f.exp_factor)>(sfo.strength/f.exp_factor)
            and r.team_won) then 1
     when ((sft.strength*f.exp_factor)<(sfo.strength/f.exp_factor)
            and not(r.team_won)) then 1
else 0
end)::float/
count(*)

-

sum(
case when r.neutral_site then 0.5
     when r.team_won and not(r.neutral_site) and r.home_game then 1
     when not(r.team_won) and not(r.neutral_site) and not(r.home_game) then 1
     else 0 end)::float/
count(*)
)::numeric(4,3) as diff,
count(*)
from ncaa_pbp.team_schedules r
join ncaa_pbp.teams t
  on (t.year,t.team_id)=(r.year,r.team_id)
join ncaa_pbp.teams o
  on (o.year,o.team_id)=(r.year,r.opponent_id)
join ncaa_pbp._schedule_factors sft
  on (sft.year,sft.school_id)=(r.year,r.team_id)
join ncaa_pbp._schedule_factors sfo
  on (sfo.year,sfo.school_id)=(r.year,r.opponent_id)

join ncaa_pbp._factors f
  on (f.parameter,f.level)=('field',
  (case when r.neutral_site
          then 'neutral'
  	when (not(r.neutral_site) and r.home_game) then 'offense_home'
        when (not(r.neutral_site) and not(r.home_game)) then 'defense_home'
	end))

where

r.team_won is not null

-- each game once
and r.team_id > r.opponent_id

-- Test March,April
--and extract(month from r.game_date) in (3,4)

-- Ignore neutral games
--and not(r.neutral_site)

and t.division=o.division

group by div
order by div;

-- Overall

select

(sum(
case when ((sft.strength*f.exp_factor)>(sfo.strength/f.exp_factor)
            and r.team_score>r.opponent_score) then 1
     when ((sft.strength*f.exp_factor)<(sfo.strength/f.exp_factor)
            and r.team_score<r.opponent_score) then 1
else 0 end)::float/
count(*))::numeric(4,3) as model,

(
sum(
case when r.neutral_site then 0.5
     when r.team_won and not(r.neutral_site) and r.home_game then 1
     when not(r.team_won) and not(r.neutral_site) and not(r.home_game) then 1
     else 0 end)::float/
count(*)
)::numeric(4,3) as naive,

(
sum(
case when ((sft.strength*f.exp_factor)>(sfo.strength/f.exp_factor)
            and r.team_won) then 1
     when ((sft.strength*f.exp_factor)<(sfo.strength/f.exp_factor)
            and not(r.team_won)) then 1
else 0
end)::float/
count(*)

-

sum(
case when r.neutral_site then 0.5
     when r.team_won and not(r.neutral_site) and r.home_game then 1
     when not(r.team_won) and not(r.neutral_site) and not(r.home_game) then 1
     else 0 end)::float/
count(*)
)::numeric(4,3) as diff,
count(*)
from ncaa_pbp.team_schedules r
join ncaa_pbp.teams t
  on (t.year,t.team_id)=(r.year,r.team_id)
join ncaa_pbp.teams o
  on (o.year,o.team_id)=(r.year,r.opponent_id)
join ncaa_pbp._schedule_factors sft
  on (sft.year,sft.school_id)=(r.year,r.team_id)
join ncaa_pbp._schedule_factors sfo
  on (sfo.year,sfo.school_id)=(r.year,r.opponent_id)

join ncaa_pbp._factors f
  on (f.parameter,f.level)=('field',
  (case when r.neutral_site
          then 'neutral'
  	when (not(r.neutral_site) and r.home_game) then 'offense_home'
        when (not(r.neutral_site) and not(r.home_game)) then 'defense_home'
	end))

where

r.team_won is not null

-- each game once
and r.team_id > r.opponent_id

-- Test March,April
--and extract(month from r.game_date) in (3,4)

-- Ignore neutral games
--and not(r.neutral_site)

-- D1
--and t.division=1
--and o.division=1

and t.division=o.division;
