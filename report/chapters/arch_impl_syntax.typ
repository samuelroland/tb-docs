= Développement de la syntaxe DY <arch_impl_dy>

Cette partie documente la définition et l'implémentation de la syntaxe DY, son parseur et l'intégration IDE qui a pu être développée.

Cette partie décrit d'une manière semi-formelle la syntaxe DY et son usage dans PLX.

*Avertissement: ceci est une brouillon, il sera continué les semaines suivantes.*

== Définition semi-formelle de la syntaxe DY en abstrait

=== Les clés
TODO

=== Les types de clés
TODO

=== Les propriétés
TODO

=== Longueurs et types de contenu
TODO

=== Hiérarchie implicite
Les fins de ligne définissent la fin du contenu pour les clés sur une seule ligne. La clé `exo` supporte plusieurs lignes, son contenu se termine ainsi dès qu'une autre clé valide est détecté (ici `check`). La hiérarchie est implicite dans la sémantique, un exercice contient un ou plusieurs checks, sans qu'il y ait besoin d'indentation ou d'accolades pour indiquer les relations de parents et enfants. De même, un check contient une séquence d'action à effectuer (`run`, `see`, `type` et `kill`), ces clés n'ont de sens qu'à l'intérieur la définition d'un check (uniquement après une ligne avec la clé `check`).

TODO

=== Détection d'erreurs générales

== Usage de la syntaxe dans PLX
TODO

=== Exemple d'usage dans PLX
#figure(
  image("../sources/plx-dy-all.svg", width:100%),
  caption: [Aperçu des possibilités de DY sur un exercice plus complexe],
) <exemple-dy-all>

Le @exemple-dy-all nous montre qu'il existe plusieurs clés
- La clé `exo` introduit un exercice, avec un titre sur la même ligne et le reste de la consigne en Markdown sur les lignes suivantes.
- `check` introduit le début d'un check avec un titre, en Markdown également.
- `run` donne la commande de démarrage du programme.
- `skip` avec la propriété `.until` permet de cacher toutes les lignes d'output jusqu'à voir la ligne donnée.
- `see` demande à voir une ou plusieurs lignes en sortie standard.
- `type` simule une entrée au clavier
- et finalement `kill` indique comment arrêter le programme, ici en envoyant le `.signal` `9` sur le processus `qemu-system-arm` (qui a été lancé par notre script `./st`).

Toutes les propriétés sont optionnelles, soit elles ont une valeur par défaut, soit la configuration est implicite.

==== Détection d'erreurs spécifiques à PLX
TODO

TODO fix headings level

== Implémentation de la librairie `dy`
TODO

== Intégration de `dy` dans PLX
TODO

== Implémentation de la syntaxe Tree-Sitter
TODO

== Implémentation du serveur de language
TODO
