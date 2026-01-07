# Makefile pour générer les PDFs de documentation

.PHONY: all clean questions todo terminology help

# Couleurs pour l'affichage
BLUE := \033[0;34m
GREEN := \033[0;32m
NC := \033[0m # No Color

all: questions todo terminology
	@echo "$(GREEN)✓ Tous les PDFs ont été générés avec succès$(NC)"

questions: QUESTIONS_AUTEUR.pdf

todo: TODO.pdf

terminology: TERMINOLOGY.pdf

QUESTIONS_AUTEUR.pdf: QUESTIONS_AUTEUR.md template.latex generate-pdf.sh
	@echo "$(BLUE)Génération de QUESTIONS_AUTEUR.pdf...$(NC)"
	@./generate-pdf.sh QUESTIONS_AUTEUR.md --toc --author "Équipe de développement"

TODO.pdf: TODO.md template.latex generate-pdf.sh
	@echo "$(BLUE)Génération de TODO.pdf...$(NC)"
	@./generate-pdf.sh TODO.md --toc --author "Équipe de développement"

TERMINOLOGY.pdf: TERMINOLOGY.md template.latex generate-pdf.sh
	@echo "$(BLUE)Génération de TERMINOLOGY.pdf...$(NC)"
	@./generate-pdf.sh TERMINOLOGY.md --toc --author "Équipe de développement"

clean:
	@echo "$(BLUE)Nettoyage des fichiers générés...$(NC)"
	@rm -f *.pdf *.tex *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz
	@echo "$(GREEN)✓ Nettoyage terminé$(NC)"

help:
	@echo "Makefile pour Go on RASALVA - Génération de PDFs"
	@echo ""
	@echo "Cibles disponibles:"
	@echo "  make all          - Génère tous les PDFs (défaut)"
	@echo "  make questions    - Génère QUESTIONS_AUTEUR.pdf"
	@echo "  make todo         - Génère TODO.pdf"
	@echo "  make terminology  - Génère TERMINOLOGY.pdf"
	@echo "  make clean        - Supprime tous les fichiers générés"
	@echo "  make help         - Affiche cette aide"
	@echo ""
	@echo "Utilisation du script directement:"
	@echo "  ./generate-pdf.sh FICHIER.md [OPTIONS]"
	@echo "  ./generate-pdf.sh --help pour plus d'informations"
