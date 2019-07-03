#!/bin/bash

# recsys/run.sh

# exit on error
set -e

make evaluate

# A correct solution should print something like
# {
#     "status": "PASS", 
#     "p_at_01": 0.5122212999799651, 
#     "p_at_05": 0.40450213228770143, 
#     "p_at_10": 0.33878187698560347
# }
