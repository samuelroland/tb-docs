= Introduction <introduction>

== Contexte
Ce travail de Bachelor vise à développer le projet PLX (voir #link("https://plx.rs")[plx.rs], Terminal User Interface (TUI) écrite en Rust, permettant de faciliter la pratique intense sur des exercices de programmation en retirant un maximum de friction. PLX vise également à apporter le plus vite possible un feedback automatique et riche, dans le but d'appliquer les principes de la pratique délibérée à l'informatique. PLX peut à terme aider de nombreux cours à la HEIG-VD (tels que PRG1, PRG2, PCO, SYE, ...) à passer de long moments de théorie en session d'entrainement dynamique et très interactive. En réfinissant l'expérience des étudiants et des enseignants sur les exercices et laboratoires, l'ambition est qu'à terme, cela génère un apprentissage plus profond de modèles mentaux solides chez les étudiants. Cela aidera les étudiants qui ont beaucoup de peine à s'approprier la programmation à avoir moins de difficultés avec ces cours. Et ceux qui sont plus à l'aise pourront développer des compétences encore plus avancées.

== Problème

Le projet est inspiré de Rustlings (TUI pour apprendre le Rust), permettant de s'habituer aux erreurs du compilateur Rust et de prendre en main la syntaxe @RustlingsWebsite. PLX fournit actuellement une expérience locale similaire pour le C et C++. Les étudiants clonent un repos Git et travaillent localement sur des exercices afin de faire passer des checks automatisés. À chaque sauvegarde, le programme est compilé et les checks sont lancés. Cependant, faire passer les checks n'est que la 1ère étape. Faire du code qualitatif, modulaire, lisible et performant demande des retours humains pour pouvoir progresser. De plus, les exercices existants étant stockés dans des PDF ou des fichiers Markdown, cela nécessite de les migrer à PLX.

#figure(
  image("../imgs/plx-preview-home.png", width: 100%),
  caption: [Aperçu de la page d'accueil de PLX dans le terminal @PlxDocsStatus],
) <fig-plx-preview-home>

#figure(
  image("../imgs/plx-preview-checks.png", width: 100%),
  caption: [Aperçu d'un exercice dans PLX, avec un check qui échoue et les 2 suivants qui passent @PlxDocsStatus],
) <fig-plx-preview-checks>

== Défis

Ce TB aimerait pousser l'expérience en classe plus loin pour permettre aux étudiants de recevoir des feedbacks sur leur réponse en live, sur des sessions hautement interactives. Cela aide aussi les enseignants à mesurer l'état de compréhension et les compétences des étudiants tout au long du semestre, et à adapter leur cours en fonction des incompréhensions et des lacunes.

Pour faciliter l'adoption de ces outils et la rapidité de création/transcription d'exercices, on souhaiterait avoir une syntaxe épurée, humainement lisible et éditable, facilement versionnable dans Git. Pour cette raison, nous introduisons une nouvelle syntaxe appelée DY. Elle sera adaptée pour PLX afin de remplacer le format TOML actuel.

Voyons maintenant un exemple concret d'exercice de programmation, très inspiré d'un laboratoire du cours Système d'exploitation (SYE) à la HEIG-VD.

#figure(raw(block: true, lang: "markdown", read("../schemas/plx-dy-all.md")), caption: [Exemple d'exercice de programmation, rédigé en Markdown, avec une implémentation du pipe dans un shell]) <exemple-dy-md-start>

Cet exercice en @exemple-dy-md-start est adapté à l'affichage et l'export PDF pour être distribué dans un recueil d'exercices ou dans une consigne de laboratoire. Cependant, ce format n'est pas adapté à être parsé par un outil qui aimerait automatiser la vérification du code. En effet, les 2 exemples de commandes à lancer ne pourront être que lancées à la main par l'étudiant, ce qui crée de la friction autour de l'exercice et ralentit l'étudiant dans son apprentissage.

Nous avons besoin d'une syntaxe qui permet de décrire le démarrage du shell, ce que l'étudiant tape à la main dans son terminal, la vérification des outputs à différement endroits et finalement la terminaison du shell.

Voyons maintenant à quoi pourrait ressembler cette syntaxe pour décrire le même exercice de manière structurée.

#figure(
  image("../schemas/plx-dy-all.svg", width:80%),
  caption: [Equivalent dans une version préliminaire de la syntaxe DY de l'exercice défini sur le @exemple-dy-md-start],
) <exemple-dy>

// Dans le @exemple-dy, on définit un exercice de programmation avec un petit programme qui doit dire bonjour à l'utilisateur, en lui demandant son prénom puis son nom. Elle contient 2 checks (vérifications automatiques) pour vérifier le comportement attendu. Le premier check décrit une situation de succès et le deuxième décrit une situation d'erreur.

Ce système de préfixe (en bleu du début des lignes) et de propriétés (après un point, définissant des propriétés supplémentaire) permet de structurer le contenu de l'exercice tout en gardant un style de rédaction proche du Markdown. 

Le préfixe `exo` introduit un exercice, avec un titre sur la même ligne et le reste de la consigne en Markdown sur les lignes suivantes. `check` introduit le début d'un check avec un titre, en Markdown également. `run` donne la commande de démarrage du programme. Le préfixe `skip` avec la propriété `.until` permet de cacher toutes les lignes d'output jusqu'à voir la ligne donnée. `see` demande à voir une ou plusieurs ligne en sortie standard. `type` simule une entrée au clavier et finalement `kill` indique comment arrêter le programme, ici en envoyant le `.signal` `9` sur le processus `qemu-system-arm` (qui a été lancé par notre script `./st`).

Cette deuxième partie demande ainsi d'écrire un parseur de cette nouvelle syntaxe et un support des différents IDE.

Voici un aperçu de l'expérience imaginée durant la rédaction de cette syntaxe.

#figure(
  image("../schemas/ide-experience-mental-model.png", width:100%),
  caption: [Aperçu de l'expérience imaginée dans un IDE],
) <ide-xp>

On voit dans la @ide-xp que l'intégration se fait sur 2 points majeures
- le surlignage de code, qui permet de coloriser les préfixes et les propriétés, afin de bien distinguer le contenu des éléments propres à la syntaxe
- intégration avancée de la connaissance et des erreurs du parseur à l'éditeur: comme en ligne 4 avec l'erreur de la commande manquante après le préfixe `run`, et comme en ligne 19 avec une auto-complétion qui propose les préfixes valides à cette position du curseur.

// == Objectifs <objectifs>
// TODO
// Ces 2 défis impliquent :
// 1. Une partie serveur de PLX, gérant des connexions persistantes pour chaque étudiant et enseignant connecté, permettant de recevoir les réponses des étudiants et de les renvoyer à l'enseignant. Une partie client est responsable d'envoyer le code modifié et les résultats après chaque lancement des checks.

== Solutions existantes <solutions-existantes>

Comme mentionné dans l'introduction, PLX est inspiré de Rustlings. Cette TUI propose une centaine d'exercices avec des morceaux de code à faire compiler ou avec des tests à faire passer. L'idée est de faire ces exercices en parallèle de la lecture du "Rust book" (la documentation officielle).
#figure(
  image("../imgs/rustlings-demo.png", width: 80%),
  caption: [Un exemple de Rustlings en haut dans le terminal et VSCode en bas, sur un exercice de fonctions],
) <fig-rustlings-demo>

De nombreux autres projets se sont inspirées de ce concept, `clings` pour le C @ClingsGithub, `golings` pour le Go @GolingsGithub, `ziglings` pour Zig @CodebergZiglings et même `haskellings` pour le Haskell @HaskellingsGithub ! Ces projets consistuent d'une suite d'exercice et d'une TUI pour les exécuter pas à pas, afficher les erreurs de compilation ou les cas de tests qui échouent, pour faciliter la prise en main aux débutants.

Chaque projet se concentre sur un language et créer des exercices dédiés. PLX prend un approche différente, il n'y a pas d'exercice proposés parce que PLX supporte de multiple langages. Le contenu sera géré indépendamment de l'outil, permettant aux enseignants en école d'intégrer leur propre contenu et compétences enseignées.

// todo solution existantes de review en live de code

== Déroulement <déroulement>
Le travail commence le 17 février 2025 et se termine le 24 juillet 2025. Sur les 16 premières semaines, soit du 17 février 2025 au 15 juin 2025, la charge de travail représente 12h par semaine. Les 6 dernières semaines, soit du 16 juin 2025 au 24 juillet 2024, ce travail sera réalisé à plein temps.

Un rendu intermédiaire noté est demandé le 23 mai 2025 avant 17h et le rendu final est prévu pour le 24 juillet 2025 avant 17h.

La défense sera organisée entre le 25 août 2025 et le 12 septembre 2025.

// todo move that somewhere useful
== Glossaire
- `Cargo.toml`, fichier dans un projet Rust définit les dépendances (les crates) et leur versions minimum à inclure dans le projet, équivalent du `package.json` de NPM
- `crate`: la plus petite unité de compilation avec cargo, concrètement chaque projet contient un ou plusieurs dossiers avec un `Cargo.toml`
- `crates.io`: le registre officiel des crates publiée pour l'écosystème Rust, l'équivalent de `npmjs.com` pour l'écosystème Javascript, ou `mvnrepository.com` pour Java
// todo check ces définitions

#pagebreak()

