import scipy.io
import matplotlib.pyplot as plt
import numpy as np

# Load the .mat files
tout_data = scipy.io.loadmat('tout.mat')
invalve_data = scipy.io.loadmat('invalve.mat')
tankheight_data = scipy.io.loadmat('tankheight.mat')

# Extract variables (checking keys usually 'tout', 'invalve', 'tankheight')
# Note: .mat files often have keys like '__header__', so we look for the variable name.
t = tout_data['tout'].flatten()
u = invalve_data['invalve'].flatten()
h = tankheight_data['tankheight'].flatten()

# Plotting
plt.figure(figsize=(10, 6))

plt.subplot(2, 1, 1)
plt.plot(t, u, 'r', linewidth=2)
plt.title('Input: Valve Position (invalve)')
plt.ylabel('Valve Position')
plt.grid(True)

plt.subplot(2, 1, 2)
plt.plot(t, h, 'b', linewidth=2)
plt.title('Output: Tank Height (tankheight)')
plt.ylabel('Height (m)')
plt.xlabel('Time (s)')
plt.grid(True)

plt.tight_layout()
plt.savefig('system_id_plot.png')

# Calculation of Transfer Function (Integrator Model: G(s) = K/s)
# Formula: h(t) = K * u(t) * t  => Slope = K * u_step
# We need to find the slope of the height and the amplitude of the input step.

# 1. Find Input Amplitude (assuming it starts at 0 and goes to a value)
u_final = np.max(u)
u_initial = np.min(u)
step_amplitude = u_final - u_initial

# 2. Find Slope of Output (in the linear region)
# Let's pick a range where the response is linear (e.g., between t=10 and t=50)
t1_idx = np.searchsorted(t, 10)
t2_idx = np.searchsorted(t, 50)

h1 = h[t1_idx]
h2 = h[t2_idx]
dt = t[t2_idx] - t[t1_idx]
dh = h2 - h1

slope = dh / dt

# 3. Calculate Gain K
K_estimated = slope / step_amplitude if step_amplitude != 0 else 0

print(f"Input Step Amplitude: {step_amplitude}")
print(f"Calculated Slope: {slope:.4f}")
print(f"Estimated Gain (K): {K_estimated:.4f}")