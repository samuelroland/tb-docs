// Temporary document in waiting maturity of the Typst template

#set page(margin: 3em)
#show link: underline
#set text(font: "Cantarell", size: 12pt, lang: "fr")

#outline(
 title: "Table of Contents",
)

// todo move that somewhere useful
== Dictionnaire
- `Cargo.toml` définit les dépendances (les crates) et leur versions minimum à inclure dans le projet, équivalent du `package.json` de NPM
- `crate`: la plus petite unité de compilation avec cargo, concrètement chaque projet contient un ou plusieurs dossiers avec un `Cargo.toml`
- `crates.io`: le registre officiel des crates publiée pour l'écosystème Rust, l'équivalent de `npmjs.com` pour l'écosystème Javascript, ou `mvnrepository.com` pour Java
// todo check ces définitions

#pagebreak()

== Etat de l'art

=== Format de données existant orienté humainement éditable
Ces recherches ignorent les formats de données largement supporté et répandu tel que le XML, JSON, YAML et TOML. Ils sont tout à fait adapter pour des configurations, de la sérialisation et de l'échange de donnée et sont pour la plupart facilement lisible. Cependant la quantité de séparateurs et délimiteurs en plus du contenu qu'ils n'ont pas été optimisé pour la rédaction par des humains. Le YAML et le TOML, bien que plus léger que le JSON, inclue de nombreux types de données autre que les strings, des tabulations et des guillemets, ce qui rend la rédaction plus fastidieuse qu'en Markdown.

On cherche quelque chose du niveau de simplicité du Markdown en terme de rédaction, mais avec une validation poussée customisable par le projet qui définit le schéma.

TODO: continuer markdown inspiration + besoin

Ces recherches se focalisent sur les syntaxes qui ne sont pas spécifique à un domaine ou qui seraient complètement déliée de l'informatique ou de l'éducation. Ainsi, l'auteur ne présente pas Cooklang @cooklangMention, qui se veut une langage de balise pour les recettes de cuisines, même si l'implémentation du parseur en Rust @cooklangParserInRust pourra servir pour d'autres recherches. On ignore également les projets qui créent une syntaxe très proche du Rust, comme la Rusty Object Notation (RON) @ronMention, de par leur nécessité de connaître un peu la syntaxe du Rust et surtout parce qu'elle ne simplifie pas vraiment l'écriture comparé à du YAML. On ignore également les projets dont la spécification ou l'implémentation est en état de "brouillon" et n'est pas encore utilisable en production.

Contrairement aux languages de programmation qui existent par centaines, les syntaxes de ce genre ne sont pas monnaies courantes. Différentes manières de les nommer existent: language de balise (markup language), format de donnée, syntaxes, langage de donnée, language spécifique à un domaine (de l'anglais Domain Specific Language - DSL), ... Les mots-clés utilisés suivants ont été utilisés sur Google, la barre de recherche de Github.com et de crates.io: `data format`, `human friendly`, `human writable`, `human readable`.

#show raw.where(block: false): b => {
    box(fill: rgb(175, 184, 193, 20%), inset: 2pt, outset: 2pt, [#b.text])
}

#show raw.where(block: true): b => {
    block(stroke: 1pt + black, fill: rgb(249, 251, 254), inset: 15pt, radius: 5pt,)[#align(left)[#b.text]]
}

==== KHI - Le langage de données universel
D'abord nommée UDL (Universal Data Language) @UDLCratesio, cette syntaxe a été inventée pour mixer les possibilités du JSON, YAML, TOML, XML, CSV et Latex, afin de supporter toutes les structures de données modernes. Plus concrètement le markup, les structs, les listes, les tuples, les tables/matrices, les enums, les arbres hiérarchiques sont supportés. Les objectifs sont la polyvalence, un format source (fait pour être rédigé à la main), l'esthétisme et la simplicité.

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
    caption: [Un exemple simplifié tiré de leur README @KHIGithub, décrivant un exemple d'article d'encyclopédie.],
) <khi-example>

Une implémentation en Rust en proposée @KHIRSGithub. Son dernier commit sur ces 2 repositorys date du 11.11.2024, le projet a l'air de ne pas être fini au vu des nombreux `todo!()` présent dans le code.

==== Bitmark - le standard des formats éducatifs digitaux
Bitmark est un standard open-source, qui vise à uniformiser tous les formats de données utilisés pour décrire du contenu éducatif digital sur les nombreuses plateformes existantes @bitmarkAssociation. Cette diversité de formats rend l'interropérabilité très difficile et freine l'accès à la connaissance et restreint les créateurs de contenus et les éditeurs dans les possibilités de migration entre plateformes. La stratégie est de définir un format basé sur le contenu (Content-first) plus que basé sur son rendu (layout-first) permettant un affichage sur tous type d'appareils incluant les appareils mobiles @bitmarkAssociation. C'est la Bitmark Association en Suisse à Zurich qui développe ce standard, notamment à travers des Hackatons organisés en 2023 et 2024 @bitmarkAssociationHackaton.

Le standard permet de décrire du contenu statique et interactif, comme des articles ou des quiz de divers formats. 2 formats équivalents sont définis: le bitmark markup language et le bitmark JSON data model @bitmarkDocs

La partie quizzes du standard inclut des textes à trous, des questions à choix multiple, du texte à surligner, des essais, des vrai/faux, des photos à prendre ou audios à enregister et de nombreux autres type d'exercices.

#figure(
```
[.multiple-choice-1]
[!What color is milk?]
[?Cows produce milk.]
[+white]
[-red]
[-blue]
```, caption: [Un exemple de question à choix multiple tiré de leur documentation @bitmarkDocsMcqSpec. L'option correcte `white` est préfixée par `+` et les 2 autres options incorrectes par `-`. Plus haut, `[!...]` décrit une consigne, `[?...]` décrit un indice.]
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
```, caption: [Extrait simplifié de la réponse JSON, respectant le standard Bitmark @bitmarkDocsClozeSpec. La phrase `There used to be a ___ here.` doit être complétée par le mot `school` en s'aidant du texte en allemand.]
)
Open Taskpool, projet qui met à disposition des exercices d'apprentissage de langues @openTaskpoolIntro, fournit une API JSON utilisant le Bitmark JSON data model.

Demander à Open Taskpool des exercices d'allemand vers anglais autour du mot `school` de format `cloze` (texte à trou), se fait avec cette simple requête: `https://taskpool.taskbase.com/exercises?translationPair=de->en&word=school&exerciseType=bitmark.cloze`.

#figure(
```json
...
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
...
```, caption: [Extrait simplifié de la réponse JSON, respectant le standard Bitmark @bitmarkDocsClozeSpec. La phrase `There used to be a ___ here.` doit être complétée par le mot `school` en s'aidant du texte en allemand.]
)
Un autre exemple d'usage se trouve dans la documentation de Classtime @ClasstimeDocs, on voit que le système de création d'exercices est basé sur des formulaires.
Ces 2 exemples donnent l'impression que la structure JSON est plus utilisée que le markup. Au vu de tous séparateurs et symboles de ponctuations à se rappeler, la syntaxe n'a peut-être pas été imaginée dans le but d'être rédigée à la main directement. Finalement, Bitmark ne spécifie pas de type d'exercices programmation nécessaire à PLX.

==== NestedText — Un meilleur JSON
NestedText se veut human-friendly, similaire au JSON mais pensé pour être facile à modifier et visualiser par les humains. Le seul type de donnée scalaire supporté est la chaîne de caractères, afin de simplifier la syntaxe et retirer le besoin de mettre des guillemets. La différence avec le YAML, en plus des types de données restreint est la facilité d'intégrer des morceaux de code sans échappements ni guillemets, les caractères de données ne peuvent pas être confondus avec NestedText @nestedTextGithub.

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

Ce format a l'air assez léger visuellement et l'idée de faciliter l'intégration de blocs multi-lignes sans contraintes de charactères réservée serait utile à PLX. Cependant, tout comme le JSON la validation du contenu n'est pas géré directement par le parseur mais par des librairies externes qui vérifient le schéma @nestedTextSchemasLib. De plus, l'implémentation officielle est en Python et il n'y a pas d'implémentation Rust disponible; il existe une crate réservée mais vide @nestedTextRsCrateEmpty.

==== SDLang - Simple Declarative Language

SDLang se définit comme "une manière simple et concise de représenter des données textuellement. Il a une structure similaire au XML: des tags, des valeurs et des attributs, ce qui en fait un choix polyvalent pour la sérialisation de données, des fichiers de configuration ou des langages déclaratifs." (Traduction personnelle de leur site web @sdlangWebsite). SDLang définit également différents types de nombres (32bit, 64bit, entier, flottant, ...), 4 valeurs de booléans (`true`, `false`, `on`, `off`) comme en YAML, différents formats de dates et un moyen d'intégrer des données binaires encodées en Base64.

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
  caption: [Exemple tiré de leur site web @sdlangWebsite]
)

Ce format s'avère plus intéressant que les précédents de part le faible nombre de caractères réservés et la densité d'information: avec l'auteur décrit par son nom, email et un attribut booléan sur une seule ligne ou la matrice de 9 valeurs définie sur 5 lignes. Il est cependant regrettable de voir de les strings doivent être entourées de guillemets et les textes sur plusieurs lignes doivent être entourés de backticks ``` ` ```. De même la définition de la hiéarchie d'objets définis nécessite d'utiliser une paire `{` `}`, ce qui rend la rédaction un peu plus lente.

==== KDL - Le "Cuddly Data language"

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
  caption: [Exemple simplifié tiré de leur site web @kdlWebsite]
)
Est-ce que cela paraît proche de SDLang vu précédemment ? C'est normal puisque KDL est basé sur SDLang avec quelques améliorations. Celles qui nous intéressent concernent la possibilité d'utiliser des guillemets pour les strings sans espace (`person name=Samuel` au lieu de `person name="Samuel"`). Cette simplification n'inclue malheureusement des strings multilines, qui demande d'être entourée par `"""`. Le problème d'intégration de morceaux de code est également relevé, les strings brutes sont supportées entre `#` sur le mode une ou plusieurs lignes, ainsi pas d'échappements des backslashs à faire par ex.

En plus des autres désavantages restant de hiéarchie avec `{` `}` et guillemets, il reste toujours le problème des types de nombres qui posent soucis avec certaines strings si on ne les entoure pas de guillemets. Par exemple ce numéro de version `version "1.2.3"` a besoin de guillemets sinon `1.2.3` est interprété comme une erreur de format de nombre à virgule.

==== Conclusion


#pagebreak()
=== Librairies existantes de parsing en Rust
Après s'être intéressé aux syntaxes existantes, nous nous intéressons maintenant aux solutions existantes pour simplifier ce parsing de cette nouvelle syntaxe en Rust.

Après quelques recherches avec le tag `parser` sur crates.io @cratesIoParserTagsList, j'ai trouvé la liste de librairies suivantes:

- `winnow` @winnowCratesio, fork de `nom`, utilisé notamment par le parseur Rust de KDL @kdlrsDeps
- `nom` @nomCratesio, utilisé notamment par `cexpr` @nomRevDeps
- `pest` @pestCratesio
- `combine` @combineCratesio
- `chumsky` @chumskyCratesio


A noter aussi l'existance de la crate `serde`, un framework de sérialisation et desérialisation très populaire dans l'écosystème Rust (selon lib.rs @librsMostPopular). Il est notamment utilisé pour les parseurs JSON et TOML. Ce n'est pas une librairie de parsing mais un modèle de donnée basée sur les traits de Rust pour faciliter son travail. Au vu du modèle de données de Serde @serdersDatamodel, qui supporte 29 types de données, ce projet paraît à l'auteur apporter plus de complexités qu'autre chose pour trois raisons:
- Seulement les strings, listes et structs sont utiles pour PLX. Par exemple, les 12 types de nombres sont inutiles à différencier et seront propre au besoin de la variante.
- La sérialisation (struct Rust vers syntaxe DY) n'est pas prévue, seulement la desérialisation est utile.
- Le mappage des préfixes et flags par rapport aux attributs des structs Rust qui seront générées, n'est pas du 1:1, cela dépendra de la structure définie pour la variante de PLX.

Après ces recherches et quelques essais avec `winnow`, l'auteur a finalement décidé qu'utiliser une librairie était trop compliqué pour le projet et que l'écriture manuelle d'un parseur ferait mieux l'affaire. La syntaxe DY est relativement petite à parser, et sa structure légère et souvent implicite rend compliqué l'usage de librairies pensées pour des langages de programmation très structuré.

Par exemple, une simple expression mathématique `((23+4) * 5)` paraît idéale pour ces outils, les débuts et fin sont claires, une stratégie de combinaisons de parseurs fonctionnerait bien pour les expressions parenthésées, les opérateurs et les nombres. Elles semble bien adapter à exprimer l'ignorance des espaces, extraire les nombres tant qu'il contiennent des chiffres, extraires des opérateurs et les 2 opérandes autour...

Pour DY, l'aspect multilignes et qu'une partie des préfixes optionnel, complique l'approche de définir le début et la fin et d'appeler combiner récursivement des parseurs comme on ne sait pas facilement où est la fin.

#figure(
```
exo Dog struct
Consigne très longue

en *Markdown*
sur plusieurs lignes

xp 20
checks
...
```,
    caption: [Exemple d'un début d'exercice de code, on voit que la consigne se trouve après la ligne `exo` et continue sur plusieurs lignes jusqu'à qu'on trouve un autre préfixe (ici `xp` qui est optionnel ou alors `checks`).],
)

// todo la variante, terme correcte ?

#pagebreak()
=== Systèmes de surglignage de code
Les IDEs modernes supportent possèdent des systèmes de surglignage de code (syntax highlighting en anglais) permettant de rendre le code plus lisible en colorisant les mots, charactères ou groupe de symboles de même type (séparateur, opérateur, mot clé du langage, variable, fonction, constante, ...). Ces systèmes se distinguent par leur possibilités d'intégration. Les thèmes intégrés aux IDE peuvent définir directement les couleurs pour chaque type de token. Pour un rendu web, une version HTML contenant des classes CSS spécifiques à chaque type de token peut être générée, permettant à des thèmes écrits en CSS de venir appliquer les couleurs. Les possibilités de génération pour le HTML pour le web implique parfois une génération dans le navigateur ou sur le serveur directement.

Un système de surlignage est très différent d'un parseur. Même s'il traite du même langage, dans un cas, on cherche juste à découper le code en tokens et y définir un type de token. Ce qui s'apparente seulement à la premier étape du lexer/tokenizer généralement rencontré dans les parseurs.

==== Textmate
Textmate est un IDE pour MacOS qui a inventé un système de grammaire Textmate. Ces grammaires permettent de décrire comment tokeniser le code basée sur des expressions régulières. Ces expressions régulières viennent de la librairie Oniguruma @textmateRegex. VSCode utilise ces grammaires Textmate @vscodeSyntaxHighlighting. Intellij IDEA l'utilise également pour les langages non supportés par Intellij IDEA @ideaSyntaxHighlighting.

==== Tree-Sitter
Tree-Sitter est supporté dans Neovim @neovimTSSupport, dans le nouvel éditeur Zed @zedTSSupport, ainsi que d'autres. Tree-Sitter a été inventé par l'équipe derrière Atom @atomTSSupport

==== Semantic highlighting

==== Choix final
Si le temps le permet, une grammaire développée avec Tree-Sitter permettra de supporter du surglignage dans Neovim et VSCode dans le futur.

#pagebreak()

=== Les serveurs de language et librairies Rust existantes
Une part importante du support d'un langage dans un éditeur, consiste en l'intégration des erreurs, l'auto-complétion, les propositions de corrections et des informations au survol... et de nombreuses fonctionnalités qui améliorent l'interaction et la productivité autour du travail avec le code. Par ex. les erreurs de compilation étant intégrées à l'éditeur, il est possible de voir immédiatement les problèmes même avant d'avoir lancer une compilation manuelle dans une interface séparée.

Contrairement au surlignage de code, ces fonctionnalités demandent une compréhension beaucoup plus fine, ils sont implémentés des processus séparés de l'éditeur (étant donc agnostique du langage de programmation utilisé). Ces processus séparés sont appelés des serveurs de langage (language server en anglais).

La communication entre l'éditeur et un serveur de langage démarré pour le fichier en cours, se fait via le `Language Server Protocol (LSP)` inventé par Microsoft pour VSCode.

Fonctionnement général du protocole
- *JSON-RPC* est utilisé pour faire des appels 
JSON-RPC is a bit like HTTP
// todo cite code provenance

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
```

    - https://github.com/rust-lang/rust-analyzer/blob/master/lib/lsp-server/examples/goto_def.rs
    - https://github.com/rust-lang/rust-analyzer/tree/master/lib/lsp-server
    - https://github.com/Myriad-Dreamin/tinymist/tree/main/crates/sync-lsp
    - tower-lsp
==== lsp-server
https://github.com/rust-lang/rust-analyzer/blob/master/lib/lsp-server/examples/goto_def.rs

==== async-lsp

==== tower-lsp-server

==== Choix final
Si le temps le permet...

#pagebreak()

=== Protocoles de synchronisation existants

==== gRPC
==== Websockets

==== Choix final


#bibliography("bibliography.bib")
