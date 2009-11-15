#!/bin/bash

find_bleu () {
	find -L $* -name "*.mert.output.bleu"
}

get_lang+fact () {
	awk '
	BEGIN {
		FS = "/"
		OFS = "\t"
	}
	{
		lang = $(NF-3)
		fact = $(NF-2)
		print lang, fact
	}'
}

get_corpus+para+mert () {
	awk '
	BEGIN {
		FS = "."
		OFS = "\t"
	}
	{
		cn = split($1, c, "-")
		corpus = c[1]
		dist = c[2]
		num = $2
		para = sprintf("%s.%s", dist, num)
		mert = $4
		print corpus, para, mert
	}'
}

print_bleu () {
	awk '
	{
		print $3
	}' |
	tr -d ,
}

print_meteor () {
        meteor=`echo $1 | sed 's/.bleu$/.meteor/'`
        if [[ -s "$meteor" ]]; then
                awk '
                /Score:/ {
                        print 100 * $2
                }' < $meteor
        fi
}


print_range () {
	sig=`echo $1 | sed 's/.bleu$/.sig/'`
	if [[ -s "$sig" ]]; then
		awk '
		BEGIN {
			FS = "<="
		}
		/SYSTEM BLEU/ {
			print 100*($3-$1)/2
		}' < $sig
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
		  <(print_sig $1) \
		  <(print_meteor $1)
}

format_data () {
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
		meteor = $9

		fact = sprintf("%-10s", fact)

                if (range) {
#                       range = sprintf("+/-%.2f%%", (100 * range / bleu))
                        range = sprintf("+/-%.2f", range)
                }
                else {
                        range = "--"
                }
                range = sprintf("%6s", range)

		bleu = sprintf("%5.2f", bleu)

		snum = split(sig, s, "/")
		if (snum == 3) {
			w = s[1]; l = s[2]; d = s[3]
			sig = 100 * w / (w + l + d)
			sig = sprintf("%4.1f%", sig)
		}
		else {
			sig = "--"
		}
		sig = sprintf("%6s", sig)

        if ((lang != plang) || (corpus != pcorpus) || (fact != pfact)) {
        	base = ""
        }
        plang = lang
        pcorpus = corpus
        pfact = fact

        if (meteor > 0) {
        	meteor = sprintf("%5.2f", meteor)
        }
        else {
        	meteor = "--"
        }
        meteor = sprintf("%6s", meteor)

        if (para ~ /.0$/) {
        	base = bleu
        }
		
		delta = "--"
		if (base) {
			delta = bleu - base
			if (delta == 0) {
				delta = "--"
			}
			else if (delta > 0) {
				delta = sprintf("+%.2f", delta)
			}
			else {
				delta = sprintf("%.2f", delta)
			}
#                       delta = 100 * delta / base
#			delta = sprint("%s%", delta)
		}
		delta = sprintf("%9s", delta)

		print lang, corpus, fact, para, bleu, range, delta, sig, meteor
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
