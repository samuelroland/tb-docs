= État de l'art

Cette section explore l'état de l'art de cinq sujets liés aux deux défis de ce travail. Avant de développer la syntaxe DY, une recherche est faite autour des *syntaxes existantes moins répandues* qui ont des objectifs proches à la notre. *Les librairies de parsing* en Rust sont discutées ensuite pour comprendre si elles peuvent nous aider à l'implémentation du parseur. Pour inclure la compréhension du parseur directement dans les IDE, nous verrons comment *les serveurs de language* permettent d'améliorer grandement l'expérience d'édition. Nous parlerons également des techniques de *surlignage de code*, dans les IDEs et sur le web, qui permettent de rendre notre syntaxe agréable à lire.

Pour conclure ces recherches, le défi du serveur de session live a demandé d'explorer les *protocoles de communication bidirectionnels*, pour nous permettre d'envoyer et recevoir des messages en temps réel. Ce dernier sujet inclut aussi une comparaison entre *formats textes et binaires de sérialisation* des messages.

En plus de la comparaison des solutions existantes, quelques *POCs* ont été développés pour découvrir et tester le fonctionnement des solutions choisies. Les POC ont été implémenté dans le dossier `pocs` du repository Git de la documentation du projet. Ce dossier est accessible sur #link("https://github.com/samuelroland/tb-docs/tree/main/pocs")
// todo lien en bibliographie aussi ?

// TODO: lien qqepart des 2-3 repos ?


== Format de données humainement éditables existants
Avant de commencer ce travail conséquent de créer une nouvelle syntaxe, il est nécessaire de s'assurer qu'il n'existe pas d'autres librairies qui existent déjà et qui pourraient apporter la même expérience, simplicité et rapidité de rédaction. Nous avons aussi besoin d'avoir une intégration Rust puisque PLX est développé en Rust. Nous cherchons aussi une validation du contenu intégrée à l'éditeur, pour éviter des allers retours constants entre l'éditeur et l'affichage d'erreurs de rédaction dans PLX.

Les parseurs JSON vérifie que le document est correcte mais le choix des clés et valeurs n'est pas vérifié. C'est pour cette raison que le projet JSON Schema @JsonSchemaWebsite existe. Un schéma JSON définit un ensemble de clés valides, les types attendus pour chaque valeur, les champs requis et optionnels. L'intégration de ce projet dans l'IDE permet d'intégrer des erreurs lorsque des structures ne respecte pas le schéma et facilite la rédaction avec l'auto-complétion des clés et valeurs. Nous cherchons une solution qui mixe dans un seul outil la définition de la syntaxe et sa validation.

La recherche se concentre sur les projets qui visent à créer des meilleurse alternatives aux formats bien répandus ou qui ont un lien avec l'éducation. On ignore aussi les projets dont la spécification ou l'implémentation n'est pas encore utilisable en production. Ainsi, le langage de balise pour les recettes de cuisines Cooklang @cooklangMention n'est pas présenté. La recherche n'est pas évidente comme il existe de nombreuses manières de nommer ce que l'on cherche: langage de balise (_markup language_), format de donnée, syntaxe, langage de donnée, langage spécifique à un domaine (_Domain Specific Language_ - DSL), ... La recherche a principalement été faite en anglais avec les mots-clés suivants la barre de recherche de Google, Github.com et de crates.io: `data format`, `syntax`, `human friendly`, `alternative to YAML`, `human writable`, et `human readable`.

=== KHI - Le langage de données universel
D'abord nommée UDL (_Universal Data Language_) @UDLCratesio, cette syntaxe a été inventée pour mixer les possibilités du JSON, YAML, TOML, XML, CSV et Latex, afin de supporter toutes les structures de données modernes. Plus concrètement, les balises, les structures, les listes, les tuples, les tables/matrices, les énumérations et les arbres hiérarchiques sont supportés.

#figure(
```khi
{article}:
uuid: 0c5aacfe-d828-43c7-a530-12a802af1df4
type: chemical-element
key: aluminium
title: Aluminium
description: The <@element>:{chemical element} aluminium.
tags: [metal; common]

{chemical-element}:
symbol: Al
number: 13
stp-phase: <Solid>
melting-point: 933.47
boiling-point: 2743
density: 2.7
electron-shells: [2; 8; 3]

{references}:
wikipedia: \https://en.wikipedia.org/wiki/Aluminium
snl: \https://snl.no/aluminium
```,
    caption: [Un exemple simplifié de KHI tiré du README @KHIGithub\ décrivant un exemple d'article d'encyclopédie.],
) <khi-example>

Les objectifs sont la polyvalence, un format source (fait pour être rédigé à la main), l'esthétisme et la simplicité. Le @khi-example permet de percevoir l'intérêt qu'une combinaison plus légère de toutes ces structures de données peut avoir. Cependant, PLX n'a pas besoin d'autant de possibilités, les différents séparateurs `@`, `{`, `;`, `[`, `\`, etc. sont nécessaires pour que le parseur puisse différencier ces structures, mais créent une charge mentale additionnelle durant la rédaction. De plus, une implémentation en Rust est proposée @KHIRSGithub mais son dernier commit date du 11.11.2024, en plus du fait que le projet contient encore de nombreux `todo!()` dans son code.

=== Bitmark - le standard des contenus éducatifs digitaux
De nombreux formats de données existent pour décrire du contenu éducatif digital au vu de toutes les plateformes existantes autour de l'éducation et de l'enseignement. Cette diversité de formats rend l'interopérabilité très difficile, freine l'accès à la connaissance. Ces limites restreignent les créateurs de contenus et les éditeurs dans les possibilités de migration entre plateformes ou de publication du même contenu à différents endroits.

Bitmark est un standard open-source @bitmarkLicense, qui vise à uniformiser tous ces formats pour améliorer l'interopérabilité @bitmarkAssociation. Leur stratégie est de définir un format basé sur le contenu (_Content-first_) plutôt que son rendu (_Layout-first_) permettant de supporter un affichage sur un maximum de plateformes, incluant les appareils mobiles @bitmarkAssociation. C'est la Bitmark Association en Suisse à Zurich qui développe ce standard, notamment à travers des Hackatons organisés en 2023 et 2024 @bitmarkAssociationHackaton.

Le standard permet de décrire du contenu statique, comme des articles, et du contenu interactif comme des quiz de divers formats. Deux équivalents sont définis : le _bitmark markup language_ et le _bitmark JSON data model_ @bitmarkDocs. La partie quiz du standard inclut des textes à trous, des questions à choix multiple, du texte à surligner, des essais, des vrai/faux, des photos à prendre, des audios à enregistrer et de nombreux autres types d'exercices.

#figure(
```
[.multiple-choice-1]
[!What color is milk?]
[?Cows produce milk.]
[+white]
[-red]
[-blue]
```, caption: [Un exemple de question à choix multiple tiré de leur documentation @bitmarkDocsMcqSpec. #linebreak() L'option correcte `white` est préfixée par `+` et les 2 autres options incorrectes par `-`. #linebreak()Plus haut, `[!...]` décrit une consigne, `[?...]` décrit un indice.]
)
<mcq-bitmark>

#figure(
```json
{
    "markup": "[.multiple-choice-1]\n[!What color is milk?]\n[+white]\n[-red]\n[-blue]",
    "bit": {
        "type": "multiple-choice-1",
        "format": "text",
        "item": [],
        "instruction": [ { "type": "text", "text": "What color is milk?" } ],
        "body": [],
        "choices": [
            { "choice": "white", "item": [], "isCorrect": true },
            { "choice": "red", "item": [], "isCorrect" : false },
            { "choice": "blue", "item": [], "isCorrect" : false }
        ],
        "hint": [ { "type": "text", "text": "Cows produce milk." } ],
        "isExample": false,
        "example": []
    }
}
```, caption: [Equivalent de @mcq-bitmark dans le Bitmark JSON data model @bitmarkDocsMcqSpec]
)

La plateforme Open Taskpool, qui met à disposition des exercices d'apprentissage de langues @openTaskpoolIntro, fournit une API JSON utilisant le _bitmark JSON data model_.

#figure(
text(size: 0.8em)[
```sh
curl "https://taskpool.taskbase.com/exercises?translationPair=de->en&word=school&exerciseType=bitmark.cloze"
```
] , caption: [Requête HTTP à Open Taskpool pour demander une paire de mots de \ l'allemand vers l'anglais, autour du mot `school` et de format `cloze` (texte à trou).]) <taskpool>

#figure(
```json
"cloze": {
    "type": "cloze",
    "format": "text",
    "instruction": "Gegeben: \"Früher war hier eine Schule.\", schreiben Sie das fehlende Wort",
    "body": [
        { "type": "text", "text": "There used to be a " },
        {
            "type": "gap",
            "solutions": [ "school" ],
            "answer": { "text": "" }
        },
        { "type": "text", "text": " here." }
    ]
},
```, caption: [Extrait de la réponse au @taskpool, respectant le standard Bitmark @bitmarkDocsClozeSpec. La phrase `There used to be a ___ here.` doit être complétée par `school`, en s'aidant du texte en allemand.]
)
Une autre plateforme, Classtime, utilise Bitmark pour son système d'import et export de questions @classtimeUsingBitmark. On voit dans leur documentation @ClasstimeDocs que le système de création d'exercices reste basé sur des formulaires.

Ces 2 exemples donnent l'impression que la structure JSON est plus utilisée que le _markup_. Au vu de tous séparateurs et symboles de ponctuations à se rappeler,  et la présence d'un équivalent JSON, la spécification du _markup_ n'a peut-être pas été optimisée pour la rédaction à la main directement. En plus, Bitmark ne spécifie pas de type d'exercices programmation nécessaires à PLX. On salue au passage l'envie de standardiser le format des différentes plateformes, à long-terme cela ne peut que simplifier la vie des enseignant·es dans la gestion de leur contenu et augmenter la qualité de la pratique des étudiant·es.

=== NestedText — Un meilleur JSON
NestedText se veut _human-friendly_, similaire au JSON, mais pensé pour être facile à modifier et visualiser par les humains. Le seul type de donnée scalaire supporté est la chaîne de caractères, afin de simplifier la syntaxe et retirer les guillemets @nestedTextGithub. En plus des types de données restreints, l'autre différence avec le YAML est la facilité d'intégrer des morceaux de code sans échappements ni guillemets, les caractères de données ne peuvent pas être confondus avec NestedText @nestedTextVsYaml.

#figure(
```
Margaret Hodge:
    position: vice president
    address:
        > 2586 Marigold Lane
        > Topeka, Kansas 20682
    phone: 1-470-555-0398
    email: margaret.hodge@ku.edu
    additional roles:
        - new membership task force
        - accounting task force
```,
  caption: [Exemple tiré de leur README @nestedTextGithub ]
)

Les tabulations restent nécessaires pour définir la hiéarchie. Tout comme le JSON la validation du contenu n'est géré que par des librairies externes qui vérifient la validité à l'aide d'un schéma @nestedTextSchemasLib. De plus, l'implémentation officielle est en Python et il n'en existe pas pour le Rust. Il existe une crate réservée qui est restée vide @nestedTextRsCrateEmpty.

#pagebreak()

=== SDLang - Simple Declarative Language

SDLang se définit comme "une manière simple et concise de représenter des données textuellement. Il a une structure similaire au XML : des tags, des valeurs et des attributs, ce qui en fait un choix polyvalent pour la sérialisation de données, des fichiers de configuration ou des langages déclaratifs." (Traduction personnelle de leur site web @sdlangWebsite). SDLang définit également différents types de nombres (32 bits, 64 bits, entiers, flottants...), 4 valeurs de booléens (`true`, `false`, `on`, `off`), différents formats de dates et un moyen d'intégrer des données binaires encodées en Base64.

#figure(
```
// This is a node with a single string value
title "Hello, World"

// Multiple values are supported, too
bookmarks 12 15 188 1234

// Nodes can have attributes
author "Peter Parker" email="peter@example.org" active=true

// Nodes can be arbitrarily nested
contents {
  section "First section" {
    paragraph "This is the first paragraph"
    paragraph "This is the second paragraph"
  }
}

// Anonymous nodes are supported
"This text is the value of an anonymous node!"

// This makes things like matrix definitions very convenient
matrix {
  1 0 0
  0 1 0
  0 0 1
}
```,
  caption: [Exemple de SDLang tiré de leur site web @sdlangWebsite]
) <sdl>

Cet exemple en @sdl est intéressant par le faible nombre de caractères réservés et la densité d'information. Il s'approche de ce qui avait été imaginé sur la syntaxe DY, dans l'introduction en @exemple-dy. En YAML, trois lignes auraient été nécessaires à définir l'auteur avec son nom, email et un attribut booléen. En SDLang une seule ligne suffit: `author "Peter Parker" email="peter@example.org" active=true`. Les neuf valeurs de la matrice sont définie sur seulement cinq lignes, avec l'espace comme séparateur.

Il est regrettable que les strings doivent être entourées de guillemets. Le texte brut sur plusieurs lignes (comme du code) doit être entouré de backticks ``` ` ``` @sdlangWebsiteReferenceStrings. De même, la définition de la hiérarchie d'objets nécessite d'utiliser une paire d'accolades.

=== KDL - Cuddly Data language

#figure(
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
```,
  caption: [Exemple de KDL simplifié tiré de leur site web @kdlWebsite]
) <kdl>
Si l'exemple en @kdl paraît proche de SDLang, c'est normal puisque KDL est un fork de SDLang. Les améliorations qui nous intéressent concernent la possibilité de retirer des guillemets pour les strings sans espace (`person name=Samuel` au lieu de `person name="Samuel"`). Cette simplification n'inclut malheureusement pas le texte multiligne, qui demande d'être entourée par `"""`. Le problème d'intégration de morceaux de code entre #raw("`") pour certains langages qui utilisent ce symbole (comme Bash), a été relevé par l'auteur du fork dans la FAQ. Le text brut est ainsi supportée avec un `#` ajouté autour des guillemets, par exemple `regex #"\d{3} "[^/"]+""#` ou dans la @kdl avec le noeud `build`. Une répétition des `#` permet d'inclure ce caractère littéral pour éviter tout besoin d'échappement. Par exemple `msg ##"hello#"john"##` contient un noeud `msg` avec la valeur `hello#"john` @kdlWebsite.

En dehors des autres désavantages déjà évoqués pour SDLang, il reste toujours le problème des types de nombres qui peuvent créer des ambiguités avec le texte. C noeud `version 1.2.3` est interprété comme nombre à virgule avec une erreur de format, il a besoin de guillemets `version "1.2.3"` pour indiquer que ce n'est pas un nombre.

=== Conclusion
En conclusion, au vu du nombre de tentatives/variantes existantes, qui va au delà de ce qui a été documenté dans ce rapport, on voit que la verbosité des formats largement répandus du XML, JSON et même du YAML est un problème identifié par plusieurs personnes. Même Apple a fait son propre format de configuration, le Pkl qui mixe des constructions de programmation et de données pour la validation des fichiers @PklLangWebsite.

La diminution de la verbosité des syntaxes décrites précédement est intéressante mais elles ciblent des usages plus avancés que nécessaire pour PLX. Parfois on y gagne à éviter des guillemets, parfois d'autres séparateurs, on rend l'information plus dense... Mais le besoin d'exprimer de la hiérachie sans tabulations ni accolades perdure, tout comme celui de la validation intégrée. Notre syntaxe DY souhaite proposer une approche encore plus légère, en représentant moins de chose pour simplifier encore la rédaction.

#pagebreak()
== Librairies de parsing en Rust
// todo mieux expliquer le challenge
Après s'être intéressé aux syntaxes existantes, nous nous intéressons maintenant aux solutions pour simplifier le développement du parseur DY. Après quelques recherches avec le tag `parser` sur crates.io @cratesIoParserTagsList, j'ai trouvé la liste de librairies suivantes :

- `nom` @nomCratesio, utilisé notamment par `cexpr` @nomRevDeps
- `winnow` @winnowCratesio, fork de `nom`, utilisé notamment par le parseur Rust de KDL @kdlrsDeps
- `pest` @pestCratesio
- `combine` @combineCratesio
- `chumsky` @chumskyCratesio

À noter aussi l'existence de la crate `serde` @serders, un framework de sérialisation et desérialisation très populaire dans l'écosystème Rust (selon le site lib.rs @librsMostPopular). Il est notamment utilisé pour les parseurs JSON `serde_json` et TOML `toml`. Ce n'est pas une librairie de parsing mais un modèle de donnée basée sur des _traits_ Rust (des interfaces) pour faciliter le passage d'un arbre syntaxique abstrait (AST) aux structures de données Rust. Le modèle de données de Serde @serdersDatamodel supporte 29 types de données. Trois raisons nous poussent à ne pas construire un parseur compatible avec `serde`:
+ Seulement les strings, listes et structs sont utiles pour PLX. Par exemple, les 12 types de nombres sont inutiles à différencier.
+ La sérialisation (structure Rust vers syntaxe DY) n'est pas prévue, seul la desérialisation nous intéresse
+ L'association des clés et propriétés vers les attributs des structs Rust n'est pas du 1:1. La valeur après `exo` contient le nom de l'exercice puis la consigne, ce qui signifie une seule string pour deux champs `name` et `instruction` dans la structure `Exo` finale.

Parser des simples expressions de math comme `((23+4) * 5)` est idéal pour ces outils: les débuts et fin de chaque partie sont claires, une combinaison de fonctions de parsing permettraient facilement identifier les expressions parenthésées, les opérateurs puis les nombres. Elles semblent bien adaptées à ignorer des espaces, extraire les nombres tant qu'ils contiennent des chiffres, extraire des opérateurs et les deux opérandes autour...

Pour DY, l'aspect multiligne et le fait qu'une partie des clés est optionnelle, rend compliqué l'approche de combinaisons de parseurs.

#figure(
  image("../syntax/examples/long-desc.svg", width: 50%), caption: [Exemple d'exercice PLX en DY, avec une consigne en Markdown sur plusieurs lignes]) <harddymultiline>
// todo check width preview, modified in svg

Le @harddymultiline nous montre une consigne qui démarre après la ligne `exo` et continue sur plusieurs lignes jusqu'à qu'on trouve une autre clé (ici `check`). Le problème se pose aussi avec la clé `see`, qui est aussi multiligne, dont la valeur s'arrête au prochain `see`, `type`, `exit` ou `check`.

La syntaxe DY est relativement simple à parser et sa nature implicite rend compliqué l'usage de librairies pensées pour des formats avec beaucoup de séparateurs. Après ces recherches et quelques essais avec `winnow`, nous avons décidé que l'écriture manuelle du parseur sans librairie serait plus simple.

#pagebreak()
== Les serveurs de langage

Par défaut, avec un nouveau langage, il faut manuellement lancer le compilateur ou le parseur sur son fichier, voir les erreurs et de revenir dans l'éditeur pour les corriger. Certaines opérations répétitives, comme renommer une fonction à chaque appel, doivent être faites à la main. Pour ces raisons, il devient très intéressant d'intégrer un nouveau langage aux différents IDE utilisés dans le monde, mais cela posent de nombreux challenges.

Le support d'un éditeur consiste à intégrer les erreurs du parseur, l'auto-complétion, les propositions de corrections, des informations au survol... et de nombreuses petites fonctionnalités qui améliorent l'expérience de rédaction. L'avantage d'avoir les erreurs de compilation directement soulignées dans l'éditeur c'est de pouvoir voir les erreurs dans leur contexte et de corriger immédiatement les problèmes. Supporter chaque éditeur de code indépendamment signifie travailler avec des API légèrement différentes pour faire la même chose et utiliser plusieurs langages de programmation différents.

Les développeur·euses de nouveaux IDE font face à un défi similaire mais encore plus large, celui de supporter des centaines de langages pour qu'un maximum de monde puisse développer avec. Microsoft était face au même problème pour son éditeur VSCode et a inventé un protocole, nommé `Language Server Protocol (LSP)` @lspWebsite. Ce protocole définit un pont commun entre un client LSP implémenté à l'interne de chaque IDE et un serveur LSP, appelé serveur de langage (_language server_). L'IDE peut ainsi demander de manière unique des informations, tel que _Donne moi les résultats d'auto-complétion pour le curseur a tel position_ sans devoir supporter des détails du langage édité. Le projet a pour but de simplifier la vie des développeur·euses de nouveaux langages et des nouveaux éditeurs qui peuventt intégrer rapidement des centaines de langages en implémentant "juste" un client LSP.

Les serveurs de langages tournent dans des processus séparés de l'éditeur, ce qui permet de ne pas imposer de langage de programmation. Le client LSP se charge de lancer le processus du serveur, de lancer des requêtes et d'intégrer les données des réponses dans leur interface visuelle. Les serveurs de langage n'ont aucune idée de l'éditeur qui leur demande des informations et ils n'en ont pas besoin puisque le protocole définit les réponses attendues en retour.

#figure(
  image("../imgs/neovim-autocompletion-example.png", width: 70%),
  caption: [Exemple d'auto-complétion dans Neovim, générée par le serveur de langage `rust-analyzer` sur l'appel d'une méthode sur les `&str`],
) <fig-neovim-autocompletion-example>

Un serveur de langage n'a pas besoin d'implémenter toutes les fonctionnalités du protocole. Un système de capacités (_Capabilities_) est défini pour annoncer les méthodes implémentées @lspCapabilities. Nous pourrons ainsi implémenter que la petite partie du protocole qui nous intéresse.

Le protocole *JSON-RPC* (_JSON Remote Procedure Call_) est utilisé comme protocole de communication. Similaire au HTTP, il possède des entêtes et un corps. Ce standard définit quelques structures de données à respecter. Une requête doit contenir un champ `jsonrpc`, `id`, `method` et optionnellement `params` @jsonrpcSpec. L'`id` sert à associer une réponse à une requête. Il est aussi possible d'envoyer une notification, c'est à dire une requête qui n'attend de réponse. Le champ `method` va indiquer l'action à appeler. Le transport des messages JSON-RPC peut se faire en `stdio` (flux standards d'entrée/sortie), sockets TCP ou même en HTTP.

// todo vraiment utile ce morceau du coup ??
#figure(
```
Content-Length: ...\r\n
\r\n
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "textDocument/completion",
    "params": {
        ...
    }
}
```,
  caption: [Exemple de requête JSON-RPC du client pour demander des propositions d'auto-complétion (`textDocument/completion`). Tiré de la spécification @lspCompletionExample],
) <jsonRpcExample>

Quelques exemples de serveurs de langages implémentés en Rust
- `rust-analyzer`, serveur de langage officiel du langage Rust
- `tinymist`, serveur de langage de Typst (système d'édition de document, concurrent du Latex, utilisé pour la rédaction de ce rapport)
- `asm-lsp` @AsmLspCratesio, permet d'inclure des erreurs dans du code assembleur

D'autres exemples de serveurs de langages implémentés dans d'autres langages
- `jdtls` le serveur de langage pour Java implémenté en Java @EclipseJdtlsGithub
- `tailwindcss-language-server`, le serveur de langage pour le framework TailwindCSS, implémenté en TypeScript @TailwindcssIntellisenseGithub
- `typescript-language-server` pour TypeScript, implémenté en TypeScript également @TypescriptLanguageServerGithub
- et beaucoup d'autres...


=== Adoption
Selon la liste sur le site de la spécification @lspClientsList, la liste des IDE qui supportent le LSP est longue : Atom, Eclipse, Emacs, GoLand, Intellij IDEA, Helix, Neovim, Visual Studio, VSCode bien sûr et d'autres. La liste des serveurs LSP @lspServersList quant à elle, contient plus de 200 projets, dont 40 implémentés en Rust ! Ce large support et ces nombreux exemples faciliteront le développement de ce serveur de langage et son intégration dans différents IDE.

=== Librairies disponibles
Pour ne pas devoir réimplémenter la mise en place d'un serveur, il existe plusieurs crates qui prennent en charge une partie des parties du protocole commune à tous les langages, comme l'initialisation de la communication.

En cherchant à nouveau sur `crates.io` sur le tag `lsp`, on trouve différents projets dont `async-lsp` @AsyncLspCratesio utilisée par la même auteure dans `nil` @NilUsingAsyncLspGithub (un serveur de langage pour le système de configuration de NixOS).

Le projet `tinymist` a extrait une crate `sync-ls`, mais le README déconseille son usage et conseille `async-lsp` à la place @tinymistSyncLspImpl. En continuant la recherche, on trouve encore une autre crate `tower-lsp` et un fork `tower-lsp-server` @TowerLspServerCratesio... `rust-analyzer` a également extrait une crate `lsp-server`. Une crate commune à plusieurs projets est `lsp-types` @lspTypesCratesio qui définit les structures de données, comme `Diagnostic`, `Position`, `Range`. Ce projet est utilisé par `lsp-server`, `tower-lsp` et d'autres @lspTypesUses.

=== Choix final
L'auteur travaillant dans Neovim, l'intégration se fera en priorité dans Neovim pour ce travail. L'intégration dans VSCode pourra être fait dans le futur et devrait être relativement simple.

Le choix de `lsp-types` fait sens mais les nombreuses autres crates ne facilitent pas leur choix. Les 2 projets les plus utilisés (en termes de _reverse dependencies_ sur crates.io) sont `lsp-server` (56 projets) @LspServerCratesio et `tower-lsp` (85 projets) @TowerLspCratesio. L'auteur a choisi d'utiliser la crate `lsp-server` étant développé par la communauté Rust, la probabilité d'une maintenance long-terme est plus élevée. L'autre argument est que le projet `tower-lsp` est basée sur des abstractions asynchrones, nous préférons partir sur la version synchrone pour simplifier l'implémentation.

Cette partie est un _nice-to-have_, nous espérons avoir le temps de l'intégrer dans ce travail. Après quelques heures sur le POC suivant, cela semble être assez facile et rapide.

=== POC de serveur de language avec `lsp-server`

La crate `lsp-server` contient un exemple de `goto_def.rs` @gotodefLspserver qui implémente la possibilité de `Aller à la définition` (_Go to definition_), généralement accessible dans l'IDE par un `Ctrl+clic` sur une fonction. Nous avons modifié et exécuté cet exemple puis créé un petit script `demo.fish` qui simule un client et affiche chaque requête. Le client va simplement demander la définition `/tmp/another.rs`

#figure(
  box(image("../imgs/lsp-demo.svg"), width:80%),
  caption: [Exemple de communication entre un client et un serveur LSP de notre POC, _output_ du script `demo.fish` dans le dossier `pocs/lsp-server-demo`],
) <lsp-demo>
// todo comment citer les dossiers de POCs à coté ??

Sur la @lsp-demo les lignes après `CLIENT:` sont envoyés en stdin et celles après `SERVER:` sont reçues en stdout.

Durant l'initialisation, le serveur nous indique qu'il supporte un "fournisseur de définition" avec `definitionProvider` à `true`. Le client envoie ensuite une requête `textDocument/definition`, pour le symbole dans un fichier `/tmp/test.rs` sur la ligne 7 au caractère 23.\ Le serveur répond une position dans le code (de type `Location`) sur le fichier `/tmp/another.rs` la ligne 3 entre les caractères 12 et 25 (la plage est de type `Range`). Une fois la réponse reçue, le client a terminé et demande au serveur de s'arrêter.

Le code qui gère la requête du type `GotoDefinition` est visible en @gotodefrs.
#figure(
  ```rust
  match cast::<GotoDefinition>(req) {
      Ok((id, params)) => {
          let locations = vec![Location::new(
              Uri::from_str("file:///tmp/another.rs")?,
              Range::new(Position::new(3, 12), Position::new(3, 25)),
          )];
          let result = Some(GotoDefinitionResponse::Array(locations));
          let result = serde_json::to_value(&result).unwrap();
          let resp = Response { id, result: Some(result), error: None };
          connection.sender.send(Message::Response(resp))?;
          continue;
      }
      ...
  };
  ```,
  caption: [Extrait de `goto_def.rs` modifié qui retourne un emplacement `Location` dans une réponse `GotoDefinitionResponse`],
) <gotodefrs>

== Surlignage du code

// todo surlignage de code comme terme prioritaire, à refactor

Par défaut un nouveau langage avec une extension de fichier dédiée reste en noir en blanc dans l'IDE. Pour faciliter la lecture, nous souhaitons pouvoir coloriser la majorité du contenu de notre syntaxe, tout en groupant les couleurs par type d'éléments surlignés. Pour notre syntaxe DY, on aimerait que toutes les clés aient la même couleur, tout comme les propriétés qui doivent être toutes colorisés d'une seconde couleur. Les commentaires doivent être grisés.

Le bout de C `printf("salut");` est vu par un système de surlignage de code comme une suite de morceaux d'une certaines catégorie, qu'on appelle _tokens_. Ce bout de code pourrait être subdivisé avec les tokens suivants `printf` (identifiant), `(` (séparateur), `"` (séparateur), `salut` (valeur litérale), `"`, `)` et `;` (séparateur).

Les IDE modernes supportent possèdent des systèmes de surlignage de code (_code highlighting_) et définissent leur propre liste de catégories de tokens, par exemple: séparateur, opérateur, mot clé, variable, fonction, constante, macro, énumération, ... Une fois la catégorie attribuée, il reste encore à définir quel couleur concrète est utilisé pour chaque catégorie. C'est le rôle des thèmes comme Monokai, Darcula, Tokioynight et beaucoup d'autres. Les systèmes de surlignage supporte parfois un rendu web via une version HTML contenant des classes CSS spécifiques à chaque type de token. Des thèmes écrits en CSS peuvent ainsi appliquer leurs couleurs. Le surlignage peut être de type syntaxique (_syntax highlighting_), avec une analyse purement basée sur la présence et l'ordre des tokens, ou sémantique (_semantic highlighting_) après une analyse de la sens du token.
// todo note surlignage syntaxique !

=== Textmate
TextMate est un IDE pour macOS qui a introduit un concept de grammaires. Ces grammaires permettent de définir la manière dont le code doit être tokenisé, à l’aide d'expressions régulières issues de la bibliothèque C Oniguruma (55) @textmateRegex. VSCode s’appuie sur ces grammaires TextMate @vscodeSyntaxHighlighting, tout comme IntelliJ IDEA, qui les utilise pour le Swift, C++ ou Perl qui ne sont pas supportés nativement @ideaSyntaxHighlighting.

Le @textmateexemple montre un exemple de grammaire Textmate décrivant un langage nommé `untitled` avec 4 mots clés (`if`, `while`, `for`, `return`) et des chaines de caractères entre guillemets. Les expressions régulières données en `match`, `begin` et `end` permettent de trouver les tokens dans le document et leur attribué une catégorie (comme `keyword.control.untitled`).
#figure(
```js
{  scopeName = 'source.untitled';
   fileTypes = ( );
   foldingStartMarker = '\{\s*$';
   foldingStopMarker = '^\s*\}';
   patterns = (
      {  name = 'keyword.control.untitled';
         match = '\b(if|while|for|return)\b';
      },
      {  name = 'string.quoted.double.untitled';
         begin = '"';
         end = '"';
         patterns = ( 
            {  name = 'constant.character.escape.untitled';
               match = '\\.';
            }
         );
      },
   );
}
``` , caption: [Exemple de grammaire Textmate tiré de leur documentation @TextMateDocsLanguageGrammars.]) <textmateexemple>

La documentation précise un choix important de conception: "A noter que ces regex sont matchées contre une seule ligne à la fois. Cela signifie qu'il n'est pas possible d'utiliser une pattern qui matche plusieurs lignes. La raison est technique: être capable de redémarrer le parseur à une ligne arbitraire et devoir reparser seulement un nombre minimal de lignes affectés par un changement. Dans la plupart des situations, il est possible d'utiliser le model `begin`/`end` pour dépasser cette limite." @TextMateDocsLanguageGrammars (Traduction personnelle, dernier paragraphe section 12.2).

=== Tree-Sitter

Les expressions régulières sont puissantes mais ont de limites pour représenter 

Tree-Sitter @TreeSitterWebsite se définit comme un "outil de génération de parser et une librairie de parsing incrémentale. Il peut construire un arbre de syntaxe concret (CST) depuis un fichier source et efficacement mettre à jour cet arbre quand le fichier source est modifié." @TreeSitterWebsite (Traduction personnelle)

Rédiger une grammaire Tree-Sitter consiste en l'écriture d'une grammaire en JavaScript dans un fichier `grammar.js`. Le CLI `tree-sitter` va ensuite générer un parseur en C qui pourra être utilisé directement via le CLI `tree-sitter` durant le développement et être facilement embarquée comme librairie C sans dépendance dans n'importe quel type d'application @TreeSitterCreatingParsers @TreeSitterWebsite.

Tree-Sitter est supporté dans Neovim @neovimTSSupport, dans le nouvel éditeur Zed @zedTSSupport, ainsi que d'autres. Tree-Sitter a été inventé par l'équipe derrière Atom @atomTSSupport et est même utilisé sur GitHub, notamment pour la navigation du code pour trouver les définitions et références et lister tous les symboles (fonctions, classes, structs, etc) @TreeSitterUsageGithub.

#figure(
  image("../imgs/tree-sitter-on-github.png", width: 100%),
  caption: [Liste de symboles générées par Tree-Sitter, affichés à droite du code sur GitHub pour un exemple de code Rust de PLX],
) <fig-tree-sitter-on-github>

// todo: make sure enough info here after POC has moved below

#pagebreak()

=== Surlignage sémantique
Le surlignage sémantique (_Semantic highlighting_) est une extension du surlignage syntaxique. Les serveurs de langage peuvent ainsi fournir des tokens sémantiques qui apportent une classification plus fine du langage, que les systèmes syntaxiques ne peuvent pas détecter. @VSCodeSemanticHighlighting

#figure(
  image("../imgs/semantic-highlighting-example.png", width: 100%),
  caption: [Exemple tiré de la documentation de VSCode, démontrant quelques améliorations dans le surlignage. Les paramètres `languageModes` et `document` sont colorisés différemment que les variables locales. `Range` et `Position` sont colorisées commes des classes.#linebreak() `getFoldingRanges` dans la condition est colorisée en tant que fonction ce qui la différencie des autres propriétés. @VSCodeSemanticHighlighting],
) <fig-semantic-highlighting-example>

En voyant la liste des tokens sémantiques possible dans la spécification LSP @LspSpecSemanticTokens, on comprend mieux l'intérêt et les possibilités de surlignage avancé. Par exemple, on trouve des tokens `macro`, `regexp`, `typeParameter`, `interface`, `enum`, `enumMember`, qui seraient difficiles de différencier durant la tokenisation, mais qui peuvent être surligné différemment pour mettre en avant leur différence sémantique.

Sur le @example-c-colors surligné ici uniquement grâce à Tree-Sitter (sans surlignage sémantique) on voit que les appels de `HEY` et `hi` dans le `main` ont les mêmes couleurs alors que l'un est une macro, l'autre une fonction. En effet, à l'appel, il n'est pas possible de les différencier, ce n'est que le contexte plus large que seul le serveur de langage possède, qu'on peut déterminer cette différence.
#figure(
```c
#include <stdio.h>

const char *HELLO = "Hey";
#define HEY(name) printf("%s %s\n", HELLO, name)
void hi(char *name) { printf("%s %s\n", HELLO, name); }

int main(int argc, char *argv[]) {
    hi("Samuel");
    HEY("Samuel");
    return 0;
}
```    ,
    caption: [Exemple de code C `hello.c`, avec macro et fonction surligné de la même manière à l'appel]

) <example-c-colors>

#pagebreak()
Sur le @ts-tree-c-code, on voit que les 2 lignes `hi` et `HEY` sont catégorisés sans surprise comme des fonctions (noeuds `function`, `arguments`, ...).
#figure(
```
(expression_statement ; [7, 4] - [7, 17]
  (call_expression ; [7, 4] - [7, 16]
    function: (identifier) ; [7, 4] - [7, 6]
    arguments: (argument_list ; [7, 6] - [7, 16]
      (string_literal ; [7, 7] - [7, 15]
        (string_content))))) ; [7, 8] - [7, 14]
(expression_statement ; [8, 4] - [8, 18]
  (call_expression ; [8, 4] - [8, 17]
    function: (identifier) ; [8, 4] - [8, 7]
    arguments: (argument_list ; [8, 7] - [8, 17]
      (string_literal ; [8, 8] - [8, 16]
        (string_content))))) ; [8, 9] - [8, 15]
``` , caption: [Aperçu de l'arbre syntaxique concret généré par Tree-Sitter#linebreak()récupéré via `tree-sitter parse hello.c`]
) <ts-tree-c-code>

Si on inspecte l'état de l'éditeur, on peut voir qu'au-delà des tokens générés par Tree-Sitter, le serveur de langage (`clangd` ici), a réussi à préciser la notion de macro au-delà du simple appel de fonction.
#figure(
```
Semantic Tokens
  - @lsp.type.macro.c links to PreProc   priority: 125
  - @lsp.mod.globalScope.c links to @lsp   priority: 126
  - @lsp.typemod.macro.globalScope.c links to @lsp   priority: 127
```, caption: [Extrait de la commande `:Inspect` dans Neovim avec le curseur sur le `HEY`])

Ainsi dans Neovim une fois `clangd` lancé, l'appel de `HEY` prend ainsi la même couleur que celle attribuée sur sa définition.

=== Choix final
L'auteur a ignoré l'option du système de SublimeText. pour la simple raison qu'il n'est supporté nativement que dans SublimeText, probablement parce que cet IDE est propriétaire @SublimeHQEULA. Ce système utilisent des fichiers `.sublime-syntax`, qui ressemble à TextMate @SublimeHQSyntax, mais rédigé en YAML.

*Si le temps le permet, une grammaire sera développée avec Tree-Sitter pour supporter du surlignage dans Neovim.*

Le choix de ne pas explorer plus les grammaires Textmate, laisse penser que l'auteur du travail délaisse complètement VSCode. Ce qui parait étonnant comme VSCode est régulièrement utilisé par 73% des 65,437 répondants au sondage de StackOverflow 2024 @StackoverflowSurveyIDE.

Cette décision se justifie notamment par la roadmap de VSCode: entre mars et mai 2025 @TSVSCodeWorkStart @TSVSCodeWorkNow, du travail d'investigation autour de Tree-Sitter a été fait pour explorer les grammaires existantes et l'usage de surlignage de code dans VSCode @ExploreTSVSCodeCodeHighlight. Des premiers efforts d'exploration avait d'ailleurs déjà eu lieu en septembre 2022 @EarlyTSVSCodeExp.

L'usage du surlignage sémantique n'est pas au programme de ce travail mais pourra être exploré dans le futur si certains éléments sémantiques pourraient en bénéficier.

=== POC de surlignage de notre syntaxe avec Tree-Sitter
Ce POC vise à prouver que l'usage de Tree-Sitter fonctionne pour coloriser les clés et les propriétés de @exo-dy-ts-poc pour ne pas avoir cet affichage noir sur blanc qui ne facilite pas la lecture.
#figure(
```
// Basic MCQ exo
exo Introduction

opt .multiple
- C is an interpreted language
- .ok C is a compiled language
- C is mostly used for web applications
```,
  caption: [Un exemple de question choix multiple dans un fichier `mcq.dy`, décrite avec la syntaxe DY. Les clés sont `exo` (titre) et `opt` (options). Les propriétés sont `.ok` et `.multiple`.]
) <exo-dy-ts-poc>

Une fois la grammaire mise en place avec la commande `tree-sitter init`, il suffit de remplir le fichier `grammar.js`, avec une ensemble de règles construites via des fonctions fournies par Tree-Sitter et des expressions régulières. `seq` indique une liste de tokens qui viendront en séquence, `choice` permet de tester plusieurs options à la même position. On remarque également la liste des clés et propriétés insérés dans les tokens de `prefix` et `property`. La documentation *The Grammar DSL* de la documentation explique toutes les options possibles en détails @TreeSitterGrammarDSL.
#figure(
```js
module.exports = grammar({
  name: "dy",
  rules: {
    source_file: ($) => repeat($._line),
    _line: ($) =>
      seq( choice($.commented_line, $.prefixed_line, $.list_line, $.content_line), "\n"),
    prefixed_line: ($) =>
      seq($.prefix, optional(repeat($.property)), optional(seq(" ", $.content))),
    commented_line: (_) => token(seq(/\/\/ /, /.+/)),
    list_line: ($) =>
      seq($.dash, repeat($.property), optional(" "), optional($.content)),
    dash: (_) => token(prec(2, /- /)),
    prefix: (_) => token(prec(1, choice("exo", "opt"))),
    property: (_) => token(prec(3, seq(".", choice("multiple", "ok")))),
    content_line: ($) => $.content,
    content: (_) => token(prec(0, /.+/)),
  },
});
``` , caption: [Résultat de la grammaire minimaliste `grammar.js`, définissant un ensemble de règles sous `rules`.]
) <grammar-js-poc>

On observe dans le @grammar-js-poc plusieurs règles : 
- `source_file`: décrit le point d'entrée d'un fichier source, défini comme une répétition de ligne.
- `_line`: une ligne est une séquence d'un choix entre 4 types de lignes qui sont chacune décrites en dessous et un retour à la ligne
- `prefixed_line`: une ligne préfixée consiste en séquence de token composé d'une clé en préfixe, puis optionnellement d'un ou plusieurs propriétés. Elle se termine optionnellement par un contenu qui commence après un premier espace
- `commented_line` définit les commentaires comme `//` puis un reste
- `list_line`, `dash` et le reste des règles suivent la même logique de définition

Après avoir appelé `tree-sitter generate` pour générer le code du parser C et `tree-sitter build` pour le compiler, on peut demander au CLI de parser un fichier donné et afficher le CST. Dans cet arbre qui démarre avec son noeud racine `source_file`, on y voit les noeuds du même type que les règles définies précédemment, avec le texte extrait dans la plage de caractères associée au noeud. Par exemple, on voit que l'option `C is a compiled language` a bien été extraite à la ligne 5, entre le byte 6 et 30 (`5:6  - 5:30`) en tant que `content`. Elle suit un token de `property` avec notre propriété `.ok` et le tiret de la règle `dash`.

#figure(
  image("../imgs/tree-sitter-cst.svg", width: 70%),
  caption: [Concrete Syntax Tree généré par la grammaire définie sur le fichier `mcq.dy`],
)

La tokenisation fonctionne bien pour cet exemple, chaque élément est correctement découpé et catégorisé. Pour voir ce snippet en couleurs, il nous reste deux choses à définir. La première consiste en un fichier `queries/highlighting.scm` qui décrit des requêtes de surlignage sur l'arbre (_highlights query_) permettant de sélectionner des noeuds de l'arbre et leur attribuer un nom de surlignage (_highlighting name_). Ces noms ressemblent à `@variable`, `@constant`, `@function`, `@keyword`, `@string`... et des versions plus spécifiques comme `@string.regexp`, `@string.special.path`. Ces noms sont ensuite utilisés par les thèmes pour appliquer un style.

#figure(
```scm
(prefix) @keyword
(commented_line) @comment
(content) @string
(property) @property
(dash) @operator
``` , caption: [Aperçu du fichier `queries/highlights.scm`])

Le CLI supporte directement la configuration d'un thème via son fichier de configuration, on reprend simplement chaque nom de surlignage en lui donnant une couleur.
#figure(
```json
{
    "parser-directories": [ "/home/sam/code/tree-sitter-grammars" ],
    "theme": {
        "property": "#1bb588",
        "operator": "#20a8c3",
        "string": "#1f2328",
        "keyword": "#20a8c3",
        "comment": "#737a7e"
    }
}
```, caption: [Contenu du fichier de configuration de Tree-Sitter#linebreak()présent sur Linux au chemin `~/.config/tree-sitter/config.json`])

#figure(
  box(image("../imgs/mcq.svg"), width:50%),
  caption: [Screenshot du résultat de la commande #linebreak() `tree-sitter highlight mcq.dy` avec notre exercice surligné]
)

L'auteur de ce travail s'est inspiré de l'article *How to write a tree-sitter grammar in an afternoon* @SirabenTreeSitterTuto pour ce POC.
// todo comment citer ??
Le résultat de ce POC est encourageant, même s'il faudra probablement plus que quelques heures pour gérer les détails, comprendre, tester et documenter l'intégration dans Neovim, cette partie nice to have a des chances de pouvoir être réalisée dans ce travail au vu du résultat atteint avec ce POC.

Le surlignage sémantique pourrait être utile en attendant l'intégration de Tree-Sitter dans VSCode. L'extension `tree-sitter-vscode` en fait déjà une intégration avec cette approche, qui est beaucoup plus lente qu'une intégration native, mais qui fonctionne. À noter que l'extension n'est pas triviale à installer et configurer, qu'on peut considérer son usage encore expérimental. Elle nécessite d'avoir un build WASM de notre parseur Tree-Sitter @TreeSitterVscodeGithub.
#figure(
  image("../imgs/tree-sitter-vscode-ext-demo.png", width: 60%),
  caption: [Screenshot dans VSCode une fois l'extension `tree-sitter-vscode` configuré, le surlignage est fait via notre syntaxe Tree-Sitter via ],
) <fig-tree-sitter-vscode-ext-demo>

#pagebreak()

== Protocoles de communication bidirectionnels et formats de sérialisation
Le serveur de gestion de sessions live a besoin d'un système de communication bidirectionnelle en temps réel, afin de transmettre le code et les résultats des étudiants. Ces messages seront transformés dans un format standard, facile à sérialiser et désérialiser en Rust. Cette section explore les formats textuels et binaires disponibles, ainsi que les protocoles de communication bidirectionnelle.

=== JSON
Contrairement à toutes les critiques relevées précédemment sur le JSON et d'autres formats, dans leur usage en tant que format source, JSON est une option solide pour la communication client-serveurs. Le format JSON est très populaire pour les API REST, les fichiers de configuration, et d'autres usages.
// todo okay ces affirmations ? pas besoin de présenter plus ?

#figure(
```rust
use serde::{Deserialize, Serialize};
use serde_json::Result;

#[derive(Serialize, Deserialize)]
struct Person {
    name: String,
    age: u8,
    phones: Vec<String>,
}
// ...
let data = r#" {
        "name": "John Doe",
        "age": 43,
        "phones": [ "+44 1234567", "+44 2345678" ]
    }"#;
let p: Person = serde_json::from_str(data).unwrap();
println!("Please call {} at the number {}", p.name, p.phones[0]);
```, caption: [Exemple simplifié de parsing de JSON, tiré de leur documentation @DocsRSSerdeJson.])

#figure(
```rust
use serde_json::json;

fn main() {
    // The type of `john` is `serde_json::Value`
    let john = json!({
        "name": "John Doe",
        "age": 43,
        "phones": [ "+44 1234567", "+44 2345678" ]
    });
    println!("first phone number: {}", john["phones"][0]);
    println!("{}", john.to_string());
}
```
    ,
    caption: [Autre exemple de sérialisation vers JSON d'une structure arbitraire.#linebreak()Egalement tiré de leur documentation @DocsRSSerdeJsonConJsonVal.]

)

En Rust, avec `serde_json`, il est simple de parser du JSON dans une struct. Une fois la macro `Deserialize` appliquée, on peut directement appeler `serde_json::from_str(json_data)`.
=== Protocol Buffers - Protobuf
Parmi les formats binaires, on trouve Protobuf, un format développé par Google pour sérialiser des données structurées, de manière compacte, rapide et simple. L'idée est de définir un schéma dans un style non spécifique à un langage de programmation, puis de génération automatiquement du code pour interagir avec ces structures depuis du C++, Java, Go, Ruby, C\# et d'autres. @ProtobufWebsite

#figure(
```proto
edition = "2023";

message Person {
  string name = 1;
  int32 id = 2;
  string email = 3;
}
```, caption: [Un simple exemple de description d'une personne en ProtoBuf#linebreak()tiré de leur site web @ProtobufWebsite.])


#figure(
```java
Person john = Person.newBuilder()
    .setId(1234)
    .setName("John Doe")
    .setEmail("jdoe@example.com")
    .build();
output = new FileOutputStream(args[0]);
john.writeTo(output);
``` , caption: [Et son usage en Java avec les classes autogénérées à la compilation#linebreak()tiré de leur site web @ProtobufWebsite.])

Le langage Rust n'est pas officiellement supporté, mais un projet du nom de PROST! existe @ProstGithub et permet de générer du code Rust depuis des fichiers Protobuf.

=== MessagePack
Le slogan de MessagePack, format binaire de sérialisation: "C'est comme JSON, mais rapide et léger" (Traduction personnelle). Une implémentation en Rust du nom de RPM existe @DocsRmp.

//todo un exemple ou pas ?

=== Websocket
Le protocole Websocket, définie dans la RFC 6455 @WSRFC, permet une communication bidirectionnelle entre un client et un serveur. A la place de l'approche de requête-réponses du HTTP, le protocole Websocket définit une manière de garder une connexion TCP ouverte et un moyen d'envoyer des messages dans les 2 sens.
On évite ainsi d'ouvrir plusieurs connexions HTTP, une nouvelle à chaque fois qu'un événement se produit ou que le client veut vérifier si le serveur n'a pas d'événements à transmettre. La technologie a été pensée pour être utilisée par des applications dans les navigateurs, mais fonctionne également en dehors @WSRFC.

La section *1.5 Design Philosophy* explique que le protocole est conçu pour un _minimal framing_ (encadrement minimal autour des données envoyées), juste assez pour permettre de découper le flux TCP en _frame_ (en message d'une durée variable définie) et de distinguer le texte des données binaires. Le texte doit être encodé en UTF-8. @WSRFConepointfive

La section *1.3. Opening Handshake*, nous explique que pour permettre une compatibilité avec les serveurs HTTP et intermédiaires sur le réseau, l'opening handshake (l'initialisation du socket une fois connecté) est compatible avec le format des entêtes HTTP. Cela permet d'utiliser un serveur websocket sur le même port qu'un serveur web, ou d'héberger plusieurs serveurs websocket sur différentes routes par exemple `/chat` et `/news`. @WSRFConepointthree

Dans l'écosystème Rust, il existe plusieurs crate qui implémente le protocole, parfois côté client, côté serveur ou les deux. Il existe plusieurs approches sync (synchrone) et async (asynchrone), nous nous concentrons ici sur une approche sync avec gestion des threads natifs manuelle pour simplifier l'implémentation et les recherches.

La crate `tungstenite` propose une abstraction du protocole qui permet de facilement interagir avec des `Message`, leur écriture `send()` et leur lecture `read()` de façon très simple @TungsteniteCratesio. Elle passe la _Autobahn Test Suite_ (suite de tests de plus de 500 cas pour vérifier une implémentation Websocket) @AutobahnTestsuiteGithub.

#figure(
```rust
use std::net::TcpListener;
use std::thread::spawn;
use tungstenite::accept;

/// A WebSocket echo server
fn main () {
    let server = TcpListener::bind("127.0.0.1:9001").unwrap();
    for stream in server.incoming() {
        spawn (move || {
            let mut websocket = accept(stream.unwrap()).unwrap();
            loop {
                let msg = websocket.read().unwrap();

                // We do not want to send back ping/pong messages.
                if msg.is_binary() || msg.is_text() {
                    websocket.send(msg).unwrap();
                }
            }
        });
    }
}
``` , caption: [Exemple de serveur echo en WebSocket avec la crate `tungstenite`. Tiré de leur README @TungsteniteCratesio])

Une version async pour le runtime Tokio existe également, elle s'appelle `tokio-tungstenite`, si le besoin de passer à un modèle async avec Tokio se fait sentir, nous devrions pouvoir y migrer @TokioTungsteniteCratesio.

Il existe une crate `websocket` avec une approche sync et async, qui est dépréciée et dont le README @WebsocketCratesio conseille l'usage de `tungstenite` ou `tokio-tungstenite` à la place @WebsocketCratesio.

Pour conclure cette section, il est intéressant de relever qu'il existe d'autres crates tel que `fastwebsockets` @FastwebsocketsCratesio à disposition, qui ont l'air de permettre de travailler à un plus bas niveau. Pour faciliter l'implémentation, nous les ignorons pour ce travail.

=== gRPC

gRPC est un protocole basé sur Protobuf, inventé par Google. Il se veut être un système de Remote Procedure Call (RPC - un système d'appel de fonctions à distance), universelle et performant qui supporte le streaming bidirectionnel sur HTTP2. La possibilité de travailler avec plusieurs langages reposent sur la génération automatique de code pour les clients et serveurs permettant de gérer la sérialisation en Protobuf et gérant le transport.

En plus des définitions des messages en Protobuf déjà présentés, il est possible de définir des services, avec des méthodes avec un type de message et un type de réponse.

#figure(
```proto
// The greeter service definition.
service Greeter {
  // Sends a greeting
  rpc SayHello (HelloRequest) returns (HelloReply) {}
}

// The request message containing the user's name.
message HelloRequest {
  string name = 1;
}

// The response message containing the greetings
message HelloReply {
  string message = 1;
}
```
    ,
    caption: [Exemple de fichier .proto définissant 2 messages et un service permettant d'envoyer un nom et de recevoir des salutations en retour. Tiré de leur documentation d'introduction @GrpcDocsIntro]

)

Comme Protobuf, Rust n'est pas supporté officiellement, mais une implémentation du nom de Tonic existe @TonicGithub, elle utilise PROST! mentionnée précédemment pour l'intégration de Protobuf.

Un article de 2019, intitulé *The state of gRPC in the browser* @GrpcBlogStateOfGrpcWeb montre que l'utilisation de gRPC dans les navigateurs web est encore malheureusement mal supportée. En résumé, "il est actuellement impossible d'implémenter la spécification HTTP/2 gRPC dans le navigateur, comme il n'y a simplement pas d'API de navigateur avec un contrôle assez fin sur les requêtes." (Traduction personnelle). La solution a été trouvée à ce problème est le projet gRPC-Web qui fournit un proxy entre le navigateur et le serveur gRPC, faisant les conversions nécessaires entre gRPC-Web et gRPC.

Il reste malheureusement plusieurs limites : le streaming bidirectionnel n'est pas possible, le client peut faire des appels unaires (pour un seul message) et peut écouter une _server-side streams_ (flux de messages venant du serveur). L'autre limite est le nombre maximum de connexions en streaming simultanées dans un navigateur sur HTTP/1.1 fixées à 6 @EventSourceStreamMax, ce qui demande de restructurer ses services gRPC pour ne pas avoir plus de six connexions en _server-side streaming_ à la fois.


=== tarpc
tarpc également développé sur l'organisation GitHub de Google sans être un produit officiel, se définit comme "un framework RPC pour Rust, avec un focus sur la facilité d'utilisation. Définir un service peut être fait avec juste quelques lignes de code et le code boilerplate du serveur est géré pour vous." (Traduction personnelle) @TarpcGithub

tarpc est différent de gRPC et Cap'n Proto "en définissant le schéma directement dans le code, au lieu d'utiliser un langage séparé comme Protobuf. Ce qui signifie qu'il n'y a pas de processus de compilation séparée et pas de changement de contexte entre différents langages." (Traduction personnelle) @TarpcGithub

=== Choix final

Par soucis de facilité de debug, d'implémentation et d'intégration, l'auteur a choisi de rester sur un format textuel et d'implémenter la sérialisation en JSON via la crate mentionnée précédemment `serde_json`. L'expérience existante des websocket de l'auteur, sa possibilité de choisir le format de données, et son solide support dans les navigateurs (au cas où PLX avait une version web un jour), font que ce travail utilisera la combinaison de Websocket et JSON.

gRPC aurait pu aussi être une option comme PLX est en dehors du navigateur, il ne serait pas touché par les limites exprimées. Cependant, cela rendrait plus difficile un support d'une version web de PLX si le projet en avait besoin dans le futur.

Quand l'usage de PLX dépassera des dizaines/centaines d'étudiants connectés en même moment et que la latence sera trop forte ou que les coûts d'infrastructures deviendront un souci, les formats binaires plus légers seront une option à creuser. Au vu des nombreux choix, mesurer la taille des messages, la latence de transport et le temps de sérialisation sera important pour faire un choix. D'autres projets pourraient également être considérés comme Cap'n Proto @CapnprotoWebsite qui se veut plus rapide que Protobuf, ou encore Apache Thrift @ThriftWebsite. Ces dernières options n'ont pas été explorés dans cet état de l'art principalement parce qu'elles proposent un format binaire.

=== POC de synchronisation de messages JSON via Websocket avec tungstenite
Pour vérifier la faisabilité technique d'envoyer des messages en temps réel en Rust via websocket, un petit POC a été développé dans le dossier `pocs/websockets-json`. Le code et les résultats des checks doivent être transmis des étudiants depuis le client PLX des étudiants vers ce lui de l'enseignant, en passant par le serveur de session live.

À cause de sa nature interactive, il n'est pas évident de retranscrire ce qui s'y passe quand on lance le POC dans trois shells côte à côte, le mieux serait d'aller compiler et lancer à la main. Nous documentons ici un aperçu du résultat.

Ce petit programme en Rust prend en argument son rôle (`server`, `teacher` ou `student`), tout le code est ainsi dans un seul fichier `main.rs` et un seul binaire.

Ce programme a la structure suivante, le dossier `fake-exo` contient l'exercice à implémenter.
#figure(
```
.
├── Cargo.lock
├── Cargo.toml
├── fake-exo
│  ├── Cargo.lock
│  ├── Cargo.toml
│  ├── compare_output.txt
│  └── src
└── src
   └── main.rs
``` ,
    caption: [Structure de fichiers du POC.]
)

#figure(
```rust
// Just print "Hello <name> !" where <name> comes from argument 1
fn main() {
    println!("Hello, world!");
}
```,
    caption: [Code Rust de départ de l'exercice fictif à compléter par l'étudiant]
)

Le protocole définit pour permettre cette synchronisation est découpé en 2 étapes.
#figure(
  image("../schemas/websocket-json-poc-arch-announce.png", width: 60%),
  caption: [La première partie consiste en une mise en place par la connexion et l'annonce des clients de leur rôle, en se connectant puis en envoyant leur rôle en string.],
)
#figure(
  image("../schemas/websocket-json-poc-arch-forwarding.png", width: 60%),
  caption: [La deuxième partie consiste en l'envoi régulier du client du résultat du check vers le serveur, qui ne fait que de transmettre au socket associé au `teacher`.],
)

Dans un premier shell (S1), nous lançons en premier lieu le serveur :
#figure(
```
websockets-json> cargo run -q server
Starting server process...
Server started on 127.0.0.1:9120
```,
    caption: [Lancement du serveur et attente de connexions sur le port 9120.]
)

Dans un deuxième shell (S2), on lance le `teacher`:
#figure(
```
websockets-json> cargo run -q teacher
Starting teacher process...
Sending whoami message
Waiting on student's check results
```
    ,
    caption: [Lancement du `teacher`, connexion au serveur et envoi d'un premier message littéral `teacher` pour annoncer son rôle]

)

Dans S1, on voit que le serveur a bien reçu la connexion et a détecté le rôle de `teacher`.
#figure(
```
...
Teacher connected, saved associated socket.
``` , caption: [`teacher` est bien connecté au serveur])

Dans S3, on lance finalement le rôle de l'étudiant :
#figure(
```
websockets-json> cargo run -q student
Starting student process...
Sending whoami message
Starting to send check's result every 2000 ms
Sending another check result
{"path":"fake-exo/src/main.rs","status":{"IncorrectOutput":{"stdout":"Hello, world!\n"}},"code":"// Just print \"Hello <name> !\" where <name> comes from argument 1\nfn main() {\n    println!(\"Hello, world!\");\n}\n"}
```
    ,
    caption: [Le processus `student` compile et execute le check, afin d'envoyer le résultat, ici du type `IncorrectOutput`.]

)

Le @check-result-details nous montre le détail de ce message.
#figure(
```json
{
  "path": "fake-exo/src/main.rs",
  "status": {
    "IncorrectOutput": {
      "stdout": "Hello, world!\n"
    }
  },
  "code": "// Just print \"Hello <name> !\" where <name> comes from argument 1\nfn main() {\n    println!(\"Hello, world!\");\n}\n"
}
```
    ,
    caption: [Le message envoyé avec un chemin de fichier, le code et le statut. Le statut est une enum définie à "output incorrect", puisque l'exercice n'est pas encore implémenté.]
) <check-result-details>

Le serveur sur le S1, on ne voit que le `Forwarded one message to teacher`. Sur le S2, on voit immédiatement ceci:
#figure(
```
Exo check on file fake-exo/src/main.rs, with given code:
// Just print "Hello <name> !" where <name> comes from argument 1
fn main() {
    println!("Hello, world!");
}
Built but output is incorrect
Hello, world!
```, caption: [Le `teacher` a bien reçu le message et peut l'afficher, la synchronisation temps réel a fonctionné.]
)

Si l'étudiant introduit une erreur de compilation, un message avec un statut différent est envoyé, voici ce que reçoit le `teacher`:
#figure(
  ```
  Exo check on file fake-exo/src/main.rs, with given code:
  // Just print "Hello <name> !" where <name> comes from argument 1
  fn main() {
      println!("Hello, world!", args[3]);
  }
  failed build with error
    Compiling fake-exo v0.1.0
  error: argument never used
  --> src/main.rs:3:31
    |
  3 |     println!("Hello, world!", args[3]);
    |              ---------------  ^^^^^^^ argument never used
    |              |
    |              formatting specifier missing
  ```
    ,
    caption: [Le `teacher` a bien reçu le code actuel avec l'erreur et l'output de compilation de Cargo]
)

Le système de synchronisation en temps réel permet ainsi d'envoyer différents messages au serveur qui le retransmet directement au `teacher`. Même si cet exemple est minimal puisqu'il ne vérifie pas la source des messages, et qu'il n'y a qu'un seul étudiant et enseignant impliqué, nous avons démontré que la crate `tungstenite` fonctionne.

