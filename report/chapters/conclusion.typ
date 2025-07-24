= Conclusion <conclusion>
Tous les objectifs généraux du cahier des charges ont été atteints. Le serveur de session live fonctionne et peut être démarré depuis `plx server`. Le parseur sous forme de librairie et d'intégration à PLX est fonctionnel. PLX desktop est passé des fichiers TOML vers ces fichiers DY. Le parseur a aussi été intégré au CLI (`plx parse`) pour permettre la visualisation des erreurs directement dans le terminal.

Pour le tableau de bord des enseignant·es, nous nous sommes concentrés sur l'affichage du code et des checks avec des petites bulles au-dessus. Un autre visualisation des checks sous forme de tableau sans le code pourra être implémentée facilement dans le futur, puisque toutes les données sont déjà disponibles dans le _frontend_.

Notre syntaxe DY, avec notre librairie Rust `dy` permet de rapidement définir une nouvelle spec DY. Celle des cours PLX ne fait que 30 lignes de code Rust et 30 lignes de constantes pour définir les clés et leur hiérarchie. Il est possible de créer de sortes d'extensions de la syntaxe en faisait du parsing après l'extraction des valeurs et en validant la donnée dans une spec DY. Cette extension permettra de supporter aisément des formats autres que des strings pour des clés particulières.

Grâce au système de hiérarchie visuellement implicite dans la syntaxe DY et la restriction de types aux strings, nous avons pu définir une syntaxe sans guillemets, tabulations, deux-points ni accolades. Nous avons pu donc réduire une quantité importante de friction à la rédaction, qui était présente sur d'autres formats.

En terme d'objectifs non fonctionnels, le parseur est bien plus rapide que prévu. Nous arrivons à parser 1000 fois le même exercice Salue-moi (en relisant le fichier à chaque fois) en 40ms, l'objectif de 200 exercices en moins d'une seconde est largement atteint, probablement grâce à l'optimisation du langage Rust et l'exécution native. De nombreux tests automatisés ont été développés sur le serveur et le parseur pour valider le comportement, incluant des tests de bouts en bouts pour le serveur. Le nombre de clients simultanés connectés à un serveur n'a pas encore pu être mesuré.

La gestion des pannes des clients a été définie dans le protocole et pourra être implémentée à l'avenir sans trop de difficulté. L'intégration des sessions live dans PLX desktop a été mise en priorité pour mieux démontrer le fonctionnement du serveur.

// todo phrase sur temps de transfert de check

Pour la suite du travail, de nombreux éléments pourront être étendus, améliorés ou ajoutés pour continuer d'améliorer l'expérience d'apprentissage et d'enseignement de la programmation.
+ Gérer les pannes des clients en leur renvoyant les messages utiles à la reconnexion
+ Gérer la promotion d'autres leaders que le créateur de la session, pour permettre aux assistant·es d'accéder aux bouts de code envoyés pour aider à la relecture
+ Étendre la syntaxe DY et les possibilités du coeur du parseur pour supporter d'autres types d'exercices dans PLX
+ Développer le serveur de langage de la syntaxe DY, en y incluant l'autocomplétion et la documentation des clés au survol
+ Finaliser la grammaire Tree-Sitter. Le POC a déjà servi à coloriser les exemples de ce rapport, nous pourrons à l'avenir la finaliser et l'intégrer dans Neovim.
+ Améliorer l'expérience du tableau de bords pour ajouter des filtres, afficher les checks dans un tableau séparé
+ Implémenter une sélection de certaines réponses particulières pour les afficher au beamer, pouvoir les commenter ou demander à la classe de critiquer constructivement le code choisi.

En conclusion personnelle, il était très intéressant d'explorer beaucoup de technologies que je connaissais depuis longtemps sans avoir le temps de creuser, comme Tree-Sitter, les serveurs de langages et Tokio. Toutes ces recherches ont enrichi ma compréhension des langages, des IDEs, des applications réseaux et de l'écosystème Rust. Ce travail a été le premier usage de Tokio, que j'ai appris au début du développement du serveur, qui s'est heureusement révelé pas trop difficile à prendre en main.

Les enseignant·es de programmation ont maintenant de nouveaux outils à disposition pour rendre leurs cours dynamiques, donner du feedback en live durant des exercices et très rapidement créer de nouveaux exercices dans des fichiers texte.  Nous espérons que de nombreux cours à la HEIG-VD et d'autres universités pourront en bénéficier dans le futur. Il reste à les convaincre de la valeur de l'outil et qu'ajouter de l'interaction dans leur cours avec PLX peut aider leurs étudiant·es à acquérir des compétences profondes et complexes.

