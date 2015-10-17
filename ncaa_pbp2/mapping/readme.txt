# Old file names

#psql basketball-w -f deduplicate_rosters.sql
#psql basketball-w -f load_manual_missing.sql
#psql basketball-w -f create_rails_name_mappings.sql

# Revised file names (for clarity)

psql basketball-w -f rosters_remove_duplicates.sql

psql basketball-w -f rosters_manually_load_missing.sql

psql basketball-w -f rosters_create_name_mappings.sql

./rosters_create_name_hashes.rb

psql basketball-w -f rosters_manually_update_remaps.sql

# Requires the PostgreSQL Levenshtein functionfound in the contributed
# fuzzystrmatch module

# To install:
# apt-get install postgresql-contrib
# CREATE EXTENSION fuzzystrmatch;

psql basketball-w -f rosters_compute_levenshtein_distances.sql

