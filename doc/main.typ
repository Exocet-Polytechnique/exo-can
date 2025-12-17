#import "@preview/bytefield:0.0.7": *
#set page("us-letter")
#set text(lang: "fr")

#let annex(body) = {
  set heading(numbering: "A1.", supplement: [Annexe])
  counter(heading).update(0)
  body
}

#show link: underline

#include("title.typ")

#pagebreak()

#set heading(numbering: "1.", supplement: none)
#outline()

#pagebreak()
#set page(numbering: "1")
#counter(page).update(1)
#heading("Définitions", numbering: none)

/ Module: Une unité de contrôle électronique du bateau (en anglais : _Electronic Control Unit - ECU_ ). Chaque module est un nœud du réseau CAN et vice-versa.

/ Procédure: Une séquence d’étapes à effectuer. Par exemple, la _pre-charge_ est une procédure..

= Identifiants des trames
== Adresses des modules <sec-module-addr>

Une adresse de 4 bits sera assignée à chaque module. Cette définition sera utile pour représenter l'adressage de l'expéditeur de la trame ainsi que son destinataire.

Les adresses sont présentées dans le tableau suivant:

#figure(table(
  columns: 2,
  align: (center + horizon, center + horizon),
  table.header([*Module \ (bits 3 à 0)*],[*Nom du module*#footnote[Voir #link("https://github.com/Exocet-Polytechnique/exo-pcbs/wiki/Requis-PCB")[Requis PCBs] sur GitHub]],),
  [`0b1111`], [_Broadcast_],
  [`0b0000`], [Cockpit (PCB 1)],
  [`0b0001`], [Gestion hydrogène (PCB 2)],
  [`0b0010`], [Basse puissance (PCB 3)],
  [`0b0011`], [Haute puissance (PCB 4)],
  [`0b0100`], [Télémétrie Écran (HAT 01)],
  [`0b0101`], [Télémétrie LTE (HAT 02)]
))

Ces valeurs sont susceptibles de changer au fur et à mesure. Un fichier de configuration (lien à venir) contiendra les définitions nécessaires donc il ne sera jamais nécessaire de manipuler directement ces valeurs. Une valeur de module égale à 15 est aussi réservée pour tout type de _broadcast_.

L'adressage des sous-modules (senseurs, capteurs situés sur un même PCB) seront définis dans les champs de données des trames.

== Types de trames
Il y aura principalement 3 types de trames: des trames d'instructions, des trames de données et des trames d'erreurs. Une série de 2 bits sera utilisée pour définir ce type dans l'identifiant. 

Les valeurs associées à chaque type :

- *0b00* : Trames d'erreur
- *0b01* : Trames de procédure
- *0b10* : Trames de donnée

== Dans les trames CAN

Nous utiliserons un réseau CAN standard où l’identifiant de chaque trame est de 11 bits. Lors d'un envoi simultané de deux messages ou plus, il est possible que certains messages entrent en conflit dans le bus. Par défaut, le protocole CAN utilise un système qui évalue l'identifiant de chaque trame et compare les bits un par un, attribuant une plus grande priorité à celui qui possède la plus petite valeur d'identifiant. Afin d'ajouter un niveau supplémentaire de flexibilité, le premier bit de l'identifiant sera donc un _bit de priorité_. 

- *0b1* : Priorité basse (recommandé pour un cas normal d'opération du bateau)
- *0b0* : Priorité haute (utilisé en cas d'erreur ou de procédure urgente à traiter par le pilote)

Les 4 bits suivants constituent l’identification du sous-système qui envoie la trame, tel que décrit décrit à la section @sec-module-addr. En effet, le module qui constitue la source du message joue un rôle pour définir la priorité de la trame. 

Les 2 bits qui suivent représentent le type de la trame (erreur, procédure, donnée)

Finalement, les bits restants sont mis à 1 (#highlight[et pourront être changés lorsque le protocole évoluera dans un futur]).

#linebreak()
#bytefield(
  bpr: 11,
  msb: left,
  bitheader(10,9,6,5,4,3,0), 
  bits(1)[Priorité],
  bits(4)[#align(center)[
    Module expéditeur\ 
    #text(size: 8pt)[(bits 9 à 6 de l'adresse)]
  ]],
  bits(2)[#align(center)[
    Type de trame\ 
    #text(size: 8pt)[(bits 5 et 4 de l'adresse)]
  ]],
  bits(4)[0b1111],
)
#linebreak()

= Champs de données


// #figure(table(
//   columns: 4,
//   align: (center + horizon, center + horizon, center + horizon, center + horizon),
//   table.header([*Type (bits 7 à 5)*],[*Nom du type*],[*Sous-type (bits 4 à 0)*],[*Nom du sous-type*]),
//   table.cell(rowspan: 4)[`0b000`],  table.cell(rowspan: 4)[État],
//   [`0b00000`], [Annonce de l’état actuel],
//   [`0b00001`], [Requête de confirmation],
//   [`0b00010`], [Requête de l’état actuel],
//   [`0b00011`], [Confirmation de l’état actuel],
  
//   table.cell(rowspan: 2)[`0b001`], table.cell(rowspan: 2)[Ping],
//   [`0b00000`], [Requête de présence],
//   [`0b00010`], [Annonce de présence],
  
//   table.cell(rowspan: 2)[`0b010`], table.cell(rowspan: 2)[Donnée],
//   [`0b00000`], [Requête d'une donnée],
//   [`0b00010`], [Annonce d'une donnée],
  
//   table.cell(rowspan: 3)[`0b011`], table.cell(rowspan: 3)[Procédure],
//   [`0b00000`], [Contrôle d’une procédure],
//   [`0b00001`], [Requête d’état d’une procédure],
//   [`0b00010`], [Réponse d’état d’une procédure]
// ))

Les trames CAN de format standard peuvent envoyer 8 octets de contenu par trame. La structure du premier octet est commune à toutes les trames et est constituée de deux signaux: l'adresse du module destinataire de la trame (voir la section @sec-module-addr), ainsi que le sous-adressage pour les senseurs et les capteurs sur un même PCB. // Dans le cas où on ne veut pas de sous-adressage I guess qu'on peut mettre les bits de sous-adressage à 0.

#linebreak()
*Premier Octet du Champs de Données*:
#bytefield(
  bpr: 8,
  msb: left,
  bitheader(7,4,3,0), 
  bits(4)[Module destinataire\ 
    #text(size: 8pt)[(bits 7 à 4 de l'octet)]],
  bits(4)[Sous-module destinataire\ 
    #text(size: 8pt)[(bits 3 à 0 de l'octet)]]
)
#linebreak()

#highlight()[(À DÉFINIR: SOUS-ADRESSAGE DES SENSEURS DANS UN MEME MODULE)]

Pour les 7 octets restants, on définira des signaux spécifiques selon le type de la trame. À noter que ceux-cis peuvent être multiplexés et définis davantage en détail dans le fichier DBC.

== Trames de procédure
Les trames de procédures permettent d’exécuter les routines et les tâches du bateau. Un identifiant unique est attribué à chacune d'elles pour pouvoir reconnaître lesquelles sont en cours d'exécution ou déjà finalisées.

Afin de surveiller le bon déroulement d'une procédure en exécution sur un PCB, on établie une convention d'état. Ainsi, les états possibles d'une procédure sont les suivants:

*READY*: #h(1em) La procédure n'est pas active, mais elle est prête à être exécutée. Elle passe ensuite à l'état _RUNNING_.

*RUNNING*:  #h(1em) État actif de la procédure. Celle-ci est en cours d’exécution.

*SUSPENDED*:  #h(1em) La procédure est mise en pause. Pour revenir à l'état _RUNNING_ celle-ci doit d'abord passer à l'état _READY_ pour s'assurer qu'elle est prête à revenir sur le fil d'exécution.

*COMPLETED*:  #h(1em) La procédure a complètement fini son exécution (ou a été achevée en avance). Elle ne devrait plus revenir dans le fil d'exécution.

// Je laisse ici la définition des état d'une procédure comme référence interne: pour que le PCB seulement soit au courant de l'état de la procédure qui s'éxécute. Dans le cas ou on voudrait que le cockpit soit aussi au courant de l'état d'une procédure on pourrait envoyer l'état par trame de donnée (créer un sous-groupe à multiplexer (tout comme pression, température, voltage, etc.)). 

Ce type de trame sert surtout à déclencher une série d'instructions prédéfinie dans un module. Celui-ci sera constamment en écoute de ce genre de trame, vérifiera si l'identifiant de la procédure correspond à une des siennes, puis il entamera la procédure en passant son état à RUNNING. 

// Un exemple de documentation pour les procédures
#figure(table(
  columns: 4,
  align: (center + horizon, center + horizon, center + horizon, center + horizon),
  table.header([*Nom de procédure*], [*\# Identifiant*], [*Description*], [*Déclenchement*]),
  [Démarrage], 
  [12345], 
  align(left)[
    - Procédure de démarrage du bateau. 
    - Active tous les PCBs et commence un processus de vérification d'état.], 
  align(left)[
    - Bouton d'allumage du bateau
  ],
  [...], 
  [...], 
  [...], 
  [...]
))

La structure des 8 octets de la trame de procédure contiendra:

#bytefield(
  bpr: 8,
  msb: right,
  bitheader(0,1,7), 
  bits(1)[Réservé],
  bits(7)[\# Identifiant de la procédure 
    #text(size: 8pt)[(octets 0 à 6)]],
)


== Trames de données
Les données dépassant certains seuils seront envoyés dans un trame avec une
priorité plus élevée et nécessiteront parfois une réponse du module du cockpit. //(À voir si c'est nécessaire?)

#highlight()[(À DÉFINIR: Types de données à envoyer)]

La structure des 8 octets de la trame de donnée contiendra:

#bytefield(
  bpr: 8,
  msb: right,
  bitheader(0,1,7), 
  bits(1)[Réservé],
  bits(1)[Type de donnée],
  bits(6)[Donnée]
)

== Trames d'erreurs

La structure des 8 octets de la trame d'erreur contiendra:

#bytefield(
  bpr: 8,
  msb: right,
  bitheader(0,1,7), 
  bits(1)[Réservé],
  bits(1)[Type d'erreur],
  bits(6)[Message]
)




== Exemple: Démarrage
#linebreak()
Au démarrage, le bateau sera dans un état spécial d’initialisation (_STARTING_) en attendant que tous les modules aient annoncé leur présence. Comme décrit précédemment, le module du cockpit gardera une liste des modules connectés. Ce dernier enverra périodiquement des requêtes de présences jusqu’à ce que tous les modules aient répondu. Le bateau ne peut pas sortir de cet état tant que tous les modules ne sont pas connectés. Lorsque tous les modules sont connectés et aucune présence n’est expirée, le module de cockpit envoie alors.

// % -Etats possibles: IDLE, STARTING, RUNNING, SHUTDOWN

// % Annonce de etat:
// % -1 octet
// % -etat desiree
// % -envoye du cockpit

// % Requête de confirmation:
// % -Adresse PCB ciblé (ou broadcast)
// % -Verifier que PCB est dans le bon etat

// % Requête état actuel:
// % -Demande d'un PCB vers cockpit pour etat actuel (bateau)
// % -Reponse avec annonce de l'état actuel

// % Confirmation etat actuel:
// % -Etat actuel du PCB (1er octet)
// % -ACK pour Requête de confirmation

// % Requête de présence:
// % -Adresse ciblee (1er octet)

// % Annonce de présence:
// % -ACK

// % Annonce d’une donnée:
// % -Adressage interne du PCB (capteurs)
// % -Donnée mesurée (format dépends du capteur)

// % Requête d’une donnée:
// % -Adresse PCB cible
// % -Adressage interne du PCB (capteurs)

// % Contrôle d’une procédure:
// % -Identifiant: Démarrage, Shutdown, Alimentation FCs (id number) 
// % -Action: Start Action, Stop Action, Suspend Action

// % Requête d’état d’une procédure:
// % -Numero d'identifiant
// % -États possibles: Running, Completed, Not Running, Not Started

// % Annonce d’état d’une procédure:
// % -État possibles 
// % -Numero d'identifiant

// % Erreurs:
// % -Types d'erreurs: Temperature, Pression, Valeurs critiques
// % -Donnees? (i.e.: Temp, pression élevée)

#show: annex

= Capteurs et données <annex:sensors>

== Capteurs

#table(columns: 3,
  table.header([Capteur], [Données], [Format]),

  [#link("https://www.analog.com/en/products/ds18b20.html")[DS18B20]], [Température (#sym.degree C)], [Fixed point: 12 bits (4 bits de décimales)],

  [_Capteur de température ambiante_ (modèle à déterminer)], [Température (#sym.degree C)], [Fixed point: 20 bits (12 bits de décimales)#footnote[Basé sur la datasheet du #link("https://www.adafruit.com/product/5183")[DHT20], une option considérée pour ce capteur.]],

  table.cell(rowspan: 3)[#link("https://www.analog.com/en/products/ltc2944.html")[LTC2944]],
  [État de charge (%)], [`u8` (255 = 100%, 0 = 0%)],
  [Courant (A)], [Fixed point: 16 bits (9 bits de décimales)],
  [Tension (V)], [Fixed point: 16 bits (9 bits de décimales)],

  table.cell(rowspan: 3)[#link("https://www.sparkfun.com/gps-module-gp1818mk-56-channel.html")[GP1818MK]#footnote[On regarde pour changer le modèle de GPS, mais il devrait nous permettre d'obtenir les mêmes données. On peut réduire la latitude/longitude à 24 bits au besoin (avec 7 bits de décimales chaque).]],
  [Latitude (#sym.degree, minutes)#footnote[Voir datasheet pour les unités, c'est un peu étrange.]], [Fixed point: 32 bits (15 bits de décimales)],
  [Longitude (#sym.degree, minutes)], [Fixed point: 32 bits (15 bits de décimales)],
  [Vitesse (km/h)], [Fixed point: 16 bits (10 bits de décimales)],

  table.cell([#link("https://www.bosch-sensortec.com/products/smart-sensor-systems/bno055", [BNO055])], rowspan: 2),
  [Accélération (m/s#super[2])], [Pour chacun des trois axes:\ Fixed point: 16 bits (9 bits de décimales)],
  [Orientation (#sym.degree)], [Pour chacun des trois axes (_heading_, _roll_, _pitch_):\ Fixed point: 16 bits (5 bits de décimales)],

  table.cell([Protium 2500#footnote[Le modèle n'est plus disponible sur le site du manufacturier. Il faut donc se contenter des fichiers sur #link("https://polymtlca0.sharepoint.com/:f:/r/sites/Exocet/Shared%20Documents/General/2-%20Documents%20Actifs%20(2024-2025)/1-%20Embarqu%C3%A9%20+%20%C3%89lectrique/Datasheets/Electric%20System%20Components/Hydrogen%20Fuel%20Cell%20-%20Protium-2500?csf=1&web=1&e=TkVA5z")[Teams de l'équipe] pour l'instant. Il sera remplacé d'ici peu par un Google Drive.]], rowspan: 7),
  [Puissance (W)], [Fixed point: 14 bits (4 bits de décimales)],
  [Tension (V)], [Fixed point: 14 bits (7 bits de décimales)],
  [Courant (A)], [Fixed point: 14 bits (7 bits de décimales)],
  [Énergie (Wh)], [`u16`],
  [Température (#sym.degree C)], [Fixed point: 16 bits (7 bits de décimales)],
  [Pression interne (barg)], [Fixed point: 14 bits (8 bits de décimales)],
  [Efficacité (%)], [`u8` (255 = 100%, 0 = 0%],

  table.cell([Outboard 5.0#footnote[Ces données proviendront sûrement du _charge controller_, mais
  tout ça reste à voir]], rowspan: 3),
  [Courant (A)], [Fixed point: 16 bits (7 bits de décimales)],
  [Tension (V)], [Fixed point: 16 bits (8 bits de décimales)],
  [Puissance (W)], [Fixed point: 16 bits (2 bits de décimales)],

  [#link("https://www.swagelok.com/downloads/webcatalogs/fr/ms-02-225.pdf")[PTI-S-AG4-21\?\?-\?]#footnote[La valeur des capteurs de pressions est lu par l'ADC des STM32.]], [Pression (barg)], [Fixed point: 12 bits (10 bits de décimales)],
  [#link("https://www.swagelok.com/downloads/webcatalogs/fr/ms-02-225.pdf")[PTI-S-AG400-21BG-\?]], [Pression (barg)], [Fixed point: 12 bits (3 bits de décimales)],

  [_Actuateur de valve_], [État (`enum` + `bool`)], [
  Une de ces valeurs:
  - `OPEN`
  - `CLOSED`
  - `UNKNOWN`

  Ainsi qu'un `bool` (`true` = bon état, `false` = mauvais état).
  ],

  table.cell([_État du bateau_]), [État (`enum`)], [
    Une de ces valeurs:
    - `IDLE`
    - `STARTING`
    - `STARTED`
    - `SHUTTING DOWN`
  ],

  table.cell([_Switch électronique_]), [État], [`bool` (`true` = ouverte, `false` = fermée)],

  table.cell([_Connexion LTE_]), [État], [`bool` (`true` = connecté, `false` = pas de connexion)],

  table.cell([_Ventilateur_]), [Vitesse de rotation], [`u8` (255 = vitesse max., 0 = à l'arrêt)],

  table.cell([_Détecteur d'isolation_]), [État de l'isolation], [`bool` (`true` = ok, `false` = défaut d'isolation)],

  table.cell([_Charge controller_]), [_À déterminer_], [_à déterminer_],
)

== Capteurs sur chaque module

#table(columns: 3,
  table.header([Module], [Capteurs/données disponibles], [Description (quantité)]),

  [PCB01 - Cockpit], [_État du bateau_], [État actuel du bateau (1)],

  table.cell(rowspan: 4)[PCB02 - Plaque hydrogène],
  [DS18B20], [
    - Température de la plaque
    - À déterminer
    - À déterminer

    (3 au total)
  ],
  [PTI-S-AG4-21\?\?-\?], [Basse pression (1)],
  [PTI-S-AG400-21BG-\?], [Haute pression (1)],
  [_Actuateurs de valve_], [
    - Haute pression
    - Basse pression
    - À déterminer

    (3 au total)
  ],

  table.cell(rowspan: 3)[PCB03 - Batterie de télémétrie],
  [LTC2944], [Informations sur la batterie (1)],
  [DS18B20], [Température de la batterie (1)],
  [_Switch électronique_], [État de l'alimentation 24V (1)],

  table.cell(rowspan: 6)[PCB04 - Contrôle de la puissance],
  [DS18B20], [
    - Température de la batterie
    - Température pile à combustible A
    - Température pile à combustible B

    (3 au total)
  ],
  [LTC2944], [Informations sur la batterie auxiliaire (1)],
  [Protium 2500], [
    - Informations pile à combustible A
    - Informations pile à combustible B

    (2 au total)
  ],
  [Outboard 5.0], [Informations sur le moteur (1)],
  [_Switches électroniques_], [
    - BOP
    - Sortie pile à combustible A
    - Sortie pile à combustible B
    - Résistance de freinage
    - Alimentation du moteur

    (5 au total)
  ],
  [_Charge controller_], [À déterminer (1)],

  table.cell(rowspan: 2)[PCB05 - Capteurs],
  [GP1818MK], [Données GPS (1)],
  [BNO055], [Orientation et accélération (1)],

  table.cell(rowspan: 2)[PCB06 - Système de refroidissement],
  [_Capteur de température ambiante_], [Température ambiante du boîtier (à déterminer)],
  [_Ventilateur_], [Vitesse du ou des ventilateur(s) (à déterminer)],

  table.cell(rowspan: 1)[PCB07 - Contrôle d'isolation électrique#footnote[Pourrait être combiné avec
  le PCB04.]],
  [_Détecteur d'isolation_], [
    - Isolation pile à combustible A
    - Isolation pile à combustible B

    (2 au total)
  ],

  table.cell(rowspan: 1)[HAT01 - Dashboard du pilote],
  [_aucune donnée_], [N/A],

  table.cell(rowspan: 1)[HAT02 - Télémétrie LTE],
  [_Connexion LTE_], [État de la connexion (1)],
)
