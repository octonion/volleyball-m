#!/usr/bin/python3

import sys
import csv
import datetime
import psycopg2

from scipy.special import comb

try:
    conn = psycopg2.connect("dbname='volleyball-m'")
except:
    print("Can't connect to database.")
    sys.exit()

today = datetime.datetime.now()
start = today.strftime("%F")
end = today + datetime.timedelta(days=6)

select = """
select
ts.game_date,
(case when ts.neutral_site then 'Neutral'
      when not(ts.neutral_site) and ts.home_game then 'Home'
      when not(ts.neutral_site) and not(ts.home_game) then 'Away'
end),
t.team_name,
'D'||t.division as t_div,
(tf.exp_factor*td.exp_factor*sft.offensive),
o.team_name,
'D'||o.division as o_div,
(of.exp_factor*od.exp_factor*sfo.offensive)
--ts.neutral_site,
--ts.home_game,
--tf.exp_factor,
--of.exp_factor
from ncaa_pbp.team_schedules ts
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(ts.team_id,ts.year)
join ncaa_pbp._schedule_factors sft
  on (sft.school_id,sft.year)=(ts.team_id,ts.year)
join ncaa_pbp._factors td
  on (td.parameter,td.level::integer)=('o_div',t.division)
join ncaa_pbp.teams o
  on (o.team_name,o.year)=(ts.opponent_name,ts.year)
join ncaa_pbp._schedule_factors sfo
  on (sfo.school_id,sfo.year)=(o.team_id,o.year)
join ncaa_pbp._factors od
  on (od.parameter,od.level::integer)=('o_div',o.division)
join ncaa_pbp._factors tf on
tf.level=
(case when ts.neutral_site then 'neutral'
      when not(ts.neutral_site) and ts.home_game then 'offense_home'
      when not(ts.neutral_site) and not(ts.home_game) then 'defense_home'
end)
join ncaa_pbp._factors of on
of.level=
(case when ts.neutral_site then 'neutral'
      when not(ts.neutral_site) and ts.home_game then 'defense_home'
      when not(ts.neutral_site) and not(ts.home_game) then 'offense_home'
end)
where ts.game_date between current_date and current_date+6
and t.team_name < o.team_name
order by ts.team_name asc,ts.game_date asc
;
"""

cur = conn.cursor()
cur.execute(select)

rows = cur.fetchall()

csvfile = open('predict_weekly.csv', 'w', newline='')
predict = csv.writer(csvfile)

header = ["game_date","site","team","tdiv","opponent","odiv",
          "win","lose","w3","w4","w5","l3","l4","l5",
          "e_m","e_w3","e_w4","e_w5","e_l3","e_l4","e_l5"]

predict.writerow(header)

for row in rows:
    
    game_date = row[0]
    site = row[1]
    team = row[2]
    tdiv = row[3]
    to = row[4]
    opponent = row[5]
    odiv = row[6]
    oo = row[7]

    r = to/oo

    p = r/(1+r)
    q = 1-p

    # For team to win with 25 points:
    #   Final point is won by team
    #   Team wins 24 other points
    #   Opponent wins 23 or fewer points
    # Therefore probability of win with 25 (w25):
    #   Opponent points i range from 0 to 23
    #   Team's 24 other points and opponent's points can have any permutation

    we25 = 0.0
    
    for i in range(0, 24):
        we25 = we25 + comb(24+i, i)*p**24*q**i*p

    le25 = 0.0
    
    for i in range(0, 24):
        le25 = le25 + comb(24+i, i)*q**24*p**i*q

    # For team to win with more than 25 points:
    #   Score must be tied 24-24 at some point
    #   For team to win from tied score, must either win 2 points in a row or
    #     win-lose, lose-win then win from new tie
    #   If p_tie is probability of tie, probability of winning given tie:
    #     w_tie = p^2 + 2*p*q*w_tie
    #     w_tie*(1-2*p*q) = p^2
    #     w_tie = p^2/(1-2*p*q)
    # P(winning & tie) = P(winning | tie) * P(tie)
    
    tie25 = comb(48, 24)*p**24*q**24

    wm25 = tie25*p**2/(1-2*p*q)
    
    w25 = we25 + wm25

    lm25 = tie25*q**2/(1-2*q*p)
    
    l25 = le25 + lm25

    # Expected points
    # win with 25 points

    e_we25 = 0.0
    
    for i in range(0, 24):
        e_we25 = e_we25 + (25+i)*comb(24+i, i)*p**24*q**i*p

    e_we25 = e_we25/we25

    # Expected points
    # win with more than 25 points

    e_wm25 = 48+2*(1+q)/p

    e_w25 = e_we25*we25/w25 + e_wm25*wm25/w25

    # Expected points
    # lose to 25 points

    e_le25 = 0.0
    
    for i in range(0, 24):
        e_le25 = e_le25 + (25+i)*comb(24+i,i)*q**24*p**i*q

    e_le25 = e_le25/le25

    # Expected points
    # lose to more than 25 points

    e_lm25 = 48+2*(1+p)/q

    e_l25 = e_le25*le25/l25 + e_lm25*lm25/l25

    # 5th set

    # Win 5th set

    we15 = 0.0

    for i in range(0, 14):
        we15 = we15 + comb(14+i,i)*p**14*q**i*p

    # Lose 5th set

    le15 = 0.0

    for i in range(0, 14):
        le15 = le15 + comb(14+i,i)*q**14*p**i*q

    tie15 = comb(28, 14)*p**14*q**14

    wm15 = tie15*p**2/(1-2*p*q)
    w15 = we15 + wm15

    lm15 = tie15*q**2/(1-2*q*p)
    l15 = le15 + lm15

    # Expected points
    # win with 15 points

    e_we15 = 0.0
    
    for i in range(0, 14):
        e_we15 = e_we15 + (15+i)*comb(14+i, i)*p**14*q**i*p

    e_we15 = e_we15/we15

    # Expected points
    # win with more than 15 points

    e_wm15 = 28+2*(1+q)/p

    e_w15 = e_we15*we15/w15 + e_wm15*wm15/w15

    # Expected points
    # lose to 15 points

    e_le15 = 0.0
    
    for i in range(0, 14):
        e_le15 = e_le15 + (15+i)*comb(14+i,i)*q**14*p**i*q

    e_le15 = e_le15/le15

    # Expected points
    # lose to more than 15 points

    e_lm15 = 28+2*(1+p)/q

    e_l15 = e_le15*le15/l15 + e_lm15*lm15/l15

    e_w3 = 3*e_w25
    e_w4 = 3*e_w25 + e_l25
    e_w5 = 2*e_w25 + 2*e_l25 + e_w15
    e_l3 = 3*e_l25
    e_l4 = 3*e_l25 + e_w25
    e_l5 = 2*e_l25 + 2*e_w25 + e_l15

    # Match probabilities
    
    win = w25**3 + comb(3,1)*(w25**3)*l25 + comb(4,2)*(w25**2)*(l25**2)*w15
    lose = 1-win
    
    pall = w25**3 + comb(3,1)*w25**3*l25 + comb(4,2)*w25**2*l25**2*w15 + l25**3 + comb(3,1)*l25**3*w25 + comb(4,2)*l25**2*w25**2*l15
    
    # Expected match points

    e_m = (3*e_w25)*w25**3 + (3*e_w25+e_l25)*comb(3,1)*w25**3*l25 + (2*e_w25+2*e_l25+e_w15)*comb(4,2)*w25**2*l25**2*w15 + (3*e_l25)*l25**3 + (3*e_l25+e_w25)*comb(3,1)*l25**3*w25 + (2*e_l25+2*e_w25+e_l15)*comb(4,2)*l25**2*w25**2*l15

    win = "%4.3f" % win
    lose = "%4.3f" % lose

    w3 = "%4.3f" % (w25**3)
    w4 = "%4.3f" % (comb(3,1)*w25**3*l25)
    w5 = "%4.3f" % (comb(4,2)*w25**2*l25**2*w15)

    l3 = "%4.3f" % (l25**3)
    l4 = "%4.3f" % (comb(3,1)*l25**3*w25)
    l5 = "%4.3f" % (comb(4,2)*l25**2*w25**2*l15)
    e_m = "%4.1f" % (e_m)
    e_w3 = "%4.1f" % (e_w3)
    e_w4 = "%4.1f" % (e_w4)
    e_w5 = "%4.1f" % (e_w5)
    e_l3 = "%4.1f" % (e_l3)
    e_l4 = "%4.1f" % (e_l4)
    e_l5 = "%4.1f" % (e_l5)
    data = [game_date,site,team,tdiv,opponent,odiv,
            win,lose,w3,w4,w5,l3,l4,l5,
            e_m,e_w3,e_w4,e_w5,e_l3,e_l4,e_l5]
    predict.writerow(data)

csvfile.close()
