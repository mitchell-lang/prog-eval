# Copyright 2019 Systems & Technology Research. All Rights Reserved.
MITCHELL_LIB ?= "/mitchell_lib"

main: main.sml main.mlb lgc.sig lgc.sml
	mlton -mlb-path-var "MITCHELL_LIB $(MITCHELL_LIB)" -link-opt "-lkann-ffi -lkann -lgsl -lblas -lm" main.mlb

.PHONY: predict validate evaluate
evaluate: run validate

run results/ista_score.txt results/pnib_score.txt: data/jhu.mtx main
	./main

validate: results/ista_score.txt results/pnib_score.txt
	python validate.py
