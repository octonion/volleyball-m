begin;

drop table if exists ncaa_pbp.box_scores;

create table ncaa_pbp.box_scores (
       game_id					integer,
       section_id				integer,
       player_id				integer,
       player_name				text,
       player_url				text,
       position					text,
       s					integer,
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
       pts					integer,
       bhe					integer
--       primary key (game_id,section_id,player_id) --,player_name)
);

copy ncaa_pbp.box_scores from '/tmp/ncaa_games_box_scores.csv' with delimiter as E'\t' csv header;

commit;
