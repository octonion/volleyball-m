begin;

drop table if exists ncaa_pbp.results;

create table if not exists ncaa_pbp.results (
	game_id		      integer,
	game_date	      date,
	year		      integer,
	team_id		      integer,
	opponent_id	      integer,
	field		      text,
	team_score	      integer,
	opponent_score	      integer,
	set_number	      integer,
	primary key (game_id, team_id, set_number)
);

insert into ncaa_pbp.results
(game_id,
 game_date,
 year,
 team_id, opponent_id,
 field,
 team_score, opponent_score,
 set_number)
(
select
p1.game_id,
ts.game_date,
ts.year,
p1.team_id,
p2.team_id,

(case when ts.neutral_site then 'neutral'
      when not(ts.neutral_site) and ts.home_game then 'offense_home'
      when not(ts.neutral_site) and not(ts.home_game) then 'defense_home'
end) as field,

x.team_score,
y.opponent_score,
x.rn1
from ncaa_pbp.periods p1, ncaa_pbp.periods p2,
unnest(p1.period_scores) with ordinality x(team_score, rn1),
unnest(p2.period_scores) with ordinality y(opponent_score, rn2),
ncaa_pbp.team_schedules ts
where
    p2.game_id=p1.game_id
and (ts.game_id,ts.team_id)=(p1.game_id,p1.team_id)
and p1.section_id=0 and p2.section_id=1
and rn1=rn2
and rn1 < array_length(p1.period_scores, 1)
and p1.team_id is not null
and p2.team_id is not null
);

commit;

begin;

insert into ncaa_pbp.results
(game_id,
 game_date,
 year,
 team_id, opponent_id,
 field,
 team_score, opponent_score,
 set_number)
(
select
game_id,
game_date,
year,
opponent_id,
team_id,
(case when field='offense_home' then 'defense_home'
      when field='defense_home' then 'offense_home'
      when field='neutral' then 'neutral' end)
as field,
opponent_score,
team_score, 
set_number
from ncaa_pbp.results
);

commit;
