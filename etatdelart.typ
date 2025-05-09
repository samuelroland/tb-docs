// Temporary document in waiting maturity of the Typst template
#set text(lang: "fr")  // assuming you want French

// Use "Snippet" instead of Liste -> Snippet 1, Snippet 2, ...
#show figure.where(kind: raw): set figure(
  supplement: "Snippet"
)

#set par(justify: true)

#set page(margin: 3em)
#show link: underline
#set text(font: "Cantarell", size: 12pt, lang: "fr")

// todo only for svg !
#show image: box.with(
  // fill: rgb(249, 251, 254),
  inset: 10pt,
  outset: (y: 3pt),
  radius: 2pt,
  stroke: 1pt + luma(200)
)
// Display inline code in a small box that retains the correct baseline.
#show raw.where(block: false): box.with(
  fill: luma(240),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)

#show block: text.with(size: 0.95em, font: "Fira Code")

// Display block code in a larger block with more padding.
#show raw.where(block: true): block.with(
  // fill: rgb(249, 251, 254),
  inset: 10pt,
  radius: 2pt,
  stroke: 1pt + luma(200)
)

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
    caption: [Un exemple simplifié de KHI de leur README @KHIGithub, décrivant un exemple d'article d'encyclopédie.],
) <khi-example>

Une implémentation en Rust en proposée @KHIRSGithub. Son dernier commit sur ces 2 repositorys date du 11.11.2024, le projet a l'air de ne pas être fini au vu des nombreux `todo!()` présent dans le code. La large palette de structures supportées implique une charge mentale additionnelle pour se rappeler, ce qui en fait une mauvaise option pour PLX.

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
```, caption: [Equivalent de @mcq-bitmark dans le Bitmark Json data model @bitmarkDocsMcqSpec]
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
En conclusion, au vu du nombre de tentatives/variantes trouvées, on voit que la verbosité des formats largement répandu du XML, JSON et même du YAML est un problème qui ne touche pas que l'auteur. Le gain de verbosité des syntaxes listées est réel mais reste ciblé sur un usage plus avancé de structure de données et types variés. L'auteur pense pouvoir proposer une approche encore plus légère et plus simple, inspirée du style du Markdown en évitant une partie des charactères non explicites.

TODO finish + merge intro above

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
Textmate est un IDE pour MacOS qui a inventé un système de grammaire Textmate. Elles permettent de décrire comment tokeniser le code basée sur des expressions régulières. Ces expressions régulières viennent de la librairie Oniguruma @textmateRegex. VSCode utilise ces grammaires Textmate @vscodeSyntaxHighlighting. Intellij IDEA l'utilise également pour les langages non supportés par Intellij IDEA @ideaSyntaxHighlighting.

==== Tree-Sitter

Tree-Sitter @TreeSitterWebsite se définit comme un "outil de génération de parser et une librairie de parsing incrémentale. Il peut construire un arbre de syntaxe concret (CST) pour depuis un fichier source et efficacement mettre à jour cet arbre quand le fichier source est modifié." @TreeSitterWebsite (Traduction personnelle)

Rédiger une grammaire Tree-Sitter consiste en l'écriture d'une grammaire en Javascript dans un fichier `grammar.js`. Le cli `tree-sitter` va ensuite générer un parseur en C qui pourra être utilisé directement via le CLI `tree-sitter` durant le développement et être facilement embarquée comme librarie C sans dépendance dans n'importe quelle type d'application @TreeSitterCreatingParsers @TreeSitterWebsite.

Etant donné @exo-dy-ts-poc, le défi est d'arriver à coloriser les préfixes et les flags pour ne pas avoir cette affichage noir sur blanc qui ne facilite pas la lecture.
#figure(
```
// Basic MCQ exo
exo Introduction
opt .multiple
- C is an interpreted language
- .ok C is a compiled language
- C is mostly used for web applications
```,
  caption: [Un exemple de question choix multiple, décrite avec la syntaxe DY. Les préfixes sont `exo` (titre) et `opt` (options). Les flags sont `.ok` et `.multiple`.]
) <exo-dy-ts-poc>

Une fois la grammaire mise en place avec la commande `tree-sitter init`, il suffit de remplir le fichier `grammar.js`, avec une ensemble de régle construites via des fonctions fournies par Tree-Sitter et des expressions régulières.

// todo link or not link to ts docs ??

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
    list_line: ($) => seq($.dash, repeat($.property), optional(" "), optional($.content)),
    dash: (_) => token(prec(2, /- /)),
    prefix: (_) => token(prec(1, choice("exo", "opt"))),
    property: (_) => token(prec(3, seq(".", choice("multiple", "ok")))),
    content_line: ($) => $.content,
    content: (_) => token(prec(0, /.+/)),
  },
});
```

On observe dans cet exemple un fichier source, découpé en une répétition de ligne. Il y a 4 types de lignes qui sont chacunes décrites avec des plus petits morceaux. `seq` indique une liste de tokens qui viendront en séquence, `choice` permet de tester plusieurs options à la même position. On remarque également la liste des préfixes et flags insérés dans les tokens de `prefix` et `property`. La documentation The Grammar DSL de la documentation explique toutes les options possibles en détails @TreeSitterGrammarDSL.

Après avoir appelé `tree-sitter generate` pour générer le code du parser C et `tree-sitter build` pour le compiler, on peut demander au CLI de parser un fichier donné et afficher le CST. Dans cet arbre qui démarre avec son noeud racine `source_file`, on y voit les noeuds du même type que les règles définies précédemment, avec le texte extrait dans la plage de charactères associée au noeud. Par exemple, on voit que l'option `C is a compiled language` a bien été extraite à la ligne 4, entre le byte 6 et 30 (`4:6  - 4:30`) en tant que `content`. Elle suit un token de `property` avec notre flag `.ok` et le tiret de la règle `dash`.

```
> tree-sitter parse -c mcq.dy
0:0  - 6:0    source_file 
0:0  - 0:16     commented_line `// Basic MCQ exo`
0:16 - 1:0      "\n"
1:0  - 1:16     prefixed_line 
1:0  - 1:3        prefix `exo`
1:3  - 1:4        " "
1:4  - 1:16       content `Introduction`
1:16 - 2:0      "\n"
2:0  - 2:13     prefixed_line 
2:0  - 2:3        prefix `opt`
2:3  - 2:13       property ` .multiple`
2:13 - 3:0      "\n"
3:0  - 3:30     list_line 
3:0  - 3:2        dash `- `
3:2  - 3:30       content `C is an interpreted language`
3:30 - 4:0      "\n"
4:0  - 4:30     list_line 
4:0  - 4:2        dash `- `
4:2  - 4:5        property `.ok`
4:5  - 4:6        " "
4:6  - 4:30       content `C is a compiled language`
4:30 - 5:0      "\n"
5:0  - 5:39     list_line 
5:0  - 5:2        dash `- `
5:2  - 5:39       content `C is mostly used for web applications`
5:39 - 6:0      "\n"
```

La tokenisation fonctionne bien pour cette exemple, chaque élément est correctement découpé et catégorisé. Pour voir ce snippet en couleurs, il nous reste deux choses à définir. La première consiste en un fichier `queries/highlighting.scm` qui décrit des requêtes de surlignage sur l'arbre (highlights query) permettant de sélectionner des noeuds de l'arbre et leur attribuer un nom de surlignage (highlighting name). Ces noms ressembles à `@variable`, `@constant`, `@function`, `@keyword`, `@string` etc... et des versions plus spécifiques comme `@string.regexp`, `@string.special.path`. Ces noms sont ensuite utilisés par les thèmes pour appliquer un style.

```
> cat queries/highlights.scm
(prefix) @keyword
(commented_line) @comment
(content) @string
(property) @property
(dash) @operator
```

Le CLI supporte directement la configuration d'un thème via son fichier de configuration, on reprend simplement chaque nom de surlignage en lui donnant une couleur.
```
> cat ~/.config/tree-sitter/config.json
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
```

#figure(
  box(image("./imgs/mcq.svg"), width:50%),
  caption: [Résultat final surligné par `tree-sitter highlighting mcq.dy`]
)

Tree-Sitter est supporté dans Neovim @neovimTSSupport, dans le nouvel éditeur Zed @zedTSSupport, ainsi que d'autres. Tree-Sitter a été inventé par l'équipe derrière Atom @atomTSSupport.

==== Semantic highlighting

==== Choix final
Si le temps le permet, une grammaire développée avec Tree-Sitter permettra de supporter du surglignage dans Neovim. Le choix de ne pas explorer plus les grammaires Textmate se justifie également par l'intégration en cours de Tree-Sitter dans de VSCode

#pagebreak()

=== Les serveurs de language et librairies Rust existantes
Une part importante du support d'un langage dans un éditeur, consiste en l'intégration des erreurs, l'auto-complétion, les propositions de corrections, des informations au survol... et de nombreuses fonctionnalités qui améliorent la compréhension ou l'interaction. L'avantage d'avoir les erreurs de compilation directement soulignées dans l'éditeur, permet de voir et corriger immédiatement les problèmes sans lancer une compilation manuelle dans une interface séparée.

Contrairement au surlignage de code, ces fonctionnalités demandent une compréhension beaucoup plus fine, ils sont implémentés dans des processus séparés de l'éditeur (aucun langage de programmation n'est ainsi imposé). Ces processus séparés sont appelés des serveurs de langage (language server en anglais). Les éditeurs qui intègre Tree-Sitter développe un client LSP qui se charge de lancer ce serveur, de lancer des requêtes et d'intégrer les données des réponses dans leur interface visuelle.

La communication entre l'éditeur et un serveur de langage démarré pour le fichier en cours, se fait via le `Language Server Protocol (LSP)`. Ce protocole inventé par Microsoft pour VSCode, résoud le problème des développeurs de langages qui doivent supporter chaque éditeur de code indépendamment avec des APIs légèrement différentes pour faire la même chose. Le projet a pour but également de simplifier la vie des nouveaux éditeurs pour intégrer rapidement des dizaines de langages via ce protocole commun et standardisé @lspWebsite.

#figure(
  image("imgs/neovim-autocompletion-example.png", width: 70%),
  caption: [Exemple d'auto-complétion dans Neovim, générée par le serveur de language `rust-analyzer` sur l'appel d'une méthode sur les `&str`],
) <fig-neovim-autocompletion-example>

Les points clés du protocole à relever sont les suivants:
- *JSON-RPC* (JSON Remote Procedure Call) est utilisé comme format de sérialisation des requêtes. Similaire au HTTP, il possède des entêtes et un corps. Ce standard définit quelques structures de données à respecter. Une requête doit contenir un champ `jsonrpc`, `id`, `method` et optionnelement `params` @jsonrpcSpec. Il est possible d'envoyer une notification (requête sans attendre de réponse). Par exemple, le champ `method` va indiquer l'action qu'on tente d'appeler, ici une des fonctionnalités du serveur. Voir @jsonRpcExample
- Un serveur de langage n'a pas besoin d'implémenter toutes les fonctionnalités du protocole. Un système "Capabilities" est défini pour annoncer les méthodes implémentées @lspCapabilities.
- Le transport des messages JSON-RPC peut se faire en `stdio` (flux standard entrée et sorties), sockets TCP ou même en HTTP.

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
  caption: [Exemple de requête en JSON-RPC envoyé par le client pour demander des propositions d'auto-complétion à une position de curseur données. Tiré de la spécification @lspCompletionExample],
) <jsonRpcExample>

Quelques exemples de serveurs de langages implémentés en Rust
- `tinymist`, serveur de langage de Typst (système d'édition de document, utilisé pour la rédaction de ce rapport).
- `rust-analyzer`, projet officiel du langage Rust.
- `asm-lsp` @AsmLspCratesio, permet d'inclure des erreurs dans du code assembleur

Une crate commune à plusieurs projet est `lsp-types` @lspTypesCratesio qui définit les structures de données, comme `Diagnostic`, `Position`, `Range`. Ce projet est utilisé par `lsp-server`, `tower-lsp`, `lspower` et d'autres @lspTypesUses

- https://github.com/rust-lang/rust-analyzer/blob/master/lib/lsp-server/examples/goto_def.rs
- https://github.com/rust-lang/rust-analyzer/tree/master/lib/lsp-server
- https://github.com/Myriad-Dreamin/tinymist/tree/main/crates/sync-lsp
- tower-lsp

==== Adoption
Selon la liste des clients qui supportent le LSP sur le site de la spécification @lspClientsList, de nombreux éditeurs tel que Atom, Eclipse, Emacs, GoLand, Intellij IDEA, Helix, Neovim, Visual Studio et bien sûr VSCode. La liste des serveurs LSP @lspServersList quand à elle, contient plus de 200 projets, dont 40 implémentés en Rust! Ce large support et ces nombreux exemples vont faciliter le développement et le support de différents IDE.

==== Librairies disponibles
En cherchant à nouveau sur `crates.io` sur le tag `lsp`, on trouve différent projets dont `async-lsp` @AsyncLspCratesio utilisée dans `nil` @NilUsingAsyncLspGithub (un serveur de langage pour le système de configuration de NixOS) et de la même auteure.

Le projet `tinymist` a fait une abstraction `sync-ls`, mais le README déconseille son usage et conseille `async-lsp` à la place @tinymistSyncLspImpl. En continuant la recherche on trouve encore un autre `tower-lsp` et un fork `tower-lsp-server` @TowerLspServerCratesio... `rust-analyzer` a également extrait une crate `lsp-server`.

==== Choix final
L'auteur travaillant dans Neovim, l'intégration ne sera faite que dans Neovim pour ce TB, l'intégration dans VSCode pourra être fait dans le futur et devrait être relativement simple.

Les 2 projets les plus utilisés (en terme de reverse dependencies sur crates.io) sont `lsp-server` @LspServerCratesio (56) et `tower-lsp` (85) @TowerLspCratesio. L'auteur a choisi d'utiliser la crate `lsp-server` étant développé par la communauté Rust, la probabilité d'une maintenance long-terme est plus élevée, et le projet `tower-lsp` est basée sur des abstractions asynchrones, l'auteur préfère partir sur la version synchrone pour simplifier l'implémentation.

Cette partie est un nice-to-have de ce travail, il n'est pas sûr qu'elle puisse aboutir.

#pagebreak()

=== Protocoles de synchronisation existants

==== gRPC
==== Websockets

==== Choix final


#bibliography("bibliography.bib")
