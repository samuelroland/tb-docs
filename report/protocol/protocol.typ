== Définition du `Live protocol`

=== Vue d'ensemble
Cette partie définit le protocole de communication nommé `Live Protocol`, qui régit les interactions entre les clients PLX et un serveur PLX. Sur le plan technique, il fonctionne sur le protocole WebSocket pour permettre une communication bidirectionnelle. Trois parties composent notre protocole: la gestion de la connexion, la gestion des sessions et le transfert du code et résultats autour d'un exercice. La particularité du protocole est qu'il n'inclue pas d'authentification. Les clients sont néamoins identifiés par un identifiant unique (`client_id`) permettant de reconnaître un client qui perd la connexion et se reconnecte ensuite.

Le protocole définit deux types de messages: les clients envoie des actions (message `Action`) au serveur et le serveur leur envoie des événements (message `Event`). Ne pas avoir de système de compte implique que tous les clients sont égaux par défaut. Pour éviter que n'importe quel client puisse contrôler une session en cours, comme changer d'exercice ou arrêter la session, un système de role est défini. Ce role attribué à chaque client dans une session est soit leader soit follower. Seul les clients leaders peuvent agir sans restriction sur la session. Les clients leaders ne font pas les exercices, mais recoivent chaque modification envoyée par les clients followers. Pour supporter des contextes variés, il est possible d'avoir plusieurs leaders par session si nécessaire. De même, nous aurions pu définir un rôle enseignant·e et étudiant·e, mais cela met de côté des usages avec des assistant·es en plus ou des étudiant·es durant une révision en groupe.

Un système de gestion des pannes du serveur et des clients est défini, pour une expérience finale claire et fluide. Les clients pourront ainsi afficher dans leur interface quand le serveur s'est éteint. Pour un·e étudiant·e qui aurait du redémarer son ordinateur durant une session, son enseignant·e ne devrait pas voir 2 versions du même code avant et après redémarrage, mais bien uniquement la dernière version à jour. Les clients doivent pouvoir facilement se reconnecter et récupérer l'état actuel en cours. Un·e enseignant·e qui se déconnecterait involontairement, n'impacterait pas la présence de la session. Ces gestions de pannes sont importantes pour supporter des instabilités de Wifi notamment.

#pagebreak()

=== Architecture haut niveau
La @high-level-arch montre un aperçu des besoins sur les informations à transmettre et recevoir. PLX a déjà accès aux exercices, stockés dans des repository Git clonés au début du semestre. Une fois une session lancée, le serveur n'a pas besoin de connaître les détails des exercices, il agit principalement comme un relai. Le serveur n'est utile que pour un entrainement dans une session live, il n'est pas nécessaire pour un entrainement tout seul.

#figure(
  image("../schemas/high-level-arch.opti.svg", width:100%),
  caption: [Architecture haut niveau décrivant les interactions entre les clients PLX et le serveur de session live],
) <high-level-arch>
// todo schéma -> inclusif
// todo schéma -> update to desktop ui ?

=== Définition des sessions live
Le protocole tourne autour du concept de session, qui peut être vu comme un endroit virtuel temporaire où plusieurs personnes s'entrainent sur les mêmes exercices au même moment, une partie des personnes ne participent pas directement mais observe les changements. Une session est définie par un titre et une ID textuel de groupe, cette combinaison est unique sur le serveur.

Cette ID de groupe est complètement arbitraire et permet de grouper les sessions du même cours ensemble. Par défaut, le client PLX va prendre le lien HTTPS du repository Git. Dans le cas de fork du cours qui souhaiterai apparaître dans la même liste, cette ID peut être reconfigurée.

Si 100 sessions live tournent en même temps, seul les sessions du cours seront listées. Si 1-6 enseignant·es enseignent un cours en même temps, la liste ne sera que de 1-6 entrées, ce qui simplifie l'accès à la bonne session. Le titre de la session sert aux étudiant·es à trouver la session qui les intéressent.

Cela complique aussi une attaque qui viserait à polluer la liste des sessions pour tromper des étudiant·es. Un·e attaquant·e ne peut pas facilement récupérer la liste de toutes les sessions ouvertes, puisqu'il est nécessaire de donner le lien d'un repository Git pour avoir une partie de la liste.

Une personne démarre une session pour un repository qui contient des exercices pour PLX, en choisit une sélection et d'autres rejoignent pour faire ces exercices. La session vit jusqu'à que la personne qui l'a démarrée décide de l'arrêter ou qu'un temps d'expiration côté serveur décide de l'arrêter après un certain temps d'inactivité. L'arrêt d'une session déconnecte tous les clients connectés.

// TODO ajouter notion de sans compte, sécurité particulière,
// sans avoir de système d'authentification.
// rate limiting ?
// éviter le spam ?
//
// Modèle de sécurité
// pas de compte + considère qu'il n'y aura pas de spam + mesure cotés client pour filtrer un potentiel spam
// mesure de trust on first use pour vérifier l'identité du prof

=== Définition et configuration du client
Un "client PLX" est défini comme la partie logicielle de PLX qui se connecte à un serveur PLX. Un client n'a pas besoin d'être codé dans une langage ou pour une plateforme spécifique, le seul prérequis est la capacité d'utiliser le protocole WebSocket. Chaque client est anonyme (le nom n'est pas envoyé, il ne peut pas être connu de l'enseignant·e facilement), mais s'identifie par un `client_id`, qu'il doit persister. Cette ID doit rester secrète entre le client et serveur, sinon il devient possible de se faire passer pour un autre client. Cela pose surtout des problèmes lorsque ce même client gère des sessions. Par soucis de simplicité, les clients PLX génère une UUID (exemple `aeb5f2ec-aa69-42b0-a55d-8948842b3df6`), un identifiant de plus grande entropie pourrait être utilisé plus tard facilement si le besoin de plus de sécurité devient nécessaire.

// add ref to UUID spec

Un même client ne peut pas se connecter en même temps au même serveur. En démarrant deux fois l'application, les deux chargeront les même `client_id`, qu'une seule instance pourra être connectée à la fois. Chaque client ne peut aussi rejoindre qu'une session à la fois. Les messages n'ont pas besoin d'indiquer la session concernée, le serveur doit maintenir le lien entre un socket et son `client_id` vers session.

Pour qu'un client puisse se connecter au serveur, un repository d'un cours PLX doit contenir à sa racine un fichier `live.toml` avec les entrées suivantes.
// todo to figure
```toml
# This is the configuration used to connect to a live server
domain = "live.plx.rs"
port = 9120
group_id = "https://github.com/samuelroland/plx-demo.git"
```
Le `port` et le `group_id` sont optionnels: la valeur par défaut du port est utilisée et le `group_id` peut être récupérée via l'origine du repository cloné.

=== Transport, sérialisation et gestion de la connexion
Ce protocole se base sur le protocole Websocket *RFC 6455* @WSRFC qui est basé sur TCP. Il utilise le port *9120* par défaut, qui a été choisi parmi la liste des ports non assignés publiés par l'IANA @IANAPortsNumbers. Ce port est également configurable s'il est nécessaire d'avoir plusieurs serveurs sur la même adresse IP ou s'il serait déjà pris par un autre logiciel. Les messages, transmis dans le type de message `Text` du protocole WebSocket, sont transmis sous forme de JSON sérialisé en chaine de caractères.

La @wsurl montre les champs `live_protocol_version` et `live_client_id` qui sont deux informations obligatoires.
#figure(
text(size: 0.9em)[
```
ws://live.plx.rs:9120?live_protocol_version=0.1.0&live_client_id=e9fc3566-32e3-4b98-99b5-35be520d46cb
```
], caption: [Lien de connexion en WebSocket]) <wsurl>

#figure(raw(block: true, lang: "json", read("messages/Action-SendFile.json")), caption: [Un exemple de message en format JSON, ici l'action `SendFile`])

// todo connection managment ??

#pagebreak()
=== Messages
Voici les actions définies, avec l'événement associé en cas de succès de l'action. Cet événement est parfois renvoyé au même client ou à d'autres, la 4ème colonne indique les destinataires de l'événement.

Tous les champs et le messages final en JSON doit être encodés en UTF-8 valide. Toutes les dates sont gérées en UTC, seulement l'affichage s'adapte au fuseau horaire local. Les dates sont sérialisées sous forme de `timestamp`, c'est à dire en nombre de secondes depuis l'époque Unix (1er janvier 1970).
// TODO ref biblio

L'implémentation de la structure de messages est défini en Rust (`msg.rs`) et également dans les bindings TypeScript (`desktop/src/ts/bindings.ts`) générés.

// TODO: make sure all messages are here !!!!!
// see #include "messages/messages.typ"

#text(size: 0.8em)[
#table(
  columns: 4,
  stroke: 1pt + gray,
  [*Identifiant*], [*But*],[*Evénement associé*],[*Evénement envoyé à*],
  [`Action::StartSession`], [Démarrer une session],[`Event::SessionJoined`], [même client],
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Action-StartSession.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionJoined.json"))]),

  [`Action::GetSessions`], [Lister les sessions ouvertes pour un `group_id` donné],[`Event::SessionsList`], [même client],
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Action-GetSessions.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionsList.json"))]),

  [`Action::JoinSession`], [Rejoindre une session en cours],[`Event::SessionJoined`], [même client],
  table.cell(colspan: 2,[#raw(block: true, lang: "json", read("messages/Action-JoinSession.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionJoined.json"))]),

  [`Action::LeaveSession`], [Quitter une session],[`Event::SessionLeaved`], [même client],
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Action-LeaveSession.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionLeaved.json"))]),
  [`Action::StopSession`], [Arrêter une session, seul le client qui a démarré peut le faire],[`Event::SessionStopped`], [tous les clients de la session],
  table.cell(colspan: 2,[#raw(block: true, lang: "json", read("messages/Action-StopSession.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionStopped.json"))]),

  [`Action::SendFile`], [Envoyer une nouvelle version d'un fichier],[`Event::ForwardResult`], [aux clients leaders de la session],
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Action-SendFile.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-ForwardFile.json"))]),

  [`Action::SendResult`], [Envoyer le résultat d'un check],[`Event::ForwardResult`], [aux clients leaders de la session],
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Action-SendResult.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-ForwardResult.json"))]),
  table.cell(colspan: 4, [todo fix with other examples]),
  // table.cell(colspan: 4, [#raw(block: true, lang: "json", read("messages/Action-SendResult.json"))]),
  // table.cell(colspan: 4, [#raw(block: true, lang: "json", read("messages/Action-SendResult.json"))]),
  // table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Action-SendResult.json"))]),
  // TODO: fix ces variantes de SendResults

  [`Action::SwitchExo`], [Changer d'exercice actuel de la session, identifié par un chemin relatif],[`Event::ExoSwitched`], [à tous les clients de la session],
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Action-SwitchExo.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-ExoSwitched.json"))]),
  // [`Action::`], [],[`Event::`], [même client],
)
]

Voici les événements non couvert précédemment. Le message `Stats` sur la @statsevent est envoyé aux leaders à chaque fois qu'un client rejoint ou quitte la session, excepté quand le leader créateur rejoint.
#text(size: 0.8em)[
#figure(raw(block: true, lang: "json", read("messages/Event-Stats.json")), caption: [Message `Event::Stats`]) <statsevent>
]


#text(size: 0.8em)[
#figure(raw(block: true, lang: "json", read("messages/Event-ServerStopped.json")), caption: [Message `Event::ServerStopped`]) <serverstoppedevent>
]

Pour terminer une liste des types d'erreur qui peuvent être reçues du serveur via un `Event::Error`, contentant différent types de `LiveProtocolError`. Ces erreurs peuvent arriver dans différents contextes et ne sont pas toujours liées à une action précise. Une partie des erreurs ne peut pas arriver si le client gère correctement son état et ne tente pas des actions non autorisée par son rôle. Il faut bien sûr gérer les cas où le client aurait été modifié pour être malicieux ou simplement par erreur de logique, le serveur doit réagir correctement.
// TODO make sure all files are here

#text(size: 0.8em)[
#table(
  columns: 2,
  stroke: 1pt + gray,

[#raw(block: true, lang: "json", read("messages/Event-Error-0.json"))#text(size: 0.9em)[`Event::Error(LiveProtocolError::FailedToStartSession)`]],
[#raw(block: true, lang: "json", read("messages/Event-Error-1.json"))#text(size: 0.9em)[`Event::Error(LiveProtocolError::FailedToJoinSession)`]],
[#raw(block: true, lang: "json", read("messages/Event-Error-2.json"))#text(size: 0.9em)[`Event::Error(LiveProtocolError::FailedSendingWithoutSession)`]],
[#raw(block: true, lang: "json", read("messages/Event-Error-3.json"))#text(size: 0.9em)[`Event::Error(LiveProtocolError::FailedToLeaveSession)`]],
[#raw(block: true, lang: "json", read("messages/Event-Error-4.json"))#text(size: 0.9em)[`Event::Error(LiveProtocolError::SessionNotFound)`]],
[#raw(block: true, lang: "json", read("messages/Event-Error-5.json"))#text(size: 0.9em)[`Event::Error(LiveProtocolError::CannotJoinOtherSession)`]],
[#raw(block: true, lang: "json", read("messages/Event-Error-6.json"))#text(size: 0.9em)[`Event::Error(LiveProtocolError::ForbiddenSessionStop)`]],
[#raw(block: true, lang: "json", read("messages/Event-Error-7.json"))#text(size: 0.9em)[`Event::Error(LiveProtocolError::ActionOnlyForLeader)`]],
  )
]

// - Client: En tant que client follower, configurer le mode du broadcast: sa fréquence (live, ou quelques secondes), le type de changement à recevoir (tout, seulement les checks) ou lancer une mise à jour maintenant
// - Client: Mettre en pause le streaming des changements du serveur vers le client // système d'activation et désactivation de l'abonnement ? meilleur wording ?

#pagebreak()

=== Diagrammes de séquences

Maintenant que les différents types de messages sont connus, voici quelques diagrammes de séquence pour mieux comprendre le contexte et l'ordre des messages.

#figure(
  box(image("diagrams/session.svg", width: 100%)),
  caption: [Exemple de communication de gestion d'une session],
)
// todo bigger width ??

#figure(
  box(image("diagrams/training.svg", width: 100%)),
  caption: [Exemple de communication pour montrer le transfert des fichiers et des résultats],
)
// todo bigger width ??

#figure(
  box(image("diagrams/shutdown.svg", width: 80%)),
  caption: [Exemple de communication pour montrer l'arrêt du serveur,#linebreak()avec différents clients connectés à un session ou non],
)

==== Gestion des clients face aux pannes ou redémarrages

TODO faire propre
// Si un·e étudiant·e quitte PLX et le relance, on aimerait que le client PLX soit reconnu comme étant le même que précédemment, sans avoir de système d'authentification. Le but est d'éviter des incohérences dans l'interface, par exemple de voir le code d'un·e étudiant·e deux fois, parce que le client PLX a été redémarré entre deux et qu'il est considéré comme un tout nouveau client.
//
// Afin de supporter différentes instabilités du réseau, tel que de pertes de Wifi ou des Wifi surchargés,  nous mettons en place quelques mécanismes permettant de reconnecter des clients. 
//
// Nous ne supportons pas les pannes du serveur. Nous pourrions dans le futur imaginer un système où les clients leaders recréent la session si le serveur a été redémarré, mais cela ne sera pas nécessaire pour les premières versions de PLX.
//
// keep alive, fermeture de connexion

==== Workflow d'usage des sessions live
TODO faire propre
// Nous souhaitons définir un système flexible, qui peut être autant utilisés avec 40 étudiant·es et 1 enseignant·e, que 120 étudiant·es, 3 enseignant·es et 2 assistant·es, ou encore 3 étudiant·es coachés par un·e étudiant·e plus expérimenté·e durant des révisions. Au final, ce protocole ne distingue que 2 rôles: leader et follower. Le rôle leader est attribué au client qui crée une session, il permet de gérer l'avancement des exercices, de recevoir le code et les résultats ou encore d'arrêter la session. Le rôle de follower permet de rejoindre une session, envoyer du code et des résultats pour cette session. Un client follower ne recevra pas le code et les résultats d'autres clients followers. Il peut cependant y avoir plusieurs leaders sur une session.


==== Versions et rétrocompatibilité
TODO faire propre
// Pour que le serveur et les clients connectés puissent savoir s'ils communiquent avec une version compatible, il est nécessaire d'envoyer un numéro de version de ce protocole à la première connexion. C'est le serveur qui sera souvent le plus à jour et décide ainsi s'il refuse la connexion, en renvoyant un code HTTP 400.
//
// Pour ce numéro de version on utilise le Semantic Versionning 2.0.0 @SemverWebsite. Durant le développement, le protocole reste en version `0.x.y` et ne sera stabilisé qu'une fois le protocole et son implémentation dans PLX auront été testés quelques temps en grandeur nature.

==== Evolutivité
TODO faire propre
// Pour permettre d'évoluer le protocole au fil du temps, le numéro de version sera passée dans l'entête du "handshake" HTTP, sous le nom de `LiveProtocolVersion`, qui ne devrait pas avoir besoin de changer. Ce champ n'est évidemment pas standard mais IETF recommende depuis 2012 de ne pas ajouter le préfix `X-` @IetfNoXPrefixRfc.  Cela permettra de changer le format ou les types de messages, ou encore le format de sérialisation, tout en gardant ce numéro de version séparé et toujours accessible peu importe la version du serveur.
//
// Le concept de session lancée par des clients leaders et de synchronisation de données provenant de clients followers vers des clients leaders, peut facilement être étendu à d'autres usages. Si on imagine d'autres types d'exercice que du code, des exercices de choix multiples par exemple, il suffirait d'ajouter une nouvelle action pour envoyer une réponse et un événement associer pour renvoyer cette réponse vers les clients leaders.
//
// Si la première requête ne contient pas de numéro de version, la requête est ignorée et la connexion est fermée.

===== Performance
TODO faire propre
// Des mesures basiques sont prises pour éviter un poids ou un nombre inutile de messages envoyés sur le réseau. Ces mesures ont pour but de limiter le nombre de messages que le serveur doit gérer lorsque plusieurs sessions avec de nombreux clients connectés. Nous ne faisons pas de benchmark pour le moment, pour se concentrer sur développer une implémentation correcte.
//
// - N'envoyer un morceau de code uniquement s'il a été modifié depuis le dernier envoi
// - N'envoyer que les fichiers modifiés par rapport au code de départ à la première synchronisation. Dans un exercice à 3 fichiers avec 1 fichier à changer, les 2 autres fichiers ne devraient pas être envoyés, puisque les clients followers peuvent avoir la version originale stockée dans le repository.
// - N'envoyer un résultat que s'il est différent depuis le dernier envoi. Sauver 3 fois le même fichier sans modification, donnera le même résultat, qui ne peut être envoyé qu'une seule fois pour la première sauvegarde.
// - Bufferiser les envois en boucle: quand le serveur doit envoyer une longue suite de messages à un client, l'envoi se fait en bufferisant les messages pour éviter une partie d'appels systèmes

//
// NOTES
// ' Action are actions taken mostly by client, but could also be the server closing the session after inactivity or during shutdown.
// ' Event are responses to actions, as everything is asynchronous
// ' exemple messages JSON pour les 2 formats

