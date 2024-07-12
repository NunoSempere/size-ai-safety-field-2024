# make build

# Filenames
INPUT=index.md
OUTPUT=estimate-ais-community-size.pdf

# Config options
PDF_ENGINE=--pdf-engine=xelatex
URL_PROPERTIES=-V colorlinks=true -V linkcolor=blue -V urlcolor=blue 
VERBOSE=--verbose
MARKDOWN_IMAGES=-f markdown-implicit_figures
TOC=--table-of-contents

build: $(OUTPUT)

$(OUTPUT): $(INPUT)
	pandoc $(INPUT) --output $(OUTPUT) $(PDF_ENGINE) $(URL_PROPERTIES) $(VERBOSE) $(MARKDOWN_IMAGES) $(TOC)
