# Moses Make

Author: Eric Nichols <ericnichols79@gmail.com>, Tohoku University, Japan

Moses Make is a set of makefiles and utilities for automatic setup of Moses SMT systems. Moses Make will tokenize and annotate data with POS, lemma form, and morphology factors. Currently, Moses Make supports English, Italian, Japanese, and Spanish, but it can easily be extended to support any language with a POS tagger and morphological analyzer.

## INSTALLATION

### Via apt-get

Run the following commands as root setting $distro to your Ubuntu distribution name:

	$ echo "# Ubuntu NLP
	deb http://cl.naist.jp/~eric-n/ubuntu-nlp $distro nlp
	deb-src http://cl.naist.jp/~eric-n/ubuntu-nlp $distro nlp" >> /etc/apt/sources.list
	$ apt-get update
	$ apt-get install mosesmake

### Via git

	$ git clone 'https://github.com/underspecified/git@github.com:underspecified/moses-make.git' /path/to/mosesmake

### Via zip file

	$ wget 'http://cl.naist.jp/~eric-n/hg/mosesmake/archive/tip.tar.gz' -O /path/to/mosesmake.tgz
	$ cd /path/to/ && tar -zxvf mosesmake.tgz

## DEPENDENCIES

* [make](http://www.gnu.org/software/make/): a program for automatically generating files from dependencies
* [moses](http://www.statmt.org/): a factored, phrase-based beam-search decoder for MT
* [srilm](http://www.speech.sri.com/projects/srilm/): a toolkit for building and applying language models
* [giza++](http://code.google.com/p/giza-pp/): a C++ implementation of IBM word alignment models 1-5
* [treetagger](http://www.ims.uni-stuttgart.de/projekte/corplex/TreeTagger/): a language-independent part-of-speech tagger. Download and install English
(optionally Italian and Spanish) tagging models.
* [morph](http://www.informatics.susx.ac.uk/research/groups/nlp/carroll/morph.html): an English morphological analyzer/generator used for lemma factors
* [mecab](http://mecab.sourceforge.net/): a Japanese part-of-speech tagger used for tokenization and POS factors
* [mecab-ipadic](http://mecab.sourceforge.net/): part-of-speech dictionary for parsing with mecab

## SHELL ENVIRONMENT SETUP

Add the following to your .bashrc. Skip this step if you installed via apt-get.

	# Makefile-based automation of Moses SMT system construction
	MTHOME=/path/to/mosesmake
	if [ -f $MTHOME/setup.sh ]; then
		. $MTHOME/setup.sh
	fi

## TESTING MOSES MAKE

Run the following commands to create a Japanese-English toy system.

	$ cd /path/to/mosesmake
	$ cd test/systems/test2007/ja-en/factorless/
	$ cat Makefile.vars	
	$ make corpus lm model recaser tuning evaluation

Moses make will format the corpus, create a language model, train a translation model, train a recaser, conduct MERT optimization on the translation model, and evaluate the MT system.

Any of these steps can be ran in isolation. Moses Make will automatically figure out what order the steps need to be performed in.

New systems can be made by copying Makefile and Makefile.vars from an example system and editing the settings and data sources accordingly.
