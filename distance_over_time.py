#!/home/kas/miniconda3/bin/python
import numpy as np
import matplotlib.pyplot as plt

# Load the data
data = np.loadtxt('distance.dat')

## Determine the number of frames and bins
#num_frames = int(np.max(data[:, 0])) + 1
#num_bins = len(data) // num_frames
#num_frames=6913
num_frames=6896
num_bins=len(data) // num_frames
print(num_frames,num_bins)
#print(np.max(data[:, 0]))

# Reshape the data into a 2D array (time, z) with the ion counts
ion_counts = data[:, 1].reshape((num_frames, num_bins))

# Generate the time and z-axis values
time = np.arange(num_frames)
z = data[:num_bins, 0]

# Plot the ion count as a function of time and z
plt.imshow(ion_counts.T, aspect='auto', cmap='hot', origin='lower', extent=[time.min(), time.max(), z.min(), z.max()])
plt.colorbar(label='Ion count')
plt.xlabel('Time')
plt.ylabel('Z')
plt.title('Ion count as a function of time and z')
plt.show()
