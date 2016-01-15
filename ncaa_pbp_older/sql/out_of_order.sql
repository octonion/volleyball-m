select *
from ncaa_pbp.play_by_play p1
join ncaa_pbp.play_by_play p2
  on (p1.game_id, p1.period_id, p1.event_id+1)=
     (p2.game_id, p2.period_id, p2.event_id) and p1.time < p2.time;
