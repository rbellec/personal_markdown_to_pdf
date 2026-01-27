# Makefile générique pour convertir des fichiers Markdown en PDF

.PHONY: all clean help list

# Couleurs pour l'affichage
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

# Options par défaut (peuvent être surchargées)
PDF_OPTIONS ?= --toc

# Trouver tous les fichiers .md dans le répertoire courant
MD_FILES := $(wildcard *.md)
PDF_FILES := $(MD_FILES:.md=.pdf)

# Cible par défaut : convertir tous les fichiers .md en .pdf
all: $(PDF_FILES)
	@echo "$(GREEN)[OK] Tous les PDFs ont ete generes avec succes$(NC)"

# Règle générique : convertir n'importe quel .md en .pdf
%.pdf: %.md template.latex generate-pdf.sh
	@echo "$(BLUE)Generation de $@...$(NC)"
	@./generate-pdf.sh $< $(PDF_OPTIONS)

# Lister les fichiers qui seront convertis
list:
	@echo "$(YELLOW)Fichiers Markdown trouves :$(NC)"
	@for f in $(MD_FILES); do echo "  - $$f -> $${f%.md}.pdf"; done
	@echo ""
	@echo "$(YELLOW)Options actuelles : $(PDF_OPTIONS)$(NC)"

clean:
	@echo "$(BLUE)Nettoyage des fichiers generes...$(NC)"
	@rm -f *.pdf *.tex *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz
	@echo "$(GREEN)[OK] Nettoyage termine$(NC)"

help:
	@echo "Markdown to PDF - Makefile generique"
	@echo ""
	@echo "Cibles disponibles:"
	@echo "  make              - Convertit tous les .md en .pdf (defaut)"
	@echo "  make all          - Idem"
	@echo "  make FICHIER.pdf  - Convertit un fichier specifique"
	@echo "  make list         - Liste les fichiers qui seront convertis"
	@echo "  make clean        - Supprime tous les fichiers generes"
	@echo "  make help         - Affiche cette aide"
	@echo ""
	@echo "Personnalisation des options:"
	@echo "  make PDF_OPTIONS='--toc --author \"Mon Nom\"'"
	@echo "  make FICHIER.pdf PDF_OPTIONS='--no-toc'"
	@echo ""
	@echo "Utilisation du script directement:"
	@echo "  ./generate-pdf.sh FICHIER.md [OPTIONS]"
	@echo "  ./generate-pdf.sh --help pour plus d'informations"
