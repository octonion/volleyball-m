begin;

insert into ncaa_pbp.rounds
(year,round_id,seed,division_id,school_id,team_name,bracket,p)
(
select
r1.year as year,
r1.round_id+1 as round,
r1.seed,
r1.division_id,
r1.school_id,
r1.team_name,
r1.bracket,

sum(
(case when r2.school_id is null then 1.0
      else r1.p*r2.p*mp.team_p
 end)
) as p

from ncaa_pbp.rounds r1
left join ncaa_pbp.rounds r2
  on ((r1.year,r1.round_id,r1.bracket[r1.round_id+1])=
      (r2.year,r2.round_id,r2.bracket[r1.round_id+1])
       and not(r1.bracket[r1.round_id]=r2.bracket[r1.round_id]))
left join ncaa_pbp.matrix_field mf
  on (mf.year,mf.round_id,mf.school_id,mf.opponent_id)=
     (r1.year,r1.round_id,r1.school_id,r2.school_id)
left join ncaa_pbp.matrix_p mp
  on (mp.year,mp.field,mp.school_id,mp.opponent_id)=
     (r1.year,mf.field,r1.school_id,r2.school_id)

where
    r1.year=2018
and r1.round_id=1
group by r1.year,round,r1.seed,r1.division_id,r1.school_id,r1.team_name,r1.bracket
);

commit;
