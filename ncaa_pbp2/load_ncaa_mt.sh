#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'volleyball-m';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database volleyball-m\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
#   cmd="createdb volleyball-m"
   eval $cmd
fi

psql volleyball-m -f loaders/create_ncaa_pbp_schema.sql

cp csv/ncaa_teams.csv /tmp/ncaa_teams.csv
psql volleyball-m -f loaders/load_ncaa_teams.sql
rm /tmp/ncaa_teams.csv

cp csv/ncaa_team_schedules_mt.csv /tmp/ncaa_team_schedules.csv
psql volleyball-m -f loaders/load_ncaa_team_schedules.sql
rm /tmp/ncaa_team_schedules.csv

cp csv/ncaa_games_box_scores_mt.csv /tmp/ncaa_games_box_scores.csv
psql volleyball-m -f loaders/load_ncaa_box_scores.sql
rm /tmp/ncaa_games_box_scores.csv

cp csv/ncaa_team_rosters_mt.csv /tmp/ncaa_team_rosters.csv
psql volleyball-m -f loaders/load_ncaa_team_rosters.sql
rm /tmp/ncaa_team_rosters.csv

cp csv/ncaa_games_periods_mt.csv /tmp/ncaa_games_periods.csv
rpl "[" "{" /tmp/ncaa_games_periods.csv
rpl "]" "}" /tmp/ncaa_games_periods.csv
psql volleyball-m -f loaders/load_ncaa_games_periods.sql
rm /tmp/ncaa_games_periods.csv

#cp csv/ncaa_games_play_by_play_mt.csv /tmp/ncaa_games_play_by_play.csv
#psql volleyball-m -f loaders/load_ncaa_games_play_by_play.sql
#rm /tmp/ncaa_games_play_by_play.csv
