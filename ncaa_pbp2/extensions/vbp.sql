
create extension if not exists plpython3u;

drop function if exists vbp(float, float, text);

create or replace function vbp
  (mu1 float, mu2 float, outcome text, OUT p float)
returns float
as $$

import math

from scipy.special import comb

r = math.sqrt(mu1/mu2)

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

win = w25**3 + comb(3,1)*(w25**3)*l25 + comb(4,2)*(w25**2)*(l25**2)*w15
lose = 1-win

if (outcome=="win"):
   return(win)
else:
   return(lose)

$$ language plpython3u;
