#!/bin/bash

find_bleu () {
	find -L $* -name "*.bleu"
}

get_lang+fact () {
	awk '
	BEGIN {
		FS = "/"
		OFS = "\t"
	}
	{
		print$(NF-3), $(NF-2)
	}'
}

get_corpus+para+mert () {
	awk '
	BEGIN {
		FS = "."
		OFS = "\t"
	}
	{
		print $1, $2, $(NF-1)
	}' |
	sed 's/output/w_mert/g
		 s/test/0/g'
}

print_bleu () {
	awk '
	{
		print $3
	}' |
	tr -d ,
}

print_range () {
	sig=`echo $1 | sed 's/.bleu$/.sig/'`
	if [[ -s "$sig" ]]; then
		cat $sig |
		awk '
		BEGIN {
			FS = "<="
		}
		/SYSTEM BLEU/ {
			printf "+/- %2.2f\n", 100*($3-$1)/2
		}'
	fi
}

print_sig () {
	sig=`echo $1 | sed 's/.bleu$/.sig/'`
	if [[ -s "$sig" ]]; then
		tail -n 3 $sig |
		awk '
		BEGIN {
			FS = "\n"
			RS = "\n\n"
			OFS = "/"
		}
		/system1:/ && /system2:/ && /draw:/ {
			sub(/^.*:/, "", $1)
			sub(/^.*:/, "", $2)
			sub(/^.*:/, "", $3)
			print $1, $2, $3
		}'
	fi
}

format_data () {
	paste <(echo $1 | get_lang+fact) \
		  <(basename $1 | get_corpus+para+mert) \
		  <(print_bleu < $1) \
		  <(print_range $1) \
		  <(print_sig $1) |
	awk '
	BEGIN {
		FS = OFS = "\t"
	}
	{
		lang = $1
		fact = $2
		corpus = $3
		para = $4
		mert = $5
		bleu = $6
		range = $7
		sig = $8
		print lang, corpus, fact, mert, para, bleu, range, sig
	}'
}

get_bleu () {
	for f in `find_bleu $*`; do
		format_data $f
	done
} 

get_bleu $* |
sort
