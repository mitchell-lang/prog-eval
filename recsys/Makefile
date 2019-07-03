# Copyright 2019 Systems & Technology Research. All Rights Reserved.
MITCHELL_LIB ?= "/mitchell_lib"

main: main.sml main.mlb recsys.sig recsys.sml
	mlton -mlb-path-var "MITCHELL_LIB $(MITCHELL_LIB)" -link-opt "-lkann-ffi -lkann -lgsl -lblas -lm" main.mlb

.PHONY: predict validate evaluate
evaluate: predict validate

predict results/topk: data/cache_train.txt main
	./main

validate: results/topk
	python validate.py

data/ml-10m.ratings.dat:
	mkdir -p data
	wget "http://public.sdh.cloud/prog-eval-data/recsys/ml-10m.ratings.dat.gz" -O "data/ml-10m.ratings.dat.gz"
	gunzip "data/ml-10m.ratings.dat.gz"

data/cache_train.npy: data/ml-10m.ratings.dat
	python prep.py

data/cache_train.txt: data/cache_train.npy
	python sml-prep.py | tr -d "[]," > data/cache_train.txt
