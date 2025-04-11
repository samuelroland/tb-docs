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

=== EDN
```
{:name "Hans", :born 1970,
    :pets [{:name "Cap'n Jack" :kind "Sparrow"}
            {:name "Freddy" :kind "Cockatiel"}]}
```
#bibliography("bibliography.bib")
