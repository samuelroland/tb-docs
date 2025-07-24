= Planification <planification>

== Déroulement <déroulement>
Le travail commence le 17 février 2025 et se termine le 24 juillet 2025. Sur les 16 premières semaines, soit du 17 février 2025 au 15 juin 2025, la charge de travail représente 12h par semaine. Les 6 dernières semaines, soit du 16 juin 2025 au 24 juillet 2024, ce travail sera réalisé à plein temps.

Un rendu intermédiaire noté est demandé le 23 mai 2025 avant 17h et le rendu final est prévu pour le 24 juillet 2025 avant 17h.

La défense sera organisée entre le 25 août 2025 et le 12 septembre 2025.

== Planification initiale <planification-initiale>
_Note: cette planification est reprise du cahier des charges original en annexe, avec quelques corrections mineures._

En se basant sur le calendrier des travaux de Bachelor, voici un aperçu du découpage du projet pour les différents rendus.

==== Rendu 1 - 10 avril 2025 - Cahier des charges
- Rédaction du cahier des charges.
- Analyse de l'état de l'art des parseurs, des formats existants de données humainement éditables, du surlignage de code et des serveurs de langages.
- Analyse de l'état de l'art des protocoles bidirectionnels temps réel (WebSocket, gRPC...) et des formats de sérialisation (JSON, Protobuf, ...).
- Prototype avec les librairies disponibles de parsing et de serveurs de langages en Rust, choix du niveau d'abstraction espéré et réutilisation possible.

==== Rendu 2 - 23 mai 2025 - Rapport intermédiaire
- Rédaction du rapport intermédiaire.
- Définition de la syntaxe DY à parser, des clés liées à PLX, la liste des vérifications et des erreurs associées.
- Définition d'un protocole de synchronisation du code entre les participants d'une session.
- Prototype d'implémentation de cette synchronisation.
- Prototype des tests automatisés sur le serveur PLX.
- Définition du protocole entre les clients PLX et le serveur pour les entrainements live.

==== Moitié des 6 semaines à temps plein - 4 juillet 2025
- Écriture des tests de validation du protocole et de gestion des erreurs.
- Développement du serveur PLX.
- Rédaction du rapport final par rapport aux développements effectués.

==== Rendu 3 - 24 juillet 2025 - Rapport final
- Développement d'une librairie `dy`.
- Intégration de cette librairie à PLX.
- Rédaction de l'affiche et du résumé publiable.
- Rédaction du rapport final.

== Planification finale
La rédaction du rapport de l'état de l'art a pris beaucoup de temps au début du projet, en plus de la finition du cahier des charges, pour bien creuser les cinq sujets concernés par ce travail. Le nombre important de technologies à investiguer, en parallèle du développement des POCs, a retardé la spécification du protocole de communication et de la syntaxe DY.

De manière générale, la rédaction du rapport a pris important dans ce travail. Pour apprendre petit à petit à mieux contextualiser, à expliquer d'abord les problèmes puis les solutions, il a fallu passer par de multiples relectures et éditions, demander des retours à d'autres personnes et intégrer ces retours.

L'écriture des tests de validation du protocole, qui était prévue avant de commencer le serveur, s'est finalement intégrée au développement du serveur. Cela avait plus du sens d'écrire les tests au fur et à mesure que les nouveaux messages du protocole étaient définis pour s'adapter aux nombreux ajustements des structures de données et de l'architecture.

Après la préparation du développement du serveur qui a permis de spécifier le protocole et le comportement attendu du client et du serveur, le développement a été plus rapide que prévu. Nous pensions passer deux semaines de développement et une semaine pour les tests et de rapport. Au final, l'historique Git nous montre que c'est plutôt en une semaine, entre le 24 juin et le 30 juin, que la majorité du serveur a pu être mise en place. Cela n'a pas permis de prendre de l'avance sur le programme, car l'intégration dans l'application desktop de PLX n'a pas été évidente.

Heureusement, la deuxième partie de développement autour de notre syntaxe DY a été également plus courte que prévu. Entre le 13 et 18 juillet, le développement du parseur de son intégration dans PLX desktop et dans un CLI ont pu être menés à bien.

Malgré ces décalages, nous avons réussi à développer et documenter tous les éléments planifiés.

Ce que l'on peut retenir comme apprentissage de cette planification, c'est que le développement, lorsqu'il est bien préparé en amont, peut aller plus vite que prévu. Au contraire, le temps de rédaction et raffinage du rapport est souvent le double ou le triple du temps estimé au départ.

Le fait de fixer des dates de relectures externes avec des collègues ou de proposer de montrer notre application à une personne qui pourrait être intéressé de l'utiliser est un vrai moteur pour avancer plus rapidement et se concentrer sur les parties les plus importantes.
