== Outils utilisés <tools>

=== Usage de l'intelligence artificielle
Nous nous sommes aidés de l'IA, avec un mix de modèles: GPT4o, GPT4.1 et Claude Sonnet 3.5, via l'interface de GitHub Copilot en ligne @GithubCopilot.
- pour chercher des syntaxes humainement éditables, comme certains projets ne sont pas bien référencés sur Google, en raison d'une faible utilisation ou du fait qu'ils sont décrits avec d'autres mots-clés.
- pour trouver la raison de certaines erreurs d'exécution ou de compilation dans les POC fait en Rust
- pour trouver des bugs basiques dans mon code ou pour la méthode Rust adaptée dans une manipulation particulière
- pour trouver d'autres approches d'architecture durant le développement du serveur
- pour mieux comprendre les règles de précédence de Tree-Sitter et avoir des exemples
- avec LanguageTool @languagetoolWebsite pour trouver les fautes d'orthographes ou de frappe et les corriger, basé sur des règles logiques et sur l'IA
- avec Reverso @ReversoWebsite pour reformuler certaines tournures
- pour apprendre à générer des diagrammes Graphviz dans le rapport

=== Aide à la rédaction
Tout le texte et le code a été rédigé à la main, sans utiliser d'IA à ce niveau. Bertil Chapuis a aidé à reformuler et avoir une meilleure accroche, sur quelques phrases dans l'introduction.

=== Outils techniques
- Neovim pour l'édition du rapport et l'écriture du code
- Template Typst `HEIG-VD typst template for TB` @HEIGVDTypstTemplateForTBGithub
- Convertisseur de BibTex vers Hayagriva @JonasloosBibtexToHayagrivaWebapp
- Toutes les dépendances Cargo et NPM listées dans les fichiers `Cargo.toml` et `package.json` du code

=== Logo et inspiration
Le logo de PLX utilisé sur la page de titre a été créé durant le projet PDG durant l'été 2024 @PlxBookLogo.

La syntaxe DY, la structure du parseur DY et ses concepts sont inspirés d'un autre projet fait dans le passé. Ni le code ni la documentation de cet ancien projet n'ont été repris @DelibayDocsSyntax @DelibayDocsParser.
