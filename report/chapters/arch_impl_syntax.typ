= Développement de la syntaxe DY <arch_impl_dy>

Cette partie documente les besoins de PLX, la définition et l'implémentation de la syntaxe DY, son parseur, l'intégration dans PLX et son usage via le CLI.

Le code de cette partie a été développé sur le repository #link("https://github.com/samuelroland/dy") qui contient les deux librairies `dy` et `plx-dy`. Le parseur a été intégré ensuite dans le repository #link("https://github.com/samuelroland/plx") avec le CLI (sous dossier `cli`) et dans les fichiers de modèles (`src/models`).

== Vue d'ensemble
Tout l'enjeu de ce développement consiste à prendre un bout de texte écrit dans notre syntaxe DY et de la convertir vers une struct Rust.
#grid(columns: (2fr, 1fr) , gutter: 19pt,
[#figure(
  image("../syntax/course/course.svg", width: 100%),
  caption: [Définition d'un cours PLX en syntaxe DY],
) <course-basic>],
[#figure(
```rust
struct DYCourse {
    name: String,
    code: String,
    goal: String,
}
``` , caption: [Struct Rust\ d'un cours PLX]) <rust-course-struct>]
)
Dans la @course-basic, les clés sont `course`, `code` et `goal`, chaque clé introduit une valeur. Le but est de remplir la struct Rust du @rust-course-struct avec ces valeurs.

Nous souhaitons aussi intégrer une validation du document à notre parseur et de permettre un affichage dans ce style de la @styleerror.
#figure(
  image("../syntax/course-error/course-parsed.svg", width: 80%),
  caption: [Exemple d'affichage d'erreurs],
) <styleerror>

Cette idée de syntaxe légère et optimisée pour l'écriture par des humains peut être utile à d'autres projets ou d'autres exercices en dehors de la programmation, le but n'est pas de construire un parseur spécifique à PLX. Nous cherchons à mettre en place une abstraction qui nous permet rapidement d'intégrer cette syntaxe dans un autre contexte qui souhaite utiliser des fichiers textes structurés. La syntaxe DY se base d'un côté sur une hiérarchie de clés, qui est fournie au coeur du parseur afin d'extraire le contenu et de le valider en partie. Pour des erreurs plus spécifiques que la vérification des contraintes définies sur les clés, il est possible de définir en Rust des validations plus avancées.

Pour la détection d'erreurs, si on adoptait l'approche des compilateurs de langages de programmation qui échoue la compilation à la moindre erreur, l'expérience serait très frustrante. Au moindre exercice mal retranscrit parmi une centaine présents, tout le cours serait inaccessible dans l'interface de PLX. Nous préférons au contraire accepter d'avoir des objets partiels (un exercice avec un titre vide, mais une consigne et des checks valides par exemple) et d'afficher les erreurs dans l'interface pour avertir des erreurs présentes. Les parties érronées ne sont pas extraites pour ne pas impacter le reste des données valides.

// todo objet

Le parseur prend en entrée une `String` directement et n'est pas responsable d'aller lire un fichier. Ceci nous permet de parser un snippet de DY sans qu'il soit sauvé dans un fichier, ce qui est utile pour des snippets DY intégrés à une documentation web. Cela laisse aussi le choix au projet qui intègre la syntaxe, de choisir les noms de fichiers. Nous verrons quels fichiers PLX a choisi d'utiliser pour stocker son modèle de données.

Tout le développement du parseur s'est fait en _Test Driven Development_ (TDD), qui s'est révélé très facile à mettre en place comme chaque étape possède des entrées et sorties bien définies.

L'extension de fichier recommandée est `.dy`. Ces fichiers doivent être encodés en UTF8 et le caractère de retour à la ligne doit être le `\n`.

=== Définition et contraintes des clés
Les clés sont tirées du concept de clé/valeur du JSON. Une clé est une string en minuscule, contenant uniquement des caractères alphabétiques. Elle doit se trouver tout au début d'une ligne sans espace. Si un caractère existe après la clé, il ne peut être que l'espace ou le retour à la ligne `\n`. Ainsi `coursetest` ne contient pas la clé `course`. Les clés introduisent une valeur et parfois le début d'un objet si elles contiennent d'autres clés enfants.

Dans l'exemple de la @keys-example, les clés sont `course`, `code` et `goal`. La clé `course` introduit une valeur (le nom du cours) et un objet (le cours) qui contiendra les valeurs tirées des clés enfants (`code` et `goal`). Les types de valeurs introduites sont toujours une string qui s'étend au maximum sur une seule ligne ou sur plusieurs. La clé `code` introduit la valeur `PRG1`, qui ne peut être définie que sur une ligne, car un code raccourci ne peut pas contenir de retour à la ligne. La valeur de la clé `goal` peut s'étendre sur plusieurs lignes.
#figure(
  image("../syntax/keys-example/course.svg", width: 80%),
  caption: [Exemple d'usage de clés et de leur hiérarchie avec un cours PLX],
) <keys-example>

Si du contenu devait contenir un mot qui est aussi utilisé pour une clé il suffit de ne pas le placer au début d'une ligne. Ajouter un espace devant le mot suffit à respecter cette contrainte comme le démontre la @escaped-exo. Cet espace supplémentaire n'aura pas d'impact sur l'affichage si le Markdown est interprété en HTML, puisque le rendu graphique d'un navigateur ignore les double espaces.

#figure(
  image("../syntax/escaped-exo/exo.svg", width: 80%),
  caption: [Exemple de consigne avec un mot en début de ligne qui est aussi une clé, ici `check` échappé par un espace],
) <escaped-exo>

En Rust, les clés sont définies grâce à la struct `KeySpec` définie par la librairie `dy`. Cette struct contient tous les attributs suivants à définir obligatoirement pour que le code compile. Cette déclaration des clés n'est que déclarative, elle ne contient pas de code.
+ `id`: Le texte de la clé (exemple `course`), qui doit être unique pour toute la spec DY, en minuscule et avec des caractères alphabétiques uniquement.
+ `desc`: Une description qui sert à documenter le but de la clé, qui sera utile pour la documentation au survol et l'autocomplétion pour le futur serveur de langage.
+ `subkeys`: un vecteur de sous-clés possibles, qui peut être vide.
+ `vt`: Un type de valeur, soit ligne simple ou multiple, défini via l'enum `ValueType`.
+ `once`: champ booléen qui définit si la clé ne peut se retrouver qu'une fois dans chaque objet de la clé parent ou du document si la clé est à la racine. L'erreur `DuplicatedKey` est créée si la clé est trouvée plus d'une fois.
+ `required`: si la clé doit exister au moins une fois dans tout objet de la clé parent et si une valeur est requise pour la clé. Si ces contraintes ne sont pas respectées, des erreurs `MissingRequiredKey` ou `MissingRequiredValue` sont générées.

Une valeur ne peut être que de type string. Elle commence après la clé et se termine dès qu'une autre clé valide est trouvée ou que la fin du fichier est atteint. Si le type de valeur (attribut `vt`) est une ligne simple, alors le contenu s'arrête à la fin de la ligne, les lignes suivantes ne sont pas incluses et générent des erreurs `InvalidMultilineContent` si elles ne sont pas vides.

=== Librairies implémentées

L'implémentation est divisée en deux parties très claires: le coeur du parseur et les spécifications DY (appelées par la suite #quote("spec DY")). Les deux sont inséparables et leur combinaison permet de parser du contenu définit par un spec DY. Le coeur du parseur définit le "comment parser" et la spécification définit le "parser quoi" et "comment gérer le résultat". Une spec DY définit l'ensemble des clés valides et leur hiérarchie pour un objet donné. Elle est associée à une struct qui définit l'objet en question. Par exemple, la définition de la @course-basic aura une spec DY qui définit la clé `course` et les sous-clés `code` et `goal`. La struct associée le `DYCourse`. La clé `course` servira à remplir l'attribut `name` et les deux autres clés, les attributs de même noms.

Le projet PLX a maintenant 3 librairies. En plus de `plx-core` déjà présenté pour le développement du serveur, nous avons créé deux nouvelles crates: la crate `dy` pour implémenter le coeur du parseur et la crate `plx-dy` pour définir la spec DY de PLX. Cette dernière inclut des fonctions haut-niveaux comme `parse_course()`, facilement utilisable par le CLI et `plx-core`.

#figure(
  image("../schemas/parser-libs-deps.png", width: 80%),
  caption: [Aperçu des librairies en jeu, ainsi que les dépendances entre librairie et du CLI et de l'application desktop.],
)
// todo update tout vers prg2 !!!

Le coeur du parseur ne connait _que_ le concept de clé, de leur hiérarchie et des commentaires. Il ne sait pas savoir quelles clés seront utilisées au final. Une spec DY définit des clés et leur hiérarchie. Elle définit en Rust comment construire la struct final à partir du résultat du coeur du parseur. Elle peut aussi générer d'autres erreurs spécifiques si nécessaire.

Pour faire un parallèle avec le JSON, son parseur est indépendant de son validateur de schéma (du projet JSON Schema @JsonSchemaWebsite). Le parseur peut sans hésitation déterminer où sont les clés et valeurs en JSON grâce au nombreux séparateurs (`:` et `"`). En DY, le coeur du parseur est incapable de déterminer si une ligne commence par une clé ou non, comme un clé n'est pas distinguable des autres mots, tant que ce mot n'est pas définie comme une clé. C'est comme si on avait fusionné le code du parseur JSON et de son validateur, tout en ne donnant le schéma à valider qu'au moment de parser un document.

Une spec DY est le schéma et se définit directement en Rust au lieu d'être dans un fichier texte comme les schémas JSON. Cela permet de faire des validations finales avec du code si nécessaire. Cette spec est utilisée à l'appel de la fonction `parse_with_spec`, qui est le point d'entrée de la librairie `dy`.

#figure(
  image("../schemas/parser-core-specs-separation.png", width: 80%),
  caption: [Aperçu de la séparation claire des concepts entre spec DY et coeur du parseur, développés dans deux librairies différentes.],
)

=== Lignes directrices de conception <lignes-conception>
Ces lignes directrices permettent de mieux comprendre certains choix de clés, de syntaxe ou de stratégie.
+ *Privilégier la facilité de rédaction, plutôt que la facilité de parsing*
+ *Pas de tabulations ni d'espace en début de ligne*. Cela introduit le fameux débat des espaces versus tabulations. En utilisant des espaces, le nombre d'espaces par tabulation devient configurable, ce qui va générer de la perte de temps autour de la rédaction. Du temps sera perdu à discuter du style à adopter, à configurer son IDE ou à relire des changements dans Git qui contiendraient principalement des changements de formatage. Créer un formateur automatique n'est pas une solution, car cela demande de l'installer et le configurer également. Si une partie de l'équipe d'enseignant·es ne l'utilisent pas, son utilité est diminuée.
+ *Une seule manière de définir un objet*. Au lieu d'ajouter différentes variantes pour arriver au même résultat juste pour satisfaire différents style, ne garder qu'une seule possibilité. Dès que des variantes sont introduites, cela complexifie le parseur et l'apprentissage de la syntaxe. On trouve le même problème autour des formateurs ou linters que précédemment.
// + *Privilégier une limitation des mouvements du curseur*: lors de la rédaction d'un nouvel exercice, le curseur de l'éditeur ne devrait jamais avoir besoin de retourner en arrière.
+ *Peu de caractères réservés, simple à taper et restreint à certains endroits*. Le moins de caractère réservés possible doivent être définis car cela pourrait rentrer en conflit avec le contenu. Ils doivent toujours rester restreints à des zones spécifiques du texte, pour être facilement détournées si nécessaire. L'échappement via un caractère du type `\` n'est pas une bonne option.
+ *Pas de caractères en pair*. Les caractères réservés ne doivent pas être `()`, `{}`, ou `[]` ou d'autres caractères qui vont toujours ensemble pour délimiter le début et la fin d'un élément. Surtout durant la retranscription, ces pairs requièrent des mouvements de curseur plus complexe, pour aller une fois au début et une fois à la fin de la zone délimitée.
+ *Utiliser des clés courtes*. Si une clé est utilisée très souvent et que son nom est long (plus de 5 lettres), il peut être judicieux de choisir une alternative plus courte. L'alternative peut être un surnom (`exercise` -> `exo`) ou le début (`directory` -> `dir`). Une clé devrait au minimum avoir deux lettres. L'autocomplétion du serveur de langage pourra aider à taper des clés plus longues, mais il n'est pas sûr que tout le monde ait pu l'installer ou travail avec un des IDE supportés.
+ *Une erreur ne doit pas empêcher le reste de l'extraction*. Le parseur doit détecter les erreurs mais continuer comme si elle n'était pas là. Une information manquante prend ainsi une valeur par défaut, pour permettre un usage ou aperçu limité plutôt qu'aucune information.
+ *Les attributs de la struct Rust ne doivent pas contraindre la définition des clés*. Par exemple, pour une struct Rust `Exo` avec deux champs `name` et `instruction` (consigne), ne doit pas imposer la présence de deux clés de même nom dans spec DY. Dans ce cas, on pourrait préférer avoir une seule clé `exo` qui contient les deux valeurs, qui seraient séparées à la fin.
+ *Le seul type natif est la string*. Les projets qui intègrent la syntaxe DY ne récupèrent que des strings en valeurs après les clés définies. Tout d'abord pour éviter le besoin de guillemets. Ensuite, contrairement au YAML, TOML et d'autres, aucun type de dates, nombres entiers ou flottants ne sont pas définis, afin de garder une base minimaliste et éviter toute ambiguïté d'interprétation. Pour rappel, ces problèmes étaient mentionnés sur plusieurs syntaxes dans l'état de l'art. Cela n'empêche pas que ces projets décident de supporter des nouveaux types et s'occupent eux-même du parsing et de la validation de ces valeurs.

Dans l'état actuel, la syntaxe DY n'a pas de tabulations ni d'espace, aucun caractère réservé (la fin de ligne et l'espace sont des séparateurs mais ne sont pas réservés à la syntaxe). Les clés réservées peuvent être échappées facilement pour écrire le mot littéral.

// + Réutiliser des concepts déjà utilisés dans d'autres formats quand ils sont concis: concept de clé comme le YAML, usage des commentaires en `//`

=== Commentaires
Pour permettre de communiquer des informations supplémentaires durant la rédaction, les commentaires sont supportés et ne sont visibles que dans le fichier DY. Le parseur les ignore et ne se rappelle pas de leur position. Les commentaires ne peuvent être définis que sur une ligne dédiée, les 2 premiers caractères de la ligne doivent être `//` et le reste de la ligne est complètement libre. Le texte tel que `exo intro // c'est basique` ne contient pas de commentaire, contrairement au C et d'autres langages.

=== Support du Markdown
Tous les champs supportent le Markdown. La syntaxe du Markdown n'est pas interprétée sauf pour les snippets de code qui sont considérées comme du contenu à ne pas analyser. La zone concernée commence par #raw("```") ou `~~~`, elle est ignorée jusqu'à trouver le même marqueur. Ainsi, de potentielles clés ou commentaires présents ne sont pas considérés. Cette spécificité permet aussi de préserver les commentaires de code dans le texte extrait et de ne pas les ignorer comme les commentaires DY.

#figure(
  image("../syntax/meta-exo/exo.svg", width: 90%),
  caption: [Exercice avec une consigne qui contient un bloc de code, contenant lui-même un autre exercice en DY. Le contenu du bloc de code n'est pas interprété et la consigne se termine avant le `check` colorisé],
)


== Implémentation de la librairie `dy`

Dans la @steps, la vue d'ensemble des étapes haut niveaux est présentée. Le point d'entrée `parse_with_spec<T>`, avec `T` le type générique de la struct Rust de résultat (`DYCourse` par exemple). Cette fonction va lancer les différentes étapes: le contenu est découpé en un vecteur de lignes pour les catégoriser (processus inspiré d'un lexer/tokenizer), puis un arbre de blocs est construit (inspiré du concept de l'analyse syntaxique dans la construction d'un compilateur classique). Cet arbre représente la hiérarchie valide des instances des clés trouvées dans le document avec les lignes constituant la valeur associée à la clé. Chaque bloc à la racine de l'arbre est converti ensuite vers la struct Rust, via du code défini par la spec DY.

#figure(
  image("../schemas/parser-steps.png", width: 90%),
  caption: [Etapes haut-niveau du coeur du parseur, via son point d'entrée `parse_with_spec<T>`],
)<steps>

Nous avons mentionné que `parse_with_spec` était le point d'entrée, voici sa signature en @parsesig
#figure(
```rust
pub fn parse_with_spec<'a, T>(
    spec: &'a ValidDYSpec,
    some_file: &Option<String>,
    content: &'a str,
) -> ParseResult<T>
where
    T: FromDYBlock<'a> {...}
``` , caption: [La définition de `parse_with_spec`, avec la contrainte que `T` doit implémenter le trait `FromDYBlock` (visible après)]) <parsesig>

Le @parseresult donne la définition du type de retour de `parse_with_spec`, la struct `ParseResult` qui inclut un vecteur de résultat du type générique et les erreurs détectées. Le nom du fichier est inclus s'il a été fourni à l'appel de `parse_with_spec`. Une copie du contenu du fichier est inclus en cas d'erreurs pour permettre l'affichage des erreurs avec les lignes associées.
#figure(
```rust
pub struct ParseResult<T> {
    pub items: Vec<T>,
    pub errors: Vec<ParseError>,
    pub some_file_path: Option<String>,
    pub some_file_content: Option<String>,
}
``` , caption: [La struct `ParseResult` retournée de `parse_with_spec`]) <parseresult>

#figure(
```rust
pub trait FromDYBlock<'a> {
    fn from_block_with_validation(block: &Block<'a>) -> (Vec<ParseError>, Self);
}
``` , caption: [Un trait (interface) `FromDYBlock` qui impose d'implémenter `from_block_with_validation`, utilisé sur chaque struct final associée à une spec DY])

=== Types d'erreurs

Les erreurs stockées dans `ParseResult`, présenté précédemment en @parseresult, sont de types `ParseError` visibles en @parseerrors. Chaque erreur contient un `Range`, type tirés de la crate `lsp-types`, qui définit une plage de caractères entre un caractère de début et de fin, afin de définir la zone à surligner lors de l'affichage de l'erreur. Cette plage sera aussi utilisée dans le futur serveur de langage pour indiquer à l'éditeur quelle zone doit être soulignée de vaguelettes rouges.

Nous avons défini deux catégories d'erreurs: les erreurs structurelles basées sur la définition des contraintes sur les clés et les erreurs spécifiques à la spec DY, avec la variante `ValidationError` qui a été définie pour cet usage. Ainsi, l'implémentation de `FromDYBlock` peut générer des erreurs avec cette variante. Les messages d'erreurs associés au variantes seront visibles plus loin lorsque la liste des erreurs seront exemplifiées.

#figure(
```rust
pub struct ParseError {
    pub range: Range,
    pub error: ParseErrorType,
}

#[derive(thiserror::Error)]
pub enum ParseErrorType {
    // Blocks tree building errors
    #[error("The '{0}' key can be only used under a `{1}`")]
    WrongKeyPosition(String, String),
    DuplicatedKey(String, u8),
    InvalidMultilineContent(String),
    ContentOutOfKey,
    MissingRequiredKey(String),
    MissingRequiredValue(String),

    /// An error generated by FromDYBlock::from_block_with_validation()
    #[error("{0}")]
    ValidationError(String),
}
``` , caption: [Définition de `ParseError` et extrait simplifié de `ParseErrorType`. Dans le code, chaque variante possède une `#[error]` qui définit son message (retirés ici pour alléger le schéma). Cette énumération contient les variantes pour les erreurs structurelles puis la seule variante pour les erreurs spécifiques.]) <parseerrors>


=== Catégorisation des lignes
La première étape consiste à prendre le contenu brut, d'itérer sur chaque ligne et de catégoriser la ligne pour définir si elle contient une clé (`WithKey`) ou non (`Unknown`). Une liste de toutes les clés présente dans l'arbre `ValidDYSpec` est extraite avant ce parcours. Pour ne pas comparer toutes les clés à chaque ligne, elles sont regroupées par longueur dans une `HashMap`. A chaque ligne, on extrait le premier mot et on regarde uniquement les clés de même longeur que ce mot.

#figure(
  image("../syntax/exo/exo.svg", width: 100%),
  caption: [L'exercice Salue-moi, déjà présentée en introduction],
)
En reprenant l'exercice Salue-moi, la catégorisation des lignes est affiché en @somelines.
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

À ce stade, aucune analyse de la hiérarchie des clés et effectuée, nous cherchons seulement à distinguer les lignes avec clé du reste, pour mieux générer certaines erreurs durant la phase suivante. Par exemple si une clé n'est pas au bon endroit (prenons le `code` d'un cours avant la clé `cours`), elle risque d'être considéré simplement du contenu invalide non associé à une clé (`ContentOutOfKey`) alors que nous aimerions être plus spécifique avec l'erreur `WrongKeyPosition`, qui a trouvé une clé mais pas à la bonne position. De par la manière de parcourir la hiérarchie de clé durant la construction de l'arbre de blocs, nous ne pouvons pas détecter que `code` est en fait une clé valide, même si ce n'est pas la bonne position. La définition de la clé `code` se trouve sous la définition de la clé `course` et elle ne sera pas prise en compte tant qu'une clé `course` n'a pas été rencontrée.

#pagebreak()

=== Construction d'un arbre de blocs
Cet arbre représente la hiérarchie des clés et valeurs trouvées et respecte en tout temps la hiérarchie de `ValidDYSpec`. Un bloc contient le texte extrait (sous forme de vecteur de lignes), la plage du contenu concerné (`Range`) et une référence vers la définition de la clé associée au bloc. Les erreurs rencontrées au fur et à mesure n'impacte pas cet arbre et sont insérées dans une liste d'erreurs séparées. Les commentaires ne sont pas inclus.

#figure(
  image("../syntax/blocks/salue-moi-blocks.svg", width:100%),
  caption: [Arbre de blocs généré à partir des lignes du @somelines, l'ordre des blocs est de haut en bas.],
)

=== Conversion vers la struct T

Grâce à l'interface `FromDYBlock`, implémenté pour le type générique `T` passé à `parse_with_spec`, nous pouvons donner chaque bloc racine à la méthode `T::from_block_with_validation(&block)` afin qu'il puisse être converti en type `T`. La liste d'erreur retournée étend la liste récupérée par la construction de l'arbre de blocs. Finalement, les erreurs sont triées par position de début dans le fichier, pour permettre de les afficher de haut en bas et faciliter la lecture d'une longue liste d'erreurs. Si cette position est la même entre deux erreurs, le type de l'erreur est utilisé comme second critère de comparaison.

== Implémentation de `plx-dy`

=== Modèle de données de PLX et choix des clés
Pour que l'application desktop de PLX fonctionne, nous avons besoin de décrire un cours, divisé en compétences, qui regroupent des exercices. Un exercice définit un ou plusieurs checks. Voici une liste des informations associées à ces quatre objets.
+ *Un cours*: un nom (par exemple `Programmation 2`), un code (il existe souvent un raccourci du nom, comme `PRG2`) et une description de l'objectif du cours. Une liste de compétences.
+ *Une compétence*: un nom, une description et un ensemble d'exercices. Une compétence peut aussi être une sous compétence, pour subdiviser une grande compétence en sous compétences plus spécifiques.
+ *Un exercice*: un nom, une consigne et un ou plusieurs checks pour vérifier le comportement d'un programme.
+ *Un check*: un nom, des arguments à passer au programme, un code d'exit attendu et une séquence d'actions/assertions à lancer. Une action peut être ce qu'on tape au clavier et une assertion concerne la vérification que l'output est correct.

Nous avons ensuite défini la liste de clés et leur hiérarchie pour le modèle de données précédent, ainsi que les structs finales à remplir.
#grid(columns: 2, gutter: 10pt,
[
Un cours
  - `course` est le nom du cours, qui sera intégré au champ `name` de la struct
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
  - `skill` définit un nom la même ligne et une description optionnelle sur les lignes suivantes. Cette valeur ira dans le champ `name` et `description` de la struct.
    - `dir` est le dossier dans lequel sont définis les exercices de cette compétence
    - `subskill` une sous compétence, pour découper en compétences plus spécifiques
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
  - `exo` définit un nom sur la même ligne et une consigne optionnel sur les lignes suivantes. Ces deux informations iront dans le champ `name` et `instruction` de la struct.
    - `check` introduit le début d'un check avec un titre
      - `args` définit les arguments du programme de l'exercice
      - `see` demande à voir une ou plusieurs lignes en sortie standard. L'entrée peut être sur plusieurs lignes.
      - `type` simule une entrée au clavier
      - `exit` définit le code d'exit attendu, qui est une valeur optionnelle
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

=== Définition d'une hiérarchie de clés en Rust

Après avoir présenté les attributs de la struct `KeySpec`, voici un exemple concret de la définition de spec DY en Rust d'un cours PLX. Nous avons défini sur le @speccourse une constante par clé, puis regroupés les clés `goal` et `code` en sous-clés de `course`.

#figure(

  text(size: 0.9em)[
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
```] , caption: [Exemple de définition en Rust de la spec DY des cours PLX, avec 3 `KeySpec` pour les 3 clés]) <speccourse>

Dans le @speccourse, le tableau de `KeySpec` de toutes les clés autorisées à la racine possède un alias de type nommé `DYSpec`. Il est stocké dans la constante `COURSE_SPEC` et doit encore être validé. Un type _wrapper_ `ValidDYSpec` permet de valider que chaque id de clé est bien unique.

En suivant la même logique que précédemment, nous avons défini trois specs DY, avec les structures et contraintes de clés montrées sur les trois schémas suivants.
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
  caption: [Aperçu graphique de la spec DY des exercices PLX. La clé `exo`, `check` et `see` sont obligatoires (`required=true`). `args` et `exit` ne peut apparaître qu'une seule fois par check (`once=true`). Seuls `exo` et `see` peuvent être donnés sur plusieurs lignes (`ValueType=Multiline`).],
)

=== Exemple d'implémentation de `FromDYBlock`
Toujours sur la spec DY d'un cours PLX, voici l'implémentation d'une conversion simple entre un arbre de blocs et la struct `DYCourse`. 

Le code en @fromblockcourse crée un cours avec la valeur du bloc puis itère sur les sous-blocs pour chercher les valeurs pour les attributs `code` et `goal`. Aucune erreur ne doit être détectée ici, un vecteur vide est retourné.
#figure(
  text(size: 0.9em)[
```rust
impl<'a> FromDYBlock<'a> for DYCourse {
    fn from_block_with_validation(block: &Block<'a>) -> (Vec<ParseError>, DYCourse) {
        let errors = Vec::new();
        let mut course = DYCourse {
            name: block.get_joined_text(),
            ..Default::default()
        };
        for subblock in block.subblocks.iter() {
            let id = subblock.key.id;
            if id == CODE_KEYSPEC.id {
                course.code = subblock.get_joined_text();
            }
            if id == GOAL_KEYSPEC.id {
                course.goal = subblock.get_joined_text();
            }
        }
        (errors, course)
    }
}
```] , caption: [implémentation de `FromDYBlock` pour `DYCourse`]) <fromblockcourse>

==== Fonctions haut niveau des specs DY
Chacune des 3 spécifications donne accès à une fonction haut niveau comme `parse_course`, `parse_skills` et `parse_exo`. Ces fonctions font simplement appel à `parse_with_spec`, comme le montre l'exemple en @parse-with-spec-example.
#figure(
```rust
pub fn parse_course(some_file: &Option<String>, content: &str) -> ParseResult<DYCourse> {
    parse_with_spec::<DYCourse>(
        &ValidDYSpec::new(COURSE_SPEC).expect("COURSE_SPEC is invalid !"),
        some_file,
        content,
    )
}
``` , caption: [Définition de la fonction `parse_course` dans la spec DY des cours, avec appel de `parse_with_spec`]) <parse-with-spec-example>


== Intégration de `plx-dy`
Maintenant que nous avons des fonctions haut niveau, il suffit d'importer la librairie `plx-dy` et de les intégrer au CLI et à PLX desktop.

=== Structures de fichiers DY
La crate `plx-dy` définit des constantes pour des fichiers dans lesquels se trouvent les définitions de nos 3 objets. Le cours est décrit dans `course.dy`, les compétences dans `skills.dy`. Chaque exercice se trouve dans un fichier `exo.dy` dans son dossier à côté des fichiers de code et de ses solutions. Le fichier `live.toml` est attendue à la racine également.
#figure(
```
plx-demo> tree
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
``` , caption: [Exemple de structure de fichiers pour un cours PLX de démonstration, avec 2 compétences `intro` et `structs` et 3 exercices (sous-dossiers dans les compétences)])

=== Intégration à PLX desktop
Le parseur a été intégré à `plx-core` dans les fichiers `src/models/course.rs` et `src/models/exo.rs`, au lieu de lire des fichiers TOML, les fichiers DY sont maintenant utilisés. Certains fichiers TOML existent encore, mais ne servent qu'à gérer de l'état d'un exercice (terminé ou non) et ne sont modifiés que par PLX. L'interface affiche les cours, compétences et exercices comme avant ce travail, la migration a fonctionné. Un compteur du nombre d'erreurs sera affiché dans l'interface pour indiquer leur présence, tout en permettant l'entrainement du cours. Bien sûr, si le cours ou les compétences ne sont pas définis, il n'est pas possible de l'ouvrir, mais ces erreurs ne sont pas liées au parseur. Dans le futur, les détails des erreurs pourront facilement être affichés dans cette interface, pour les personnes qui préfèrent une interface graphique à l'usage du CLI.

// todo fix button

=== Intégration au CLI

La première intégration a été faite dans le CLI (qui permet aussi de démarrer le serveur, pour rappel). Ce CLI est utile pour que les enseignant·es puissent vérifier que le contenu d'un cours PLX est valide. Dans le futur, il pourrait aussi servir à d'autres programmes qui souhaiterait réutiliser ce contenu sans intégrer le parseur Rust, mais en utilisant le JSON généré.
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

Si un fichier `course.dy` est donnée à la commande `plx parse`, la fonction `parse_course` est appelée. On peut aussi donner le dossier du cours pour le même résultat.
#figure(
  image("../syntax/course/course.svg", width: 60%),
  caption: [Définition d'un cours PLX dans un fichier `course.dy`],
)
#figure(
  image("../syntax/course/course-parsed.svg", width: 90%),
  caption: [Résultat du parsing du cours affiché en JSON],
)

Si un fichier `skills.dy` est donnée à la commande `plx parse`, la fonction `parse_skills` est appelée.
#figure(
  image("../syntax/skills/skills.svg", width: 90%),
  caption: [Définition d'une liste de compétences PLX dans un fichier `skills.dy`],
)
#figure(
  image("../syntax/skills/skills-parsed.svg", width: 70%),
  caption: [Résultat du parsing des compétences affichées en JSON],
)

Si un fichier `exo.dy` est donnée à la commande `plx parse`, la fonction `parse_exo` est appelée.
#figure(
  image("../syntax/exo/exo.svg", width: 90%),
  caption: [Définition d'un exercice PLX dans un fichier `exo.dy`],
)
#figure(
  image("../syntax/exo/exo-parsed.svg", width: 90%),
  caption: [Résultat du parsing de l'exercice affiché en JSON],
)

Tout nom de fichier autre que les trois mentionnés sera refusé par le CLI, car aucune autre spec DY n'existe. Ces affichages se produise lorsqu'aucune erreur est détectée.

A noter que tous les messages d'erreurs ou les messages de succès sont envoyés sur le flux `stderr`. Ceci permet d'utiliser le JSON en `stdout` par d'autres outils sans devoir séparer le message du JSON.

== Détection d'erreurs

Après avoir vu les cas de contenu valides, voici une liste exemplifiée de toute les types d'erreurs qui peuvent être détectés. En cas d'erreur détectée, le CLI échoue le code d'exit 2. En cas d'erreur non liée au parseur (fichier inexistant par exemple), le code d'exit est 1.

#figure(
  image("../syntax/course-error/course.svg", width: 100%),
  caption: [Exemple erroné de `course.dy`: Définition incorrecte d'un cours PLX dans un fichier `course.dy`.\ La clé `goal` manque et le `code` doit être placé après la clé `course`.],
)
#figure(
  image("../syntax/course-error/course-parsed.svg", width: 100%),
  caption: [Les 3 erreurs ont été détectées par le parseur],
)

// TODO fix the error !!

#figure(
  image("../syntax/skills-error/skills.svg", width: 100%),
  caption: [Exemple erroné de `skills.dy`: Le dossier `dir` est obligatoire et ne peut pas être donné sur plusieurs lignes. Le nom d'une compétence ne peut pas être vide.],
)
#figure(
  image("../syntax/skills-error/skills-parsed.svg", width: 100%),
  caption: [Les 3 erreurs ont été détectées par le parseur],
)

#pagebreak()
#figure(
  image("../syntax/exo-error/exo.svg", width: 100%),
  caption: [Exemple erroné de `exo.dy`: La clé `args` ne peut pas être définie plusieurs fois, le `see` est requis dans chaque `check`. Le code d'exit doit être un nombre, `one` n'est pas un entier.],
)
// TODO fix the error !!
#figure(
  image("../syntax/exo-error/exo-parsed.svg", width: 100%),
  caption: [Les 3 erreurs ont été détectées par le parseur],
) <exoerrors>

Dans cette dernière @exoerrors, la dernière erreur est particulièrement intéressante. Nous disions en section @lignes-conception que seul le type string était nativement supporté et là nous avons une erreur sur le type qui doit être un entier 32 bits signé. La ligne directrice a été respectée, cette erreur a été généré dans l'implémentation de `FromDYBlock` sur `DYExo`. Le problème d'ambiguïté entre les strings et les nombres n'existe pas dans ce cas comme ce nombre n'est possible que après la clé `exit`.

Sur l'extrait du @parseexitcode, lorsque le sous bloc correspond à la clé `exit`, le texte est parsé en `i32` (le type Rust d'entier signé 32bits). Le code d'exit doit être initialisé à une valeur par défaut (ici `None`). Si le parsing du nombre échoue, l'erreur spécifique avec le message défini dans la constante `ERROR_CANNOT_PARSE_EXIT_CODE`, est ajouté à la liste des erreurs via la variante `ParseErrorType::ValidationError`. La plage de l'erreur est le plage de la valeur, ce qui produit ces marqueurs `^^^` juste sous le `one`.

#text(size:0.9em)[

#figure(
```rust
if check_subblock_id == EXIT_KEYSPEC.id {
    check.exit = None;
    match check_subblock.get_joined_text().parse::<i32>() {
        Ok(code) => check.exit = Some(code),
        Err(_) => {
            errors.push(ParseError {
                range: range_on_line_part(
                    check_subblock.range.start.line,
                    check_subblock.range.start.character + check_subblock_id.len() as u32 + 1,
                    check_subblock.range.end.character,
                ),
                error: ParseErrorType::ValidationError(ERROR_CANNOT_PARSE_EXIT_CODE.to_string()),
            });
        }
    }
}
``` , caption: [Extrait de l'implémentation de `FromDYBlock` sur `DYExo`]) <parseexitcode>
]

// todo fix heading levels and names
== Tests unitaires

Tout le développement du parseur s'est fait en _Test Driven Development_ (TDD), ce qui a facilité la refactorisation et nous a permis de valider chaque étape. Un parseur ayant souvent de nombreux cas limites, au vu de l'infinité des possibilités de représentations, il est indispensable de tester chaque erreur générée et chaque condition implémentée.

#figure(
```
> cargo test

running 22 tests
test lexer::tests::test_can_tokenize_and_ignore_anything_inside_code_blocks ... ok
test lexer::tests::test_can_tokenize_basic_lines ... ok
test lexer::tests::test_can_tokenize_comments_and_empty ... ok
test lexer::tests::test_line_into_parts ... ok
test parser::tests::test_can_build_blocks_for_simple_course ... ok
test lexer::tests::test_line_starts_with_key ... ok
test parser::tests::test_can_build_blocks_for_complex_skills ... ok
test parser::tests::test_can_build_blocks_with_multiline_keys_ignoring_comments ... ok
test lexer::tests::test_can_tokenize_lines_with_invalid_keys_and_empty_lines ... ok
test parser::tests::test_can_detect_duplicated_key_error ... ok
test parser::tests::test_can_detect_invalid_multiline_content ... ok
test parser::tests::test_can_detect_content_out_of_key ... ok
test parser::tests::test_can_detect_wrong_key_positions ... ok
test parser::tests::test_required_key_also_work_at_root ... ok
test parser::tests::test_empty_lines_are_present_in_block_text ... ok
test parser::tests::test_can_extract_complex_exos_blocks_with_errors_ignorance ... ok
test spec::tests::test_empty_spec_is_invalid ... ok
test spec::tests::test_spec_with_duplicated_key_at_root ... ok
test spec::tests::test_spec_with_duplicated_key_deeply ... ok
test spec::tests::test_can_validate_valid_spec ... ok
test parser::tests::test_strange_exo_parsing_can_correctly_ignore_error ... ok
test parser::tests::test_missing_keys_and_values_with_required_keys_are_detected ... ok

running 10 tests
test course::tests::test_can_parse_simple_valid_course ... ok
test course::tests::test_parse_result_display_is_also_correct ... ok
test course::tests::test_parse_result_display_can_highlight_unknown_content ... ok
test course::tests::test_parse_result_display_is_correct ... ok
test skill::tests::test_can_detect_subskill_missing_value ... ok
test skill::tests::test_can_parse_simple_skills ... ok
test exo::tests::test_can_error_on_invalid_exit_code ... ok
test exo::tests::test_can_extract_args_by_space_split ... ok
test exo::tests::test_detect_empty_args_error_but_ignores_empty_type ... ok
test exo::tests::test_can_parse_a_simple_exo ... ok
``` , caption: [Aperçu des 32 tests unitaires développés pour les crates `dy` puis `plx-dy`])

Pour mieux se représenter à quoi ressemble ces tests. Ce test `test_can_error_on_invalid_exit_code`, écrit pour s'assurer que l'implémentation de `FromDYBlock` pour `DYExo` détecte bien l'erreur d'un code d'exit non numérique et qu'il prend sa valeur par défaut (`None`). On s'assure aussi que le reste de l'exercice est extrait correctement (`titre`, `check`, `see`).

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
            parse_exo(some_file, text),
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
``` , caption: [Code du test `test_can_error_on_invalid_exit_code` en exemple de test unitaire])

