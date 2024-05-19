include .env

OUTPUT_DIR=_output
LATEX_DIR=latex
DATA_DIR=abstracts

all: book

$(OUTPUT_DIR)/abstracts.tex: compile_abstracts.bb $(DATA_DIR)/* $(LATEX_DIR)/*.latex
	mkdir -p $(OUTPUT_DIR)
	bb compile_abstracts.bb --path $(DATA_DIR) --format latex >$(OUTPUT_DIR)/abstracts.tex

$(OUTPUT_DIR)/book-of-abstracts.pdf: $(OUTPUT_DIR)/abstracts.tex $(LATEX_DIR)/*.latex
	cd $(OUTPUT_DIR) && \
	xelatex ../$(LATEX_DIR)/book-of-abstracts.latex && \
	while grep -q 'Rerun to get' book-of-abstracts.log || grep -q 'LaTeX Warning: Label(s) may have changed' book-of-abstracts.log; do \
		xelatex ../$(LATEX_DIR)/book-of-abstracts.latex; \
	done

book: $(OUTPUT_DIR)/book-of-abstracts.pdf

clean:
	rm -f $(OUTPUT_DIR)/abstracts.tex $(OUTPUT_DIR)/book-of-abstracts.pdf \
		$(OUTPUT_DIR)/*.aux $(OUTPUT_DIR)/*.log $(OUTPUT_DIR)/*.out

deploy_pdf: $(OUTPUT_DIR)/book-of-abstracts.pdf
	aws s3 cp $(OUTPUT_DIR)/book-of-abstracts.pdf s3://$(AWS_S3_BUCKET_NAME)/$(PDF_TARGET_NAME)


