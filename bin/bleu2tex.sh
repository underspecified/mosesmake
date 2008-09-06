#!/bin/bash

header () {
	cat <<- HEADER
		\documentclass{article}
		\begin{document}
		\begin{tabular}{lllrrrr}

		Factors & Corpus & Paraphrases & Bleu & Variance & Delta & Significance \\\\ \hline
	HEADER
}

body () {
	grep -v pos |
	cut -f1,2,4- |
	sed 's#ja-en#JE#g
	     s#en-ja#EJ#g
	     s#--#\\--#g
	     s#w_mert#mert#g
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
