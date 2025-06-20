=== Protocole de sessions live

*Etat: en cours de rédaction*

Cette partie définit le protocole de communication entre les clients et un serveur PLX, pour toutes les interactions nécessaires à la gestion et participation à des sessions lives.

==== Définition des sessions live
Le protocole tourne autour du concept de session, qui peut être vu comme un endroit virtuel temporaire où plusieurs personnes s'entrainent sur les mêmes exercices. Une session est définie par un titre et un lien HTTPS d'un repository Git, cette combinaison est unique sur le serveur. Une personne démarre une session pour un repository qui contient des exercices pour PLX, en choisit une sélection et d'autres rejoignent pour faire ces exercices. La session vit jusqu'à que la personne qui l'a démarée décide de l'arrêter ou qu'un temps d'expiration côté serveur décide de l'arrêter après un certain temps d'inactivité. L'arrêt d'une session déconnecte tous les clients connectés.

==== Besoins
- Client: Démarrer et arrêter une session, seul le client qui a démarré doit pouvoir arrêter une session.
- Serveur: Envoyer l'information de fermeture de la session
- Serveur: Renvoyer des erreurs en cas de données invalides
- Client: Lister les sessions ouvertes pour une repository Git donné
- Client: Rejoindre une session en cours
- Client: En tant que client follower, configurer le mode du broadcast: sa fréquence (live, ou quelques secondes), le type de changement à recevoir (tout, seulement les checks) ou lancer une mise à jour maintenant
- Client: Lancer un exercice, pour qu'il puisse être affiché sur tous les clients de la session
- Client: Mettre en pause le streaming des changements du serveur vers le client // système d'activation et désactivation de l'abonnement ? meilleur wording ?

==== Tolérance aux instabilités du réseau
Afin de supporter différentes instabilités du réseau, tel que de pertes de Wifi ou des Wifi surchargés, qui 

==== Définition des clients
Un "client PLX" est défini comme la partie logicielle de PLX qui se connecte à un serveur PLX. Pour qu'un client puisse survivre à une perte temporaire de conn

==== Workflow d'usage des sessions live
Nous souhaitons définir un système flexible, qui peut être autant utilisés avec 40 étudiant·es et 1 enseignant·e, que 120 étudiant·es, 3 enseignant·es et 2 assistant·es, ou encore 3 étudiant·es coachés par un·e étudiant·e plus expérimenté·e durant des révisions. Au final, ce protocole ne distingue que 2 rôles: leader et follower. Le rôle leader est attribué au client qui crée une session, il permet de gérer l'avancement des exercices, de recevoir le code et les résultats ou encore d'arrêter la session. Le rôle de follower permet de rejoindre une session, envoyer du code et des résultats pour cette session. Un client follower ne recevra pas le code et les résultats d'autres clients followers. Il peut cependant y avoir plusieurs leaders sur une session.

==== Transport et sérialisation
Ce protocole se base sur le protocole Websocket *RFC 6455* @WSRFC qui est basé sur TCP. Il utilise le port *9120* par défaut, qui a été choisi parmi la liste des ports non assignés publiés par l'IANA @IANAPortsNumbers. Ce port doit être configurable s'il est nécessaire d'avoir plusieurs serveurs sur la même adresse IP ou s'il serait déjà pris par un autre logiciel. Les messages sont transmis sous forme de JSON sérialisé en chaine de caractères.

==== Versions et rétrocompatibilité
Pour que le serveur et les clients connectés puissent savoir s'ils communiquent avec la même version ou une version compatible, il est nécessaire d'envoyer un numéro de version de ce protocole à la première connexion. Pour ce numéro de version on utilise le Semantic Versionning 2.0.0 @SemverWebsite. Durant le développement, le protocole reste en version `0.x.y` et ne sera stabilisé qu'une fois le protocole et son implémentation dans PLX auront été testés quelques temps en grandeur nature.


===== Performance
Des mesures basiques sont prises pour éviter un poids ou un nombre inutile de messages envoyés sur le réseau. Ces mesures ont pour but de limiter le nombre de messages que le serveur doit gérer lorsque plusieurs sessions avec de nombreux clients connectés. Nous ne faisons pas de benchmark pour le moment, pour se concentrer sur développer une implémentation correcte.

- N'envoyer un morceau de code uniquement s'il a été modifié depuis le dernier envoi
- N'envoyer que les fichiers modifiés par rapport au code de départ à la première synchronisation. Dans un exercice à 3 fichiers avec 1 fichier à changer, les 2 autres fichiers ne devraient pas être envoyés, puisque les clients followers peuvent avoir la version originale stockée dans le repository.
- N'envoyer un résultat que s'il est différent depuis le dernier envoi. Sauver 3 fois le même fichier sans modification, donnera le même résultat, qui ne peut être envoyé qu'une seule fois pour la première sauvegarde.
// - Bufferiser les envois en boucle: quand le serveur doit envoyer une longue suite de messages à un client, l'envoi se fait en bufferisant les messages pour éviter une partie d'appels systèmes

==== Messages


#figure(raw(block: true, lang: "json", read("messages/session-create.json")), caption: [Message `SessionStart`])
