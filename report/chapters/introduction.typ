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

L'informatique et particulièrement la programmation, sont des domaines abstraits et complexes à apprendre. Dans la majorité des universités, l'informatique est enseignée sur des cours composés d'une partie théorique, dispensée par un·e professeur·e, et d'une partie pratique, sous forme de laboratoires, encadrée par des assistant·es.
Les sessions théoriques sont souvent données sous forme magistrale: des slides durant 2 périodes pour présenter différents concepts, morceaux de code et études de cas. Les étudiant·es ont rarement la possibilité d'être actif·ves, ce qui limite fortement la concentration et la rétention de l'information. Une grande partie de l'auditoire décroche et préfère travailler sur des laboratoires ou réviser d'autres cours.

Lors des rares sessions d'exercice en classe et durant la révision en dehors des cours, un temps important est perdu à mettre en place les exercices et les vérifications manuelles.
// garder ? c'est à dire: copier des fichiers, effectuer une première compilation, et résoudre des problèmes de reproductibilité.
Ce processus fastidieux se fait au détriment de la pratique délibérée, concept popularisé par le psychologue Anders Ericsson dans ses recherches en expertise @peakBook. Cette méthode consiste à travailler de manière concentrée sur des sous-compétences spécifiques. Afin de constamment corriger et affiner son modèle mental, elle demande de recevoir un feedback rapide et régulier. La solidité du modèle mental construit par l'expérience, permet d'attendre un haut niveau d'expertise. #linebreak()
Ce travail de Bachelor s'inscrit dans ce contexte et vise à redéfinir l'expérience d'apprentissage et d'enseignement de la programmation en s'inspirant de cette méthode.

// todo aussi expliquer le besoin de fichiers texte ? ou ca doit venir plus loin ?

#pagebreak()
== Problèmes de l'expérience originale
Pour mieux comprendre à quel point le processus actuel d'entrainement est fastidieux, regardons un exercice concret de C pour débutant. Une enseignante qui suit une classe de 40 étudiant·es, fournit la consigne suivante sur un serveur, comme premier exercice de la session.

// TODO en français l'exo ??

#roundedbox()[#include "../sources/plx-dy-simple.typ"]

// Problème de la friction pour les étudiants sur un exercice

Un titre, une consigne et un scénario pour tester le bon fonctionnement sont fournis. L'enseignante annonce un temps alloué de dix minutes. Une fois la consigne récupérée et lue par un des étudiant·es, il prend le code de départ et de crée un nouveau fichier dans ses fichiers personnels. L'étudiant ouvre ensuite son IDE favori dans le dossier de l'exercice et configure la compilation avec CMake. Après trois de mise en place, il peut enfin commencer à coder.

Une première solution est développée et est prête à être testée après deux minutes. Il lance un terminal, compile le code, rentre `John` et `Doe` et s'assure du résultat. Après relecture de la sortie générée, il se rend compte d'une erreur sur `Passe une belle journée Doe !`: seul le nom de famille s'affiche, le prénom a été oublié. Deux minutes pour tester son code se sont écoulées. Après une minute de correction, l'étudiant retourne dans son terminal et recommence le processus de validation. L'exercice est terminé juste à la fin du temps alloué et l'étudiant peut suivre la correction. S'il avait eu une erreur de plus, il aurait eu besoin de quelques minutes de plus. Certain·es étudiant·es à ses côtés n'ont pas eu le temps de finir et doivent s'arrêter.

En résumé, sur les dix minutes seulement trois ont été utilisées pour de l'écriture de code. Tout le reste a été perdu sur des tâches "administratives" autour de l'exercice.

// Problème du manque d'accès aux solutions en live et manque de feedback -> coté étudiants et enseignants
// perte de l'expérience locale sur des services en ligne

Durant la correction, l'enseignante va présenter sa solution et demander s'il y a des questions. Certain·es étudiant·es les plus avancé·es poseront peut-être des questions sur l'approche ou une fonction spécifique. Il est cependant rare d'entendre une question du type "Je suis complètement paumé·e, vous pouvez réexpliquer ce que fait cette fonction ?" ou encore "Je ne n'ai pas ce qui est flou mais je n'ai vraiment pas compris votre solution". D'autres qui n'ont pas pu terminer l'exercice ne savent pas si leur début partait dans la bonne direction, même si la solution était bien expliquée.

Faire fonctionner le programme n'est que la première étape. Faire du code robuste, modulaire, lisible et performant demande des retours humains pour pouvoir progresser. Les étudiant·es moins expérimenté·es ne savent pas immédiatement si la compétence est acquise, comme le feedback n'arrive que dans les corrections des évaluations notées, plusieurs semaines plus tard.

Côté de l'enseignante, en comptant uniquement sur les questions des étudiant·es, savoir si le message de l'exercice est passé reste un challenge. Il est difficile aussi de savoir quand l'exercice doit se terminer. Peut-être qu'il aurait fallu 5 minutes de plus pour qu'une majorité ait le temps de finir ? Pour avoir accès aux réponses, elles doivent être manuellement rendues sur un serveur. Ce rendu prend à nouveau du temps pour chaque étudiant·e. Pour l'enseignante, les récupérer, ouvrir et fermer 40 fichiers, pour évaluer l'état d'avancement à l'oeil et comprendre les différentes approches, prendrait trop de temps en classe.

Une autre approche serait de coder dans un fichier Google Docs partagé à toute la classe. L'enseignante a maintenant un moyen de relire au fur et à mesure, détecter les incompréhensions, mais les étudiant·es ont perdu toute l'expérience du développement en local. Dans Google Docs, il n'y a pas de couleur sur le code, pas d'auto-complétion et pas d'erreur de compilation visible dans le code. Tous les raccourcis, le formattage automatique et les informations au survol manquent terriblement. Pour tester leur programme, les étudiant·es doivent constamment copier leur code dans un fichier local.

En conclusion, le problème c'est que l'entrainement est fastidieux pour les étudiants, ce qui implique moins d'exercices effectués, moins de motivation à avancer et freine l'apprentissage en profondeur. Le manque de retour ralentit également la progression des compétences autour de la qualité du code produit. Les enseignant·es n'ont pas accès aux réponses des étudiant·es, ce qui empêche d'avoir une vision précise des incompréhensions et de donner de feedbacks.

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

#pagebreak()

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
Ce travail de Bachelor vise à poursuivre le développement du projet PLX @plxWebsite, Terminal User Interface (TUI) écrite en Rust. Cette application permet aux étudiant·es de se concentrer pleinement sur l'écriture du code. PLX est inspiré de Rustlings (TUI pour apprendre le Rust), permettant de s'habituer aux erreurs du compilateur Rust et de prendre en main la syntaxe @RustlingsWebsite. PLX fournit actuellement une expérience locale similaire pour le C et C++.

Pour commencer à s'entrainer, les étudiant·es clonent un repository Git et travaillent localement dans leur IDE favori qui s'exécute en parallèle de PLX. Les scénarios de vérifications, exécutés auparavant manuellement, sont lancés automatiquement à chaque sauvegarde de fichier. Ces suites de tests automatisées, appelées "checks", permettent d'apporter un feedback automatisé rapide, continu et riche. Au lieu de perdre sept minutes sur dix sur des tâches "administratives", PLX en automatise la majorité et permet à l'étudiant·e de réduire ce temps à une minute.

// todo yatil des études scientifiques dans l'état de l'art à mentionner ? peut-être qui soutient les défaut du YAML ou d'autres formats ?

#figure(
  image("../imgs/plx-preview-home.png", width: 100%),
  caption: [Aperçu de la page d'accueil de PLX dans le terminal @PlxDocsStatus],
) <fig-plx-preview-home>

#figure(
  image("../imgs/plx-preview-checks.png", width: 100%),
  caption: [Aperçu d'un exercice de C dans PLX, avec un check qui échoue et 2 autres qui passent @PlxDocsStatus],
) <fig-plx-preview-checks>

// todo screen 2 avec vscode à coté mieux ?

#pagebreak()

== Nouveaux défis
Le besoin de feedback humain pour les étudiant·es en plus du feedback automatisé, et celui de permettre aux enseignant·es d'accéder aux réponses, ne sont pas encore résolus par PLX. Ces nouveaux défis sont le point de départ des deux extensions majeures qui seront développées dans le cadre de ce travail.

// potentiel utile ?
// PLX peut à terme aider de nombreux cours à la HEIG-VD (tels que PRG1, PRG2, PCO, SYE...) à passer de longs moments de théorie en session d'entrainement dynamique et très interactive. L'ambition est qu'à terme, cela génère un apprentissage plus profond de modèles mentaux solides chez les étudiants. Cela aidera les étudiants qui ont beaucoup de peine à s'approprier la programmation à avoir moins de difficultés avec ces cours. Et ceux qui sont plus à l'aise pourront développer des compétences encore plus avancées.

=== Défi 1: Comment les enseignants peuvent voir le code et les résultats en temps réel ?

// todo mix de permet et permettra et permettrait ? que faire ?

Comme mentionné précédemment, le rendu manuel d'exercices prend un peu de temps et ne sera pas fait fréquemment durant un entrainement. De plus, avoir accès à une archive de fichiers de code, demanderait encore de les lancer localement avant de pouvoir construire des statistiques de l'état des checks.
// todo c'est un dupliqué ou pas ?

Comme l'application fonctionne localement et s'exécute à chaque sauvegarde, le code et les résultats des checks sont déjà connus par PLX. Il suffirait d'avoir un serveur central, qui héberge les sessions d'entrainement en classe (appelées "sessions live"), vers lequel PLX envoie le code et l'état des checks en continu. Ces informations peuvent ensuite être récupérées du serveur et affichées sur l'interface PLX de l'enseignant·e.

Des interfaces de visualisation sur une échelle globale ou plus zoomée, permettront aux enseignant·es de rapidement comprendre les lacunes des étudiant·es, en relisant les différentes réponses affichées. Grâce à l'état des checks, il sera facile de voir si la classe a terminé l'exercice ou de filtrer les réponses pour concentrer sa relecture. Il sera possible de sélectionner certaines réponses particulières pour les afficher au beamer, pouvoir les commenter ou demander à la classe de critiquer constructivement le code choisi.

Sur la @live-sessions-flow suivante, on voit qu'avant de commencer, les étudiants ont dû cloner le repository Git du cours sur leur machine pour accéder aux exercices. Une fois une session live démarrée par un·e enseignant·e et les étudiant·es ayant rejoint la session, l'enseignant·e peut choisir de faire un exercice l'un après l'autre en choisissant le rythme.
#figure(
  image("../schemas/live-sessions-flow.png", width:100%),
  caption: [Interactions entre les clients PLX chez l'enseignant·e et les étudiant·es, le code est synchronisé via un serveur central, le cours "PRG2" a un repository Git publique],
) <live-sessions-flow>
// todo inclusif schéma ?


L'exercice en cours est affiché sur tous les clients PLX. À chaque sauvegarde d'un fichier de code, le code est compilé et les checks sont lancés. Les résultats des checks et le code modifié seront envoyés à l'enseignant de la session.

Ce premier défi nécessite le développement d'un serveur central et d'un protocole de synchronisation. Elle implique aussi l'utilisation d'un protocole de communication bidirectionnel pour permettre cette expérience en direct en classe.

=== Défi 2: Comment faciliter la rédaction et la maintenance des exercices ?

La rédaction de contenu sous forme de fichier textes, au lieu de l'approche classique de formulaires, semble particulièrement plaire en informatique. En effet, de nombreux enseignant·es à la HEIG-VD rédigent tout ou partie de leur contenu (exercices, slides, consignes de laboratoires) dans divers formats textuels.

Un exemple d'usage du Markdown est le recueil d'exercices du cours de PRG1 (cours de C++) @PRG1RecueilExercicesGithub. On note également l'usage de balises HTML `<details>` et `<summary>`, pour rendre disponible la solution tout en la cachant par défaut. Pour combler le manque de mise en page du Markdown, d'autres enseignant·es utilisent Latex ou Typst @TypstWebsite.

// - Markdown pas adapté car pas assez structuré pour être parsé sans ambiguité
// - format structuré facilement parsable trop verbeux
// - yaml entre deux 

#pagebreak()

// La gestion des exercices dans un format textuel dans son IDE favori est largement plus productive qu'utiliser des interfaces web parfois lentes avec des dizaines de champs de formulaires. La possibilité de versionner ces fichiers textuels dans Git et facilement collaborer dans des pull requests est un avantage majeur que de nombreux enseignants apprécient. Une partie d'entre eux gèrent leur slides, exercices et évaluations, en utilisant le Markdown, Latex, Typst ou encore AsciiDoc.
//
// Le défi maintenant est de permettre de rédiger des exercices de programmation en format textuel, tout en y incluant une partie d'interactivité et d'automatisation d'un outil comme PLX à côté de l'éditeur de code.

// todo okay de mettre des infos d'opinions ?? je peux pas vraiment citer je crois. -> selon les recherches de l'auteur.


Pour faciliter l'adoption de PLX, nous avons besoin d'un format de données simple à prendre en main, pour décrire les différents types d'exercices supportés. Si on reprend l'exercice présenté plus tôt, qu'on le rédige en Markdown, en y ajoutant la solution comme sur le recueil de PRG1, cela donne @exemple-dy-md-start.

#figure(raw(block: true, lang: "markdown", read("../sources/plx-dy-simple.md")), caption: [Exemple d'exercice de programmation, rédigé en Markdown]) <exemple-dy-md-start>

Ce format en @exemple-dy-md-start est pensé pour un document lisible par des humains. Cependant, si on voulait pouvoir automatiser l'exécution du code et des étapes manuelles de rentrer le prénom, le nom et de vérifier l'output, nous aurions besoin d'extraire chaque information sans ambiguïté. Hors cette structure, bien que reproductible sur d'autres exercices, n'est pas assez standardisée pour une extraction automatique.

En effet, sans comprendre le langage naturel, comment savoir que `John` et `Doe` doivent être rentrés à la main et ne font pas partie de l'output ? Comment le parseur peut détecter qu'on parle du code d'exit du programme et que ce code doit valoir zéro ? Et si on avait différents scénarios comment pourrait-on les décrire et différencier ? Comment distinguer la consigne utile du reste des instructions générique, comme _en répondant `John` et `Doe` manuellement_, qui ne devrait pas apparaire si le scénario a pu être automatisé?
Ce qui peut être clair sur le langage naturel pour les humains du découpage mentale des informations, devient une tâche impossible pour un parseur qui doit être prédictible et rapide (on exclut l'usage de l'intelligence artificielle pour ces raisons).

De plus, ce format possède plusieurs parties qui demandent plus de travail à la rédaction. Le code de la solution est développé dans un fichier `main.c` séparé et doit être copié manuellement. Une partie du texte comme _Assure toi d'avoir la même sortie que ce scénario_ est générique et doit pourtant être constamment répétée à chaque exercice pour introduire le snippet. L'output est à maintenir à jour avec le code de la solution, si celle-ci évolue, on risque d'oublier de mettre à jour la consigne de l'exercice.

Dans le contexte du développement de PLX, la manière la plus rapide et facile à mettre en place serait simplement de définir un schéma JSON à respecter. On aurait d'abord un champ pour le titre (sous la clé `exo` pour raccourcir le mot `exercice`) et la consigne.

Ensuite une liste de checks serait fournie. Chaque check serait défini par un titre et une séquence d'opérations à effectuer. Chaque opération serait de type `see` (ce que l'on s'attend à "voir" dans l'output), `type` (ce qu'on tape dans le terminal) et finalement `exit` (pour définir le code d'exit attendu). Il serait pratique de définir cette séquence dans un objet, avec en clé `see`, `type` ou `exit` et en valeur, un paramètre. Comme les clés des objets en JSON n'ont pas d'ordre et doivent être uniques @JsonRfcIntro, nous ne pourrions pas répéter plusieurs étapes `see`. Nous devons décrire la séquence comme un tableau d'objets. Voici un exemple d'usage de ce schéma sur le @exemple-dy-json.

#figure(raw(block: true, lang: "json", read("../sources/plx-dy-simple.json")), caption: [Equivalent JSON de l'exercice défini sur le @exemple-dy-md-start]) <exemple-dy-json>

Cet exemple d'exercice en @exemple-dy-json est minimal, mais montre clairement que rédiger dans ce format serait fastidieux. Si la consigne s'étalait sur plusieurs lignes, nous aurions du remplacer manuellement les retours à la ligne par des `\n`. Au-delà du texte brut, tous les guillemets, deux points, crochets et accolades nécessaires demande un effort de rédaction important.

Un autre format plus léger à rédiger est le YAML, regardons ce que cela donne:

#figure(raw(block: true, lang: "yaml", read("../sources/plx-dy-simple.yaml")), caption: [Equivalent YAML de l'exercice défini sur le @exemple-dy-md-start]) <exemple-dy-yaml>

Le YAML nous a permis ici de retirer tous les guillemets, les accolades et crochets. Cependant, malgré sa légereté, il contient encore plusieurs points de friction:
- Les tirets sont nécessaires pour chaque élément de liste et les deux points pour chaque clé
- Pour avoir plus d'une information par ligne, il faut ajouter une paire d'accolades autour des clés (`- { kind: see, value: Passe une belle journée John Doe ! }`)
- Les tabulations sont difficiles à gérer dès qu'on dépasse 3-4 niveaux, elles sont aussi nécessaires sur du contenu multiligne
- Certaines situations nécessitent encore des guillemets autours des chaines de caractères

L'intérêt clair du YAML, tout comme le JSON est la possibilité de définir des pairs de clés/valeurs, ce qui n'est pas possible en Markdown. On pourrait définir une convention par dessus Markdown: définir qu'un titre de niveau 1 est le titre de l'exercice, qu'un bloc de code sans langage défini est l'output ou encore que le texte entre le titre et l'output est la consigne. Quand on arrive sur des champs plus spécifiques aux exercices de programmation, cela se corce un peu: comment définir le code d'exit attendu, définir la commande pour stopper un programme, ou encore définir les parties de l'output qui sont des entrées utilisateurs ?

#pagebreak()

Pour résoudre ces problèmes, nous proposons une nouvelle syntaxe, nommée DY, à mi-chemin entre le Markdown et le YAML, concise et compacte. Pour les clés, on définit un système de préfixe qui permet de structurer le contenu de l'exercice. On reprend les idées de `see`, `type`, et `exit`. Voici un exemple en @exemple-dy.

#figure(
  image("../sources/plx-dy-simple.svg", width:70%),
  caption: [Equivalent de l'exercice du @exemple-dy-md-start, dans une version préliminaire de la syntaxe DY],
) <exemple-dy>

Dans cette syntaxe, plus de tabulation, de deux points, juste des informations séparées ligne par ligne, avec un préfixe avant chaque nouveau champ. La consigne est définie dans la suite du titre et peut s'étendre sur plusieurs lignes. Le Markdown est toujours supportés dans le titre et la consigne.

Ce deuxième défi demande d'écrire un parseur de cette nouvelle syntaxe. Ce n'est que la première étape, car lire du texte structuré blanc sur fond noir sans aucune couleur, sans feedback sur la validité du contenu, mène à une expérience un peu froide. En plus du parseur, il est indispensable d'avoir un support solide dans les IDE modernes pour proposer une expérience d'édition productive.

#figure(
  image("../schemas/ide-experience-mental-model-simple.png", width:100%),
  caption: [Aperçu de l'expérience imaginée de rédaction imaginée dans un IDE],
) <ide-xp>

On voit dans la @ide-xp que l'intégration consiste en deux parties principales
+ le surlignage de code, qui permet de coloriser les préfixes et les propriétés, afin de bien distinguer les préfixes et contenu
+ intégration avancée des erreurs du parseur et de la documentation à l'éditeur. On le voit en ligne 4 avec l'erreur du nom de check manquant après le préfixe `check`, en ligne 19 avec une auto-complétion qui propose les préfixes valides à cette position du curseur.

Cette nouvelle syntaxe, son parseur et support d'IDE permettront de remplacer le format TOML actuellement utilisé dans PLX.

== Solutions existantes <solutions-existantes>

L'idée de faire des exercices de programmation couverts par des suites de tests automatisées n'est pas nouvelle. Comme mentionné dans l'introduction, PLX est inspiré de Rustlings. Cette TUI propose une centaine d'exercices de Rust avec du code à faire compiler ou des tests à faire passer. Le site web de Rustlings recommende de faire ces exercices en parallèle de la lecture du _Rust book_ (la documentation officielle) @RustlingsWebsite.
#figure(
  image("../imgs/rustlings-demo.png", width: 80%),
  caption: [Rustlings en action en haut dans le terminal et VSCode en bas],
) <fig-rustlings-demo>

De nombreux autres projets se sont inspirées de ce concept, `clings` pour le C @ClingsGithub, `golings` pour le Go @GolingsGithub, `ziglings` pour Zig @CodebergZiglings et même `haskellings` pour Haskell @HaskellingsGithub ! Ces projets incluent une suite d'exercice et une TUI pour les exécuter pas à pas, afficher les erreurs de compilation ou les cas de tests qui échouent, pour faciliter la prise en main des débutant·es.

Chaque projet se concentre sur un langage de programmation et crée des exercices dédiés. PLX prend une approche différente, il n'y a pas d'exercice proposé et PLX supporte de multiples langages. Le contenu sera géré indépendamment de l'outil, permettant aux enseignant·es d'intégrer leur propre contenu.

Plusieurs plateformes web existent comme CodeCheck, qui permet de fournir un code de solution et d'ajouter des commentaires pour configurer l'exercice. Ainsi un commentaire `//HIDE` va cacher une ligne, `//EDIT` va définir un bloc éditable, `//ARGS` indique des arguments à passer au programme ou encore `//CALL 1 2 3` pour appeler une fonction avec les arguments 1, 2 et 3.

#figure(
  image("../imgs/codecheck-demo.png", width: 70%),
  caption: [Aperçu d'un exercice de Java sur CodeCheck, avec une résultat erroné],
) <fig-codecheck-demo>

Le code est exécuté sur le serveur et l'édition se fait dans la navigateur dans un éditeur simplifié. L'avantage est la simplicité d'usage et le système de pseudo commentaires pour configurer l'exercice depuis la solution directement. Comme désavantage par rapport à PLX c'est le temps de compilation qui est plus lent que localement et l'expérience d'édition en ligne reste trop minimale pour passer des heures sur des exercices. Chaque exercice a son propre URL pour l'édition et un autre pour l'entrainement, ce qui peut rendre fastidieux le déploiement de dizaines d'exercices à la chaine.

Ces solutions existantes sont intéressantes mais ne couvrent qu'une partie des besoins de PLX.

#pagebreak()
// todo move that somewhere useful once we have bottom page notes
== Glossaire
L'auteur de ce travail se permet un certain nombre d'anglicismes quand un équivalent français n'existe pas . Certaines constructions de programmations bien connues comme les `strings` au lieu d'écrire `chaînes de caractères` sont également utilisées. Certaines sont spécifiques à certains langages et sont décrites ci-dessous pour aider à la lecture.

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
