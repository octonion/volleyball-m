#!/usr/bin/sage -python

#from sage.rings.arith import *
from sage.all import *

to = 1.374
oo = 1.356

#to = 1.295
#oo = 1.250

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

print w25

w15 = 0.0

for i in xrange(0, 14):
    w15 = w15 + binomial(14+i, i)*p**14*q**i*p

tie = binomial(28, 14)*p**14*q**14

#print tie

w15 = w15 + tie*p**2/(1-2*p*q)

print w15

win = w25**3 + binomial(3, 1)*w25**3*(1-w25) + binomial(4, 2)*w25**2*(1-w25)**2*w15

print win

print w25**3 + binomial(3, 1)*w25**3*(1-w25) + binomial(4, 2)*w25**3*(1-w25)**2
