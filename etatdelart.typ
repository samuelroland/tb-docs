// Temporary document in waiting maturity of the Typst template

#set page(margin: 3em)
#show link: underline
#set text(font: "Cantarell", size: 12pt, lang: "fr")

== Etat de l'art

=== Syntaxes existantes de format de données humainement éditable

#show raw.where(block: false): b => {
    box(fill: rgb(175, 184, 193, 20%), inset: 2pt, outset: 2pt, [#b.text])
}

#show raw.where(block: true): b => {
    block(stroke: 1pt + black, fill: rgb(249, 251, 254), inset: 15pt, radius: 5pt,)[#align(left)[#b.text]]
}

==== KHI
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

Pour PLX, je n'ai de loin pas besoin d'autant de structures de données différentes, ce qui fait que KHI est trop verbeux à mon goût. De plus, certains caractères en pair et séparateurs sont réservés (`<`, `>`, `[`, `]`, `{`, `}`, `"`, `:`, `;`), ce qui rendrait l'inclusion de code source dans les consignes ardue, de part la nécessité d'échapper ces caractères avec `\`.

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
```, caption: [Un exemple de question à choix multiple avec `white` comme réponse correct et 2 autres options incorrectes. `[!...]` décrit une consigne, `[?...]` décrit un indice.]
)

A nouveau, cette syntaxe ne nous aide pas parce qu'elle ne permet pas de définir des exercices de programmation nécessaire pour PLX. Cette syntaxe n'a pas l'air d'être pensée pour une rédaction à la main au vu de tous séparateurs et symboles de ponctuations à se rappeler. D'ailleurs on voit dans la documentation de Classtime @ClasstimeDocs, une plateforme qui utilise Bitmark, que le système de création d'exercices est basé sur des formulaires et non une zone de texte pour rédiger cette syntaxe.

=== EDN
```
{:name "Hans", :born 1970,
    :pets [{:name "Cap'n Jack" :kind "Sparrow"}
            {:name "Freddy" :kind "Cockatiel"}]}
```
TODO

#bibliography("bibliography.bib")
