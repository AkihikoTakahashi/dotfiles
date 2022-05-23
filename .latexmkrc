#!/usr/bin/env perl
$latex            = 'platex -synctex=1 -halt-on-error';
$latex_silent     = 'platex -synctex=1 -halt-on-error -interaction=batchmode';
$bibtex           = 'pbibtex';
$biber            = 'biber --bblencoding=utf8 -u -U --output_safechars';
$dvipdf           = 'dvipdfmx %O -o %D %S';
$makeindex        = 'mendex %O -o %D %S';

$max_repeat       = 5;
$pdf_mode         = 3;	# generate pdf via pdfmx
$pvc_view_file_via_temporary = 0;
$pdf_previewer    = "open -a /Applications/Skim.app";  # open by Skim
