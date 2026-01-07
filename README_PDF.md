# Génération de PDFs pour la Documentation

Ce dossier contient un système de génération de PDFs professionnels à partir des fichiers Markdown de documentation.

Cet outil a été fait pour mes besoins et n'a aucune prétention. N'hesitez pas à vous en inspirer.

## Prérequis

### 1. Pandoc
```bash
brew install pandoc  # macOS
```

### 2. LaTeX (pdflatex)
```bash
# macOS - Installation légère (recommandé)
brew install --cask basictex
# Puis installer les packages nécessaires
sudo tlmgr update --self
sudo tlmgr install collection-fontsrecommended
sudo tlmgr install babel-french

# Ou installation complète (plus gros, ~4GB)
brew install --cask mactex-no-gui
```

### Vérification
```bash
pandoc --version
pdflatex --version
```

## Utilisation Rapide

### Méthode 1 : Makefile (recommandé)

Générer tous les PDFs :
```bash
make all
```

Générer un PDF spécifique :
```bash
make questions      # QUESTIONS_AUTEUR.pdf
make todo          # TODO.pdf
make terminology   # TERMINOLOGY.pdf
```

Nettoyer tous les fichiers générés :
```bash
make clean
```

### Méthode 2 : Script direct

Générer un PDF avec table des matières :
```bash
./generate-pdf.sh QUESTIONS_AUTEUR.md --toc
```

Options avancées :
```bash
./generate-pdf.sh TODO.md \
    --toc \
    --output mes-taches.pdf \
    --author "Mon Nom" \
    --date "7 janvier 2026"
```

Voir toutes les options :
```bash
./generate-pdf.sh --help
```

## Fichiers

### Fichiers de Configuration
- `template.latex` - Template LaTeX professionnel avec mise en page soignée
- `generate-pdf.sh` - Script de génération
- `Makefile` - Automatisation de la génération

### Fichiers Source (Markdown)
- `QUESTIONS_AUTEUR.md` - Questions pour l'auteur du jeu
- `TODO.md` - Liste des tâches du projet
- `TERMINOLOGY.md` - Clarification de la terminologie du jeu

### Fichiers Ignorés (Git)
Les fichiers suivants sont générés localement et ne sont pas versionnés :
- `*.pdf` - PDFs générés
- `*.tex` - LaTeX intermédiaire
- `*.aux`, `*.log`, `*.out`, etc. - Fichiers temporaires LaTeX

## Personnalisation du Template

Le template `template.latex` utilise :
- **Couleurs** : Bleu primaire (#2196F3), gris secondaire (#607D8B)
- **Police** : Latin Modern (lmodern)
- **Mise en page** : Marges de 25mm, en-têtes personnalisés
- **Sections** : Titres colorés avec filets séparateurs
- **Listes** : Puces colorées
- **Tableaux** : Style professionnel avec booktabs
- **Page de titre** : Personnalisée avec titre, auteur, date

Pour modifier les couleurs, éditer dans `template.latex` :
```latex
\definecolor{primarycolor}{RGB}{33, 150, 243}
\definecolor{secondarycolor}{RGB}{96, 125, 139}
\definecolor{headercolor}{RGB}{55, 71, 79}
```

## Exemples de Rendu

### Table des Matières
Le flag `--toc` génère automatiquement une table des matières avec numérotation et liens cliquables.

### Tableaux Markdown
Les tableaux Markdown sont convertis en tableaux LaTeX professionnels :

```markdown
| Concept | Description |
|---------|-------------|
| Terrain | Type de case |
| Ressource | Unité gagnée |
```

### Listes et Sous-listes
Les listes à puces sont rendues avec des couleurs progressives (bleu → gris).

### Liens
Les liens sont colorés en bleu et cliquables dans le PDF.

## Dépannage

### Erreur "pandoc: command not found"
```bash
brew install pandoc
```

### Erreur "pdflatex: command not found"
```bash
brew install --cask basictex
# Redémarrer le terminal
# Puis installer les packages français
sudo tlmgr install babel-french
```

### Erreur "! LaTeX Error: File 'XXX.sty' not found"
Installer le package manquant :
```bash
sudo tlmgr install nom-du-package
```

### Warnings LaTeX
Les warnings LaTeX sont filtrés par défaut. Pour les voir :
```bash
./generate-pdf.sh FICHIER.md --no-clean
# Les fichiers .log contiendront tous les détails
```

## Workflow Recommandé

1. Éditer les fichiers `.md` (QUESTIONS_AUTEUR.md, TODO.md, etc.)
2. Générer les PDFs :
   ```bash
   make all
   ```
3. Vérifier les PDFs :
   ```bash
   open QUESTIONS_AUTEUR.pdf
   ```
4. Envoyer les PDFs (emails, documentation)
5. Ne **pas** commiter les PDFs dans git

## Scripts et Automatisation

### Génération Automatique lors de Modifications
Avec `fswatch` (macOS) :
```bash
brew install fswatch
fswatch -o *.md | xargs -n1 -I{} make all
```

### Hook Git Pre-commit (optionnel)
Pour vérifier que les PDFs sont à jour avant commit :
```bash
# .git/hooks/pre-commit
#!/bin/bash
make all
git add *.pdf  # Si vous voulez les commiter
```

## Support

Pour toute question sur la génération de PDFs :
1. Consulter `./generate-pdf.sh --help`
2. Vérifier les logs LaTeX dans `*.log`
3. Tester avec un fichier Markdown simple
