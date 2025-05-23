= Architecture <architecture>

== Protocole de synchronisation
#figure(
  image("../schemas/high-level-arch.opti.svg", width:100%),
  caption: [Architecture haut niveau décrivant les interactions entre les clients PLX et le serveur de session live],
) <high-level-arch>

*Avertissement: Le protocole détaillé de synchronisation n'a pas encore été défini.*

#pagebreak()
== Syntaxe DY

Cette partie décrit d'une manière semi-formelle la syntaxe DY et son usage dans PLX.

*Avertissement: ceci est une brouillon, il sera continué les semaines suivantes.*

=== Définition semi-formelle de la syntaxe DY en abstrait

==== Les préfixes
TODO

==== Les types de préfixes
TODO

==== Les propriétés
TODO

==== Longueurs et types de contenu
TODO

==== Hiérarchie implicite
Les fins de ligne définissent la fin du contenu pour les préfixes sur une seule ligne. Le préfixe `exo` supporte plusieurs lignes, son contenu se termine ainsi dès qu'un autre préfixe valide est détecté (ici `check`). La hiérarchie est implicite dans la sémantique, un exercice contient un ou plusieurs checks, sans qu'il y ait besoin d'indentation ou d'accolades pour indiquer les relations de parents et enfants. De même, un check contient une séquence d'action à effectuer (`run`, `see`, `type` et `kill`), ces préfixes n'ont de sens qu'à l'intérieur la définition d'un check (uniquement après une ligne préfixée par `check`).

TODO

==== Détection d'erreurs générales

=== Usage de la syntaxe dans PLX
TODO

=== Exemple d'usage dans PLX
#figure(
  image("../schemas/plx-dy-all.svg", width:100%),
  caption: [Aperçu des possibilités de DY sur un exercice plus complexe],
) <exemple-dy-all>

Le @exemple-dy-all nous montre qu'il existe plusieurs préfixes
- Le préfixe `exo` introduit un exercice, avec un titre sur la même ligne et le reste de la consigne en Markdown sur les lignes suivantes.
- `check` introduit le début d'un check avec un titre, en Markdown également.
- `run` donne la commande de démarrage du programme.
- `skip` avec la propriété `.until` permet de cacher toutes les lignes d'output jusqu'à voir la ligne donnée.
- `see` demande à voir une ou plusieurs lignes en sortie standard.
- `type` simule une entrée au clavier
- et finalement `kill` indique comment arrêter le programme, ici en envoyant le `.signal` `9` sur le processus `qemu-system-arm` (qui a été lancé par notre script `./st`).

Toutes les propriétés sont optionnelles, soit elles ont une valeur par défaut, soit la configuration est implicite.

==== Détection d'erreurs spécifiques à PLX
TODO


