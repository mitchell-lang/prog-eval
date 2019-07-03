import numpy as np

x = np.load("data/cache_train.npy", allow_pickle=True)
for y in x:
  print(y)
