#!/bin/bash

# convnet/run.sh

set -e

make evaluate

# A correct answer should print something like
# {"test_acc": 0.9645, "status": "PASS"}
