include .env

OUTPUT_DIR=_output
TEMPLATE_DIR=latex
ABSTRACTS_DIR=abstracts
DATA_DIR=data

all: book

$(OUTPUT_DIR)/abstracts.tex: compile_abstracts.bb $(ABSTRACTS_DIR)/* $(TEMPLATE_DIR)/*.latex $(DATA_DIR)/*.yml
	mkdir -p $(OUTPUT_DIR)
	bb compile_abstracts.bb --path $(ABSTRACTS_DIR) --format latex >$(OUTPUT_DIR)/abstracts.tex

$(OUTPUT_DIR)/book-of-abstracts.pdf: $(OUTPUT_DIR)/abstracts.tex $(TEMPLATE_DIR)/*.latex
	cd $(OUTPUT_DIR) && \
	xelatex ../$(TEMPLATE_DIR)/book-of-abstracts.latex && \
	while grep -q 'Rerun to get' book-of-abstracts.log || grep -q 'LaTeX Warning: Label(s) may have changed' book-of-abstracts.log; do \
		xelatex ../$(TEMPLATE_DIR)/book-of-abstracts.latex; \
	done

book: $(OUTPUT_DIR)/book-of-abstracts.pdf

$(OUTPUT_DIR)/program.docx: compile_abstracts.bb $(ABSTRACTS_DIR)/* $(TEMPLATE_DIR)/*.latex $(DATA_DIR)/*.yml
	bb compile_abstracts.bb --path $(ABSTRACTS_DIR) --format program | \
	pandoc -f markdown -t docx -o $(OUTPUT_DIR)/program.docx

program: $(OUTPUT_DIR)/program.docx

clean:
	rm -f $(OUTPUT_DIR)/abstracts.tex $(OUTPUT_DIR)/book-of-abstracts.pdf \
		$(OUTPUT_DIR)/*.aux $(OUTPUT_DIR)/*.log $(OUTPUT_DIR)/*.out \
		$(OUTPUT_DIR)/program.docx

deploy_pdf: $(OUTPUT_DIR)/book-of-abstracts.pdf
	aws s3 cp $(OUTPUT_DIR)/book-of-abstracts.pdf s3://$(AWS_S3_BUCKET_NAME)/$(PDF_TARGET_NAME)


