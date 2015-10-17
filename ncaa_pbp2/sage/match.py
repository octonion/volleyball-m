#!/usr/bin/sage -python

#from sage.rings.arith import *
from sage.all import *

to = 1.647
oo = 1.487

offense_home = 1.04287505917001
defense_home = 0.958887635874489

to = to*defense_home
oo = oo*offense_home

r = to/oo

p = r/(1+r)
q = 1-p

#print p

w25 = 0.0

for i in xrange(0, 24):
    w25 = w25 + binomial(24+i, i)*p**24*q**i*p

tie = binomial(48, 24)*p**24*q**24

#print tie

w25 = w25 + tie*p**2/(1-2*p*q)

#print w25

w15 = 0.0

for i in xrange(0, 14):
    w15 = w15 + binomial(14+i, i)*p**14*q**i*p

tie = binomial(28, 14)*p**14*q**14

#print tie

w15 = w15 + tie*p**2/(1-2*p*q)

#print w15

win = w25**3 + binomial(3, 1)*w25**3*(1-w25) + binomial(4, 2)*w25**2*(1-w25)**2*w15

print "%4.3f to win" % win

print "%4.3f to win in 3 sets" % w25**3
print "%4.3f to win in 4 sets" % (binomial(3, 1)*w25**3*(1-w25))
print "%4.3f to win in 5 sets" % (binomial(4, 2)*w25**2*(1-w25)**2*w15)

l25 = 1.0-w25
l15 = 1.0-w15

print "%4.3f to lose in 3 sets" % l25**3
print "%4.3f to lose in 4 sets" % (binomial(3, 1)*l25**3*(1-l25))
print "%4.3f to lose in 5 sets" % (binomial(4, 2)*l25**2*(1-l25)**2*l15)
