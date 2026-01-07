#!/bin/bash

# Script pour générer des PDFs propres à partir de fichiers Markdown
# Usage: ./generate-pdf.sh FICHIER.md [OPTIONS]

set -e

# Ajouter LaTeX au PATH si nécessaire
if [[ -d "/Library/TeX/texbin" ]]; then
    export PATH="/Library/TeX/texbin:$PATH"
fi

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'aide
show_help() {
    cat << EOF
Usage: ${0##*/} FICHIER.md [OPTIONS]

Génère un PDF professionnel à partir d'un fichier Markdown.

OPTIONS:
    -h, --help          Affiche cette aide
    -t, --toc           Inclut une table des matières
    -o, --output FILE   Nom du fichier de sortie (défaut: même nom avec .pdf)
    -a, --author NAME   Nom de l'auteur
    -d, --date DATE     Date (défaut: date actuelle)
    --no-clean          Ne pas supprimer les fichiers intermédiaires .tex

EXEMPLES:
    ${0##*/} QUESTIONS_AUTEUR.md --toc
    ${0##*/} TODO.md -o tasks.pdf --author "Équipe Dev"
    ${0##*/} TERMINOLOGY.md --toc --no-clean

PRÉREQUIS:
    - pandoc (installé)
    - pdflatex (distribution LaTeX comme TeX Live ou MacTeX)

EOF
}

# Valeurs par défaut
TOC=""
OUTPUT=""
AUTHOR="Équipe de développement"
DATE=$(/bin/date "+%d %B %Y" 2>/dev/null || echo "Janvier 2026")
CLEAN=true
INPUT=""

# Parse des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -t|--toc)
            TOC="--toc"
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -a|--author)
            AUTHOR="$2"
            shift 2
            ;;
        -d|--date)
            DATE="$2"
            shift 2
            ;;
        --no-clean)
            CLEAN=false
            shift
            ;;
        -*)
            echo -e "${RED}Option inconnue: $1${NC}" >&2
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"
            else
                echo -e "${RED}Erreur: fichier d'entrée déjà spécifié${NC}" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Vérifier qu'un fichier d'entrée est spécifié
if [[ -z "$INPUT" ]]; then
    echo -e "${RED}Erreur: aucun fichier d'entrée spécifié${NC}" >&2
    show_help
    exit 1
fi

# Vérifier que le fichier existe
if [[ ! -f "$INPUT" ]]; then
    echo -e "${RED}Erreur: fichier '$INPUT' introuvable${NC}" >&2
    exit 1
fi

# Déterminer le nom de sortie
if [[ -z "$OUTPUT" ]]; then
    OUTPUT="${INPUT%.md}.pdf"
fi

# Extraire le titre du premier # du fichier Markdown
TITLE=$(grep -m 1 "^# " "$INPUT" | sed 's/^# //' || echo "Document")

echo -e "${BLUE}=== Génération du PDF ===${NC}"
echo -e "${YELLOW}Fichier source:${NC} $INPUT"
echo -e "${YELLOW}Fichier cible:${NC} $OUTPUT"
echo -e "${YELLOW}Titre:${NC} $TITLE"
echo -e "${YELLOW}Auteur:${NC} $AUTHOR"
echo -e "${YELLOW}Date:${NC} $DATE"

# Vérifier que pandoc est installé
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Erreur: pandoc n'est pas installé${NC}" >&2
    echo "Installation: brew install pandoc (macOS) ou voir https://pandoc.org/installing.html"
    exit 1
fi

# Vérifier que pdflatex est installé
if ! command -v pdflatex &> /dev/null; then
    echo -e "${RED}Erreur: pdflatex n'est pas installé${NC}" >&2
    echo "Installation: brew install --cask mactex-no-gui (macOS) ou apt-get install texlive-latex-base (Linux)"
    exit 1
fi

# Générer le PDF
echo -e "\n${BLUE}Génération en cours...${NC}"

pandoc "$INPUT" \
    --from markdown \
    --to latex \
    --template=template.latex \
    --pdf-engine=xelatex \
    --variable title="$TITLE" \
    --variable author="$AUTHOR" \
    --variable date="$DATE" \
    --variable lang=fr \
    --variable papersize=a4 \
    --variable geometry:margin=25mm \
    $TOC \
    --output="$OUTPUT" \
    2>&1 | grep -v "LaTeX Warning" || true

# Vérifier que la génération a réussi
if [[ $? -eq 0 && -f "$OUTPUT" ]]; then
    echo -e "${GREEN}✓ PDF généré avec succès: $OUTPUT${NC}"

    # Nettoyer les fichiers intermédiaires si demandé
    if [[ "$CLEAN" == true ]]; then
        echo -e "${BLUE}Nettoyage des fichiers intermédiaires...${NC}"
        rm -f *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz
        echo -e "${GREEN}✓ Nettoyage terminé${NC}"
    fi

    # Afficher la taille du fichier
    SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
    echo -e "${YELLOW}Taille du PDF:${NC} $SIZE"

    # Proposer d'ouvrir le PDF
    echo -e "\n${BLUE}Pour ouvrir le PDF:${NC} open '$OUTPUT'"
else
    echo -e "${RED}✗ Erreur lors de la génération du PDF${NC}" >&2
    exit 1
fi
