#!/bin/bash

header () {
	cat <<- HEADER
		\documentclass{article}
		\begin{document}
		\begin{tabular}{lllcrrrrr}

		%Lang & Factors & Corpus & Paraphrases & Bleu & Variance & Delta & Significance & Meteor \\\\ \hline
	HEADER
}

body () {
#	grep -v pos |
#	cut -f1,2,4- |
	sed 's#ja-en#JE#g
		s#en-ja#EJ#g
		s#slt#IWSLT05#g
		s#tc[0-9]*s#Half Tanaka Corpus#g
		s#tc[0-9]*#Full Tanaka Corpus#g
		s#--#\\--#g
		s#+/-#$\\pm$#g
		s#%#\\%#g
		s#\t# \& #g
		s#$# \\\\#g'
}

footer () {
	cat <<- FOOTER

		\end{tabular}
		\end{document}
	FOOTER
}

header
body
footer
