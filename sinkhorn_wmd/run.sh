#!/bin/bash

# sinkhorn_wmd/run.sh

set -e

make evaluate

# A correct solution will print something like
# {"max_diff": 4.997842140141984e-09, "status": "PASS"}
