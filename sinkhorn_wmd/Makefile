# Copyright 2019 Systems & Technology Research. All Rights Reserved.
MITCHELL_LIB ?= "/mitchell_lib"

main: main.sml main.mlb sinkhorn_wmd.sig sinkhorn_wmd-redacted.sml
	mlton -mlb-path-var "MITCHELL_LIB $(MITCHELL_LIB)" -link-opt "-lkann-ffi -lkann -lgsl -lblas -lm" main.mlb

.PHONY: predict validate evaluate
evaluate: run validate

run results/scores: data/cache-mat.bin data/cache-vecs.bin main
	mkdir -p results
	./main

data/cache-mat.bin data/cache-vecs.bin: data/crawl-300d-2M.vec data/dbpedia.train
	python prep.py --outpath data/cache

data/crawl-300d-2M.vec.zip:
	mkdir -p data
	wget http://public.sdh.cloud/prog-eval-data/sinkhorn_wmd/crawl-300d-2M.vec.zip -O data/crawl-300d-2M.vec.zip

data/dbpedia.train:
	mkdir -p data
	wget http://public.sdh.cloud/prog-eval-data/sinkhorn_wmd/dbpedia.train.gz -O data/dbpedia.train.gz
	gunzip data/dbpedia.train.gz

data/crawl-300d-2M.vec: data/crawl-300d-2M.vec.zip
	unzip data/crawl-300d-2M.vec.zip -d data
	touch data/crawl-300d-2M.vec

validate: results/scores
	python validate.py
