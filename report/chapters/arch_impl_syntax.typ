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
Dans la @course-basic, les clés sont `course`, `code` et `goal`, chaque clé introduit une valeur sur la même ligne. Ces valeurs doivent être extraites et doivent permet de remplir la struct Rust du @rust-course-struct.

Nous sommes parti du modèle de données de PLX, en définissant les clés possibles et leur contraintes. Cette idée de syntaxe DY pourrait être très utile à d'autres projets ou d'autres d'exercices, nous ne voulons pas construire un parseur uniquement pour PLX. Nous cherchons plutôt à mettre en place une abstraction qui nous permet rapidement de définir d'autres clés, des erreurs de validation avancée pour ses clés et le moyens de convertir les données extraites dans une struct Rust associé. La syntaxe DY se base sur une hiérarchie de clés qui permet au parseur d'extraire le contenu et de le valider en partie.

Pour des erreurs plus spécifiques, il est possible de définir en Rust des validations plus avancées.

Pour la détection d'erreurs, si on adoptait l'approche des compilateurs de langages de programmation qui échoue la compilation à la moindre erreur, l'expérience serait très frustrante. Au moindre exercice mal retranscrit parmi une centaine présents, tout le cours serait inaccessible dans l'interface de PLX.

Nous préférons avoir des structures partielles (un exercice avec un titre vide) et d'afficher les erreurs dans l'interface pour avertir qu'une erreur est présente. La structure éronnée est ignorée tout en préservant ce qui a pu être extrait, quitte à utiliser des valeurs par défaut ou vides. 
// todo how to improve

Le parseur prend en entrée une `String` directement et n'est pas responsable d'aller lire un fichier. Ceci nous permet de parser du contenu sans avoir de fichier sous jaçent, notamment dans des snippets de DY intégrée à une documentation web. Nous verrons quels fichiers PLX a choisi d'utiliser pour stocker son modèle de données.

Tout le développement du parseur s'est fait en _Test Driven Development_ (TDD), ce qui était facile à mettre en place comme chaque étape possède des entrées et sorties bien définies.

== Modèle de données de PLX et choix des clés
Avant de spécifier une syntaxe et d'implémentater un parseur, il est nécessaire de définir les données que nous souhaitons extraire.

Pour que l'application desktop de PLX fonctionne, nous avons besoin de décrire un cours, divisé en compétences, qui regroupent des exercices. Un exercice définit un ou plusieurs checks. Voici une liste des informations associés à ces quatres objets.
+ *Un cours*: un nom (par exemple `Programmation 2`), un code (souvent il existe un raccourci du nom, comme `PRG2`) et une description de l'objectif du cours. Une liste de compétences.
+ *Une compétence*: un nom, une description et un ensemble d'exercices. Une compétence peut aussi être une sous compétence, afin de diviser un niveau de plus et rendre les sous compétences plus spécifiques.
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

== Définition de la syntaxe DY


// todo tout spoiler dans les grandes lignes ici.
=== Lignes directrices
Ces lignes directrices sont la base de tous les choix de conceptions de la syntaxe.
+ *Pas de tabulations ni d'espace en début de ligne*. Cela introduit le fameux débat des espaces versus tabulations. En utilisant des espaces, le nombre d'espaces devient configurable. Cela complexifie la collaboration et le démarrage. Les changements dans Git deviennent plus difficile à lire si deux enseignant·es n'utilisent pas les mêmes réglages.
+ *Une seule manière de définir une chose*. Au lieu d'ajouter différentes variantes pour faire la même chose juste pour satisfaire différents style, ne garder qu'une seule possibilité. Dès que des variantes sont introduites, cela complexifie le parseur et l'apprentissage. Dans un cours PLX, il faut à nouveau se mettre d'accord sur le style.
// + *Privilégier une limitation des mouvements du curseur*: lors de la rédaction d'un nouvel exercice, le curseur de l'éditeur ne devrait jamais avoir besoin de retourner en arrière.
+ *Peu de caractères réservés, simple à taper et restreint à certains endroits*. Le moins de caractère réservés doivent être définis car cela pourra rentrer en conflit avec le contenu. Ils doivent toujours être possible dans des zones restreintes du texte, pour que ces contraintes puissent être détournées si nécessaire.
+ *Pas de pairs caractères pour les caractères réservés*. Les caractères réservés ne doivent pas être `()`, `{}`, ou `[]` ou d'autres caractères qui vont toujours ensemble pour délimiter le début et la fin d'un élément. Ces pairs requièrent des mouvements de curseur plus complexe, pour aller une fois au début et une fois à la fin de la zone délimitée.
+ *Une erreur ne doit pas empêcher le reste de l'extraction*
+ *Privilégier la facilité plutôt de rédaction, plutôt que la facilité d'extraction*
+ *La struct Rust des objets extraits ne doit pas contraindre la structure de rédaction*. Par exemple, pour une struct `Exo` avec deux champs `name` et `instruction` (consigne), ne doit pas contraindre la rédaction à l'usage de deux clés.

L'usage d'un formatteur pourrait aider, sauf si une partie ne l'utilise pas.

- No tabs at start of lines, because it introduces the tab vs space issue, the tab size when replaced by spaces, etc... The hierarchy should be represented by specific keyword marking the parent and child elements. it means the document can have formatting errors if the tabulation is not correct, thus requiring a formatter to fix these errors, thus making huge git diff if someone doesn't have or doesn't run this formatter...
+ Réutiliser des concepts déjà utilisés dans d'autres formats quand ils sont concis: concept de clé comme le YAML, usage des commentaires en `//`
+

=== Définition et contraintes des clés
Les clés sont tirés du concept de clé/valeur du JSON. Une clé est une string en minuscule, contenant uniquement des caractères alphabétiques. Elle doit se trouver tout au début d'une ligne sans espace avant. Les clés introduisent une valeur et parfois le début d'un objet si elles contiennent d'autres clés enfants.

Dans l'exemple de la @keys-example, les clés sont `course`, `code` et `goal`. La clé `course` introduit une valeur (le nom du court) et un objet (le cours) qui contient les valeurs tirées des clés enfants (`code` et `goal`). Les types de valeurs introduites peuvent être soit sur une ligne ou multilignes. La clé `code` introduit la valeur `PRG1`, qui ne peut être définit que sur une ligne, car un code raccourci ne peut pas contenir de retour à la ligne. Tandis que la valeur de la clé `goal` peut s'étendre sur plusieurs lignes. Si une ligne suffit, cela est aussi valide.
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
+ `id`: le texte de la clé (exemple `course`), qui doit être unique à travers la syntaxe
+ `desc`: Une description qui sert à documenter le but de la clé, qui sera utile pour la documentation au survol et l'autocomplétion pour le futur serveur de langage
+ `subkeys`: un vecteur de sous clés possibles, qui peut être vide.
+ `vt`: Un type de valeur, soit ligne simple soit multilignes, défini via l'enum `ValueType`.
+ `once`: champ booléen qui définit si la clé ne peut se retrouver qu'une seule fois dans chaque objet définit par la clé parent.
+ `required`: si la clé doit exister au moins une fois dans tout objet de la clé parent et si une valeur est requise pour la clé. Si ces contraintes ne sont pas respectées des erreurs `MissingRequiredKey` ou `MissingRequiredValue` sont générées.

Une valeur ne peut être que de type string. Elle commence après la clé et se termine dès qu'une autre clé valide est trouvée ou que la fin du fichier est atteint. Si le type de valeur (attribut `vt`) est une ligne simple, alors le contenu s'arrête à la fin de la ligne, les lignes suivantes qui ne contiendrait pas de 

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
``` , caption: [Exemple de définition en Rust de la spec DY des cours PLX, avec 3 `KeySpec` pour les 3 clés])

Les lignes vident sont autorisées. Elles n'ont pas d'impact ...

// que string (ce qui nous permet d'éviter les guillements ou des ambiguités)

=== Commentaires
Pour permettre de communiquer des informations supplémentaires durant la rédaction, les commentaires sont supportés et ne sont visibles que dans le fichier directement. Le parseur les ignore et ne se rappelle pas de leur position. Les commentaires ne peuvent être définits que sur une ligne dédiée, les 2 premiers caractères de la ligne doivent être `//` et le reste de la ligne est complètement libre. Le texte tel que `exo intro // c'est basique` n'est pas considéré comme un incluant commentaire, contrairement au C et d'autres langages.

=== Support du Markdown
Tous les champs supportent le Markdown, cela signifie que les snippets de code en Markdown sont considérées comme du contenu par notre parseur. La zone concernée commence par #raw("```") ou `~~~`, elle est ignorée jusqu'à trouver le même marqueur. Ainsi, de potentielles clés ou commentaires présents ne sont pas considérés, ce qui permet de préserver les commentaires de code.

#figure(
  image("../syntax/meta-exo/exo.svg", width: 90%),
  caption: [Exercice avec une consigne qui contient un bloc de code contenant lui-même un autre exercice en DY.\ Le contenu du bloc de code n'est pas interprété et la consigne se termine avant le `check` colorisé],
)

=== Hiérarchie implicite
Les fins de ligne définissent la fin du contenu pour les clés sur une seule ligne. La clé `exo` supporte plusieurs lignes, son contenu se termine ainsi dès qu'une autre clé valide est détecté (ici `check`). La hiérarchie est implicite dans la sémantique, un exercice contient un ou plusieurs checks, sans qu'il y ait besoin d'indentation ou d'accolades pour indiquer les relations de parents et enfants. De même, un check contient une séquence d'actions à effectuer (`run`, `see`, `type` et `kill`), ces clés n'ont de sens qu'à l'intérieur la définition d'un check (uniquement après une ligne avec la clé `check`).

TODO

=== Détection d'erreurs générales

== Usage de la syntaxe dans PLX
TODO
Toutes les propriétés sont optionnelles, soit elles ont une valeur par défaut, soit la configuration est implicite.

==== Détection d'erreurs spécifiques à PLX
TODO

TODO fix headings level

== Implémentation de la librairie `dy`
TODO

== Intégration de `dy` dans PLX
TODO

#figure(
  image("../syntax/specs/course.spec.svg", width: 50%),
  caption: [Aperçu graphique de la spec DY des cours.],
)
#figure(
  image("../syntax/specs/skills.spec.svg", width: 50%),
  caption: [Aperçu graphique de la spec DY des compétences.],
)

#figure(
  image("../syntax/specs/exo.spec.svg", width: 90%),
  caption: [Aperçu graphique de la spec DY des exercices PLX.],
)


#pagebreak()
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

== Conclusion
// todo fix header level

TODO add these ideas

Grâce à la connaissance des clés à extraire, la hiérarchie peut être implicite.

moins de chose représentée, juste les éléments des specs définis et peu de strucures de données. mais extensible via le post processing. chaque projet peut ainsi choisir de définir des éléments supplémentaires de post parsing.

