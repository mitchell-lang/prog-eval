# Copyright 2019 Systems & Technology Research. All Rights Reserved.
MITCHELL_LIB ?= "/mitchell_lib"

.PHONY: evaluate run validate

main: main.sml main.mlb ipnsw.sig ipnsw.sml
	mlton -mlb-path-var "MITCHELL_LIB $(MITCHELL_LIB)" -link-opt "-lkann-ffi -lkann -lgsl -lblas -lm" main.mlb

evaluate: run validate

run results/counter results/scores: main data/music.graphs.txt data/query_music100.txt data/database_music100.txt
	mkdir -p results
	./main @MLton fixed-heap 3.5g --

validate: results/counter results/scores
	python validate.py

data/%.gz:
	mkdir -p data
	wget http://public.sdh.cloud/prog-eval-data/ipnsw/$(notdir $@) -O $@

data/music.graphs.txt: data/music.edges.gz
	gunzip -k $<
	python prep.py --inpath data/music.edges --outpath data/music.graphs.txt

data/query_music100.txt: data/query_music100.bin.gz
	gunzip -k $<
	python dump-numpy.py --input data/query_music100.bin --rows 10000 --cols 100 > data/query_music100.txt

data/database_music100.txt: data/database_music100.bin.gz
	gunzip -k $<
	python dump-numpy.py --input data/database_music100.bin --rows 1000000 --cols 100 > data/database_music100.txt
