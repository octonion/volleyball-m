begin;

drop table if exists ncaa_pbp.team_summaries;

create table ncaa_pbp.team_summaries (
       year					integer,
       year_id					integer,
       team_id					integer,
       team_name				text,
       jersey_number				text,
       summary_type				text,
       class_year				text,
       height					text,
       games_played				integer,
       games_started				integer,

       primary key (year, team_id, summary_type),
       unique (year_id, team_id, summary_type)
);

copy ncaa_pbp.team_summaries from '/tmp/ncaa_team_summaries.tsv' with delimiter as E'\t' csv header;

commit;
