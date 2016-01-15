#!/usr/bin/env bash

year=$1
division=$2

./scrapers_tsv/ncaa_teams.rb $year $division

./scrapers_tsv/ncaa_team_rosters_mt.rb $year $division

./scrapers_tsv/ncaa_summaries.rb $year $division

./scrapers_tsv/ncaa_team_schedules_mt.rb $year $division

./scrapers_tsv/ncaa_team_box_scores_mt.rb $year $division

./scrapers_tsv/ncaa_play_by_play_mt.rb $year $division

exit
