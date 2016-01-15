begin;

drop table if exists ncaa_pbp.player_summaries;

create table ncaa_pbp.player_summaries (
       year					integer,
       year_id					integer,
       team_id					integer,
       team_name				text,
       jersey_number				text,
       player_id				integer,
       player_name				text,
       player_url				text,
       class_year				text,
       height					text,
       games_played				integer,
       games_started				integer,

       primary key (year, team_id, player_name),
       unique (year_id, team_id, player_id)
);

copy ncaa_pbp.player_summaries from '/tmp/ncaa_player_summaries.csv' with delimiter as E'\t' csv header;

commit;
