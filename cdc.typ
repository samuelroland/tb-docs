= Concevoir une expérience d'apprentissage interactive à la programmation avec PLX

== Contexte
Ce travail de Bachelor vise à poursuivre le projet PLX (voir plx.rs), TUI écrite en Rust, commencé durant PDG, permettant de faciliter la pratique intense sur des exercices de programmation en retirant un maximum de friction. PLX vise également à apporter le plus vite possible un feedback automatique et riche, dans l'idée d'appliquer les principes de la pratique délibérée à l'informatique. PLX peut à terme aider de nombreux cours à la HEIG-VD (tels que PRG1, PRG2, PCO, SYE, ...) à transformer les longs moments de théorie en session d'entrainement dynamique, et redéfinir l'expérience des étudiants sur ces exercices ainsi que les laboratoires. L'ambition est qu'à terme cela génère un apprentissage plus profond de modèles mentaux solides, pour que les étudiants aient moins de difficultés avec ces cours.

== Problème

Inspiré de Rustlings (TUI pour apprendre le Rust), PLX fournit actuellement une expérience locale similaire pour le C et C++. Les étudiants clonent un repos Git et travaillent localement sur des exercices afin de faire passer des checks automatisés, à chaque sauvegarde le programme est compilé et les checks sont lancés. Cependant, faire passer les checks n'est que la 1ère étape, faire du code qualitatif, modulaire, lisible et performant demande des retours humains pour pouvoir progresser. De plus, les exercices existant étant stockés dans des PDF ou des fichiers Markdown, cela nécessite de les migrer à PLX.

== Défis

Ce TB aimerait pousser l'expérience en classe plus loin pour permettre aux étudiants de recevoir des feedbacks sur leur réponse en live, sur des sessions hautement interactives. Cela aide aussi les enseignants mesurer l'état de compréhension et les compétences des étudiants tout au long du semestre, et adapter leur cours en fonction des incompréhensions et lacunes.

Pour faciliter l'adoption de ces outils et la rapidité de création/transcription d'exercices, on souhaiterait avoir une syntaxe épurée, humainement lisible + éditable, facilement versionnable dans Git: la syntaxe DY, inventée pour Delibay (exemple ici https://delibay.org/docs/use/dy-syntax). Cette syntaxe sera adaptée pour PLX, pour remplacer le format TOML actuel.

Ces 2 défis impliquent
1. Une partie serveur de PLX, gérant des connexions websockets pour chaque étudiant et enseignant connecté, permettant de recevoir les réponses des étudiants et de les renvoyer à l'enseignant. Une partie client responsable d'envoyer le code modifié et les résultats après chaque lancement des checks.
1. Le parseur de la syntaxe DY est écrit en TypeScript ce qui ne permet pas d'être simplement embarqué dans PLX. Le but est de réécrire le parseur en Rust s'aidant d'outils adaptés (TreeSitter, Chumsky, autre).

Le projet, les documents et les contributions de ce TB, seront publiés sous licence libre.

== Objectifs et livrables
1. Livrables standards: Rapport intermédiaire + rapport final + résumé + poster
1. Un serveur websockets en Rust lancé via le CLI plx permettant de gérer des sessions live
1. Une librairie en Rust de parsing d'une variante de la syntaxe DY
1. Une intégration de cette librairie dans PLX

=== Objectifs fonctionnels
1. Il est possible de lancer une session live via PLX pour le repository actuel. Il peut exister plusieurs sessions en même temps pour le même repository.
1. Une fois une session lancée, il est possible de la rejoindre, ou de choisir parmi la liste des sessions liées à ce repository.
1. Un pseudo aléatoire est attribué à chaque personne connectée, pas besoin de créer de compte.
1. Une vue globale permet au créateur de la session d'avoir un aperçu général de l'état des checks sur tous les exercices. En sélectionnant un exercice, il est possible de voir, la dernière version du code édité ainsi que les résultats des checks pour ce code, pour chaque étudiant.
1. La syntaxe DY adaptée à PLX permet de décrire les informations d'un cours, des compétences et des exercices. Le parseur sera capable de détecter les erreurs.
1. L'intégration dans PLX permettant d'afficher les exercices extraits de fichiers .dy et retire l'usage de fichiers TOML.

=== Objectifs non fonctionnels
1. Une session live doit supporter des déconnexions temporaires, l'enseignant pourra continuer à voir la dernière version du code envoyé, et le client PLX essaiera automatiquement de se reconnecter. Le serveur doit pouvoir supporter plusieurs sessions live incluant au total 200 connexions websockets simultanées.
1. Pour des raisons de sécurité, aucun code externe ne doit être exécuté par PLX.
1. Le temps entre la fin de l'exécution des checks et la visibilité des modifications par l'enseignant ne doit pas dépasser 3s.
1. Le code doit être le plus possible couvert par des tests automatisés, notamment par des tests end-to-end avec multiples clients PLX.
1. Le parseur DY doit être assez capable de parser 200 exercices en < 1s.
1. Retranscrire un exercice existant du Markdown en DY ne devrait pas prendre plus d'une minute.

=== Objectif nice to have
1. Syntax highlighting dans VSCode et Neovim
1. Implémenter un Language Server au-dessus du parseur pour intégrer les erreurs dans l'IDE

