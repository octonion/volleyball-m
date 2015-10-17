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
       position					text,
       height					text,
       games_played				integer,
       games_started				integer,
       s					integer,
       mp					integer,
       ms					integer,
       kills					integer,
       errors					integer,
       total_attacks				integer,
       pct					float,
       assists					integer,
       aces					integer,
       serr					integer,
       digs					integer,
       rerr					integer,
       block_solos				integer,
       block_assists				integer,
       berr					integer,
       pts					float,
       bhe					integer,
       trpl_dbl					integer,
       primary key (year, team_id, player_id)
--       unique (year_id, team_id, player_id)
);

copy ncaa_pbp.player_summaries from '/tmp/ncaa_player_summaries.tsv' with delimiter as E'\t' csv header;

commit;

