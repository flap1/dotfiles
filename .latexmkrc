#!/usr/bin/env perl

# LaTeX
$latex = 'lualatex -synctex=1 -halt-on-error -file-line-error -interaction=nonstopmode %O %S';
$max_repeat = 5;

# BibTeX
$bibtex = 'pbibtex %O %S';
$biber = 'biber --bblencoding=utf8 -u -U --output_safechars %O %S';

# index
$makeindex = 'mendex %O -o %D %S';

# DVI / PDF
$dvipdf = 'dvipdfmx %O -o %D %S';
$pdf_mode = 3; # use dvipdf

# preview
$pvc_view_file_via_temporary = 0;
if ($^O eq 'linux') {
    $dvi_previewer = "okular %S";
    $pdf_previewer = "okular %S";
} elsif ($^O eq 'darwin') {
    $dvi_previewer = "okular %S";
    $pdf_previewer = "okular %S";
} else {
    $dvi_previewer = "okular %S";
    $pdf_previewer = "okular %S";
}

# clean up
# $clean_full_ext = "%R.synctex.gz"

