#!/usr/bin/env bash

yes | ols -r; clear; rsync -a /home/vasilii/research/trillium/scratch/SHIVAN/analysis/paper_plots/light .; ols -l & pdflatex ./oja_template.tex

