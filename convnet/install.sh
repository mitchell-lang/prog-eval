#!/bin/bash

# convnet/install.sh

conda create -n convnet_env python=3.6 pip -y
conda activate convnet_env

conda install pytorch==1.1.0 -c pytorch -y
conda install torchvision==0.2.2 -c pytorch -y
pip install tqdm==4.32.1
