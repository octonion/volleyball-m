#!/bin/bash

psql volleyball-m -f sos/standardized_results.sql

psql volleyball-m -c "drop table if exists ncaa_pbp._basic_factors;"
psql volleyball-m -c "drop table if exists ncaa_pbp._parameter_levels;"

psql volleyball-m -c "vacuum analyze ncaa_pbp.results;"

R --vanilla -f sos/lmer.R

psql volleyball-m -c "vacuum full verbose analyze ncaa_pbp._basic_factors;"
psql volleyball-m -c "vacuum full verbose analyze ncaa_pbp._parameter_levels;"

psql volleyball-m -f sos/normalize_factors.sql

psql volleyball-m -c "vacuum full verbose analyze ncaa_pbp._factors;"

psql volleyball-m -f sos/schedule_factors.sql

psql volleyball-m -c "vacuum full verbose analyze ncaa_pbp._schedule_factors;"

psql volleyball-m -f sos/connectivity.sql > sos/connectivity.txt

psql volleyball-m -f sos/current_ranking.sql > sos/current_ranking.txt

psql volleyball-m -f sos/division_ranking.sql > sos/division_ranking.txt

psql volleyball-m -f sos/test_predictions.sql > sos/test_predictions.txt

psql volleyball-m -f sos/predict_daily.sql > sos/predict_daily.txt