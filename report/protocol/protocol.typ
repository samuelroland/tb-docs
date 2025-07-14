== Définition du protocole
Ce chapitre définit le protocole de communication qui régit les interactions entre les clients PLX et un serveur PLX.

=== Vue d'ensemble du protocole
Sur le plan technique, il fonctionne sur le protocole WebSocket pour permettre une communication bidirectionnelle. Trois parties composent notre protocole: la gestion de la connexion, la gestion des sessions et le transfert du code et résultats d'un exercice. La particularité du protocole est qu'il n'inclut pas d'authentification. Les clients sont néamoins identifiés par un identifiant unique (`client_id`) permettant de reconnaître un client après une déconnexion temporaire.

Le protocole définit deux types de messages: les clients envoient des actions au serveur (message `Action`) et le serveur leur envoie des événements (message `Event`). La plupart des événements sont envoyés du serveur en réponse à des actions reçues.

#figure(
  image("imgs/basic-event-action-flow.png", width: 80%),
  caption: [Les deux types de messages ne sont envoyés que dans une direction],
) <fig-basic-event-action-flow>

Ne pas avoir de système de compte implique que tous les clients sont égaux par défaut. Pour éviter que n'importe quel client puisse contrôler une session en cours et arrive à changer d'exercice ou arrêter la session, un système de rôle est défini. Nous aurions pu définir un rôle enseignant·e et étudiant·e, mais cela exclut d'autres contextes: lorsque des assistant·es sont présent·es ou qu'un groupe d'étudiant·es révisent ensemble, en dehors des cours. Nous avons besoin de définir deux rôles qui permettent de distinguer les clients qui gèrent une session et les autres qui y participent. Nous choisissons ainsi de les nommer respectivement *leader* et *follower*. Le serveur peut ainsi vérifier à chaque `Action` reçue que le rôle du client autorise l'action.

Ce rôle est attribué à chaque client dans une session, avoir un rôle en dehors d'une session ne fait pas de sens. Les clients followers suivent les exercices lancés par les clients leaders et envoient le code et les résultats des checks à chaque changement. Les clients leaders ne participent pas aux exercices, mais le serveur leur transfère chaque modification envoyée par les clients followers. Le protocole n'empêche pas d'avoir plusieurs leaders par session, pour permettre certains contextes avec plusieurs enseignant·es ou assistant·es présent·es, pour aider à relire tous les morceaux de code envoyés.
// TODO really la dernière phrase ?

Un système de gestion des pannes du serveur et des clients est défini, pour éviter d'engendrer de la confusion dans l'expérience finale. Les instabilités de Wifi, la batterie vide ou un éventuel crash de l'application ne devrait pas impacter le reste des participant·es de la session. Quand le serveur s'éteint, en cas de panne ou de mise à jour, les clients doivent pouvoir afficher une alerte dans leur interface. Un·e enseignant·e qui se déconnecte involontairement, n'impacte pas la présence de la session, qui continuera d'exister sur le serveur.


=== Définition des sessions live
Le protocole tourne autour du concept de _session live_, qui peut être vu comme un endroit virtuel temporaire où plusieurs personnes s'entrainent sur les mêmes exercices au même moment. Une partie des personnes ne participent pas directement, mais observent l'entrainement des autres.

Une session est définie par un nom et un ID de groupe (`group_id`), cette combinaison est unique sur le serveur. Cet ID textuel de groupe est complètement arbitraire. Par défaut, le client PLX va prendre le lien HTTPS du repository Git pour regrouper les sessions du même cours. Dans le cas d'un fork du cours qui souhaiterait apparaître dans la même liste, cet ID peut être reconfiguré. Cette ID peut paraitre inutile, mais elle présente deux intérêts importants: une simplification de l'accès à une session et une limitation du spam.

Si 100 sessions live tournent en même temps, il serait difficile de trouver une session en particulier parmi une liste de 100 entrées. Ainsi, graĉe au regroupement par `group_id`, seules les sessions du cours seront listées. Si 1-6 enseignant·es enseignent un cours en même temps, la liste ne sera longue que de 1-6 entrées et le nom de la session sera suffisant pour que les étudiant·es puissent trouver celle qui les intéressent.

Un problème potentiel de spam est la création automatisée d'autres sessions avec des noms très proches des sessions légitimes pour tromper les étudiant·es. Un autre cas encore plus ennuyant de pollution d'une session, est l'envoi de morceau de code aléatoire de centaines de clients fictifs. Cette attaque rendrait le tableau de bord des enseignant·es inutilisable, comme le code des 20 étudiant·es seraient noyés au milieu de centaines d'autres. Puisqu'il est nécessaire de connaître le lien d'un repository Git d'un cours PLX, ce qui ne donne accès à une partie de la liste des sessions en cours du serveur, ce genre d'attaque est déjà rendue plus difficile pour un·e attaquant·e externe à l'école.

Une personne démarre une session pour un repository qui contient des exercices pour PLX et d'autres rejoignent pour faire ces exercices. Une fois une sélection d'exercices préparée, les exercices sont lancés l'un après l'autre au rythme imposé par le leader. La session vit jusqu'à que le leader l'arrête ou qu'un temps d'expiration côté serveur décide de l'arrêter après un certain temps d'inactivité. L'arrêt d'une session fait quitter tous les clients connectés mais ne coupe pas les connexions WebSocket.

=== Définition, identifiants et configuration du client
Un "client" est défini comme la partie logicielle de PLX qui se connecte à un serveur de session live. Un client n'a pas besoin d'être codé dans un langage ou pour une plateforme spécifique, le seul prérequis est la capacité d'utiliser le protocole WebSocket. Chaque client est anonyme (le nom n'est pas envoyé, il ne peut pas être connu de l'enseignant·e facilement), mais s'identifie par un `client_id`, qu'il doit persister. Cet ID doit rester secrète entre le client et serveur, sinon il devient possible de se faire passer pour un autre client, ce qui devient problématique pour un client leader.

Par souci de simplicité, les clients PLX génèrent un UUID version 4 (exemple `1be216e1-220c-4a0e-a582-0572096cea07`) @uuidv4. Le protocole ne définit pas de contrainte sur le contenu de cet identifiant, un autre format de plus grande entropie pourrait facilement être utilisé plus tard, si une sécurité plus accrue devenait nécessaire.

Les clients leader ont besoin d'identifier la source du message transféré. Est-ce qu'un bout de code vient d'un nouveau client ou correspond à une mise à jour d'un client existant ? Le `client_id` doit rester secret et ne doit pas être envoyé vers un autre client, il ne peut pas être utilisé pour ce problème. Nous avons besoin d'un autre identifiant de nature temporaire. Nous souhaitons garder l'intérêt de l'anonymité, cet identifiant doit être différent à chaque session pour un client donné.

La solution choisie consiste à générer un numéro de client `client_num`, valeur entière incrémentale (partant de zéro), attribué par le serveur dans l'ordre d'arrivée dans la session. L'ordre d'arrivée étant très souvent différent, chaque client devrait généralement avec un numéro différent. La deuxième utilité de ce numéro est de permettre aux participant·es de mentionner à l'oral un code spécifique, par exemple: _Je ne comprends pas l'erreur, est-ce que vous pouvez me dire pourquoi mon code ne compile pas, en numéro 8 ?_ Ou encore _Sur le code 23 que vous aviez montré avant, est-ce que l'approche était meilleure que ce code 12 ?_

Un client ne peut pas se connecter plusieurs fois simultanément au même serveur. Cela peut arriver lorsque l'on démarre l'application deux fois, le même `client_id` sera utilisé sur deux connexions WebSocket distinctes. Lors de la deuxième connexion, la première est fermée par le serveur après l'envoi d'une erreur. Une fois connecté, chaque client ne peut rejoindre qu'une session à la fois.

// todo check fermeture connexion du serveur implémenté ??
// todo check erreur incluse plus bas

Pour qu'un client puisse se connecter au serveur, un repository d'un cours PLX doit contenir à sa racine un fichier `live.toml` avec les entrées visibles sur le @livetoml.
#figure(
```toml
# This is the configuration used to connect to a live server
domain = "live.plx.rs"
port = 9120
group_id = "https://github.com/samuelroland/plx-demo.git"
``` , caption: [Exemple de configuration `live.toml`]) <livetoml>
Le `port` et le `group_id` sont optionnels. La valeur par défaut du port du protocole est utilisée et le `group_id` par défaut peut être récupéré via l'origine du repository cloné.
// todo default values implemented ??

=== Transport, sérialisation et gestion de la connexion
Ce protocole se base sur le protocole Websocket RFC 6455 @WSRFC qui est basé sur TCP. Il utilise le port *9120* par défaut, qui a été choisi parmi la liste des ports non assignés publiés par l'IANA @IANAPortsNumbers. Ce port est également configurable si nécessaire. Les messages, transmis dans le type de message `Text` du protocole WebSocket, sont transmis sous forme de JSON sérialisé en chaine de caractères.

#figure(raw(block: true, lang: "json", read("messages/Action-SendFile.json")), caption: [Un exemple de message en format JSON, ici l'action `SendFile`])

Pour que le serveur et les clients connectés puissent savoir s'ils communiquent avec une version compatible, il est nécessaire d'envoyer un numéro de version de ce protocole à la première connexion. C'est le serveur qui sera souvent le plus à jour et décidera d'accepter ou refuser la connexion, en renvoyant un code HTTP 400 s'il la refuse.

// todo check le 400 

Comme le montre le @wsurl, les clients doivent se connecter en indiquant la version du protocole supportée par le client (`live_protocol_version`) et le `client_id` présenté précédemment (`live_client_id`). Si cette première requête ne contient pas ces informations, le serveur la refusera également.

#figure(
text(size: 0.9em)[
```
ws://live.plx.rs:9120?live_protocol_version=0.1.0&live_client_id=e9fc3566-32e3-4b98-99b5-35be520d46cb
```
], caption: [Lien de connexion en WebSocket]) <wsurl>

Les navigateurs web ne pouvant pas définir des entêtes HTTPs via l'API `WebSocket`, il est nécessaire de passer via la querystring.
// todo ref biblio

Pour ce numéro de version on utilise le Semantic Versionning 2.0.0 @SemverWebsite. Le numéro actuel est `0.1.0` et restera sur la version majeur zéro (`0.x.y`) durant la suite du développement, jusqu'à que le protocole ait pris de la maturité.

La connexion WebSocket devrait se terminer comme le protocole WebSocket le définit, c'est à dire en fermant proprement la connexion WebSocket avec un message de type `Close`.
// todo ref et check ? utile ?


=== Messages
Voici les actions définies, avec l'événement associé en cas de succès de l'action. Tous les champs et le message final en JSON doivent être encodés en UTF-8. Toutes les dates sont générées par le serveur en UTC. Les dates sont sérialisées sous forme de _timestamp_ #footnote[le nombre de secondes depuis l'époque Unix (1er janvier 1970).].
// TODO ref biblio


// TODO: make sure all messages are here !!!!!
// see #include "messages/messages.typ"

#text(size: 0.7em)[
#table(
  columns: (3fr, 2fr, 4fr, 4fr, 4fr),
  stroke: 1pt + gray,
  [*Identifiant*], [*Clients#linebreak()autorisés*], [*But*],[*Evénement associé*],[*Evénement envoyé*],
  [`Action::StartSession`], [tous], [Démarrer une session],[`Event::SessionJoined`], [même client],
  table.cell(colspan: 3, [#raw(block: true, lang: "json", read("messages/Action-StartSession.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionJoined.json"))\Le numéro retourné est le `client_num`.]),

  [`Action::GetSessions`], [tous], [Lister les sessions ouvertes pour un `group_id` donné],[`Event::SessionsList`], [au même client],
  table.cell(colspan: 3, [#raw(block: true, lang: "json", read("messages/Action-GetSessions.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionsList.json"))]),

  [`Action::JoinSession`], [tous], [Rejoindre une session en cours],[`Event::SessionJoined`], [au même client],
  table.cell(colspan: 3,[#raw(block: true, lang: "json", read("messages/Action-JoinSession.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionJoined.json"))\C'est le même message pour les leaders et followers.]),

  [`Action::LeaveSession`], [tous], [Quitter la session en cours],[`Event::SessionLeaved`], [au même client],
  table.cell(colspan: 3, [#raw(block: true, lang: "json", read("messages/Action-LeaveSession.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionLeaved.json"))]),
  [`Action::StopSession`], [le leader qui a démarré la session], [Arrêter la session en cours],[`Event::SessionStopped`], [à tous les clients de la session],
  table.cell(colspan: 3,[#raw(block: true, lang: "json", read("messages/Action-StopSession.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-SessionStopped.json"))]),

  [`Action::SendFile`], [followers], [Envoyer une nouvelle version d'un fichier],[`Event::ForwardResult`], [aux clients leaders de la session],
  table.cell(colspan: 3, [#raw(block: true, lang: "json", read("messages/Action-SendFile.json"))\Tout le contenu du fichier de code est envoyé peu importe la nature de la modification.]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-ForwardFile.json"))]),

  [`Action::SendResult`], [followers], [Envoyer le résultat d'un check],[`Event::ForwardResult`], [aux clients leaders de la session],
  table.cell(colspan: 3, [#raw(block: true, lang: "json", read("messages/Action-SendResult-1.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-ForwardResult.json"))]),
  table.cell(colspan: 5, [Autres exemples de `Action::SendResult`]),
  table.cell(colspan: 5, align(center, grid( columns: 3,   gutter: 2mm, 
      raw(block: true, lang: "json", read("messages/Action-SendResult-2.json")),
      raw(block: true, lang: "json", read("messages/Action-SendResult-3.json")),
      raw(block: true, lang: "json", read("messages/Action-SendResult-4.json"))
    ))),

  [`Action::SwitchExo`], [leaders], [Changer d'exercice actuel de la session, identifié par un chemin relatif],[`Event::ExoSwitched`], [à tous les clients de la session],
  table.cell(colspan: 3, [#raw(block: true, lang: "json", read("messages/Action-SwitchExo.json"))]),
  table.cell(colspan: 2, [#raw(block: true, lang: "json", read("messages/Event-ExoSwitched.json"))]),
  // [`Action::`], [],[`Event::`], [même client],
)
]

#pagebreak()

Il reste encore des événements indépendants. L'événement `Stats` sur le @statsevent est envoyé aux leaders à chaque fois qu'un client rejoint ou quitte la session, excepté quand le leader créateur rejoint. L'événement `ServerStopped` sur le @serverstoppedevent est envoyé à tous les clients lorsqu'il doit s'arrêter.

#align(center,
grid(
        columns: 2,   
        gutter: 2mm, 

text(size: 0.8em)[
#figure(raw(block: true, lang: "json", read("messages/Event-Stats.json")), caption: [Message `Event::Stats`, #linebreak()reçu uniquement par les clients leaders]) <statsevent>
],

text(size: 0.8em)[
#figure(raw(block: true, lang: "json", read("messages/Event-ServerStopped.json")), caption: [Message `Event::ServerStopped`]) <serverstoppedevent>
]
))

Pour conclure cette liste de messages, voici la liste des types d'erreurs qui peuvent être reçues du serveur via un `Event::Error`, contenant différents types de `LiveProtocolError`. Ces erreurs peuvent arriver dans différents contextes et ne sont pas toujours liées à une action précise. Une partie des erreurs ne peuvent pas arriver si le client gère correctement son état et ne tente pas des actions non autorisées par son rôle.
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

=== Diagrammes de séquence

Maintenant que les différents types de messages sont connus, voici quelques diagrammes de séquence pour mieux comprendre le déroulement d'une session et l'ordre des messages.

#figure(
  box(image("diagrams/session.svg", width: 100%)),
  caption: [Exemple de communication avec gestion d'une session],
)
// todo bigger width ??

#figure(
  box(image("diagrams/training.svg", width: 100%)),
  caption: [Exemple de communication avec transferts des bouts de code et des résultats],
)
// todo bigger width ??

#pagebreak()
Lors de la réception d'un signal d'arrêt (par exemple lors d'un `Ctrl+c`), le processus du serveur ne doit pas quitter immédiatement. Les sessions en cours doivent être arrêtées et tous les clients doivent recevoir un `Event::ServerStopped` qui informe de l'arrêt du serveur.
#figure(
  box(image("diagrams/shutdown.svg", width: 70%)),
  caption: [Exemple de communication qui montre l'arrêt du serveur, #linebreak()avec différents clients dans une session ou en dehors],
)

==== Gestion des pannes

Le serveur n'a rien besoin de persister, toutes les données des sessions peuvent rester en mémoire vive uniquement. Les cas de crash devraient être très rares grâce aux garanties de sécurité mémoire de Rust. On peut aussi configurer le conteneur Docker en mode redémarrage automatique. On suppose aussi que les mises à jour du serveur seront faites en dehors des heures de cours pour limiter les dérangements. Si un redémarrage devaient arriver avec des sessions sont en cours, les participant·es devraient juste recréer ou rejoindre les nouvelles sessions à la main.

Pour simplifier le développement et la logique de reconnexion, les clients n'ont pas besoin de persister l'état de la session, comme l'identifiant de l'exercice en cours. Durant la connexion d'un client, leader ou follower, le serveur doit renvoyer le dernier message `ExoSwitched` qu'il a envoyé dans cette session. Pour un client leader, le serveur doit aussi lui renvoyer tous les derniers `Event::ForwardFile` et `Event::ForwardResult` pour chaque client follower. Ce transfert est requis pour que l'interface puisse reprendre le même état qu'avant déconnexion #footnote[Autrement, le leader devrait attendre les prochains envois de ces événements pour chaque follower afin d'avoir une interface "à jour".].

// todo make sure thats implemented !

Pour un follower déconnecté temporairement, son leader ne devrait pas voir 2 versions du même code avant et après redémarrage, mais uniquement la dernière version. Pour permettre cette expérience, un client qui se reconnecte à une session doit récupérer le même `client_num` qu'avant déconnexion. Le serveur doit maintenir pour chaque session un lien entre `client_id` et `client_num` pour chaque client.

// tester what happening if client is losing connection.

==== Evolutivité
Le concept de session lancée par des leaders et de transfert de données provenant de followers vers des leaders, peut facilement être étendu à d'autres contextes d'apprentissage. Si on souhaite pour entrainer en live d'autres types d'exercice, comme des choix multiples, il suffirait d'ajouter une nouvelle action `Action::SendChoice` pour envoyer une réponse et un événement associé (`Event::ForwardChoice`), pour renvoyer cette réponse vers les clients leaders.

Dans le futur, de nouveaux formats d'exercices seront supportés par PLX. Si cela implique de changer trop souvent la structure des résultats dans le champ `content.check_result` dans le message `Event::SendResult`, une solution serait de ne pas spécifier la structure exacte de ce sous champ et laisser les clients gérer les structures non définies ou partielles. Cela pourrait éviter de régulièrement devoir augmenter le numéro de version majeure à cause de _breaking change_.

// todo note bas de page breaking change ou glossaire ?

// TODO en italic tous les noms en anglais !!!!!!!!!!!

// ===== Performance
// Des mesures basiques sont prises pour éviter un poids ou un nombre inutile de messages envoyés sur le réseau. Ces mesures ont pour but de limiter le nombre de messages que le serveur doit gérer lorsque plusieurs sessions avec de nombreux clients connectés. Nous ne faisons pas de benchmark pour le moment, pour se concentrer sur développer une implémentation correcte.
//
// - N'envoyer un morceau de code uniquement s'il a été modifié depuis le dernier envoi
// - N'envoyer que les fichiers modifiés par rapport au code de départ à la première synchronisation. Dans un exercice à 3 fichiers avec 1 fichier à changer, les 2 autres fichiers ne devraient pas être envoyés, puisque les clients followers peuvent avoir la version originale stockée dans le repository.
// - N'envoyer un résultat que s'il est différent depuis le dernier envoi. Sauver 3 fois le même fichier sans modification, donnera le même résultat, qui ne peut être envoyé qu'une seule fois pour la première sauvegarde.
// - Bufferiser les envois en boucle: quand le serveur doit envoyer une longue suite de messages à un client, l'envoi se fait en bufferisant les messages pour éviter une partie d'appels systèmes

