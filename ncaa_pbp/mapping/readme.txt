# Old file names

#psql volleyball-m -f deduplicate_rosters.sql
#psql volleyball-m -f load_manual_missing.sql
#psql volleyball-m -f create_rails_name_mappings.sql

# Revised file names (for clarity)

psql volleyball-m -f rosters_remove_duplicates.sql

psql volleyball-m -f rosters_manually_load_missing.sql

psql volleyball-m -f rosters_create_name_mappings.sql

./rosters_create_name_hashes.rb

psql volleyball-m -f rosters_manually_update_remaps.sql

# Requires the PostgreSQL Levenshtein functionfound in the contributed
# fuzzystrmatch module

# To install:
# apt-get install postgresql-contrib
# CREATE EXTENSION fuzzystrmatch;

psql volleyball-m -f rosters_compute_levenshtein_distances.sql

