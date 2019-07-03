# Copyright 2019 Systems & Technology Research. All Rights Reserved.
MITCHELL_LIB ?= "/mitchell_lib"

.PHONY: evaluate validate run

main: main.mlb main.sml convnet.sml
	mlton -mlb-path-var "MITCHELL_LIB $(MITCHELL_LIB)" -link-opt "-L. -lgsl -lgslcblas -lkann-ffi -lkann" main.mlb

evaluate: run validate

run: data/cifar2/X_test.txt data/cifar2/X_train.txt data/cifar2/y_test.txt data/cifar2/y_train.txt main
	mkdir -p results
	./main

validate: data/cifar2/X_test.npy data/cifar2/X_train.npy data/cifar2/y_test.npy data/cifar2/y_train.npy
	python validate.py

data/%.gz:
	wget http://public.sdh.cloud/prog-eval-data/ipnsw/$(notdir $@) -O $@

data/cifar2/%.npy:
	python prep.py

data/cifar2/%.txt: data/cifar2/%.npy
	python dump-numpy.py --input $^ > $@
