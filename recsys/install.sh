#!/bin/bash

# recsys/install.sh

conda create -n recsys_env python=3.6 pip -y
conda activate recsys_env

conda install pytorch==1.0.0 -c pytorch -y
pip install pandas==0.24.2
pip install numpy==1.16.3
pip install tqdm==4.31.1
pip install scikit-learn==0.21.2
