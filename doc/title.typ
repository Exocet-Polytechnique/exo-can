#let format_date_fr(date) = [
  #date.day()
  #("janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre",
    "octobre", "novembre", "décembre").at(date.month() - 1)
  #date.year()
]

#let hrule = line(length: 90%, stroke: 1pt)

#align(center)[
  #image("res/logo-exocet.svg", width: 30%)

  #text(size: 18pt)[Exocet -- Équipe d'embarqué]

  #text(size: 12pt)[Le #format_date_fr(datetime.today())]
  #v(12pt)

  #hrule #v(10pt, weak: true)
  #text(size: 22pt, strong[Format des trames CAN]) #v(15pt, weak: true)
  #hrule #v(15pt, weak: true)

  #table(
    stroke: none, columns: 2, align: (right, left),

    [Auteurs:], [Diego Campos],
    [et], [Eliot Fondère]
  )

  #v(1fr)

  #par(justify: false)[
    *Résumé* \
    Ce document décrit comment les trames CAN circulant dans le réseau du bateau seront formées. Un module Rust sera créé pour manipuler facilement ces trames. Ce dernier permettra de construire une trame CAN (#link("https://docs.embassy.dev/embassy-stm32/git/stm32g474rb/can/frame/struct.Frame.html")[`can::Frame`]). 
  ]
]
