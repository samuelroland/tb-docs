= Introduction <introduction>

== Contexte
Ce travail de Bachelor vise à développer le projet PLX (voir #link("https://plx.rs")[plx.rs], Terminal User Interface (TUI) écrite en Rust, permettant de faciliter la pratique intense sur des exercices de programmation. Les étudiants sont constamment ralentis par la friction de la création du fichier de départ, la gestion de la compilation, l'exécution de différents scénarios de vérifications du fonctionnement, taper les entrées utilisateur et la comparaison avec l'output attendu. Toutes ces étapes prennent du temps inutilement et empêchent les étudiants de se concentrer pleinement sur l'écriture du code et la revue des résultats des scénarios pour identifier les bugs et corriger au fur et à mesure.

PLX vise également à apporter le plus vite possible un feedback automatique et riche, dans le but d'appliquer les principes de la pratique délibérée à l'informatique. PLX peut à terme aider de nombreux cours à la HEIG-VD (tels que PRG1, PRG2, PCO, SYE, ...) à passer de long moments de théorie en session d'entrainement dynamique et très interactive. En réfinissant l'expérience des étudiants et des enseignants sur les exercices et laboratoires, l'ambition est qu'à terme, cela génère un apprentissage plus profond de modèles mentaux solides chez les étudiants. Cela aidera les étudiants qui ont beaucoup de peine à s'approprier la programmation à avoir moins de difficultés avec ces cours. Et ceux qui sont plus à l'aise pourront développer des compétences encore plus avancées.

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

#pagebreak()

== Défis

=== Comment les enseignants peuvent voir les résultats en temps réel ?
Ce TB aimerait pousser l'expérience en classe plus loin pour permettre aux étudiants de recevoir des feedbacks sur leur réponse en live, sur des sessions hautement interactives. Cela aide aussi les enseignants à mesurer l'état de compréhension et les compétences des étudiants tout au long du semestre, et à adapter leur cours en fonction des incompréhensions et des lacunes.

#figure(
  image("../schemas/live-sessions-flow.png", width:100%),
  caption: [Interactions entre les clients PLX entre l'enseignant et les étudiants, le code est synchronisé via un serveur central, le cours PRG2 a un repository Git publique],
) <live-sessions-flow>

Sur la @live-sessions-flow, on voit qu'avant de commencer, les étudiants ont du cloner le repository Git du cours sur leur machine pour accéder aux exercices. Une fois une session live démarrée par un enseignant et les étudiants ayant rejoint la session, l'enseignant peut choisir de faire un exercice l'un après l'autre en définissant son propre rythme.

L'exercice en cours est affiché sur tous les clients PLX. A chaque sauvegarde d'un fichier de code, le code est compilé et les checks sont lancés comme en dehors d'une session live. La différence est que les résultats des checks et le code modifié sera envoyé à l'enseignant de la session. L'enseignant pourra ainsi avoir un aperçu global de l'avancement et des checks qui ne passent pas, d'aller inspecter le code de certaines soumissions et au final de faire des feedbacks à la classe en live ou à la fin de l'exercice.

Cette première partie nécessite le développement d'un protocole de synchronisation des différents éléments et d'utiliser des protocoles de communication temps-réel pour rendre cette composante live/instantanée possible.

#pagebreak()

=== Comment faciliter la rédaction et la maintenance des exercices ?
La gestion des exercices dans un format textuel dans son IDE favori est largement plus productive qu'utiliser des interfaces web parfois lentes avec des dizaines de champs de formulaires. La possibilité de versionner ces fichiers textuels dans Git et facilement collaborer dans des pull requests est un avantage majeure que de nombreux enseignants apprécient. Une partie d'entre eux gèrent leur slides, exercices et évaluations, en utilisant le Markdown, Latex, Typst ou encore AsciiDoc.

Le défi maintenant est de permettre de rédiger des exercices de programmation en format textuel, tout en y incluant une partie d'interactivité et d'automatisation d'un outil comme PLX à côté de l'éditeur de code.

// todo okay de mettre des infos d'opinions ?? je peux pas vraiment citer je crois. -> selon les recherches de l'auteur.

Prenons un exemple concret d'exercice de programmation, pour entrainer la gestion d'entrées/sorties dans le terminal d'un petit CLI.

#figure(raw(block: true, lang: "markdown", read("../schemas/plx-dy-simple.md")), caption: [Exemple d'exercice de programmation, rédigé en Markdown]) <exemple-dy-md-start>

Cet exercice en @exemple-dy-md-start est adapté à l'affichage et l'export PDF pour être distribué dans un recueil d'exercices. Si un outil tel que PLX voulait automatiser l'exécution du code et des étapes manuelles de rentrer prénom et nom et de vérifier l'output, il n'est pas vraiment possible de parser de manière non ambigüe. En effet, comment savoir exactement sans comprendre le langage naturel que `John` et `Doe` doivent être rentrés à la main et ne font pas partie de l'output ? Comment détecter qu'on parle du code d'exit du programme et qu'il doit valoir zéro.

Nous avons besoin de définir de manière structurée ces assertions et ce qu'il faut entrer comme texte à quel moment. On pourrait imaginer utiliser du JSON pour y stocker le titre, et la consigne. On pourrait inventer ensuite une liste de checks avec un titre et une séquence d'opérations à effectuer pour ce check. Chaque opération serait de type `see` (ce qu'on s'attend à "voir" dans l'output), `type` (ce qu'on tappe dans le terminal) et finalement `exit` pour définir le code d'exit attendu.

#pagebreak()
Cette définition JSON pourrait ressembler à celle présentée sur le @exemple-dy-json

#figure(raw(block: true, lang: "json", read("../schemas/plx-dy-simple.json")), caption: [Equivalent JSON de l'exercice défini sur le @exemple-dy-md-start]) <exemple-dy-json>

Cet exemple d'exercice est minimale mais le @exemple-dy-json montre bien que rédiger dans ce format serait fastidieux. Si on avait eu besoin de rédiger du Markdown dans la consigne sur plusieurs lignes on aurait eu besoin de remplacer les retours à la ligne par des `\n` à la main. Ces transformations à la main complique la lisibilité, en plus de tous les guillements, deux points et accolades nécessaires au-delà du texte brut qui demande un effort de rédaction important.

Si on oublie un instant d'autres formats moins verbeux que le JSON (tel que le YAML) et qu'on inventait de zéro une toute nouvelle syntaxe qui reprend les idées de `see`, `type`, et `exit`. Une syntaxe qui permettrait de rédiger ce même exercice de manière concise, compacte et avec très peu de caractères additionnel au contenu brut, tout en gardant une structure qui peut être parsée, voici en @exemple-dy à quoi cela pourrait ressembler.

#figure(
  image("../schemas/plx-dy-simple.svg", width:100%),
  caption: [Equivalent dans une version préliminaire de la syntaxe DY de l'exercice défini sur le @exemple-dy-md-start],
) <exemple-dy>

// Dans le @exemple-dy, on définit un exercice de programmation avec un petit programme qui doit dire bonjour à l'utilisateur, en lui demandant son prénom puis son nom. Elle contient 2 checks (vérifications automatiques) pour vérifier le comportement attendu. Le premier check décrit une situation de succès et le deuxième décrit une situation d'erreur.

On retrouve dans @exemple-dy les mêmes informations que définie précédemment, délimitée par un système de préfixe (en bleu du début des lignes) qui permet de structurer le contenu de l'exercice.

// todo les variantes de DY ??

Ce 2ème défi demande ainsi d'écrire un parseur de cette nouvelle syntaxe. Une nouvelle syntaxe sans support dans les IDE modernes est peu agréable à utiliser. Lire du texte structuré blanc sur fond noir sans aucune couleur, sans feedback sur la validité du contenu, mène à une expérience un peu froide. Une fois le parseur fonctionnel, le support de certains IDEs pourra être implémenté.

Voici un aperçu de l'expérience imaginée des enseignants pour la rédaction des exercices dans cette syntaxe en @ide-xp.

#figure(
  image("../schemas/ide-experience-mental-model-simple.png", width:100%),
  caption: [Aperçu de l'expérience de rédaction imaginée dans un IDE],
) <ide-xp>

On voit dans la @ide-xp que l'intégration se fait sur 2 points majeures
- le surlignage de code, qui permet de coloriser les préfixes et les propriétés, afin de bien distinguer le contenu des éléments propres à la syntaxe
- intégration avancée de la connaissance et des erreurs du parseur à l'éditeur: comme en ligne 4 avec l'erreur du nom de check manquant après le préfixe `check`, et comme en ligne 19 avec une auto-complétion qui propose les préfixes valides à cette position du curseur.

Cette nouvelle syntaxe, son parseur et support d'IDE permettront de remplacer le format TOML actuellement utilisé dans PLX.

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

