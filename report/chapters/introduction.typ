#import "../template/style.typ": roundedbox
= Introduction <introduction>

// TODO restructurer avec problème d'abord puis PLX, puis changement à faire dans PLX

== Contexte

// Etat actuel de l'enseignement en informatique (sans jugement)
//
// - Enseignement sous forme de cours magistraux.
// - Besoin de pratique délibérée et définition de la pratique délibérée.
// - Laboratoires et des exercices (angle étudiants): motivation, responsabilisation, feedback, suivi.
// - Laboratoires et exercices (angle technique): friction lors de la mise en place des laboratoires (copie des fichiers, compilation, etc.)

L'informatique et particulièrement la programmation, sont des domaines abstraits et complexes à apprendre. Dans la majorité des universités, l'informatique est enseignée sur des cours composés d'une partie théorique, dispensée par un professeur, et d'une partie pratique, sous forme de laboratoires, encadrée par des assistants.
Les sessions théoriques sont souvent données sous forme magistrale: des slides sont présentées durant 2 périodes pour présenter différents concepts, morceaux de code et études de cas. Les étudiant·es ont rarement la possibilité d'être actifs, ce qui limite fortement la concentration et la rétention de l'information. Une grande partie de l'auditoire décroche et préfère travailler sur des laboratoires ou réviser pour d'autres cours.

Lors des rares sessions d'exercice en classe, et durant la révision en dehors des cours, un temps important est perdu à mettre en place les exercices et les vérifications manuelles de sa solution.
// garder ? c'est à dire: copier des fichiers, effectuer une première compilation, et résoudre des problèmes de reproductibilité.
Ce processus fastidieux se fait au détriment de la pratique délibérée, concept popularisé par le psychologue Anders Ericsson dans ses recherches en expertise @peakBook. Cette méthode consiste à travailler de manière concentrée sur des sous-compétences spécifiques. Afin de constamment corriger et affiner son modèle mental, elle demande de recevoir un feedback rapide et régulier. La solidité du modèle mental, construit par l'expérience permet d'attendre un niveau d'expertise. #linebreak()
Ce travail de Bachelor s'inscrit dans ce contexte et vise à redéfinir l'expérience d'apprentissage et d'enseignement de la programmation en s'inspirant de cette méthode.

#pagebreak()
== Problème de l'expérience originale
Pour mieux comprendre à quel point le processus actuel d'entrainement est fastidieux, regardons un exercice concret de C pour débutant. Une enseignante qui suit une classe de 40 étudiant·es, fournit la consigne suivante sur un serveur.

// TODO en français l'exo ??

#roundedbox()[#include "../schemas/plx-dy-simple.typ"]

// Problème de la friction pour les étudiants sur un exercice

Un titre, une consigne et un scénario pour tester le bon fonctionnement sont fournis. L'enseignante annonce un temps alloué de 10 minutes. Une fois la consigne récupérée et lue par un des étudiant·es, la première étape est de prendre le code de départ et de créer un nouveau fichier dans ses fichiers personnels. L'étudiant ouvre ensuite son IDE favori dans le dossier de l'exercice et configure la compilation avec CMake. Déjà 3 minutes sont passées, l'étudiant peut enfin commencer à coder.

Une première solution est développée et est prête à être testée après 2 minutes. L'étudiant lance un terminal, compile le code, rentre `John` et `Doe` et s'assure du résultat. Après relecture de la sortie générée, il se rend compte d'une erreur sur `Passe une belle journée Doe !`: seul le nom de famille s'affiche, le prénom a été oublié. Encore 2 minutes pour tester son code se sont écoulées. Après une minute de correction, l'étudiant retourne dans son terminal et recommence le processus de validation. Le code est terminé juste à la fin du temps alloué et l'étudiant peut suivre la correction. S'il avait eu une erreur de plus, cela aurait été trop court. Certain·es étudiant·es à ses côtés n'ont pas eu le temps de finir et doivent s'arrêter.

En résumé, sur les dix minutes seulement trois ont été utilisées pour de l'écriture de code. Tout le reste a été perdu sur des tâches "administratives" autour de l'exercice.

// Problème du manque d'accès aux solutions en live et manque de feedback -> coté étudiants et enseignants
// perte de l'expérience locale sur des services en ligne

Durant la correction, l'enseignante va présenter sa solution et demander s'il y a des questions. Certain·es étudiant·es les plus avancés poseront peut-être des questions sur l'approche ou une fonction spécifique. Il est très rare d'entendre une question du type "Je suis complètement paumé, vous pouvez réexpliquer ce que fait cette fonction ?" ou encore "Je ne n'ai pas ce qui est flou mais je n'ai vraiment pas compris votre solution". D'autres qui n'ont pas pu terminer l'exercice ne savent pas si le début partait dans la bonne direction même si la solution était bien expliquée.

Faire fonctionner le programme n'est que la première étape. Faire du code robuste, modulaire, lisible et performant demande des retours humains pour pouvoir progresser. Par manque de retour sur leurs réponses, les étudiant·es moins expérimenté·es se rendront seulement compte durant les évaluations plusieurs semaines plus tard, si la compétence derrière l'exerice était vraiment acquise.

Côté de l'enseignante, en comptant uniquement sur les questions des étudiant·es, savoir si le message de l'exercice est passé reste un challenge. Il est difficile aussi de savoir quand l'exercice doit se terminer. Peut-être qu'il aurait fallu 5 minutes de plus pour qu'une majorité ait le temps de finir ? Pour avoir accès aux réponses, elles doivent être manuellement rendues sur un serveur. Ce rendu prend à nouveau du temps et ne sera fait qu'une fois à la fin de l'exercice. Le temps de les récupérer, ouvrir et fermer 40 fichiers, pour évaluer à l'oeil l'état d'avancement et comprendre les différentes approches, prendrait trop de temps en classe.

Une autre approche serait de coder dans un fichier Google docs partagé à toute la classe. L'enseignante a maintenant un moyen de relire au fur et à mesure, détecter les incompréhensions, mais les étudiant·es ont perdu toute l'expérience du développement en local. Dans Google docs, il n'y a plus de couleurs, plus d'auto-complétion, plus d'erreurs de compilation intégrée dans le code. Tous les raccourcis, le formattage automatique et les informations au survol manquent terriblement. Pour tester leur code, les étudiant·es devraient constamment copier dans un fichier local.

En conclusion, le problème c'est que l'entrainement est fastidieux pour les étudiants, ce qui ralentit l'apprentissage en profondeur de la programmation. Leurs enseignant·es n'ont pas accès aux solutions et ne peuvent pas donner des feedbacks.

// reste evtl le problème de rédiger des tests automatisés pas toujours évident à mettre en place, teste stdin et stdout pas du tout facile

// description brève de probessus fastidieux qui empêche la pratique délibérée:
// - décrire le processus actuel avec un exemple d'exercice (C de type hello)
// - décrire les frictions de ce processus
//   - Le professeur met les fichiers à disposition sur un serveur
//   - Les étudiants copient les fichiers
//   - Configuration de l'environnement
//   - 

// faire le lien avec le sous titr problème
// le coeur de ce que PLX va automatiser sans parler de PLX sans parler de solution

// exemple de temps

// bien s'imaginer comment se passe des exercices en classe.

== L'approche de PLX

// l'existant
// - concentrer sur l'écriture de code plutot que les étapes administratives qui peuvent etre automatisées
// - fournir un feedback riche et immédiat grâce à des suites de tests automatisés
// - bénéficier de l'environnement local pour la puissance des IDE et la vitesse de compilation

// le nouveau
// - faire des exercices en classe ensemble de la partie live tout en restant en local
// - une interface de visualisation du code et des checks en temps réel pour les profs
// - permet de faire des feedbacks, générer des discussions et voir l'avancement global par l'état des checks

// TODO "poursuivre" au lieu de "développer", okay ?

// l'existant
Ce travail de Bachelor vise à poursuivre le développement du projet PLX @plxWebsite, Terminal User Interface (TUI) écrite en Rust. Cette application permet aux étudiant·es de se concentrer pleinement sur l'écriture du code. PLX est inspiré de Rustlings (TUI pour apprendre le Rust), permettant de s'habituer aux erreurs du compilateur Rust et de prendre en main la syntaxe @RustlingsWebsite. PLX fournit actuellement une expérience locale similaire pour le C et C++. Pour commencer à s'entrainer, les étudiant·es clonent un repository Git et travaillent localement dans leur IDE favori qui s'exécute en parallèle de PLX. Les scénarios de vérifications, exécutés auparavant manuellement, sont lancés automatiquement à chaque sauvegarde de fichier. Ces suites de tests automatisées, appelées des "checks", permettent d'apporter un feedback automatisé rapide, continu et riche. Au lieu de perdre 7 minutes sur 10 sur des tâches "administratives", PLX permet à l'étudiant·e de réduire ce temps à 1 minute.

// todo yatil des études scientifiques dans l'état de l'art à mentionner ? peut-être qui soutient les défaut du YAML ou d'autres formats ?

#figure(
  image("../imgs/plx-preview-home.png", width: 80%),
  caption: [Aperçu de la page d'accueil de PLX dans le terminal @PlxDocsStatus],
) <fig-plx-preview-home>

#figure(
  image("../imgs/plx-preview-checks.png", width: 100%),
  caption: [Aperçu d'un exercice dans PLX, avec un check qui échoue et les 2 suivants qui passent @PlxDocsStatus],
) <fig-plx-preview-checks>


#pagebreak()

== Nouveaux défis
Le problème du besoin de feedbacks humains pour les étudiant·es et celui de permettre aux enseignant·es d'accéder aux réponses, ne sont pas encore résolus par PLX. Ces nouveaux défis sont à la base des deux extensions majeures qui seront développées dans le cadre de ce travail.

// potentiel utile ?
// PLX peut à terme aider de nombreux cours à la HEIG-VD (tels que PRG1, PRG2, PCO, SYE...) à passer de longs moments de théorie en session d'entrainement dynamique et très interactive. L'ambition est qu'à terme, cela génère un apprentissage plus profond de modèles mentaux solides chez les étudiants. Cela aidera les étudiants qui ont beaucoup de peine à s'approprier la programmation à avoir moins de difficultés avec ces cours. Et ceux qui sont plus à l'aise pourront développer des compétences encore plus avancées.

=== Comment les enseignants peuvent voir le code et les résultats en temps réel ?

// todo mix de permet et permettra et permettrait ? que faire ?

Comme mentionné précédemment, le rendu manuel d'exercices prend un peu de temps et ne sera pas fait fréquemment durant un entrainement. De plus, avoir accès à une archive de fichiers de code, demanderait encore du travail avant de pouvoir construire des statistiques de l'état des checks.

Comme l'application fonctionne localement et s'exécute à chaque sauvegarde, le code et les résultats des checks sont déjà connus par PLX. Il suffirait d'avoir un serveur central, utilisé uniquement durant les sessions d'entrainement en classe (nommées "les sessions live"), vers lequel PLX envoie le code et l'état des checks en continu. Ces informations peuvent ensuite être affichées sur l'interface PLX de l'enseignant·e.

La visualisation sur une échelle globale ou plus zoomée, permettra aux enseignant·es de rapidement comprendre les lacunes des étudiant·es, en relisant les différentes réponses affichées. Il sera possible de sélectionner certaines réponses particulières pour les afficher au beamer, les commenter spécifiquement ou apporter des feedbacks généraux à l'oral.

#figure(
  image("../schemas/live-sessions-flow.png", width:100%),
  caption: [Interactions entre les clients PLX chez l'enseignant·e et les étudiant·es, le code est synchronisé via un serveur central, le cours "PRG2" a un repository Git publique],
) <live-sessions-flow>

Sur la @live-sessions-flow, on voit qu'avant de commencer, les étudiants ont dû cloner le repository Git du cours sur leur machine pour accéder aux exercices. Une fois une session live démarrée par un enseignant et les étudiants ayant rejoint la session, l'enseignant peut choisir de faire un exercice l'un après l'autre en définissant son propre rythme.

L'exercice en cours est affiché sur tous les clients PLX. À chaque sauvegarde d'un fichier de code, le code est compilé et les checks sont lancés comme en dehors d'une session live. La différence est que les résultats des checks et le code modifié seront envoyés à l'enseignant de la session. L'enseignant pourra ainsi avoir un aperçu global de l'avancement et des checks qui ne passent pas, éventuellement d'inspecter le code de certaines soumissions dans le but final de faire des feedbacks à la classe en durant ou à la fin de l'exercice.

Cette première partie nécessite le développement d'un protocole de synchronisation des différents éléments. Elle implique aussi l'utilisation de protocoles de communication temps-réel pour permettre cette expérience live en classe.

#pagebreak()

=== Comment faciliter la rédaction et la maintenance des exercices ?
La gestion des exercices dans un format textuel dans son IDE favori est largement plus productive qu'utiliser des interfaces web parfois lentes avec des dizaines de champs de formulaires. La possibilité de versionner ces fichiers textuels dans Git et facilement collaborer dans des pull requests est un avantage majeur que de nombreux enseignants apprécient. Une partie d'entre eux gèrent leur slides, exercices et évaluations, en utilisant le Markdown, Latex, Typst ou encore AsciiDoc.

Le défi maintenant est de permettre de rédiger des exercices de programmation en format textuel, tout en y incluant une partie d'interactivité et d'automatisation d'un outil comme PLX à côté de l'éditeur de code.

// todo okay de mettre des infos d'opinions ?? je peux pas vraiment citer je crois. -> selon les recherches de l'auteur.

Prenons un exemple concret d'exercice de programmation, pour entrainer la gestion d'entrées/sorties dans le terminal d'un petit CLI.

#figure(raw(block: true, lang: "markdown", read("../schemas/plx-dy-simple.md")), caption: [Exemple d'exercice de programmation, rédigé en Markdown]) <exemple-dy-md-start>

Cet exercice en @exemple-dy-md-start est adapté à l'affichage et l'export PDF pour être distribué dans un recueil d'exercices. Si un outil tel que PLX voulait automatiser l'exécution du code et des étapes manuelles de rentrer prénom et nom et de vérifier l'output, il n'est pas vraiment possible de parser de manière non ambigüe. En effet, comment savoir exactement sans comprendre le langage naturel que `John` et `Doe` doivent être rentrés à la main et ne font pas partie de l'output ? Comment le parseur peut détecter qu'on parle du code d'exit du programme et que ce code doit valoir zéro ?

Nous avons besoin de définir de manière structurée ces assertions et ce qu'il faut entrer comme texte à quel moment. On pourrait imaginer utiliser du JSON pour y stocker le titre et la consigne. On pourrait inventer ensuite une liste de checks avec un titre et une séquence d'opérations à effectuer pour ce check. Chaque opération serait de type `see` (ce qu'on s'attend à "voir" dans l'output), `type` (ce qu'on tape dans le terminal) et finalement `exit` pour définir le code d'exit attendu.

#pagebreak()
Cette définition JSON pourrait ressembler à celle présentée sur le @exemple-dy-json

#figure(raw(block: true, lang: "json", read("../schemas/plx-dy-simple.json")), caption: [Equivalent JSON de l'exercice défini sur le @exemple-dy-md-start]) <exemple-dy-json>

Cet exemple d'exercice est minimal, mais le @exemple-dy-json montre bien que rédiger dans ce format serait fastidieux. Si on avait eu besoin de rédiger du Markdown dans la consigne sur plusieurs lignes, on aurait eu besoin de remplacer les retours à la ligne par des `\n` à la main. Ces transformations compliquent la lisibilité, en plus de tous les guillemets, deux points et accolades nécessaires au-delà du texte brut qui demande un effort de rédaction important.

Si on oubliait un instant d'autres formats populaires moins verbeux que le JSON (tel que le YAML) et qu'on inventait de zéro une toute nouvelle syntaxe qui reprend les idées de `see`, `type`, et `exit`. Une syntaxe qui permettrait de rédiger ce même exercice de manière concise, compacte et avec très peu de caractères additionnels au contenu brut, tout en gardant une structure qui peut être parsée. Voici en @exemple-dy à quoi cela pourrait ressembler.

#figure(
  image("../schemas/plx-dy-simple.svg", width:100%),
  caption: [Equivalent dans une version préliminaire de la syntaxe DY de l'exercice défini sur le @exemple-dy-md-start],
) <exemple-dy>

// Dans le @exemple-dy, on définit un exercice de programmation avec un petit programme qui doit dire bonjour à l'utilisateur, en lui demandant son prénom puis son nom. Elle contient 2 checks (vérifications automatiques) pour vérifier le comportement attendu. Le premier check décrit une situation de succès et le deuxième décrit une situation d'erreur.

On retrouve dans @exemple-dy les mêmes informations que défini précédemment, délimitées par un système de préfixe (en bleu du début des lignes) qui permet de structurer le contenu de l'exercice.

// todo les variantes de DY ??

Ce deuxième défi demande ainsi d'écrire un parseur de cette nouvelle syntaxe. Une nouvelle syntaxe sans support dans les IDE modernes est peu agréable à utiliser. Lire du texte structuré blanc sur fond noir sans aucune couleur, sans feedback sur la validité du contenu, mène à une expérience un peu froide. Une fois le parseur fonctionnel, le support de certains IDE pourra être implémenté.

Voici un aperçu de l'expérience imaginée des enseignants pour la rédaction des exercices dans cette syntaxe en @ide-xp.

#figure(
  image("../schemas/ide-experience-mental-model-simple.png", width:100%),
  caption: [Aperçu de l'expérience de rédaction imaginée dans un IDE],
) <ide-xp>

On voit dans la @ide-xp que l'intégration se fait sur 2 points majeurs
+ le surlignage de code, qui permet de coloriser les préfixes et les propriétés, afin de bien distinguer le contenu des éléments propres à la syntaxe
+ intégration avancée de la connaissance et des erreurs du parseur à l'éditeur: comme en ligne 4 avec l'erreur du nom de check manquant après le préfixe `check`, et comme en ligne 19 avec une auto-complétion qui propose les préfixes valides à cette position du curseur.

Cette nouvelle syntaxe, son parseur et support d'IDE permettront de remplacer le format TOML actuellement utilisé dans PLX.

#pagebreak()

== Solutions existantes <solutions-existantes>

Comme mentionné dans l'introduction, PLX est inspiré de Rustlings. Cette TUI propose une centaine d'exercices avec des morceaux de code à faire compiler ou avec des tests à faire passer. L'idée est de faire ces exercices en parallèle de la lecture du _Rust book_ (la documentation officielle).
#figure(
  image("../imgs/rustlings-demo.png", width: 80%),
  caption: [Un exemple de Rustlings en haut dans le terminal et VSCode en bas, sur un exercice de fonctions],
) <fig-rustlings-demo>

De nombreux autres projets se sont inspirées de ce concept, `clings` pour le C @ClingsGithub, `golings` pour le Go @GolingsGithub, `ziglings` pour Zig @CodebergZiglings et même `haskellings` pour Haskell @HaskellingsGithub ! Ces projets incluent une suite d'exercice et une TUI pour les exécuter pas à pas, afficher les erreurs de compilation ou les cas de tests qui échouent, pour faciliter la prise en main aux débutants.

Chaque projet se concentre sur un langage de programmation et crée des exercices dédiés. PLX prend une approche différente, il n'y a pas d'exercice proposé parce que PLX supporte de multiples langages. Le contenu sera géré indépendamment de l'outil, permettant aux enseignants en école d'intégrer leur propre contenu et compétences enseignées.

// todo solution existantes de review en live de code

#pagebreak()
// todo move that somewhere useful once we have bottom page notes
== Glossaire
L'auteur de ce travail se permet un certain nombre d'anglicismes quand un équivalent français n'existe pas ou n'est pas couramment utilisé. Certaines constructions de programmations bien connues comme les `strings` au lieu d'écrire `chaînes de caractères` sont également utilisées. Certaines sont spécifiques à certains langages et sont décrites ci-dessous pour aider à la lecture.

- `POC`: _Proof Of Concept_, preuve qu'un concept fonctionne en pratique. Consiste ici en un petit morceau de code développé juste pour démontrer que le concept est fonctionnel, sans soin particulier apporté à la qualité de l'implémentation. Ce code n'est pas réutilisé par la suite, il sert seulement d'inspiration pour l'implémentation réelle.
- `exo`: abréviation familière de `exercice`. Elle est utilisée dans la syntaxe DY pour rendre plus concis la rédaction.
- `check`: nom choisi pour décrire un ou plusieurs tests unitaires ou vérifications automatisées du code
- `Cargo`: le gestionnaire de dépendances, de compilation et de test des projets Rust
- `crate`: la plus petite unité de compilation avec Cargo, concrètement chaque projet contient un ou plusieurs dossiers avec un `Cargo.toml`, ce sont des crates locales. Les dépendances sont également des crates qui ont été publié sur le registre officiel.
- `Cargo.toml`, configuration de Cargo dans un projet Rust définit les dépendances (les crates) et leurs versions minimum à inclure dans le projet, équivalent du `package.json` de NPM
- `crates.io`: le registre officiel des crates publiée pour l'écosystème Rust, l'équivalent de `npmjs.com` pour l'écosystème JavaScript ou `mvnrepository.com` pour Java
- `parsing` ou `déserialisation`: processus d'un parseur, visant à extraire de l'information brute vers une forme structurée facilement manipulable
- `sérialisation`: inverse du processus du parseur, qui vise à transformer une structure de données quelconque en une forme brute (une string par exemple) afin de la stocker sur le disque ou l'envoyer à travers le réseau
- `struct`: structure de données regroupant plusieurs champs, disponible en C, en Rust et d'autres langages inspirés
- `backtick`: caractère accent grave utilisé sans lettre, délimiteur fréquent de mention de variable ou fonction dans un rapport en Markdown
- `README` ou `README.md`: Point d'entrée de la documentation d'un repository Git, généralement écrit en Markdown, affiché directement sur la plupart des hébergeurs de repository Git
- `regex`: raccourcis pour les expressions régulières
- `snippet`: court morceau de code ou de données

// todo add note de bas de page à chaque première apparition du mot !

// todo check ces définitions

#pagebreak()

