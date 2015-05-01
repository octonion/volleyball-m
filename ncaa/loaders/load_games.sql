begin;

drop table if exists ncaa.games;

create table ncaa.games (
	year		      integer,
        school_name	      text,
        school_id	      integer,
        opponent_name         text,
        opponent_id           integer,
        game_date             text,
        team_score            integer,
        opponent_score        integer,
        location	      text,
        neutral_site_location text,
        game_length           text,
        attendance            text
);

copy ncaa.games from '/tmp/ncaa_games.csv' with delimiter as ',' csv quote as '"';

alter table ncaa.games add column game_id serial primary key;

update ncaa.games
set game_length = trim(both ' -' from game_length);

commit;
