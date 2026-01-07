# Markdown to PDF - Générateur de PDFs Professionnels

Outil pour générer des PDFs élégants et professionnels à partir de fichiers Markdown, utilisant Pandoc et XeLaTeX.

## Aperçu

Ce projet fournit un template LaTeX soigné et des scripts de génération automatisés pour créer des documents PDF de qualité professionnelle à partir de fichiers Markdown.

**Caractéristiques principales :**
- 📄 Template LaTeX professionnel avec design moderne
- 🎨 Couleurs personnalisées (bleu/gris)
- 📑 Page de titre élégante
- 📚 Table des matières avec liens cliquables
- 🌍 Support du français (et d'autres langues)
- ✨ Support des émojis (partiellement)
- 📊 Tableaux professionnels
- 🔗 Liens hypertexte
- 🎯 Scripts automatisés (make et shell)

## Installation Rapide

### 1. Installer Pandoc
```bash
brew install pandoc
```

### 2. Installer LaTeX (MacTeX)

**Option légère (~100MB) :**
```bash
brew install --cask basictex
# Redémarrer le terminal puis :
sudo tlmgr update --self
sudo tlmgr install babel-french collection-fontsrecommended
sudo tlmgr install geometry fancyhdr titlesec enumitem booktabs tocloft hyperref xcolor calc multirow
```

**Option complète (~4GB) :**
```bash
brew install --cask mactex-no-gui
```

Voir `INSTALL_LATEX.md` pour plus de détails.

## Configuration (Optionnel)

Pour définir des valeurs par défaut pour vos projets, créez un fichier `pdf-config.yaml` :

```bash
# Copier l'exemple
cp pdf-config.yaml.example pdf-config.yaml

# Éditer selon vos besoins
# Exemple de contenu :
author: "Votre Nom"
toc: true
```

Le script cherchera `pdf-config.yaml` dans :
1. Le répertoire courant (priorité)
2. Le répertoire du script

**Avantages :** Plus besoin de spécifier `--author` et `--toc` à chaque fois !

## Utilisation

### Méthode 1 : Script Direct

Générer un PDF avec table des matières :
```bash
./generate-pdf.sh mon-document.md --toc
```

Options disponibles :
```bash
./generate-pdf.sh FICHIER.md [OPTIONS]

OPTIONS:
    -t, --toc           Inclut une table des matières
    -o, --output FILE   Nom du fichier de sortie
    -a, --author NAME   Nom de l'auteur
    -d, --date DATE     Date (défaut: date actuelle)
    --no-clean          Ne pas supprimer les fichiers intermédiaires

EXEMPLES:
    ./generate-pdf.sh rapport.md --toc --author "Mon Nom"
    ./generate-pdf.sh notes.md -o mes-notes.pdf

    # Avec configuration (pdf-config.yaml définit déjà author et toc)
    ./generate-pdf.sh rapport.md
```

### Méthode 2 : Makefile (pour projets)

Pour utiliser avec vos propres documents, éditez le `Makefile` :

```makefile
# Exemple : générer documentation.pdf
documentation: documentation.pdf

documentation.pdf: documentation.md template.latex generate-pdf.sh
	@./generate-pdf.sh documentation.md --toc --author "Votre Nom"
```

Puis :
```bash
make documentation
```

## Structure des Fichiers

```
markdown-to-pdf/
├── README.md              # Ce fichier
├── README_PDF.md          # Documentation détaillée
├── INSTALL_LATEX.md       # Guide d'installation LaTeX
├── generate-pdf.sh        # Script de génération
├── template.latex         # Template LaTeX professionnel
└── Makefile              # Exemple de Makefile
```

## Personnalisation

### Modifier les Couleurs

Éditer `template.latex` :
```latex
\definecolor{primarycolor}{RGB}{33, 150, 243}    % Bleu
\definecolor{secondarycolor}{RGB}{96, 125, 139}  % Gris
\definecolor{headercolor}{RGB}{55, 71, 79}       % Gris foncé
```

### Modifier les Marges

```latex
\geometry{
    a4paper,
    left=25mm,
    right=25mm,
    top=30mm,
    bottom=30mm
}
```

### Modifier la Police

Par défaut, le template utilise les polices système. Pour utiliser une police spécifique :

```latex
\setmainfont{Nom de la Police}
```

## Exemples

### Document Simple

```markdown
# Mon Document

Ceci est un paragraphe avec des **mots en gras** et *italique*.

## Section 1

- Item 1
- Item 2
- Item 3

## Section 2

Tableau :

| Colonne 1 | Colonne 2 |
|-----------|-----------|
| Valeur 1  | Valeur 2  |
```

Générer :
```bash
./generate-pdf.sh document.md --toc --author "Mon Nom"
```

### Avec Liens et Code

```markdown
# Documentation Technique

Voir [ce lien](https://example.com) pour plus d'infos.

## Code

\`\`\`python
def hello():
    print("Hello, World!")
\`\`\`
```

## Résolution de Problèmes

### "pdflatex: command not found" OU "xelatex: command not found"

Solution : Installer MacTeX (voir section Installation)

### Warnings sur les émojis manquants

C'est normal. Les émojis ne s'afficheront pas dans le PDF mais le document sera créé correctement. Pour supporter les émojis, il faudrait une police système avec support emoji complet.

### Tableaux mal formatés

Le template gère la plupart des tableaux Markdown. Pour des tableaux très complexes, simplifiez-les ou utilisez du HTML.

## Documentation Complète

- `README_PDF.md` - Documentation détaillée
- `INSTALL_LATEX.md` - Guide d'installation LaTeX
- `./generate-pdf.sh --help` - Aide du script

## Licence

Libre d'utilisation pour vos projets personnels et professionnels.

## Auteur

Créé pour faciliter la génération de documentation professionnelle.

## Contributeurs

N'hésitez pas à suggérer des améliorations !
