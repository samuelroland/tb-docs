#import "@preview/typslides:1.2.3": * // https://github.com/manjavacas/typslides

// Project configuration
#show: typslides.with(
  ratio: "16-9",
  theme: "yelly",
)

  // Display inline code in a small box with light gray backround that retains the correct baseline.
#show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
)

// Display block code in a larger block with more padding
// include a rounded border around it
// Add `fill` attribute to define background color
#show raw.where(block: true): block.with(
    inset: 10pt,
    radius: 2pt,
    stroke: 1pt + luma(200)
)

#set text(font: "Cantarell")
#let figure = figure.with(
  kind: "image",
  supplement: none,
) // disable prefix in captions

#blank-slide[
  #align(center, [
  #text(weight: "bold", size: 1.5em, fill: black)[Concevoir une expérience d'apprentissage interactive à la programmation avec PLX]
  #image("./report/imgs/plx-logo.svg", height: 5em)
    == Travail de Bachelor - Samuel Roland - 2025
    ==== Suivi par Bertil Chapuis
  ])
]

#slide(title: "Contexte")[
#grid(columns: 2, column-gutter: 1em,
[
- Programmation complexe et abstraite
- Pratique et feedback
- Code fonctionnel vs code de qualité
- Lenteur des vérifications manuelles
],
text(size: 0.7em)[
```bash
chien-du-quartier> ls
main.c
chien-du-quartier> gcc main main.c
/usr/bin/ld: cannot find main: No such file or directory
collect2: error: ld returned 1 exit status
chien-du-quartier> gcc -o main main.c
chien-du-quartier> main
bash: main: command not found...
chien-du-quartier> ./main
Trop d info
chien-du-quartier> ./main Dogy
Trop d info
Le chien Dogy est sympa
chien-du-quartier> ????
```
])

]

#blank-slide()[
== Et PLX dans ce contexte ?
// Point démos
// - Compagnon d'apprentissage
// - Développé en Rust et VueJS pour le frontend
// - Exercice de code de C ou C++
// - Système de checks basés sur l'output
]

#slide(title: "Défi 1")[
== Comment faciliter la rédaction et la maintenance des exercices ?
- PRG1: 100+ exercices de code
- Beaucoup de temps de rédaction
- Formats textuels appréciés (#link("https://github.com/PRG1-HEIGVD/PRG1_Recueil_Exercices")[PRG1], #link("https://github.com/PRG2-HEIGVD/PRG2_Recueil_Exercices")[PRG2], #link("https://github.com/orgs/web-classroom/repositories")[WEB], #link("https://github.com/heig-vd-dai-course/heig-vd-dai-course")[DAI], #link("https://amt-classroom.github.io/")[AMT])
- Git, collaboration, IDE local
- Décrire le cours, les compétences et les exercices

#align(center)[
== Quel format textuel choisir pour optimiser la rédaction ?
]
]

#slide(title: "Exemple d'exercice de C")[
  #text(size: 0.7em)[
#include "./report/sources/plx-dy-simple.typ"
  ]
]

#slide(title: "Exemple d'exercice en Markdown")[
#text(size: 0.7em)[
#grid(columns: 2, column-gutter: 1em,
    raw(block: true, lang: "markdown", read("new/plx-dy-simple.md")),
    raw(block: true, lang: "markdown", read("new/plx-dy-simple.suite.md"))
)
]
]

#slide(title: "Solutions standards")[
#text(size: 0.93em)[
#figure(raw(block: true, lang: "json", read("./report/sources/plx-dy-simple.json")), caption: [Equivalent JSON]) <exemple-dy-json>
]
]

#slide(title: "Solutions standards")[
#text(size: 0.9em)[
#figure(raw(block: true, lang: "yaml", read("./report/sources/plx-dy-simple.yaml")), caption: [Equivalent YAML]) <exemple-dy-yaml>
]
]


#slide(title: "Solutions existantes")[
// - Exemples de formats existants
// - Problèmes restants des formats existants

#text(size: 0.7em)[

#grid(columns: 2, column-gutter: 3em,
figure(
```
package {
  name my-pkg
  version "1.2.3"

  dependencies {
    // Nodes can have standalone values as well as
    // key/value pairs.
    lodash "^3.2.1" optional=#true alias=underscore
  }

  scripts {
    // "Raw" and dedented multi-line strings are supported.
    message """
      hello
      world
      """
    build #"""
      echo "foo"
      node -c "console.log('hello, world!');"
      echo "foo" > some-file.txt
      """#
  }
}
```, caption: [Exemple de la syntaxe KDL pour définir un `package.json` @kdlWebsite]),
figure(
```
[.multiple-choice-1]
[!What color is milk?]
[?Cows produce milk.]
[+white]
[-red]
[-blue]
```, caption: [Choix multiple défini en syntaxe Bitmark @bitmarkDocsMcqSpec.])
  )
]
]

#slide(title: "Solution: la syntaxe DY")[
== Comment faciliter la rédaction et la maintenance des exercices ?
En créant une nouvelle syntaxe textuelle
- concise
- facile à rédiger
- tolérante aux erreurs
- avec validation intégrée
- et validation avancée en Rust
]

#slide(title: "Définition d'un exercice")[
  Dans un fichier `exo.dy`
  #image(width: 130%, "./report/syntax/exo/exo.svg")
]

#slide(title: "Définition d'un cours")[
  Dans un fichier `course.dy`
#image(width: 130%, "./report/syntax/course/course.svg")
]
#slide(title: "Définition des compétences du cours")[
  Dans un fichier `skills.dy`
#image(width: 150%, "./report/syntax/skills/skills.svg")
]

#slide(title: "Définitions des clés")[
#image("./report/syntax/specs/exo.spec.svg")
]

#slide(title: "Développement d'un parseur")[
- Parseur Rust - librairie `dy`
- Définitions des clés PLX - librairie `plx-dy`
- Intégration de `plx-dy` à PLX desktop
- Intégration de `plx-dy` au CLI `plx parse`
]


#blank-slide[
= Démo de la syntaxe DY
// - Montrer cours PRG2 mis en place avec seulement course.dy et skills.dy
// - Reprendre un exercice style PRG2 rédigé en Markdown
// - Le retranscrire en faisant 2 erreurs
// - Lancer plx parse
// - Voir les erreurs et les corriger
// - Relancer plx parse et montrer le JSON correctement extrait
// - Push l'exo et pull dans PLX pour montrer son affichage
]

#slide(title: "Défi 2")[

== Problèmes lors des séances d'entrainement en classe
- Est-ce que c'est acquis ?
- Est-ce que ma classe progresse ?
- Peu de questions
- Confusion ou blocage
- Le code fonctionne
- Feedback de qualité de code
// todo pictogrammes avec "?" devant sa classe et devant son code
]

#slide(title: "Solution")[
  #align(center)[
  = Comment les enseignant·es peuvent voir le code et les résultats en temps réel ?
  #linebreak()
  Solution: Les sessions live hébergées sur un serveur central
  ]
]

#slide(title: "Un serveur de session live")[
  #align(center)[
  #image("./report/schemas/high-level-arch-better.png", height: 85%)
  ]
]

#slide(title: "Définir un protocole")[
// -> voir le code et les résultats en temps réel via des session live temporaire
- Formats textuels et binaires: XML, JSON, ProtoBuf, MessagePack, ...
- Protocoles de transport bidirectionnel: WebSockets, gRPC, tarpc, ...
- JSON et WebSockets
- Pas de compte: `client_id` et `client_num`
- Système de rôle: `Leader` et `Follower`

  #grid(columns: 2,column-gutter: 2em,
figure(raw(block: true, lang: "json", read("./report/protocol/messages/Event-ExoSwitched.json"))),
  image("./report/protocol/imgs/basic-event-action-flow.png")
  )
]

#slide(title: "Action et Event")[
  #grid(columns: 2,column-gutter: 0.5em,
figure(raw(block: true, lang: "json", read("./report/protocol/messages/Action-SendFile.json"))),
figure(raw(block: true, lang: "json", read("./report/protocol/messages/Event-ForwardFile.json")))
  )
#figure(raw(block: true, lang: "json", read("./report/protocol/messages/Event-Stats.json")))
#figure(raw(block: true, lang: "json", read("./report/protocol/messages/Event-Error-1.json")))
]

#slide(title: "Réalisation")[
  #grid(columns: 2,column-gutter: 1em, [
- Serveur en Rust intégré à `plx server`
- Runtime Tokio et `tokio-tungstenite`
- Gestion des sessions
- Dashboard pour les enseignant·es
  ],
  image("new/join-session-new.png")
)
]

#blank-slide[
= Démo d'une session live
// - Invitation prof+expert à ouvrir PLX et rejoindre la session
// - Choix de 3 exos et lancer en premier de l'exo
// - Laisser prof+expert faire l'exercice un check après l'autre
// - Montrer les messages échangés avec le serveur
// - Montrer l'interface, le code visible et l'état des checks
]

#slide(title: "Objectifs du cahier des charges")[
== Objectifs principaux
- ✅ Un serveur en Rust lancé via le CLI plx permettant de gérer des sessions live.
- ✅ Une librairie en Rust de parsing de la syntaxe DY.
- ✅ Une intégration de cette librairie dans PLX.

== Objectifs fonctionnels
- ✅ Tous les objectifs atteints
- 🟧 Sauf la vue globale des checks sur tous les exercices
- 🟧 Intégration desktop des sessions
]
#slide(title: "Objectifs du CDC")[
  #text(size:0.9em)[

== Objectifs non-fonctionnels
- ❌ Supporter les déconnexions temporaires
- ✅ Le serveur doit supporter 300 connexions persistantes simultanées
- ❌ Une session live s'arrête automatiquement après 30 minutes
- ✅ Aucun code externe ne doit être exécuté automatiquement par PLX
- ✅ \< à 3s pour l'envoi et la réception d'un check
- ✅ Tests de bout en bout avec multiples clients
- ✅ Vitesse du parseur DY - 200 exercices en < 1s
- ✅ Retranscrire un exo en \< 1min

== Objectifs "nice-to-have"
- 🟧 Intégration des erreurs dans un serveur de langage dans VSCode et Neovim.
- ❌ Autogénérer des définitions TreeSitter depuis les clés
]
]

#slide(title: "Travail futur")[
- Supporter l'exécution de `type` et `exit`
- Améliorer l'envoi des résultats des checks
- Gérer les pannes des clients
- Étendre la syntaxe DY
- Améliorer le dashboard
]


#blank-slide[
  #page(margin: 0pt)[

#image("new/prg1-view-with-counters.png", width: 100%)
  ]
]

#slide(title: "Bibliographie")[

#show "Available from": "Disponible à l'adresse"
#show "Online": "En ligne"
  #bibliography("bibliography.yml", title: "", style: "iso-690-numeric")
]

#slide(title: "Performance du serveur")[
  #text(size: 0.7em)[

== Configuration
```rust
// Number of files saved per minutes per client
const MIN_SAVE_PER_MINUTE: u16 = 2;
const MAX_SAVE_PER_MINUTE: u16 = 20;
// Number of client to put in a live session
const MIN_CLIENT_PER_SESSION: u16 = 20;
const MAX_CLIENT_PER_SESSION: u16 = 60;
```
== Situation de départ
700Ko of RAM + 0% CPU
```sh
> docker stats env-plx-1
CONTAINER ID   NAME        CPU %     MEM USAGE / LIMIT   MEM %     NET I/O          BLOCK I/O   PIDS 
e692576c9958   env-plx-1   0.00%     708KiB / 1.91GiB    0.04%     5.2kB / 1.56kB   0B / 0B     2 
```
Avec ~30 connexions TCP existantes
```sh
> ss -s
Total: 217
TCP:   30 (estab 3, closed 14, orphaned 1, timewait 0)
```

== En ajoutant les 400 clients
53MB de RAM et 0.68% de CPU.
```sh
> docker stats env-plx-1
CONTAINER ID   NAME        CPU %     MEM USAGE / LIMIT    MEM %     NET I/O         BLOCK I/O   PIDS 
e692576c9958   env-plx-1   0.68%     52.84MiB / 1.91GiB   2.70%     882kB / 247kB   0B / 0B     2 
```
Le 30 est passé à 423.
```sh
> ss -s
Total: 217
TCP:   423 (estab 2, closed 407, orphaned 7, timewait 0)
```
La latence mesurée visuellement d'un changement d'exercice reste inférieur à une seconde.
  ]
]

#slide(title: "Exemple d'usage du parseur")[
#text(size: 0.7em)[
#show raw: set par(leading: 0.4em)

#grid(columns: 2, column-gutter: -10pt,

```rust
use plx_dy::parse_course;

fn main() {
    let filename = &Some("course.dy".to_string());
    let course_text = "course Programmation 2
code PRG2
goal";
    let result = parse_course(filename, course_text);
    dbg!(result);
}
```,
  figure(
```rust
ParseResult {
    items: [
        DYCourse {
            name: "Programmation 2",
            code: "PRG2",
            goal: "",
        },
    ],
    errors: [
        ParseError {
            range: Range {
              start: Position {
                line: 2, character: 4 },
              end: Position {
                line: 2, character: 4 },
            },
            error: MissingRequiredValue("goal"),
        },
    ],
    some_file_path: Some("course.dy"),
    some_file_content: Some("course Programmation 2\ncode PRG2\ngoal"),
}
```)
)
]
]
