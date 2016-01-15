select
coalesce(team_player,opponent_player) as player,
coalesce(team_event,opponent_event) as event
from ncaa_pbp.play_by_play
where coalesce(team_event,opponent_event) ilike '%dunk%';
