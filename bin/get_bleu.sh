#!/bin/bash

find_bleu () {
	find -L $* -name "*.mert.output.bleu"
}

get_corpus+size+lang+fact+para () {
	awk '
	BEGIN {
		FS = "/"
		OFS = "\t"
	}
	{
		cn = split($(NF-5), c, "-")
		para = $(NF-4)
		lang = $(NF-3)
		fact = $(NF-2)
		name = c[1]
		ver = c[2]
		size = c[3]
		if (size == "") {
			size = "147k"
		}
		corpus = sprintf("%s-%s", name, ver)
		print corpus, size, lang, fact, para
	}'
}

get_mert () {
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
		print mert
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
                /Final score:/ {
                        print 100 * $3
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
	paste <(echo $1 | get_corpus+size+lang+fact+para) \
		  <(basename $1 | get_mert) \
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
		corpus = $1
		size = $2
		lang = $3
		fact = $4
		para = $5
		mert = $6
		bleu = $7
		range = $8
		sig = $9
		meteor = $10

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

#	printf "%s == %s\n", psize, size
#	printf "%s == %s\n", pcorpus, corpus
#	printf "%s == %s\n", plang, lang
#	printf "%s == %s\n", pfact, fact
        if ((corpus != pcorpus) || (size != psize) || (lang != plang) || (fact != pfact)) {
        	base = ""
        }
        pcorpus = corpus
        psize = size
        plang = lang
        pfact = fact

        if (meteor > 0) {
        	meteor = sprintf("%5.2f", meteor)
        }
        else {
        	meteor = "--"
        }
        meteor = sprintf("%6s", meteor)

        if (para ~ /\.0$/) {
        	base = bleu
        }

#	print "base:", base		
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
	}
	delta = sprintf("%9s", delta)

	print corpus, size, lang, fact, para, bleu, range, delta, sig, meteor
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
