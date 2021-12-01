#! /usr/bin/env python3

import matplotlib.pyplot as plt
import numpy as np

data = np.loadtxt("mandelbrot.txt")
plt.imshow(data, cmap='hot', interpolation='nearest')
plt.show()
plt.savefig('mandelbrot.png')