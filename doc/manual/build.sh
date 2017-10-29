#!/bin/bash

if [ $GEM_SET_DEBUG ]; then
    set -x
fi
set -e

inkscape -A figures/rmtk_manual_cover.pdf figures/rmtk_manual_cover.svg

(pdflatex -shell-escape -interaction=nonstopmode rmtk-manual.tex
bibtex rmtk-manual
pdflatex -shell-escape -interaction=nonstopmode rmtk-manual.tex
makeindex rmtk-manual.idx
makeglossaries rmtk-manual
pdflatex -shell-escape -interaction=nonstopmode rmtk-manual.tex) | egrep -i "error|warning|missing"

if [ -f rmtk-manual.pdf ]; then
    ./clean.sh || true
    if [ "$1" == "--compress" ]; then
        pdfinfo "rmtk-manual.pdf" | sed -e 's/^ *//;s/ *$//;s/ \{1,\}/ /g' -e 's/^/  \//' -e '/CreationDate/,$d' -e 's/$/)/' -e 's/: / (/' > .pdfmarks
        sed -i '1s/^ /[/' .pdfmarks
        sed -i '/:)$/d' .pdfmarks
        echo "  /DOCINFO pdfmark" >> .pdfmarks

        gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=compressed-rmtk-manual.pdf rmtk-manual.pdf .pdfmarks

        mv -f compressed-rmtk-manual.pdf rmtk-manual.pdf
    fi
else
    exit 1
fi
