= Introduction <introduction>

== Contexte
Ce travail de Bachelor vise à développer le projet PLX (voir #link("https://plx.rs")[plx.rs], Terminal User Interface (TUI) écrite en Rust, permettant de faciliter la pratique intense sur des exercices de programmation en retirant un maximum de friction. PLX vise également à apporter le plus vite possible un feedback automatique et riche, dans l'idée d'appliquer les principes de la pratique délibérée à l'informatique. PLX peut à terme aider de nombreux cours à la HEIG-VD (tels que PRG1, PRG2, PCO, SYE, ...) à transformer les longs moments de théorie en session d'entrainement dynamique, et redéfinir l'expérience des étudiants sur ces exercices ainsi que les laboratoires. L'ambition est qu'à terme, cela génère un apprentissage plus profond de modèles mentaux solides, pour que les étudiants aient moins de difficultés avec ces cours.

== Problème

Le projet est inspiré de Rustlings (TUI pour apprendre le Rust), permettant de s'habituer aux erreurs du compilateur Rust et de prendre en main la syntaxe. PLX fournit actuellement une expérience locale similaire pour le C et C++. Les étudiants clonent un repos Git et travaillent localement sur des exercices afin de faire passer des checks automatisés. À chaque sauvegarde, le programme est compilé et les checks sont lancés. Cependant, faire passer les checks n'est que la 1ère étape. Faire du code qualitatif, modulaire, lisible et performant demande des retours humains pour pouvoir progresser. De plus, les exercices existants étant stockés dans des PDF ou des fichiers Markdown, cela nécessite de les migrer à PLX.

== Défis

Ce TB aimerait pousser l'expérience en classe plus loin pour permettre aux étudiants de recevoir des feedbacks sur leur réponse en live, sur des sessions hautement interactives. Cela aide aussi les enseignants à mesurer l'état de compréhension et les compétences des étudiants tout au long du semestre, et à adapter leur cours en fonction des incompréhensions et des lacunes.

Pour faciliter l'adoption de ces outils et la rapidité de création/transcription d'exercices, on souhaiterait avoir une syntaxe épurée, humainement lisible et éditable, facilement versionnable dans Git. Pour cette raison, nous introduisons une nouvelle syntaxe appelée DY. Elle sera adaptée pour PLX afin de remplacer le format TOML actuel.

#figure(raw(block: true, lang: "markdown", read("../schemas/plx-dy-all.md")), caption: [Exemple d'exercice de programmation, rédigé en Markdown, avec une implémentation du pipe dans un shell]) <exemple-dy-md-start>

Cet exerci

#figure(
  image("../schemas/plx-dy-all.svg", width:80%),
  caption: [Equivalent dans une version préliminaire de la syntaxe DY de l'exercice défini sur le @exemple-dy-md-start],
) <exemple-dy>

// Dans le @exemple-dy, on définit un exercice de programmation avec un petit programme qui doit dire bonjour à l'utilisateur, en lui demandant son prénom puis son nom. Elle contient 2 checks (vérifications automatiques) pour vérifier le comportement attendu. Le premier check décrit une situation de succès et le deuxième décrit une situation d'erreur.

Ce système de préfixe (en bleu du début des lignes) et de propriétés (après un point, définissant des propriétés supplémentaire) permet de structurer le contenu de l'exercice tout en gardant un style de rédaction proche du Markdown. L'exemple 


== Objectifs <objectifs>
TODO
Ces 2 défis impliquent :
1. Une partie serveur de PLX, gérant des connexions persistantes pour chaque étudiant et enseignant connecté, permettant de recevoir les réponses des étudiants et de les renvoyer à l'enseignant. Une partie client est responsable d'envoyer le code modifié et les résultats après chaque lancement des checks.
1. Le but est de définir une syntaxe et de réécrire le parseur en Rust en s'aidant d'outils adaptés (TreeSitter, Chumsky, Winnow, ...).

== Expérience imaginée

#lorem(10)

== Solutions existantes <solutions-existantes>
#lorem(110)

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

