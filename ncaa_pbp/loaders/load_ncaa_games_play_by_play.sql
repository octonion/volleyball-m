begin;

drop table if exists ncaa_pbp.play_by_play;

create table ncaa_pbp.play_by_play (
	game_id		      integer,
	period_id	      integer,
	event_id	      integer,
	time		      interval,
--	time		      text,
        team_player	      text,
	team_event	      text,
	team_text	      text,
	team_score	      integer,
	opponent_score	      integer,
	socre		      text,
        opponent_player	      text,
	opponent_event	      text,
	opponent_text	      text
);

--truncate table ncaa_pbp.play_by_play;

copy ncaa_pbp.play_by_play from '/tmp/ncaa_games_play_by_play.csv' with delimiter as E'\t' csv header;

/*
delete from ncaa_pbp.pbp where game_id=1380752;

alter table ncaa_pbp.pbp alter column time type interval using time::interval;

alter table ncaa_pbp.play_by_play add column id integer;

create temporary table reorder (
       game_id	       	       integer,
       period		       integer,
       event_id		       integer,
       id		       serial,
       primary key (game_id,period,event_id)
);

insert into reorder
(game_id,period,event_id)
(
select
game_id,period,event_id
from ncaa_pbp.pbp
order by game_id asc,period asc,time desc,
(case when coalesce(team_event,opponent_event)='Enters Games' then 1
      when coalesce(team_event,opponent_event)='Leaves Games' then 3
      else 2 end) asc
);

update ncaa_pbp.pbp
set id=r.id
from reorder r
where (r.game_id,r.period,r.event_id)=(pbp.game_id,pbp.period,pbp.event_id);

create index on ncaa_pbp.pbp (id);

--alter table ncaa.games add column game_id serial primary key;

--update ncaa.games
--set game_length = trim(both ' -' from game_length);
*/

commit;
