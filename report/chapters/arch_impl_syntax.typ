= Développement de la syntaxe DY <arch_impl_dy>

Cette partie documente les besoins de PLX, la définition et l'implémentation de la syntaxe DY, son parseur, l'intégration dans PLX et son usage via le CLI.

== Vue d'ensemble
Tout l'enjeu de cette syntaxe DY est d'arriver à convertir un bout de texte vers une _struct_ Rust.
#grid(columns: (2fr, 1fr) , gutter: 19pt,
[#figure(
  image("../syntax/course/course.svg", width: 100%),
  caption: [Définition d'un cours PLX en syntaxe DY],
) <course-basic>],
[#figure(
```rust
struct Course {
    name: String,
    code: String,
    goal: String,
}
``` , caption: [Struct Rust\ d'un cours PLX]) <rust-course-struct>]
)
Dans la @course-basic, les clés sont `course`, `code` et `goal`, chaque clé introduit une valeur. Le but est de remplir la struct Rust du @rust-course-struct avec ces valeurs.

Après avoir défini les lignes directrices de conception, nous sommes parti du modèle de données de PLX, pour lister les clés nécessaires. Cette idée de syntaxe DY pourrait être utile à d'autres projets ou d'autres d'exercices, nous ne voulons pas construire un parseur uniquement pour PLX. Nous cherchons à mettre en place une abstraction qui nous permet rapidement de définir d'autres clés et convertir ces données dans une struct Rust associée. La syntaxe DY se base se base d'un côté sur une hiérarchie de clés qui permet de l'autre côté, au coeur du parseur, d'extraire le contenu et de le valider en partie.

Pour des erreurs plus spécifiques que ce qui est possible via les contraintes définies sur la spécification d'une clé, il est possible de définir en Rust des validations plus avancées.

Pour la détection d'erreurs, si on adoptait l'approche des compilateurs de langages de programmation qui échoue la compilation à la moindre erreur, l'expérience serait très frustrante. Au moindre exercice mal retranscrit parmi une centaine présents, tout le cours serait inaccessible dans l'interface de PLX. Nous préférons au contraire accepter d'avoir des objets partielles (un exercice avec un titre vide, mais une consigne et des checks valides par exemple) et d'afficher les erreurs dans l'interface pour avertir des erreurs présentes. Les parties éronnées ne sont pas extraites pour ne pas impacter le reste des données valides.

Le parseur prend en entrée une `String` directement et n'est pas responsable d'aller lire un fichier. Ceci nous permet de parser du contenu sans avoir de fichier sous jaçent, notamment dans des snippets de DY intégrée à une documentation web. Cela laisse aussi le choix de choisir les noms de fichiers par le projet qui intègre la syntaxe. Nous verrons quels fichiers PLX a choisi d'utiliser pour stocker son modèle de données.

Tout le développement du parseur s'est fait en _Test Driven Development_ (TDD), qui s'est révelé très facile à mettre en place comme chaque étape possède des entrées et sorties bien définies.

L'extension de fichier recommendée est `.dy`. Ces fichiers doivent être encodés en UTF8 et le caractère de retour à la ligne doit être le `\n`.

=== Lignes directrices de conception
Ces lignes directrices permettent de mieux comprendre certains choix de clés, de syntaxe ou de stratégie.
+ *Privilégier la facilité plutôt de rédaction, plutôt que la facilité d'extraction*: quand de nouveaux éléments syntaxiques sont ajoutés, l'optimisation de la rédaction est la priorité, face
+ *Pas de tabulations ni d'espace en début de ligne*. Cela introduit le fameux débat des espaces versus tabulations. En utilisant des espaces, le nombre d'espaces devient configurable. Les espaces complexifient un peu la collaboration comme les changements dans Git deviennent plus difficile à lire si deux enseignant·es n'utilisent pas les mêmes réglages.
+ *Une seule manière de définir un objet*. Au lieu d'ajouter différentes variantes pour arriver au même résultat juste pour satisfaire différents style, ne garder qu'une seule possibilité. Dès que des variantes sont introduites, cela complexifie le parseur et l'apprentissage. Pour garder un style commun, il faut discuter pour se mettre d'accord sur le style ou accepter de mixer les variantes dans un cours.
// + *Privilégier une limitation des mouvements du curseur*: lors de la rédaction d'un nouvel exercice, le curseur de l'éditeur ne devrait jamais avoir besoin de retourner en arrière.
+ *Peu de caractères réservés, simple à taper et restreint à certains endroits*. Le moins de caractère réservés doivent être définis car cela pourra rentrer en conflit avec le contenu. Ils doivent toujours restreint à zones spécifiques du texte, pour que ces contraintes puissent être détournées si nécessaire.
+ *Pas de caractères en pairs*. Les caractères réservés ne doivent pas être `()`, `{}`, ou `[]` ou d'autres caractères qui vont toujours ensemble pour délimiter le début et la fin d'un élément. Surtout durant la retranscriptions, ces pairs requièrent des mouvements de curseur plus complexe, pour aller une fois au début et une fois à la fin de la zone délimitée.
+ *Utiliser des clés de préférence courtes*. Si une clé est utilisée très souvent et que son nom est long (plus de 5 lettres), il peut être judicieux de choisir une alternative plus courte. L'alternative peut être un surnom (`exercise` -> `exo`) ou le début (`directory` -> `dir`). Une clé devrait au minimum avoir deux lettres.
+ *Une erreur ne doit pas empêcher le reste de l'extraction*. Le parseur doit détecter les erreurs mais faire comme si elle n'était pas là. Une information manquante prend ainsi une valeur par défaut, pour permettre un usage ou aperçu limité à la place de perdre le reste de l'information.
+ *La struct Rust des objets extraits ne doit pas contraindre la structure de rédaction*. Par exemple, pour une struct `Exo` avec deux champs `name` et `instruction` (consigne), ne doit pas contraindre la rédaction à l'usage de deux clés séparées.
+ *Le seul type natif autorisé est la string*. Les projets qui intègre la syntaxe DY ne récupérent que des strings en valeurs après les clés définies. Contrairement au YAML, TOML et d'autres, aucun type de dates, nombre entiers ou flottants n'est défini pour garder une base minimaliste et éviter toute ambiguités d'interprétation, comme mentionné plusieurs fois dans l'état de l'art. Cela n'empêche pas que ces projets décident de supporter des nouveaux types et s'occupent eux-même du parsing et de la validation de ces valeurs.

Dans l'état actuel, la syntaxe DY n'a pas de tabulations ni d'espace, aucun caractère réservé (la fin de ligne et l'espace sont des séparateurs mais ne sont pas réservés à la syntaxe). Les clés réservées peuvent être échappées pour écrire le mot littéral.

// + Réutiliser des concepts déjà utilisés dans d'autres formats quand ils sont concis: concept de clé comme le YAML, usage des commentaires en `//`

== Modèle de données de PLX et choix des clés
Pour que l'application desktop de PLX fonctionne, nous avons besoin de décrire un cours, divisé en compétences, qui regroupent des exercices. Un exercice définit un ou plusieurs checks. Voici une liste des informations associés à ces quatres objets.
+ *Un cours*: un nom (par exemple `Programmation 2`), un code (souvent il existe un raccourci du nom, comme `PRG2`) et une description de l'objectif du cours. Une liste de compétences.
+ *Une compétence*: un nom, une description et un ensemble d'exercices. Une compétence peut aussi être une sous compétence, pour subdiviser une grande compétence en sous compétences plus spécifiques.
+ *Un exercice*: un nom, une consigne et un ou plusieurs checks pour vérifier le comportement d'un programme.
+ *Un check*: un nom, des arguments à passer au programme, un code d'exit attendu et une séquence d'actions/assertions à lancer. Une action peut être ce qu'on tape au clavier et une assertion concerne la vérification que l'output est correct.

Nous avons ensuite défini la liste de clés et leur hiérarchie pour le modèle de données précédent, ainsi que les structs finales à remplir.
#grid(columns: 2, gutter: 10pt,
[
Un cours
  - `course` est le nom du cours
    - `code` donne un raccourci du nom du cours
    - `goal` pour l'objectif du cours, sur plusieurs lignes
],

figure(
  ```rust
  pub struct DYCourse {
      pub name: String,
      pub code: String,
      pub goal: String,
  }
  ``` , caption: [Simple struct Rust pour un cours]),

[
Une compétence
  - `skill` définit un nom la même ligne et une description optionnel sur les lignes suivantes.
    - `dir` est le dossier dans lequels sont définis les exercices de cette compétences
    - `subskill`: une sous compétence, pour découper en compétences plus spécifiques
],
figure(
  ```rust
  pub struct DYSkill {
      pub name: String,
      pub description: String,
      pub directory: String,
      pub subskills: Vec<DYSkill>,
  }
  ``` , caption: [Le nom et description sont séparés en deux champs pour les compétences]),
  [ Un exercice
  - `exo` définit un nom sur la même ligne et une consigne optionnel sur les lignes suivantes.
    - `check` introduit le début d'un check avec un titre
      - `args` définit les arguments du programme de l'exercice
      - `see` demande à voir une ou plusieurs lignes en sortie standard. L'entrée peut être sur plusieurs lignes.
      - `type` simule une entrée au clavier
      - `exit` définit le code d'exit attendu, valeur optionnelle
  ],
figure(
```rust
pub enum TermAction {
    See(String),
    Type(String),
}
pub struct Check {
    pub name: String,
    pub args: Vec<String>,
    pub exit: Option<i32>,
    pub sequence: Vec<TermAction>,
}
pub struct DYExo {
    pub name: String,
    pub instruction: String,
    pub checks: Vec<Check>,
}
``` , caption: [Définition d'un exercice, avec des checks et la séquence d'action])
)

=== Définition et contraintes des clés
Les clés sont tirés du concept de clé/valeur du JSON. Une clé est une string en minuscule, contenant uniquement des caractères alphabétiques. Elle doit se trouver tout au début d'une ligne sans espace. Si un caractère existe après la clé, il ne peut être que l'espace ou le retour à la ligne `\n`. Ainsi `coursetest` ne contient pas la clé `course`. Les clés introduisent une valeur et parfois le début d'un objet si elles contiennent d'autres clés enfants.

Dans l'exemple de la @keys-example, les clés sont `course`, `code` et `goal`. La clé `course` introduit une valeur (le nom du court) et un objet (le cours) qui contient les valeurs tirées des clés enfants (`code` et `goal`). Les types de valeurs introduites peuvent être soit sur une ligne ou multilignes. La clé `code` introduit la valeur `PRG1`, qui ne peut être définit que sur une ligne, car un code raccourci ne peut pas contenir de retour à la ligne. Tandis que la valeur de la clé `goal` peut s'étendre sur plusieurs lignes. Si une ligne suffit, la valeur est aussi valide.
#figure(
  image("../syntax/keys-example/course.svg", width: 80%),
  caption: [Exemple d'usage de clés et de leur hiérarchie avec un cours PLX],
) <keys-example>

Si du contenu devait contenir un mot qui est aussi utilisé pour une clé il suffit de ne pas le placer au début d'une ligne. Ajouter un espace devant le mot suffit à respecter cette contrainte comme le démontre @escaped-exo. Cet espace supplémentaire n'aura pas d'impact sur l'affichage si le Markdown est interprété en HTML, puisque le rendu graphique d'un navigateur ignore les double espaces.

#figure(
  image("../syntax/escaped-exo/exo.svg", width: 80%),
  caption: [Exemple ],
) <escaped-exo>

Note: les mentions de "clés parents" sur des clés à la racine, concerne le document lui même.
// TODO fix

Les clés, créés dans une spec DY en Rust à l'aide de la struct `KeySpec`, possèdent les attributs suivants
+ `id`: le texte de la clé (exemple `course`), qui doit être unique pour toute la spec DY
+ `desc`: Une description qui sert à documenter le but de la clé, qui sera utile pour la documentation au survol et l'autocomplétion pour le futur serveur de langage
+ `subkeys`: un vecteur de sous clés possibles, qui peut être vide.
+ `vt`: Un type de valeur, soit ligne simple soit multilignes, défini via l'enum `ValueType`.
+ `once`: champ booléen qui définit si la clé ne peut se retrouver qu'une seule fois dans chaque objet définit par la clé parent.
+ `required`: si la clé doit exister au moins une fois dans tout objet de la clé parent et si une valeur est requise pour la clé. Si ces contraintes ne sont pas respectées des erreurs `MissingRequiredKey` ou `MissingRequiredValue` sont générées.

Une valeur ne peut être que de type string (ce qui nous permet d'éviter les guillements ou certaines ambiguités). Elle commence après la clé et se termine dès qu'une autre clé valide est trouvée ou que la fin du fichier est atteint. Si le type de valeur (attribut `vt`) est une ligne simple, alors le contenu s'arrête à la fin de la ligne, les lignes suivantes seront ignorées. Si celles-ci ne sont pas vides, cela causera une erreur de `InvalidMultilineContent`.

== Définition d'une hiérarchie de clés en Rust

Après avoir présenté les attributs de la struct `KeySpec`, voici un exemple concret de définition en Rust de spec DY. Nous avons défini sur le @speccourse une constante par clé, puis regroupés les clés `goal` et `code` en sous clés de `course`.

#figure(
```rust
const GOAL_KEYSPEC: &KeySpec = &KeySpec {
    id: "goal",
    desc: "The goal key describes the learning goals of this course.",
    subkeys: &[],
    vt: ValueType::Multiline,
    once: true,
    required: true,
};
const CODE_KEYSPEC: &KeySpec = &KeySpec {
    id: "code",
    desc: "The code of the course is a shorter name of the course, under 10 letters usually.",
    subkeys: &[],
    vt: ValueType::SingleLine,
    once: true,
    required: true,
};
const COURSE_KEYSPEC: &KeySpec = &KeySpec {
    id: "course",
    desc: "A PLX course is grouping skills and exos related to a common set of learning goals.",
    subkeys: &[CODE_KEYSPEC, GOAL_KEYSPEC],
    vt: ValueType::SingleLine,
    once: true,
    required: true,
};
pub const COURSE_SPEC: &DYSpec = &[COURSE_KEYSPEC];
``` , caption: [Exemple de définition en Rust de la spec DY des cours PLX, avec 3 `KeySpec` pour les 3 clés]) <speccourse>

Le tableau de `KeySpec` final (alias de type `DYSpec`) de toutes les clés autorisées à la racine, doit encore être validé. Un type _wrapper_ `ValidDYSpec` permet de valider que chaque id de clé est bien unique.

#grid(columns: 2, gutter: 10pt,
figure(
  image("../syntax/specs/course.spec.svg", width: 100%),
  caption: [Aperçu graphique de la spec DY des cours.],
),

figure(
  image("../syntax/specs/skills.spec.svg", width: 100%),
  caption: [Aperçu graphique de la spec DY des compétences.],
)
)

#figure(
  image("../syntax/specs/exo.spec.svg", width: 90%),
  caption: [Aperçu graphique de la spec DY des exercices PLX. La clé `exo`, `check` et `see` sont obligatoires (`required`)],
)



=== Commentaires
Pour permettre de communiquer des informations supplémentaires durant la rédaction, les commentaires sont supportés et ne sont visibles que dans le fichier directement. Le parseur les ignore et ne se rappelle pas de leur position. Les commentaires ne peuvent être définits que sur une ligne dédiée, les 2 premiers caractères de la ligne doivent être `//` et le reste de la ligne est complètement libre. Le texte tel que `exo intro // c'est basique` n'est pas considéré comme un incluant commentaire, contrairement au C et d'autres langages.

=== Support du Markdown
Tous les champs supportent le Markdown, cela signifie que les snippets de code en Markdown sont considérées comme du contenu par notre parseur. La zone concernée commence par #raw("```") ou `~~~`, elle est ignorée jusqu'à trouver le même marqueur. Ainsi, de potentielles clés ou commentaires présents ne sont pas considérés, ce qui permet de préserver les commentaires de code.

#figure(
  image("../syntax/meta-exo/exo.svg", width: 90%),
  caption: [Exercice avec une consigne qui contient un bloc de code contenant lui-même un autre exercice en DY.\ Le contenu du bloc de code n'est pas interprété et la consigne se termine avant le `check` colorisé],
)

== Abstraction du coeur du parseur

Nous ne voulons pas créer de parseur spécifique aux données d'un cours ni même des données de PLX. A la place, nous souhaitons pouvoir utiliser une abstraction qui nous permette de facilement définir des nouveaux objets en DY et avec le minimum de code pour l'extraire dans une struct Rust dédiée. Nous ne pouvons pas tout implémenter au même endroit, car cela demanderait de constamment changer la logique du parseur pour s'adapter à de nouvelles clés.

L'implémentation est donc divisée en deux parties très claires: le coeur du parseur et les spécifications DY (appelées par la suite #quote("spec DY")). Les deux sont indispensables et leur combinaison permet de parser du contenu définit par un spec DY. L'implémentation est faite dans deux crates Rust: le coeur du parseur dans la crate `dy` et la spec DY pour PLX dans la crate `plx-dy`.

#figure(
  image("../schemas/parser-core-specs-separation.png", width:100%),
  caption: [Aperçu de l'abstraction du coeur du parseur et des specs DY],
) <parser-core-specs-separation>


#figure(
```rust
pub fn parse_course(some_file: &Option<String>, content: &str) -> ParseResult<DYCourse> {
    parse_with_spec::<DYCourse>(
        &ValidDYSpec::new(COURSE_SPEC).expect("COURSE_SPEC is invalid !"),
        some_file,
        content,
    )
}
``` , caption: [Exemple d'usage de `parse_with_spec` pour définir la fonction `parse_course`]) <parse-with-spec-example>

// todo update tout vers prg2 !!!

Le coeur du parseur ne connait _que_ le concept de clé, de leur hiérarchie, des propriétés et des commentaires. Il ne sait pas savoir quelles clés et propriétés seront utilisées au final. Une spec DY définit des clés et leur hiérarchie. Elle définit en Rust comment construire la struct final à partir du résultat du coeur du parseur. Elle peut aussi générer d'autres erreurs spécifiques si nécessaire.

Pour faire un parallèle avec le JSON, son parseur est indépendant de son validateur de schéma (du projet JSON Schema @JsonSchemaWebsite), il est facile de déterminer où sont les clés et valeurs en JSON grâce au nombreux séparateurs (`:` et `"`). En DY, le coeur du parseur est incapable de déterminer si une ligne commence par une clé ou non, comme un clé n'est pas distinguable des autres mots tant que ce mot n'est pas définie comme une clé.

C'est comme si on avait fusionné le code du parseur JSON et de son validateur, tout en ne donnant le schéma à valider qu'au moment de parser un document.

En DY, la spec DY est le schéma et se définit directement en Rust au lieu d'être dans un fichier texte comme pour les schémas JSON. Cette spec DY est un paramètre du coeur du parseur qui va mixer l'extraction du contenu et une partie de sa validation en se basant sur cette spec.

== Etapes du coeur du parseur

Dans la @steps, la vue d'ensemble des étapes haut niveaux est présentées. Avec le type génLe contenu est découpé en ligne, 

#figure(
  image("../schemas/parser-steps.png", width: 90%),
  caption: [Etapes haut-niveau du coeur du parseur, via son point d'entrée `parse_with_spec<T>`],
)<steps>

#figure(
```rust
pub struct ParseResult<T> {
    pub items: Vec<T>,
    pub errors: Vec<ParseError>,
    pub some_file_path: Option<String>,
    pub some_file_content: Option<String>,
}
``` , caption: [La struct décrivant un vecteur de résultat de type générique, incluant les erreurs trouvées. Le nom du fichier, si disponible et contenu sont inclus pour permettre l'affichage des erreurs])

#figure(
```rust
pub trait FromDYBlock<'a> {
    fn from_block_with_validation(block: &Block<'a>) -> (Vec<ParseError>, Self);
}
``` , caption: [Un trait (interface) `FromDYBlock` qui impose d'implémentater `from_block_with_validation`, utilisé sur chaque struct final associée à une spec DY])

#figure(
```rust
pub fn parse_with_spec<'a, T>(
    spec: &'a ValidDYSpec,
    some_file: &Option<String>,
    content: &'a str,
) -> ParseResult<T>
where
    T: FromDYBlock<'a> {...}
``` , caption: [La définition de `parse_with_spec`, avec la contrainte que `T` doit implémenter le trait `FromDYBlock`])


=== Catégorisation des lignes
La première étape consiste à prendre le fichier brut, d'itérer sur chaque ligne et de catégoriser la ligne pour définir si elle contient une clé (`WithKey`) ou non (`Unknown`). Une liste de toutes les clés présente dans l'arbre `ValidDYSpec` est extraite. Pour ne comparer à chaque fois toutes les clés, elles sont regroupées par longueur dans une `HashMap`. A chaque ligne, on extrait le premier mot et on regarde uniquement les clés de même longeur que ce mot.

#figure(
  image("../syntax/exo/exo.svg", width: 100%),
  caption: [Reprenons l'exercice Salue-moi en exemple],
)

#figure(
  text(size: 0.8em)[

```rust
Line { index: 0, slice: "exo Salue-moi", lt: WithKey(KeySpec 'exo')},
Line { index: 1, slice: "Un petit programme qui te salue avec ton nom complet.", lt: Unknown},
Line { index: 2, slice: "", lt: Unknown},
Line { index: 3, slice: "check Il est possible d'être salué avec son nom complet", lt: WithKey(KeySpec 'check')},
Line { index: 4, slice: "see Quel est ton prénom ?", lt: WithKey(KeySpec 'see') },
Line { index: 5, slice: "type John", lt: WithKey(KeySpec 'type') },
Line { index: 6, slice: "see Salut John, quel est ton nom de famille ?", lt: WithKey(KeySpec 'see')},
Line { index: 7, slice: "type Doe", lt: WithKey(KeySpec 'type',) },
Line { index: 8, slice: "see Passe une belle journée John Doe !", lt: WithKey(KeySpec 'see')},
Line { index: 9, slice: "exit 0", lt: WithKey(KeySpec 'exit')},
```], caption: [Liste de lignes avec un index, la référence vers le morceau de texte de la ligne, ainsi que type de ligne `lt`]) <somelines>

=== Construction d'un arbre de blocs
Cet arbre représente la hiérarchie des clés et valeurs trouvées et respecte en tout temps la hiérarchie de `ValidDYSpec`. Un bloc contient le texte extrait (sous forme de vecteur de lignes), la plage du contenu concerné (`Range`) et une référence vers la définition de la clé associée au bloc. Les erreurs recontrées au fur et à mesure n'impacte pas cet arbre et sont insérées dans une liste d'erreurs séparées. Les commentaires ne sont pas inclus.

#figure(
  image("../syntax/blocks/salue-moi-blocks.svg", width:100%),
  caption: [Arbre de blocs généré à partir des lignes du @somelines, les blocs sont ordrés de haut en bas.],
)

=== Conversion vers la struct T

Grâce à l'interface `FromDYBlock`, nous pouvons donner chaque bloc racine à la méthode `T::from_block_with_validation(&block)` afin qu'il puisse être converti en type `T` et générer d'autres erreurs si nécessaires. La liste d'erreur créé durant la construction de l'arbre de blocs 




=== Hiérarchie implicite
Les fins de ligne définissent la fin du contenu pour les clés sur une seule ligne. La clé `exo` supporte plusieurs lignes, son contenu se termine ainsi dès qu'une autre clé valide est détecté (ici `check`). La hiérarchie est implicite dans la sémantique, un exercice contient un ou plusieurs checks, sans qu'il y ait besoin d'indentation ou d'accolades pour indiquer les relations de parents et enfants. De même, un check contient une séquence d'actions à effectuer (`run`, `see`, `type` et `kill`), ces clés n'ont de sens qu'à l'intérieur la définition d'un check (uniquement après une ligne avec la clé `check`).

TODO

=== Détection d'erreurs générales

== Usage de la syntaxe dans PLX
La crate `plx-dy` définit les noms des fichiers dans lesquels se trouvent les définitions de nos 3 objets. Le cours est décrit dans `course.dy`, les compétences dans `skills.dy` et chaque exercice dans un fichier `exo.dy` dans son dossier à coté du code et de ses solutions. Le fichier `live.toml` est attendue à la racine également.
#figure(
```
.
├── README.md
├── course.dy
├── skills.dy
├── live.toml
├── intro
│   ├── basic-args
│   │   ├── exo.dy
│   │   ├── main.c
│   │   └── main.sol.c
│   └── salue-moi
│       ├── debug.log
│       ├── exo.dy
│       └── main.c
├── structs
    └── meeting-participants
        ├── exo.dy
        ├── main.cpp
        └── main.sol.cpp
``` , caption: [Exemple de structure de fichiers pour un cours PLX de démonstration, avec 2 compétences et 3 exercices.])

==== Détection d'erreurs spécifiques à PLX
TODO

TODO fix headings level

== Implémentation de la librairie `dy`
TODO

== Intégration de `plx-dy`

La première intégration a été faite dans le CLI (qui permet aussi de démarrer le serveur, pour rappel). Ce CLI est utile pour que les enseignant·es puissent vérifier que le contenu du contenu d'un cours PLX est valide. Dans le futur, il pourrait aussi servir à d'autres outils qui pourrait réutiliser le JSON généré, par exemple pour insérer les exercices dans une base de données.

#figure(
```
> plx parse -h
Parse the given DY file or parse the course.dy inside given folder

Usage: plx parse [OPTIONS] <PATH>

Arguments:
  <PATH>  A PLX file with a .dy extension, or a folder with a course.dy

Options:
      --full  Enable the full course parsing in PLX's format. Only valid with a folder
``` , caption: [Aide de la sous commande `plx parse`])

#figure(
  image("../syntax/course/course.svg", width: 100%),
  caption: [Définition d'un cours PLX dans un fichier `course.dy`],
)
#figure(
  image("../syntax/course/course-parsed.svg", width: 100%),
  caption: [Equivalent extrait du parseur et affiché en JSON],
)

#pagebreak()
#figure(
  image("../syntax/course-error/course.svg", width: 100%),
  caption: [Définition incorrecte d'un cours PLX dans un fichier `course.dy`.\ Le `goal` manque et le `code` doit être placé après la clé `course`.],
)
#figure(
  image("../syntax/course-error/course-parsed.svg", width: 100%),
  caption: [Les erreurs ont été détectées par le parseur],
)

#pagebreak()
#figure(
  image("../syntax/skills/skills.svg", width: 100%),
  caption: [TODO `skills.dy`],
)
#figure(
  image("../syntax/skills/skills-parsed.svg", width: 100%),
  caption: [TODO],
)
#pagebreak()
#figure(
  image("../syntax/skills-error/skills.svg", width: 100%),
  caption: [TODO `skills.dy`],
)
#figure(
  image("../syntax/skills-error/skills-parsed.svg", width: 100%),
  caption: [TODO],
)


#pagebreak()
#figure(
  image("../syntax/exo/exo.svg", width: 100%),
  caption: [TODO `exo.dy`],
)
#figure(
  image("../syntax/exo/exo-parsed.svg", width: 100%),
  caption: [TODO],
)

#pagebreak()
#figure(
  image("../syntax/exo-error/exo.svg", width: 100%),
  caption: [TODO `exo.dy`],
)
#figure(
  image("../syntax/exo-error/exo-parsed.svg", width: 100%),
  caption: [TODO],
)


// todo fix heading levels and names
=== Tests unitaires

#figure(
```
> cargo test
running 22 tests
test parser::tests::test_line_into_parts ... ok
test semantic::tests::test_can_build_blocks_for_complex_skills ... ok
test semantic::tests::test_can_detect_content_out_of_key ... ok
test semantic::tests::test_can_build_blocks_with_multiline_keys_ignoring_comments ... ok
test parser::tests::test_can_tokenize_comments_and_empty ... ok
test semantic::tests::test_can_detect_duplicated_key_error ... ok
test parser::tests::test_can_tokenize_and_ignore_anything_inside_code_blocks ... ok
test semantic::tests::test_can_detect_invalid_multiline_content ... ok
test parser::tests::test_line_starts_with_key ... ok
test semantic::tests::test_can_detect_wrong_key_positions ... ok
test semantic::tests::test_required_key_also_work_at_root ... ok
test semantic::tests::test_missing_keys_and_values_with_required_keys_are_detected ... ok
test semantic::tests::test_empty_lines_are_present_in_block_text ... ok
test semantic::tests::test_can_extract_complex_exos_blocks_with_errors_ignorance ... ok
test semantic::tests::test_strange_exo_parsing_can_correctly_ignore_error ... ok
test parser::tests::test_can_tokenize_lines_with_invalid_keys_and_empty_lines ... ok
test parser::tests::test_can_tokenize_basic_lines ... ok
test semantic::tests::test_can_build_blocks_for_simple_course ... ok
test spec::tests::test_can_validate_valid_spec ... ok
test spec::tests::test_empty_spec_is_invalid ... ok
test spec::tests::test_spec_with_duplicated_key_at_root ... ok
test spec::tests::test_spec_with_duplicated_key_deeply ... ok

running 10 tests
test course::tests::test_can_parse_simple_valid_course ... ok
test course::tests::test_parse_result_display_is_also_correct ... ok
test course::tests::test_parse_result_display_can_highlight_unknown_content ... ok
test course::tests::test_parse_result_display_is_correct ... ok
test exo::tests::test_can_extract_args_by_space_split ... ok
test exo::tests::test_can_error_on_invalid_exit_code ... ok
test exo::tests::test_detect_empty_args_error_but_ignores_empty_type ... ok
test skill::tests::test_can_detect_subskill_missing_value ... ok
test exo::tests::test_can_parse_a_simple_exo ... ok
test skill::tests::test_can_parse_simple_skills ... ok
``` , caption: [Aperçu des 32 tests unitaires développés pour les crates `dy` et `plx-dy`])

Pour mieux se représenter à quoi ressemble ces tests. Ce test `test_can_error_on_invalid_exit_code` petit test pour s'assurer que l'implémentation de `FromDYBlock` pour `DYExo` détecte bien l'erreur d'un code d'exit non numérique et qu'il prend sa valeur par défaut (`None`). On s'assure aussi que le reste de l'exercice est extrait correctement (titre, check, see).

#figure(
```rust
    #[test]
    fn test_can_error_on_invalid_exit_code() {
        let text = "exo thing
check test
see hello
exit blabla
";
        let some_file = &Some("exo.dy".to_string());
        assert_eq!(
            parse_exos(some_file, text),
            ParseResult {
                some_file_path: some_file.clone(),
                some_file_content: Some(text.to_string()),
                items: vec![DYExo {
                    name: "thing".to_string(),
                    instruction: "".to_string(),
                    checks: vec![Check {
                        name: "test".to_string(),
                        args: vec![],
                        exit: None,
                        sequence: vec![TermAction::See("hello".to_string())],
                    }]
                }],
                errors: vec![ParseError {
                    range: range_on_line_part(3, 5, 11),
                    error: ParseErrorType::ValidationError(
                        ERROR_CANNOT_PARSE_EXIT_CODE.to_string()
                    )
                }]
            }
        )
    }
``` , caption: [Aperçu des 32 tests unitaires développés pour les crates `dy` et `plx-dy`])

#figure(
```
``` , caption: [Aperçu des 32 tests unitaires développés pour les crates `dy` et `plx-dy`])



== Conclusion
// todo fix header level

TODO add these ideas

Grâce à la connaissance des clés à extraire, la hiérarchie peut être implicite.

moins de chose représentée, juste les éléments des specs définis et peu de strucures de données. mais extensible via le post processing. chaque projet peut ainsi choisir de définir des éléments supplémentaires de post parsing.

