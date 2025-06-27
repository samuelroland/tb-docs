=== Protocole de sessions live

*Etat: en cours de rédaction*

Cette partie définit le protocole de communication entre les clients et un serveur PLX, pour toutes les interactions nécessaires à la gestion et participation à des sessions lives.

==== Transport et sérialisation
Ce protocole se base sur le protocole Websocket *RFC 6455* @WSRFC qui est basé sur TCP. Il utilise le port *9120* par défaut, qui a été choisi parmi la liste des ports non assignés publiés par l'IANA @IANAPortsNumbers. Ce port est également configurable s'il est nécessaire d'avoir plusieurs serveurs sur la même adresse IP ou s'il serait déjà pris par un autre logiciel. Les messages sont transmis sous forme de JSON sérialisé en chaine de caractères.

==== Définition des sessions live
Le protocole tourne autour du concept de session, qui peut être vu comme un endroit virtuel temporaire où plusieurs personnes s'entrainent sur les mêmes exercices disponible dans un repository Git donné. Une session est définie par un titre et une ID textuel de groupe, cette combinaison est unique sur le serveur.

Cette ID de groupe est complètement arbitraire et permet de grouper les sessions du même cours ensemble. Par défaut, le client PLX va prendre le lien HTTPS du repository Git (récupéré via l'origine du repository cloné). Celle-ci peut être reconfiguré, dans le cas de fork du cours qui veulent apparaître dans la même liste.

Si 100 sessions live tournent en même temps, seul les sessions du cours seront listées. Si 1-6 enseignant·es enseignent un cours en même temps, la liste ne sera que de 1-6 entrées, ce qui simplifie l'accès à la bonne session. Le titre de la session sert aux étudiant·es à trouver la session qui les intéressent.

Cela complique aussi une attaque qui viserait à polluer la liste des sessions pour tromper des étudiant·es, . Un·e attaquant·e ne peut pas facilement récupérer la liste de toutes les sessions ouvertes, puisqu'il est nécessaire de donner le lien d'un repository Git pour avoir une partie de la liste.

Une personne démarre une session pour un repository qui contient des exercices pour PLX, en choisit une sélection et d'autres rejoignent pour faire ces exercices. La session vit jusqu'à que la personne qui l'a démarée décide de l'arrêter ou qu'un temps d'expiration côté serveur décide de l'arrêter après un certain temps d'inactivité. L'arrêt d'une session déconnecte tous les clients connectés.

// TODO ajouter notion de sans compte, sécurité particulière,
// sans avoir de système d'authentification.
// rate limiting ?
// éviter le spam ?
//
// Modèle de sécurité
// pas de compte + considère qu'il n'y aura pas de spam + mesure cotés client pour filtrer un potentiel spam
// mesure de trust on first use pour vérifier l'identité du prof

==== Configuration du client

Pour qu'un client puisse se connecter au serveur, un repository d'un cours PLX doit contenir un fichier `live.toml` avec les entrées suivantes.
// todo to figure
```toml
# This is the configuration used to connect to a live server
domain = "live.plx.rs"
port = 9120
group_id = "https://github.com/prg2/prg2.git"
```
Le port est optionnel, la valeur par défaut est utilisée, tout comme `group_id` 
==== Besoins
- Client: Démarrer et arrêter une session, seul le client qui a démarré doit pouvoir arrêter une session.
- Serveur: Envoyer l'information de fermeture de la session
- Serveur: Renvoyer des erreurs en cas de données invalides
- Client: Lister les sessions ouvertes pour une repository Git donné
- Client: Rejoindre une session en cours
- Client: En tant que client follower, configurer le mode du broadcast: sa fréquence (live, ou quelques secondes), le type de changement à recevoir (tout, seulement les checks) ou lancer une mise à jour maintenant
- Client: Lancer un exercice, pour qu'il puisse être affiché sur tous les clients de la session
- Client: Mettre en pause le streaming des changements du serveur vers le client // système d'activation et désactivation de l'abonnement ? meilleur wording ?

==== Gestion des clients face aux pannes ou redémarrages
Si un·e étudiant·e quitte PLX et le relance, on aimerait que le client PLX soit reconnu comme étant le même que précédemment, sans avoir de système d'authentification. Le but est d'éviter des incohérences dans l'interface, par exemple de voir le code d'un·e étudiant·e deux fois, parce que le client PLX a été redémarré entre deux et qu'il est considéré comme un tout nouveau client.

Afin de supporter différentes instabilités du réseau, tel que de pertes de Wifi ou des Wifi surchargés,  nous mettons en place quelques mécanismes permettant de reconnecter des clients. 

Nous ne supportons pas les pannes du serveur. Nous pourrions dans le futur imaginer un système où les clients leaders recréent la session si le serveur a été redémarré, mais cela ne sera pas nécessaire pour les premières versions de PLX.

keep alive, fermeture de connexion

==== Définition des clients
Un "client PLX" est défini comme la partie logicielle de PLX qui se connecte à un serveur PLX. Pour qu'un client puisse survivre à une perte temporaire de conn

==== Workflow d'usage des sessions live
Nous souhaitons définir un système flexible, qui peut être autant utilisés avec 40 étudiant·es et 1 enseignant·e, que 120 étudiant·es, 3 enseignant·es et 2 assistant·es, ou encore 3 étudiant·es coachés par un·e étudiant·e plus expérimenté·e durant des révisions. Au final, ce protocole ne distingue que 2 rôles: leader et follower. Le rôle leader est attribué au client qui crée une session, il permet de gérer l'avancement des exercices, de recevoir le code et les résultats ou encore d'arrêter la session. Le rôle de follower permet de rejoindre une session, envoyer du code et des résultats pour cette session. Un client follower ne recevra pas le code et les résultats d'autres clients followers. Il peut cependant y avoir plusieurs leaders sur une session.


==== Versions et rétrocompatibilité
Pour que le serveur et les clients connectés puissent savoir s'ils communiquent avec la même version ou une version compatible, il est nécessaire d'envoyer un numéro de version de ce protocole à la première connexion. Pour ce numéro de version on utilise le Semantic Versionning 2.0.0 @SemverWebsite. Durant le développement, le protocole reste en version `0.x.y` et ne sera stabilisé qu'une fois le protocole et son implémentation dans PLX auront été testés quelques temps en grandeur nature.

==== Evolutivité
Pour permettre d'évoluer le protocole au fil du temps, le numéro de version sera passée dans l'entête du "handshake" HTTP, sous le nom de `LiveProtocolVersion`, qui ne devrait pas avoir besoin de changer. Ce champ n'est évidemment pas standard mais IETF recommende depuis 2012 de ne pas ajouter le préfix `X-` @IetfNoXPrefixRfc.  Cela permettra de changer le format ou les types de messages, ou encore le format de sérialisation, tout en gardant ce numéro de version séparé et toujours accessible peu importe la version du serveur.

Le concept de session lancée par des clients leaders et de synchronisation de données provenant de clients followers vers des clients leaders, peut facilement être étendu à d'autres usages. Si on imagine d'autres types d'exercice que du code, des exercices de choix multiples par exemple, il suffirait d'ajouter une nouvelle action pour envoyer une réponse et un événement associer pour renvoyer cette réponse vers les clients leaders.

Si la première requête ne contient pas de numéro de version, la requête est ignorée et la connexion est fermée.

===== Performance
Des mesures basiques sont prises pour éviter un poids ou un nombre inutile de messages envoyés sur le réseau. Ces mesures ont pour but de limiter le nombre de messages que le serveur doit gérer lorsque plusieurs sessions avec de nombreux clients connectés. Nous ne faisons pas de benchmark pour le moment, pour se concentrer sur développer une implémentation correcte.

- N'envoyer un morceau de code uniquement s'il a été modifié depuis le dernier envoi
- N'envoyer que les fichiers modifiés par rapport au code de départ à la première synchronisation. Dans un exercice à 3 fichiers avec 1 fichier à changer, les 2 autres fichiers ne devraient pas être envoyés, puisque les clients followers peuvent avoir la version originale stockée dans le repository.
- N'envoyer un résultat que s'il est différent depuis le dernier envoi. Sauver 3 fois le même fichier sans modification, donnera le même résultat, qui ne peut être envoyé qu'une seule fois pour la première sauvegarde.
// - Bufferiser les envois en boucle: quand le serveur doit envoyer une longue suite de messages à un client, l'envoi se fait en bufferisant les messages pour éviter une partie d'appels systèmes

==== Diagrammes de séquences

#figure(
  image("diagrams/session.svg", width: 70%),
  caption: [Exemple de communication entre 2 clients et un serveur, pour gérer une session],
)

==== Messages


#include "messages/messages.typ"
