== Résumé publiable
// === Contexte

La programmation est un domaine *abstrait et complexe* à apprendre. Dans les universités, les sessions théoriques sont souvent données sous forme *magistrale*. Les étudiant·es ont *rarement la possibilité d'être actif·ves*, ce qui conduit au décrochage d'une grande partie de l'auditoire. Ce travail de Bachelor poursuit le projet PLX, une application _desktop_ qui souhaite redéfinir l'expérience d'apprentissage et d'enseignement.

// === Problématique

En classe, les enseignant·es ont *une visibilité limitée de la compréhension et de l'acquisition des compétences par les étudiant·es*. Les étudiant·es ont très peu de retour sur l'implémentation de leur code dans les exercices et peu ont l'occasion d'améliorer la qualité de leur code.

// === Objectifs du travail

Le premier défi vise à *permettre aux enseignant·es d'accéder au code des étudiant·es* durant des sessions d'entrainement en classe. Un serveur central doit servir de relai pour transférer le code et les résultats des vérifications automatiques, vers le tableau de bord de l'enseignant·e.

Le deuxième vise à *faciliter la rédaction des exercices de programmation en créant une syntaxe concise,* appelée #quote("syntaxe DY"), pour décrire les informations du cours, au lieu d'utiliser un format répandu comme le JSON, YAML ou TOML.

Un *serveur WebSocket en Rust* a été implémenté. Les messages JSON de notre protocole ont été spécifiés puis validés avec des tests automatisés. *Un parseur de la syntaxe DY* a été créé dans une librairie Rust appelée `dy` et son intégration permet d'extraire des cours, des compétences et des exercices.

// === Perspectives futures
Les enseignant·es de programmation ont maintenant de nouveaux outils pour *rendre leurs cours dynamiques*, donner du feedback durant les sessions d'exercices et rapidement créer de nouveaux exercices.

Dans le futur, le tableau de bord pourra être amélioré pour faciliter la revue du code et de nouveaux types d'exercices pourront être intégrés.
