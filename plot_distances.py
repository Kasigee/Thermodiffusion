# file: plot_distances.py

import matplotlib.pyplot as plt
import numpy as np

# Loading the data
data = np.loadtxt('distances.dat')

# Separating the frames and distances
frames = data[:, 0]
distances = data[:, 1]

# Creating the plot
plt.plot(frames, distances)

# Setting the title and labels
plt.title('Interatomic Distance Between CLD and NAD Over Time')
plt.xlabel('Time (frames)')
plt.ylabel('Distance (Angstroms)')

# Saving the plot to a file
plt.savefig('distances.png')

# Displaying the plot
plt.show()
