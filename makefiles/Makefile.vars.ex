#!/usr/bin/make

### REQUIRED VARIABLES ###
#factors = factorless pos pos-gen lemma+pos+morph tok+lemma+pos+morph
factors = pos-gen
src = ja
tgt = en
min = 0
max = 40
corpus = slt.f.2
lm_corpus = IWSLT06_JE_training_E
recaser_corpus = IWSLT06_JE_training_E
recaser_root = $(HOME)/moses/recaser
recaser_dir = $(recaser_root)/$(tgt)/$(lm_corpus)

### REQUIRED FILES ###

train_src_file = /work2/mt/corpora/slt-080627/f.2/ja
train_tgt_file = /work2/mt/corpora/slt-080627/f.2/en
dev_src_file = /home/eric-n/mt/corpora/IWSLT/2006/JE/split/IWSLT06_JE_devset1+2_J.txt
dev_tgt_file = /home/eric-n/mt/corpora/IWSLT/2006/JE/split/IWSLT06_JE_devset1+2_E.txt
test_src_file = /home/eric-n/mt/corpora/IWSLT/2006/JE/split/IWSLT06_JE_devset3_J.txt
test_tgt_file = /home/eric-n/mt/corpora/IWSLT/2006/JE/split/IWSLT06_JE_devset3_E.txt
lm_file = /home/eric-n/mt/corpora/IWSLT/2006/JE/split/IWSLT06_JE_training_E.txt
recaser_file = /home/eric-n/mt/corpora/IWSLT/2006/JE/split/IWSLT06_JE_training_E.txt

### OPTIONAL ###
# comment out to disable evaluation. baseline(s) required only for significance testing
#evaluation = bleu significance meteor
samples=100
baseline_mert = /work2/mt/moses/slt080627/ja-en/pos-gen/evaluation/slt.f.0.test.output.mert.detok
#baseline_no_mert = /work2/mt/moses/slt080627/ja-en/pos-gen/evaluation/slt.f.0.test.output.no_mert.detok
