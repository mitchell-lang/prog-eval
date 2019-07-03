#!/bin/bash

# ipnsw/install.sh

conda create -n ipnsw_env python=3.6 pip -y
conda activate ipnsw_env

pip install numpy==1.16.3
pip install tqdm==4.31.1
pip install pandas==0.24.2
