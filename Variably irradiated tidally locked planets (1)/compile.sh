#!/bin/bash
set -e

FILE="${1:-sample7_v2}"
BASE="${FILE%.tex}"

echo "Compiling $BASE.tex ..."
pdflatex -interaction=nonstopmode "$BASE.tex"
bibtex "$BASE"
pdflatex -interaction=nonstopmode "$BASE.tex"
pdflatex -interaction=nonstopmode "$BASE.tex"
echo "Done: $BASE.pdf"
