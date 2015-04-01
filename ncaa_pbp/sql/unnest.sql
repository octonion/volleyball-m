--select game_id, team_score, opponent_score,
--row_number() over (partition by game_id) sn
--from
--(
--select p1.game_id,
--unnest(p1.period_scores) as team_score,
--unnest(p2.period_scores) as opponent_score
--
--from ncaa_pbp.periods p1
--join ncaa_pbp.periods p2
--  on (p2.game_id,p2.section_id)=(p1.game_id,1)
--where p1.section_id=0
--) v;

--select v.*, row_number() over (partition by id order by elem) rn from
--(select
--    id,
--    unnest(string_to_array(elements, ',')) AS elem
-- from myTable) v

select p1.game_id, team_score, opponent_score, rn1, rn2
from ncaa_pbp.periods p1, ncaa_pbp.periods p2, unnest(p1.period_scores) with ordinality x(team_score, rn1), unnest(p2.period_scores) with ordinality y(opponent_score, rn2)
where
    p2.game_id=p1.game_id
and p1.section_id=0 and p2.section_id=1
and rn1=rn2;
