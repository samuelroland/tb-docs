// Temporary document in waiting maturity of the Typst template

#set page(margin: 3em)
#show link: underline
#set text(font: "Cantarell", size: 12pt, lang: "fr")

// todo move that somewhere useful
== Dictionnaire
- `Cargo.toml` définit les dépendances (les crates) et leur versions minimum à inclure dans le projet, équivalent du `package.json` de NPM
- `crate`: officiellement la plus petite unité de compilation avec cargo, concrètement chaque projet contient un ou plusieurs dossiers avec un `Cargo.toml`
- `crates.io`: le registre officiel des crates publiée pour l'écosystème Rust, l'équivalent de `npmjs.com` pour l'écosystème Javascript, ou `mvnrepository.com` pour Java
// todo check ces définitions

== Etat de l'art

=== Format de données humainement éditable existants
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

=== Bitmark
Bitmark est un standard open-source, qui vise à uniformiser tous les formats de données utilisés pour décrire du contenu éducatif digital sur les nombreuses plateformes existantes @bitmarkAssociation. Cette diversité de formats rend l'interropérabilité très difficile et freine l'accès à la connaissance. La stratégie est de définir un format basé sur le contenu (Content-first) plus que basé sur son rendu (layout-first) permettant un affichage sur tous type d'appareils incluant les appareils mobiles @bitmarkAssociation. C'est la Bitmark Association en Suisse à Zurich qui développe ce standard, notamment à travers des Hackatons organisés en 2023 et 2024 @bitmarkAssociationHackaton.

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
Open Taskpool, projet qui met à disposition des exercices d'apprentissage de langues @openTaskpoolIntro, fournit une API JSON utilisant le JSON data model de Bitmark.

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
```, caption: [Extrait simplifié de la réponse JSON, respectant le standard Bitmark @bitmarkDocsClozeSpec. La phrase `There used to be a ___ here.` doit être complétée par le mot `school` en s'aidant du texte en allemand.
]
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



#bibliography("bibliography.bib")
