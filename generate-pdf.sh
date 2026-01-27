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

# Fonction pour lire la configuration YAML
load_config() {
    local config_file=""

    # Chercher pdf-config.yaml dans le répertoire courant
    if [[ -f "pdf-config.yaml" ]]; then
        config_file="pdf-config.yaml"
    # Sinon chercher dans le répertoire du script
    elif [[ -f "$(dirname "$0")/pdf-config.yaml" ]]; then
        config_file="$(dirname "$0")/pdf-config.yaml"
    fi

    if [[ -n "$config_file" ]]; then
        # Parser les valeurs simples du YAML (format "clé: valeur")
        while IFS=: read -r key value; do
            # Ignorer les commentaires et lignes vides
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue

            # Nettoyer la clé et la valeur
            key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//')

            # Appliquer les configurations
            case "$key" in
                author) CONFIG_AUTHOR="$value" ;;
                date) CONFIG_DATE="$value" ;;
                toc) [[ "$value" == "true" ]] && CONFIG_TOC="--toc" ;;
                project) CONFIG_PROJECT="$value" ;;
                project-desc) CONFIG_PROJECT_DESC="$value" ;;
            esac
        done < "$config_file"
    fi
}

# Fonction d'aide
show_help() {
    cat << EOF
Usage: ${0##*/} FICHIER.md [OPTIONS]

Génère un PDF professionnel à partir d'un fichier Markdown.

OPTIONS:
    -h, --help              Affiche cette aide
    -t, --toc               Inclut une table des matières
    -o, --output FILE       Nom du fichier de sortie (défaut: même nom avec .pdf)
    -a, --author NAME       Nom de l'auteur
    -d, --date DATE         Date (défaut: date actuelle)
    -p, --project NAME      Nom du projet (affiché sur la page de titre)
    --project-desc TEXT     Description du projet (affiché sous le nom du projet)
    --no-clean              Ne pas supprimer les fichiers intermédiaires .tex

CONFIGURATION:
    Créez un fichier 'pdf-config.yaml' dans le répertoire courant ou dans
    le répertoire du script pour définir des valeurs par défaut :

    author: "Votre Nom"
    date: "Janvier 2026"
    toc: true
    project: "Mon Projet"
    project-desc: "Documentation"

EXEMPLES:
    ${0##*/} QUESTIONS_AUTEUR.md --toc
    ${0##*/} TODO.md -o tasks.pdf --author "Équipe Dev"
    ${0##*/} TERMINOLOGY.md --toc --no-clean

PRÉREQUIS:
    - pandoc (installé)
    - pdflatex (distribution LaTeX comme TeX Live ou MacTeX)

EOF
}

# Charger la configuration depuis pdf-config.yaml si présent
CONFIG_AUTHOR=""
CONFIG_DATE=""
CONFIG_TOC=""
CONFIG_PROJECT=""
CONFIG_PROJECT_DESC=""
load_config

# Valeurs par défaut (peuvent être overridées par la config puis par les arguments CLI)
TOC="${CONFIG_TOC}"
OUTPUT=""
AUTHOR="${CONFIG_AUTHOR:-}"
DATE="${CONFIG_DATE:-$(/bin/date "+%d %B %Y" 2>/dev/null || echo "Janvier 2026")}"
PROJECT="${CONFIG_PROJECT:-}"
PROJECT_DESC="${CONFIG_PROJECT_DESC:-}"
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
        -p|--project)
            PROJECT="$2"
            shift 2
            ;;
        --project-desc)
            PROJECT_DESC="$2"
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

# Sauvegarder le nom de fichier original pour le titre et la sortie
ORIGINAL_INPUT="$INPUT"

# Déterminer le nom de sortie (basé sur le fichier original, pas le temporaire)
if [[ -z "$OUTPUT" ]]; then
    OUTPUT="${ORIGINAL_INPUT%.md}.pdf"
fi

# Extraire le titre du premier # du fichier Markdown
TITLE=$(grep -m 1 "^# " "$ORIGINAL_INPUT" | sed 's/^# //' || echo "Document")

# Créer un fichier temporaire avec les émojis remplacés
TEMP_INPUT="${ORIGINAL_INPUT%.md}_temp.md"
cp "$INPUT" "$TEMP_INPUT"

# Mapping des émojis vers des symboles/texte LaTeX
sed -i.bak \
    -e 's/🌱/[Serre]/g' \
    -e 's/💧/[Eau]/g' \
    -e 's/⛏️/[Mine]/g' \
    -e 's/⛏/[Mine]/g' \
    -e 's/📦/[Extraction]/g' \
    -e 's/✅/[OK]/g' \
    -e 's/❌/[X]/g' \
    -e 's/✓/[v]/g' \
    -e 's/✗/[x]/g' \
    -e 's/❓/[?]/g' \
    -e 's/⚠️/[!]/g' \
    -e 's/⚠/[!]/g' \
    -e 's/💻/[Code]/g' \
    -e 's/🎯/[Cible]/g' \
    -e 's/🔧/[Outil]/g' \
    -e 's/📝/[Doc]/g' \
    -e 's/🤖/[Bot]/g' \
    "$TEMP_INPUT"

# Nettoyer le fichier backup créé par sed -i
rm -f "${TEMP_INPUT}.bak"

# Utiliser le fichier temporaire pour la génération
INPUT="$TEMP_INPUT"

echo -e "${BLUE}=== Génération du PDF ===${NC}"
echo -e "${YELLOW}Fichier source:${NC} $ORIGINAL_INPUT"
echo -e "${YELLOW}Fichier cible:${NC} $OUTPUT"
echo -e "${YELLOW}Titre:${NC} $TITLE"
[[ -n "$AUTHOR" ]] && echo -e "${YELLOW}Auteur:${NC} $AUTHOR"
echo -e "${YELLOW}Date:${NC} $DATE"
[[ -n "$PROJECT" ]] && echo -e "${YELLOW}Projet:${NC} $PROJECT"
[[ -n "$PROJECT_DESC" ]] && echo -e "${YELLOW}Description:${NC} $PROJECT_DESC"

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

# Construire les options pandoc
PANDOC_OPTS=(
    --from markdown
    --to latex
    --template=template.latex
    --pdf-engine=xelatex
    --variable "title=$TITLE"
    --variable "date=$DATE"
    --variable lang=fr
    --variable papersize=a4
    --variable geometry:margin=25mm
)

[[ -n "$AUTHOR" ]] && PANDOC_OPTS+=(--variable "author=$AUTHOR")
[[ -n "$PROJECT" ]] && PANDOC_OPTS+=(--variable "project=$PROJECT")
[[ -n "$PROJECT_DESC" ]] && PANDOC_OPTS+=(--variable "project-desc=$PROJECT_DESC")
[[ -n "$TOC" ]] && PANDOC_OPTS+=($TOC)

pandoc "$INPUT" "${PANDOC_OPTS[@]}" --output="$OUTPUT" 2>&1 | grep -v "LaTeX Warning" || true

# Vérifier que la génération a réussi
if [[ $? -eq 0 && -f "$OUTPUT" ]]; then
    echo -e "${GREEN}✓ PDF généré avec succès: $OUTPUT${NC}"

    # Nettoyer les fichiers intermédiaires si demandé
    if [[ "$CLEAN" == true ]]; then
        echo -e "${BLUE}Nettoyage des fichiers intermédiaires...${NC}"
        rm -f *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz
        # Nettoyer le fichier temporaire avec émojis remplacés
        rm -f "$TEMP_INPUT" "${TEMP_INPUT}.bak"
        echo -e "${GREEN}✓ Nettoyage terminé${NC}"
    fi

    # Afficher la taille du fichier
    SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
    echo -e "${YELLOW}Taille du PDF:${NC} $SIZE"

    # Proposer d'ouvrir le PDF
    echo -e "\n${BLUE}Pour ouvrir le PDF:${NC} open '$OUTPUT'"
else
    echo -e "${RED}✗ Erreur lors de la génération du PDF${NC}" >&2
    # Nettoyer le fichier temporaire même en cas d'erreur
    rm -f "$TEMP_INPUT" "${TEMP_INPUT}.bak"
    exit 1
fi
