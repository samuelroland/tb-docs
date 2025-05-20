= Introduction <introduction>

== Contexte
Ce travail de Bachelor vise à développer le projet PLX (voir #link("https://plx.rs")[plx.rs], Terminal User Interface (TUI) écrite en Rust, permettant de faciliter la pratique intense sur des exercices de programmation en retirant un maximum de friction. PLX vise également à apporter le plus vite possible un feedback automatique et riche, dans le but d'appliquer les principes de la pratique délibérée à l'informatique. PLX peut à terme aider de nombreux cours à la HEIG-VD (tels que PRG1, PRG2, PCO, SYE, ...) à passer de long moments de théorie en session d'entrainement dynamique et très interactive. En réfinissant l'expérience des étudiants et des enseignants sur les exercices et laboratoires, l'ambition est qu'à terme, cela génère un apprentissage plus profond de modèles mentaux solides chez les étudiants. Cela aidera les étudiants qui ont beaucoup de peine à s'approprier la programmation à avoir moins de difficultés avec ces cours. Et ceux qui sont plus à l'aise pourront développer des compétences encore plus avancées.

// todo mentionner la pratique délibérée et le bouquin Peak
// todo yatil des études scientifiques dans l'état de l'art à mentionner ? peut-être qui soutient les défaut du YAML ou d'autres formats ?

== Problème

Le projet est inspiré de Rustlings (TUI pour apprendre le Rust), permettant de s'habituer aux erreurs du compilateur Rust et de prendre en main la syntaxe @RustlingsWebsite. PLX fournit actuellement une expérience locale similaire pour le C et C++. Les étudiants clonent un repos Git et travaillent localement sur des exercices afin de faire passer des checks automatisés. À chaque sauvegarde, le programme est compilé et les checks sont lancés. Cependant, faire passer les checks n'est que la 1ère étape. Faire du code qualitatif, modulaire, lisible et performant demande des retours humains pour pouvoir progresser. De plus, les exercices existants étant stockés dans des PDF ou des fichiers Markdown, cela nécessite de les migrer à PLX.

#figure(
  image("../imgs/plx-preview-home.png", width: 80%),
  caption: [Aperçu de la page d'accueil de PLX dans le terminal @PlxDocsStatus],
) <fig-plx-preview-home>

#figure(
  image("../imgs/plx-preview-checks.png", width: 100%),
  caption: [Aperçu d'un exercice dans PLX, avec un check qui échoue et les 2 suivants qui passent @PlxDocsStatus],
) <fig-plx-preview-checks>

== Défis

=== Comment les enseignants peuvent voir les résultats en temps réel ?
Ce TB aimerait pousser l'expérience en classe plus loin pour permettre aux étudiants de recevoir des feedbacks sur leur réponse en live, sur des sessions hautement interactives. Cela aide aussi les enseignants à mesurer l'état de compréhension et les compétences des étudiants tout au long du semestre, et à adapter leur cours en fonction des incompréhensions et des lacunes.

#figure(
  image("../schemas/high-level-arch.opti.svg", width:100%),
  caption: [Architecture haut niveau décrivant les interactions entre les clients PLX et le serveur de session live],
) <high-level-arch>

Une fois une session live démarrée par un enseignant et les étudiants ayant rejoint la session, l'enseignant peut choisir de faire un exercice l'un après l'autre en définissant son propre rythme. L'exercice en cours est affichés sur tous les clients PLX. A chaque sauvegarde d'un fichier de code, le code est compilé et les checks sont lancés comme en dehors d'une session live. La différence est que les résultats des checks et le code modifié sera envoyé à l'enseignant de la session, pour qu'il puisse directement dans PLX. L'enseignant pourra ainsi avoir un aperçu global de l'avancement et des checks qui ne passent pas, d'aller inspecter le code de certaines soumissions et au final de faire des feedbacks à la classe en live ou à la fin de l'exercice.

=== Comment faciliter la rédaction et la maintenance des exercices ?
Pour faciliter la productivité dans la rédaction et maintenance d'exercices ainsi que leur première transcription, on souhaiterait avoir une syntaxe épurée, humainement lisible et éditable, facilement versionnable dans Git. Pour cette raison, nous introduisons une nouvelle syntaxe appelée DY. Elle sera adaptée pour PLX afin de remplacer le format TOML actuel.

Voyons maintenant un exemple concret d'exercice de programmation, très inspiré d'un laboratoire du cours Système d'exploitation (SYE) à la HEIG-VD.

#figure(raw(block: true, lang: "markdown", read("../schemas/plx-dy-all.md")), caption: [Exemple d'exercice de programmation, rédigé en Markdown, avec une implémentation du pipe dans un shell]) <exemple-dy-md-start>

Cet exercice en @exemple-dy-md-start est adapté à l'affichage et l'export PDF pour être distribué dans un recueil d'exercices ou dans une consigne de laboratoire. Cependant, ce format n'est pas adapté à être parsé par un outil qui aimerait automatiser la vérification du code. En effet, les 2 exemples de commandes à lancer ne pourront être que lancées à la main par l'étudiant, ce qui crée de la friction autour de l'exercice et ralentit l'étudiant dans son apprentissage.

Nous avons besoin d'une syntaxe qui permet de décrire le démarrage du shell, ce que l'étudiant tape à la main dans son terminal, la vérification des outputs à différement endroits et finalement la terminaison du shell.

L'option la plus rapide et facile à ce problème serait de rédiger en format JSON.

#figure(raw(block: true, lang: "json", read("../schemas/plx-dy-all.json")), caption: [Equivalent JSON de l'exercice défini sur le @exemple-dy-md-start]) <exemple-dy-json>

Dans cet équivalent JSON, on voit bien que rédiger du contenu Markdown ou l'output sur plusieurs lignes en remplaçant les retours à la ligne `\n` à la main est fastidieux et complique la lisibilité, en plus de tous les guillements, deux points et accolades nécessaires au-delà du texte.

Voyons maintenant à quoi pourrait ressembler cette nouvelle syntaxe DY beaucoup plus légère pour l'exercice précédent:

#figure(
  image("../schemas/plx-dy-all.svg", width:80%),
  caption: [Equivalent dans une version préliminaire de la syntaxe DY de l'exercice défini sur le @exemple-dy-md-start],
) <exemple-dy>

// Dans le @exemple-dy, on définit un exercice de programmation avec un petit programme qui doit dire bonjour à l'utilisateur, en lui demandant son prénom puis son nom. Elle contient 2 checks (vérifications automatiques) pour vérifier le comportement attendu. Le premier check décrit une situation de succès et le deuxième décrit une situation d'erreur.

Ce système de préfixe (en bleu du début des lignes) et de propriétés (après un point) permet de structurer le contenu de l'exercice tout en gardant un style de rédaction proche du Markdown.

// todo les variantes de DY ??

Le préfixe `exo` introduit un exercice, avec un titre sur la même ligne et le reste de la consigne en Markdown sur les lignes suivantes. `check` introduit le début d'un check avec un titre, en Markdown également. `run` donne la commande de démarrage du programme. Le préfixe `skip` avec la propriété `.until` permet de cacher toutes les lignes d'output jusqu'à voir la ligne donnée. `see` demande à voir une ou plusieurs ligne en sortie standard. `type` simule une entrée au clavier et finalement `kill` indique comment arrêter le programme, ici en envoyant le `.signal` `9` sur le processus `qemu-system-arm` (qui a été lancé par notre script `./st`).

 Les fins de ligne définissent la fin du contenu pour les préfixes sur une seul ligne. Le préfixe `exo` supporte plusieurs ligne, son contenu se termine ainsi dès qu'un autre préfixe valide est détecté (ici `check`). La hiéarchie est implicite dans la sémantique, un exercice contient un ou plusieurs checks, sans qu'il y ait besoin d'indentation ou d'accolades pour indiquer les relations de parents et enfants. De même, un check contient une séquence d'action à effectuer (`run`, `see`, `type` et `kill`), ces préfixes n'ont de sens qu'à l'intérieur la définition d'un check (que après une ligne préfixée par `check`).

Cette deuxième partie demande ainsi d'écrire un parseur de cette nouvelle syntaxe et un support des différents IDE. Voici un aperçu de l'expérience imaginée des enseigants pour la rédaction des exercices dans cette syntaxe.

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

// todo move that somewhere useful
== Glossaire
- `Cargo.toml`, fichier dans un projet Rust définit les dépendances (les crates) et leur versions minimum à inclure dans le projet, équivalent du `package.json` de NPM
- `crate`: la plus petite unité de compilation avec cargo, concrètement chaque projet contient un ou plusieurs dossiers avec un `Cargo.toml`
- `crates.io`: le registre officiel des crates publiée pour l'écosystème Rust, l'équivalent de `npmjs.com` pour l'écosystème Javascript, ou `mvnrepository.com` pour Java
// todo check ces définitions

#pagebreak()

