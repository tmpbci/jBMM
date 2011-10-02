REBOL [
  Title: "IEEE-32"
  Description: "REBOL to IEEE-32 FLOAT"
  Date: 2004-01-28
  Version: 0.0.2
  Author: "Piotr Gapinski"
  Email: %news--rowery--olsztyn--pl
  File: %ieee.r
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
  Purpose: {Provides conversion to and from IEEE-32 float (binary)}
  License: "GNU Lesser General Public License (Version 2.1)"
  Comment: {
    http://sandbox.mc.edu/~bennet/cs110/flt/index.html

    +--------------------------------------------------------------------+
    |bit |0 1 2 3 4 5 6 7 8 9 A B C D E F 0 1 2 3 4 5 6 7 8 9 A B C D E F|
    +--------------------------------------------------+---------------+-+
    |IEEE|              mantissa                       |    exponent   |s|
    +--------------------------------------------------+---------------+-+
    UWAGA: 
    1. procedury obsługuja TYLKO liczby 24bitowe! (ułomnosc Rebol'a)
    2. zakres -0.5 > x > 0.5 nie jest suportowany
  }
  Example: {
    x: to-ieee 233.76
    from-ieee x
  }
  library: [
    level: 'intermediate
    platform: 'all
    type: [module tool]
    domain: [math]
    tested-under: [
      view 1.2.33 on [Winxp]
    ] 
    support: none
    license: 'LGPL
  ]
]


from-ieee: func [
 "Zamienia binarna liczbe float ieee-32 na number!"
 [catch]
  dat [binary!] "liczba w formacie ieee-32"
 /local ieee-sign ieee-exponent ieee-mantissa] [

  ieee-sign: func [dat] [either zero? ((to-integer dat) and (to-integer 2#{10000000000000000000000000000000})) [1][-1]] ;; 1 bit
  ieee-exponent: func [dat] [
    exp: (to-integer dat) and (to-integer 2#{01111111100000000000000000000000}) ;; 8 bitow
    exp: (exp / power 2 23) - 127 ;; 127=[2^(k-1) - 1] (k=8 dla IEEE-32bit)
  ]
  ieee-mantissa: func [dat] [
    ((to-integer dat) and 
     (to-integer 2#{00000000011111111111111111111111})) + (to-integer (1 * power 2 23)) ;; 23 bity
  ]

  s: ieee-sign dat
  e: ieee-exponent dat
  m: ieee-mantissa dat
  d: s * (to-integer m) / power 2 (23 - e)
]

to-ieee: func [
 "Zamienia decimal! lub integer! na binary! w formacie ieee-32."
 [catch]
  dat [number!] "liczba do konwersji (24 bity)"
 /local ieee-sign ieee-exponent ieee-mantissa integer-to-binary] [

  integer-to-binary: func [i [number!]] [debase/base to-hex i 16]
  ieee-sign: func [dat] [either positive? dat [0][1]]
  ieee-exponent: func [dat] [ ;; only for -0.5 > x > 0.5
    dat: to-integer dat
    weight: to-integer #{800000}
    i: 0
    forever [
      i: i + 1 
      if ((weight and dat) = weight) [break] 
      weight: to-integer (weight / 2)
    ]
    24 - i + 127
  ]
  ieee-mantissa: func [dat e] [
    m: to-integer (dat * (power 2 (23 - e + 127)))
    m: m and to-integer 2#{0111 1111 1111 1111 1111 1111}
  ]

  s: ieee-sign dat
  dat: abs dat
  e: ieee-exponent dat
  m: ieee-mantissa dat e
  integer-to-binary to-integer (m + (e * power 2 23) + (s * power 2 31))
]