
create extension if not exists plpython2u;

-- Probability of winning a race to target, win by 2, with a given
-- point win probability point_p

drop function if exists set_probability(integer, float);

create or replace function set_probability
  (target integer, point_p float,
   OUT set_p float, OUT gap_p float, OUT gap_wp float)
returns record
as $$

# To do - general gap

from scipy.misc import comb

p = point_p
q = 1-p

t = target-1

# gap = 2

w = 0.0

for i in xrange(0, t):
    w = w + comb(t+i,i)*p**t*q**i*p

gap_p = comb(2*t, t)*p**t*q**t

gap_wp = p**2/(1-2*p*q)

set_p = w + gap_p*gap_wp

return([set_p, gap_p, gap_wp])

$$ language plpython2u;
