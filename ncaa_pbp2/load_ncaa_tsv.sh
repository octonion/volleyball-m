#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'volleyball-m';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb volleyball-m;"
   eval $cmd
fi

psql volleyball-m -f loaders_tsv/create_ncaa_pbp_schema.sql

mkdir /tmp/data

tail -q -n+2 tsv/ncaa_teams*.tsv >> /tmp/ncaa_teams.tsv
psql volleyball-m -f loaders_tsv/load_ncaa_teams.sql
rm /tmp/ncaa_teams.tsv

tail -q -n+2 tsv/ncaa_team_schedules_mt_*.tsv >> /tmp/ncaa_team_schedules.tsv
psql volleyball-m -f loaders_tsv/load_ncaa_team_schedules.sql
rm /tmp/ncaa_team_schedules.tsv

#tail -q -n+2 tsv/ncaa_player_summaries_2015_[13].tsv >> /tmp/ncaa_player_summaries.tsv
#rpl -q " " "" /tmp/ncaa_player_summaries.tsv
#rpl -q '""' '' /tmp/ncaa_player_summaries.tsv
#psql volleyball-m -f loaders_tsv/load_ncaa_player_summaries.sql
#rm /tmp/ncaa_player_summaries.tsv

#cp tsv/ncaa_games_box_scores_mt_2016*.tsv.gz /tmp/data
#pigz -d /tmp/data/ncaa_games_box_scores_mt_*.tsv.gz
#tail -q -n+2 /tmp/data/ncaa_games_box_scores_mt_*.tsv >> /tmp/ncaa_games_box_scores.tsv
#psql volleyball-m -f loaders_tsv/load_ncaa_box_scores.sql
#rm /tmp/ncaa_games_box_scores.tsv
#rm /tmp/data/ncaa_games_box_scores_mt_*.tsv

tail -q -n+2 tsv/ncaa_team_rosters_mt*.tsv >> /tmp/ncaa_team_rosters.tsv
psql volleyball-m -f loaders_tsv/load_ncaa_team_rosters.sql
rm /tmp/ncaa_team_rosters.tsv

tail -q -n+2 tsv/ncaa_games_periods_mt*.tsv >> /tmp/ncaa_games_periods.tsv
rpl "[" "{" /tmp/ncaa_games_periods.tsv
rpl "]" "}" /tmp/ncaa_games_periods.tsv
psql volleyball-m -f loaders_tsv/load_ncaa_games_periods.sql
rm /tmp/ncaa_games_periods.tsv

#cp tsv/ncaa_games_play_by_play_mt.tsv /tmp/ncaa_games_play_by_play.tsv
#psql volleyball-m -f loaders_tsv/load_ncaa_games_play_by_play.sql
#rm /tmp/ncaa_games_play_by_play.tsv

rmdir /tmp/data
