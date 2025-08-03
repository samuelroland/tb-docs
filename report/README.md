# Rapport du TB
Ce dossier contient tout le contenu du rapport, écrit en Typst, pour ce travail de Bachelor.
[**Le rapport final de ce travail**](rapport-final-tb-plx.pdf) a été rendu le 2025-07-24.

## Export en PDF

1. Installer le [CLI de Typst](https://github.com/typst/typst)
1. Installer le plugin [`syntastica`](https://github.com/RubixDev/syntastica-typst) localement
1. Lancer `bash watch.sh` pour lancer `typst watch` et avoir un rafraichissement rapide
1. Lancer `bash build.sh` pour exporter un PDF à rendre, cela peut prendre plusieurs minutes à cause de la coloration avancée de `syntastica`

## Génération dynamique

Une partie des figures ou éléments intégrés au rapport sont générés dynamiquement. Un petit CLI Rust du nom de `docsgen` exporte tous les messages du protocoles vers des fichiers JSON dédiés. Les schémas PlantUML sont aussi exportés en SVG. Voir plus de détails sur cette génération sur [docsgen/README.md](docsgen/README.md).

## Template utilisé

Ce rapport est basé sur le [template Typst](https://github.com/DACC4/HEIG-VD-typst-template-for-TB) de [@DACC4](https://github.com/DACC4), publié [sous licence Apache 2.0](https://github.com/DACC4/HEIG-VD-typst-template-for-TB/blob/main/LICENSE). Ce template se base sur la version Latex de Sylvain Pasini.

Une fois le template copié-collé, j'ai fait plusieurs modifications localement afin d'adapter à mes besoins. Ces contributions pourraient être remontée après le TB si cela peut être utile.

