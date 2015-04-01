#!/bin/bash

psql basketball-w -f clean/add_ncaa_play_by_play_id.sql

psql basketball-w -f clean/add_ncaa_team_schedules_extra_fields.sql

psql basketball-w -f clean/generate_play_by_play_clean.sql

