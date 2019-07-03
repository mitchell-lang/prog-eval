#!/bin/bash

# lgc/run.sh

# --
# Download and prep data

# Dataset is small, so it's included in the git repo

# exit on error
set -e

make evaluate

# A correct implementation should print something like
# {
#     "pnib_score": 0.9999999999999999, "pnib_pass": "PASS", 
#     "ista_score": 0.9999999999999998, "ista_pass": "PASS"
# }
# Remember that a correct implementation of this task must pass _both_ PR-Nibble and ISTA
