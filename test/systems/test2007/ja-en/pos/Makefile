#!/usr/bin/make

include Makefile.vars

all:	corpus lm model recaser tuning evaluation	

nuke:
	rm -rf corpus evaluation giza.* lm model tuning

%/Makefile:	/usr/share/mosesmake/makefiles/Makefile.%
	mkdir -p $*
	cp -f $< $@
#	make -C $*

tuning:	tuning/moses.weight-reused.ini

tuning/%:	tuning/Makefile
	make -C tuning $*

evaluation:	evaluation/all

evaluation/%:	evaluation/Makefile
	make -C evaluation $*

recaser:	$(recaser_dir)/moses.ini

$(recaser_dir)/Makefile:	/usr/share/mosesmake/makefiles/Makefile.recaser.in
	mkdir -p $(recaser_dir)
	echo "#!/usr/bin/make" > $@
	echo "" > $@
	echo "lang = $(tgt)" >> $@
	echo "recaser_file = $(recaser_file)" >> $@
	echo "recaser_corpus = $(recaser_corpus)" >> $@
	echo "" >> $@
	cat $< >> $@

$(recaser_dir)/%:	$(recaser_dir)/Makefile
	make -C $(recaser_dir) $*

model:	model/moses.ini

model/moses.ini:	corpus/$(corpus).train.lc.$(src) corpus/$(corpus).train.lc.$(tgt) \
					lm/$(lm_corpus).surface.lm lm/$(lm_corpus).pos.lm
	mkdir -p model
	moses_train_am `pwd` corpus/$(corpus).train.lc $(src) $(tgt) `pwd`/lm/$(lm_corpus).surface.lm `pwd`/lm/$(lm_corpus).pos.lm $(factors)

lm:	lm/all

lm/%:	lm/Makefile
	make -C lm $*
	
corpus:	corpus/all

corpus/%:	corpus/Makefile
	make -C corpus $*

.SECONDARY:	corpus/Makefile lm/Makefile model/Makefile $(recaser_dir)/Makefile tuning/Makefile evaluation/Makefile

.PHONY: all clean nuke #corpus lm model recaser tuning evaluation
