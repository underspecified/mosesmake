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
			print 100*($3-$1)/2
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

get_data () {
	paste <(echo $1 | get_lang+fact) \
		  <(basename $1 | get_corpus+para+mert) \
		  <(print_bleu < $1) \
		  <(print_range $1) \
		  <(print_sig $1)
}

format_data () {
	awk '
	BEGIN {
		FS = OFS = "\t"
		delta = "--"
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

		snum = split(sig, s, "/")
		if (snum == 3) {
			w = s[1]
			l = s[2]
			d = s[3]
			sig = 100 * w / (w + l + d)
			sig = sprintf("%4.1f%", sig)
		}
		else {
			sig = sprintf("%5s", "--")
		}

                if ((lang != plang) || (corpus != pcorpus) || (fact != pfact)) {
                        base = ""
                }

                plang = lang
                pcorpus = corpus
                pfact = fact

                if (para == 0) {
                        base = bleu
                }

		if (base) {
			delta = bleu - base
			if (delta == 0) {
				delta = "--"
			}
			else if (delta > 0) {
				delta = sprintf("+%.2f%", (100 * delta / base))
			}
			else {
				delta = sprintf("%.2f%", (100 * delta / base))
			}
		}
		delta = sprintf("%6s", delta)

		if (range) {
#			range = sprintf("+/-%5.2f%%", (100 * range / bleu))
			range = sprintf("+/-%.2f", range)
		}
		
		print lang, corpus, fact, para, bleu, range, delta, sig
	}'
}

get_bleu () {
	for f in `find_bleu $*`; do
		get_data $f
	done
} 

get_bleu $* |
sort |
format_data |
sort
