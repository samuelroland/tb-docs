#set page(margin: 3em, header: [Cahier des Charges])
#show link: underline
// TODO: font okay ?
#set text(font: "Cantarell", size: 12pt)

= Concevoir une expérience d'apprentissage interactive à la programmation avec PLX

== Contexte
Ce travail de Bachelor vise à poursuivre le projet PLX (voir #link("https://plx.rs", [plx.rs])), TUI écrite en Rust, commencé durant PDG, permettant de faciliter la pratique intense sur des exercices de programmation en retirant un maximum de friction. PLX vise également à apporter le plus vite possible un feedback automatique et riche, dans l'idée d'appliquer les principes de la pratique délibérée à l'informatique. PLX peut à terme aider de nombreux cours à la HEIG-VD (tels que PRG+ PRG2, PCO, SYE, ...) à transformer les longs moments de théorie en session d'entrainement dynamique, et redéfinir l'expérience des étudiants sur ces exercices ainsi que les laboratoires. L'ambition est qu'à terme cela génère un apprentissage plus profond de modèles mentaux solides, pour que les étudiants aient moins de difficultés avec ces cours.

== Problème

Inspiré de Rustlings (TUI pour apprendre le Rust), PLX fournit actuellement une expérience locale similaire pour le C et C++. Les étudiants clonent un repos Git et travaillent localement sur des exercices afin de faire passer des checks automatisés, à chaque sauvegarde le programme est compilé et les checks sont lancés. Cependant, faire passer les checks n'est que la 1ère étape, faire du code qualitatif, modulaire, lisible et performant demande des retours humains pour pouvoir progresser. De plus, les exercices existant étant stockés dans des PDF ou des fichiers Markdown, cela nécessite de les migrer à PLX.

== Défis

Ce TB aimerait pousser l'expérience en classe plus loin pour permettre aux étudiants de recevoir des feedbacks sur leur réponse en live, sur des sessions hautement interactives. Cela aide aussi les enseignants à mesurer l'état de compréhension et les compétences des étudiants tout au long du semestre, et adapter leur cours en fonction des incompréhensions et lacunes.

Pour faciliter l'adoption de ces outils et la rapidité de création/transcription d'exercices, on souhaiterait avoir une syntaxe épurée, humainement lisible + éditable, facilement versionnable dans Git: la syntaxe DY, inventée pour Delibay (exemple #link("https://delibay.org/docs/use/dy-syntax", [Delibay Docs - DY Syntax])). Cette syntaxe sera adaptée pour PLX, pour remplacer le format TOML actuel.

Ces 2 défis impliquent
+ Une partie serveur de PLX, gérant des connexions persistantes pour chaque étudiant et enseignant connecté, permettant de recevoir les réponses des étudiants et de les renvoyer à l'enseignant. Une partie client responsable d'envoyer le code modifié et les résultats après chaque lancement des checks.
// TODO: connexion persistantes ok ? au lieu de connexion websockets. aussi ailleurs dans le reste du document.
+ Le parseur existant de la syntaxe DY est écrit en TypeScript ce qui ne permet pas d'être simplement embarqué dans PLX. Le but est de réécrire le parseur en Rust en s'aidant d'outils adaptés (TreeSitter, Chumsky, Winnow, ...).

Le projet, les documents et les contributions de ce TB, seront publiés sous licence libre.

== Objectifs et livrables
+ Livrables standards: Rapport intermédiaire + rapport final + résumé + poster
+ Un serveur en Rust lancé via le CLI plx permettant de gérer des sessions live
+ Une librairie en Rust de parsing d'une variante de la syntaxe DY
+ Une intégration de cette librairie dans PLX

=== Objectifs fonctionnels
+ Il est possible de lancer une session live via PLX pour le repository actuel. Il peut exister plusieurs sessions en même temps pour le même repository.
+ Une fois une session lancée, il est possible de la rejoindre, ou de choisir parmi la liste des sessions liées à ce repository.
+ Un pseudo aléatoire est attribué à chaque personne connectée, pas besoin de créer de compte.
+ Une vue globale permet au créateur de la session d'avoir un aperçu général de l'état des checks sur tous les exercices. En sélectionnant un exercice, il est possible de voir, la dernière version du code édité ainsi que les résultats des checks pour ce code, pour chaque étudiant.
+ La syntaxe DY adaptée à PLX permet de décrire les informations d'un cours, des compétences et des exercices. Le parseur sera capable de détecter les erreurs.
+ L'intégration dans PLX permettant d'afficher les exercices extraits de fichiers .dy, pourra afficher les erreurs dans les fichiers .dy et retire l'usage de fichiers TOML par des humains (le stockage d'état peut rester en TOML).

=== Objectifs non fonctionnels
+ Une session live doit supporter des déconnexions temporaires, l'enseignant pourra continuer à voir la dernière version du code envoyé, et le client PLX essaiera automatiquement de se reconnecter. Le serveur doit pouvoir supporter plusieurs sessions live incluant au total 200 connexions persistantes simultanées.
+ Pour des raisons de sécurité, aucun code externe ne doit être exécuté par PLX.
+ Le temps entre la fin de l'exécution des checks et la visibilité des modifications par l'enseignant ne doit pas dépasser 3s.
+ Le code doit être le plus possible couvert par des tests automatisés, notamment par des tests end-to-end avec multiples clients PLX.
+ Le parseur DY doit être assez capable de parser 200 exercices en < 1s.
+ Retranscrire un exercice existant du Markdown en DY ne devrait pas prendre plus d'une minute.

=== Objectif nice to have
+ Syntax highlighting dans VSCode et Neovim
+ Implémenter un Language Server au-dessus du parseur pour intégrer les erreurs dans l'IDE

== Calendrier du projet
En se basant sur le calendrier des travaux de Bachelor, voici un aperçu du découpage du projet pour les différents rendus.

=== Rendu 1 - 10 avril 2025 - Cahier des charges
- Rédaction du cahier des charges
- Analyse de l'état de l'art des parsers, du syntax highlighting et des languages servers
- Analyse de l'état de l'art des protocoles bi-directionnel temps réel (websockets, gRPC, ...) et des formats de sérialisation (JSON, protobuf, ...)
- Prototype avec les librairies disponibles de parsing et de language servers en Rust, choix du niveau d'abstraction espéré et réutilisation possibles

=== Rendu 2 - 23 mai 2025 - Rapport intermédiaire
- Rédaction du rapport intermédiaire
- Définition formelle de la syntaxe DY à parser, les spécificités liés à PLX, et la liste des vérifications et erreurs à générer
- Prototype d'un serveur PLX pour envoyer du code à chaque sauvegarde et le recevoir en temps réel
- Prototype des tests automatisés sur le serveur PLX
- Définition du protocole entre les clients PLX et le serveur pour les entrainements live

=== Moitié des 6 semaines à temps plein - 4 juillet 2025
- Ecriture des tests de validation du protocole et de gestion des erreurs
- Développement du serveur PLX
- Rédaction du rapport final par rapport aux développements effectués

=== Rendu 3 - 24 juillet 2025 - Rapport final
- Développement d'une librairie `dy`
- Intégration de cette librairie à PLX
- Rédaction de l'affiche et du résumé publiable
- Rédaction du rapport final

