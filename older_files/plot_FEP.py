import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Read the data from the file and name the columns
data = pd.read_csv('FEP_data.log', sep=' ', na_values='', comment='#',
                   names=['radius', 'ion', 'temperature', 'ES_Start', 'N_LAMBDA', 'Pressure', 'Ensemble', 'FE', 'FE_err'])

# Convert the 'FE' and 'FE_err' columns to numeric data type
data['temperature'] = pd.to_numeric(data['temperature'], errors='coerce')
data['FE'] = pd.to_numeric(data['FE'], errors='coerce')
data['FE_err'] = pd.to_numeric(data['FE_err'], errors='coerce')

# Remove rows with missing values
data = data.dropna()

# Calculate the DFE column
def calculate_dfe(group):
    group_270 = group[group['temperature'] == 270]
    if not group_270.empty:
        fe_270 = group_270['FE'].values[0]
        group['DFE'] = group['FE'] - fe_270
    else:
        group['DFE'] = float('nan')
    return group

data = data.groupby('ion', group_keys=True).apply(calculate_dfe).reset_index(drop=True)

#print(data)

# Plot the data
fig, ax = plt.subplots()
legend_entries = []

for ion, group in data.groupby('ion'):
    group = group.dropna(subset=['DFE'])
    ax.errorbar(group['temperature'], group['DFE'], yerr=group['FE_err'], fmt='o', capsize=5)

    # Add a trendline
    z = np.polyfit(group['temperature'], group['DFE'], 1)
    p = np.poly1d(z)
    ax.plot(group['temperature'], p(group['temperature']), linestyle='dotted', color=ax.lines[-1].get_color())

    # Calculate R^2 value
    r_squared = np.corrcoef(group['temperature'], group['DFE'])[0, 1] ** 2

    # Update the legend_entries list with the ion and R^2 value
    legend_entries.append(f'{ion}, R²={r_squared:.5f}')

# Set the legend using the legend_entries list
ax.legend(ax.lines[::2], legend_entries, title='Ion')

ax.set_xlabel('Temperature')
ax.set_ylabel('DFE')
plt.show()
