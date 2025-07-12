= Développement de la syntaxe DY <arch_impl_dy>

Cette partie documente la définition et l'implémentation de la syntaxe DY, son parseur, l'intégration dans PLX et l'intégration IDE.

== Définition de la syntaxe DY

=== Vue d'ensemble
// todo tout spoiler dans les grandes lignes ici.
Nous avons vu précédemment différent exemples d'exercices de C décrits dans notre syntaxe. Lister des exemples n'est pas forcément suffisant pour comprendre les possibilités, contraintes et règles qui ont été choisie.

=== Lignes directrices
Ces lignes directrices sont la base de tous les choix de conceptions de la syntaxe.
+ *Pas de tabulations ni d'espace en début de ligne*. Cela introduit le fameux débat des espaces versus tabulations. En utilisant des espaces, le nombre d'espaces devient configurable. Cela complexifie la collaboration et le démarrage. Les changements dans Git deviennent plus difficile à lire si deux enseignant·es n'utilisent pas les mêmes réglages.
+ *Une seule manière de définir une chose*. Au lieu d'ajouter différentes variantes pour faire la même chose juste pour satisfaire différents style, ne garder qu'une seule possibilité. Dès que des variantes sont introduites, cela complexifie le parseur et l'apprentissage. Dans un cours PLX, il faut à nouveau se mettre d'accord sur le style.
// + *Privilégier une limitation des mouvements du curseur*: lors de la rédaction d'un nouvel exercice, le curseur de l'éditeur ne devrait jamais avoir besoin de retourner en arrière.
+ *Peu de caractères réservés, simple à taper et restreint à certains endroits*. Le moins de caractère réservés doivent être définis car cela pourra rentrer en conflit avec le contenu. Ils doivent toujours être possible dans des zones restreintes du texte, pour que ces contraintes puissent être détournées si nécessaire.
+ *Pas de pairs caractères pour les caractères réservés*. Les caractères réservés ne doivent pas être `()`, `{}`, ou `[]` ou d'autres caractères qui vont toujours ensemble pour délimiter le début et la fin d'un élément. Ces pairs requièrent des mouvements de curseur plus complexe, pour aller une fois au début et une fois à la fin de la zone délimitée.
+ *Une erreur ne doit pas empêcher le reste de l'extraction*
+ *Privilégier la facilité plutôt de rédaction, plutôt que la facilité d'extraction*
+ *La structure Rust des objets extraits ne doit pas contraindre la structure de rédaction*. Par exemple, pour une structure `Exo` avec deux champs `name` et `instruction` (consigne), ne doit pas contraindre la rédaction à l'usage de deux clés.

L'usage d'un formatteur pourrait aider, sauf si une partie ne l'utilise pas.

- No tabs at start of lines, because it introduces the tab vs space issue, the tab size when replaced by spaces, etc... The hierarchy should be represented by specific keyword marking the parent and child elements. it means the document can have formatting errors if the tabulation is not correct, thus requiring a formatter to fix these errors, thus making huge git diff if someone doesn't have or doesn't run this formatter...
+ Réutiliser des concepts déjà utilisés dans d'autres formats quand ils sont concis: concept de clé comme le YAML, usage des commentaires en `//`
+

=== Besoin 

=== Les clés
TODO

=== Les types de clés
TODO

=== Les propriétés
TODO

=== Longueurs et types de contenu
TODO

=== Commentaires
Pour permettre de communiquer des informations supplémentaires durant la rédaction, les commentaires sont supportés et ne sont visibles qu'aux personnes qui participent à la rédaction. Les commentaires ne peuvent être définit que sur une ligne dédiée, les 2 premiers caractères de la ligne doivent être `//`, le reste de la ligne est complètement libre.

Si la consigne d'un exercice contient un morceau de code, nous ne souhaitons pas que les commentaires soient retirés dans ce code. Ce ne sont pas les mêmes types de commentaires malgré leur préfixe qui pourrait être le même. Pour résoudre ce problème, les commentaires de notre syntaxe ne sont supportés qu'à l'extérieur des blocs de code Markdown, c'est à dire en dehors des zones délimitées par #raw("```") ou par `~~~`.

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
