# Installation de LaTeX pour la Génération de PDFs

## Option 1 : BasicTeX (Recommandé - Léger, ~100MB)

### Installation
```bash
brew install --cask basictex
```

### Configuration (important !)
Après l'installation, **redémarrer le terminal** puis :

```bash
# Mettre à jour le gestionnaire de packages
sudo tlmgr update --self

# Installer les packages nécessaires pour le français
sudo tlmgr install babel-french

# Installer les collections de polices recommandées
sudo tlmgr install collection-fontsrecommended

# Installer les packages utilisés par notre template
sudo tlmgr install \
    geometry \
    fancyhdr \
    titlesec \
    enumitem \
    booktabs \
    tocloft \
    hyperref \
    xcolor
```

### Vérification
```bash
pdflatex --version
# Devrait afficher: pdfTeX 3.141592653-2.6-1.40.xx (TeX Live ...)
```

---

## Option 2 : MacTeX (Complet - ~4GB)

### Installation
```bash
brew install --cask mactex-no-gui
```

### Vérification
```bash
# Redémarrer le terminal
pdflatex --version
```

**Avantages :** Tous les packages LaTeX sont déjà installés.
**Inconvénient :** Très gros téléchargement (~4GB).

---

## Test de la Génération

Une fois LaTeX installé, tester :

```bash
cd /Users/raph/Work/3_GoOnRasalva/Go-On-Rasalva-on-BGA/goonrasalva

# Générer le PDF des questions pour l'auteur
./generate-pdf.sh QUESTIONS_AUTEUR.md --toc

# Si succès, ouvrir le PDF
open QUESTIONS_AUTEUR.pdf
```

---

## Dépannage

### Erreur "tlmgr: command not found" après installation BasicTeX

**Cause :** Le PATH n'est pas à jour.

**Solution :**
```bash
# Redémarrer le terminal
# OU ajouter manuellement au PATH
export PATH="/Library/TeX/texbin:$PATH"
```

### Erreur "! LaTeX Error: File 'XXX.sty' not found"

**Cause :** Package LaTeX manquant.

**Solution :**
```bash
sudo tlmgr install nom-du-package
```

**Exemple :** Si l'erreur mentionne `babel-french.sty` :
```bash
sudo tlmgr install babel-french
```

### Permission Denied lors de tlmgr install

**Solution :**
```bash
sudo tlmgr install nom-du-package
```

N'oubliez pas le `sudo` !

---

## Installation Alternative (Linux)

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install texlive-latex-base texlive-lang-french texlive-fonts-recommended
```

### Fedora/RHEL
```bash
sudo dnf install texlive-scheme-basic texlive-babel-french
```

---

## Prochaines Étapes

Une fois LaTeX installé :

1. **Générer tous les PDFs :**
   ```bash
   make all
   ```

2. **Ouvrir les PDFs générés :**
   ```bash
   open QUESTIONS_AUTEUR.pdf
   open TODO.pdf
   open TERMINOLOGY.pdf
   ```

3. **Lire la documentation complète :**
   ```bash
   cat README_PDF.md
   ```

---

## Ressources

- [Pandoc Documentation](https://pandoc.org/MANUAL.html)
- [LaTeX Project](https://www.latex-project.org/)
- [CTAN (Comprehensive TeX Archive Network)](https://ctan.org/)
- [BasicTeX](https://www.tug.org/mactex/morepackages.html)
