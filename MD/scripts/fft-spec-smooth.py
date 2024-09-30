import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import savgol_filter

def read_data(filename):
    t = []
    C_mu = []
    with open(filename, 'r') as file:
        for line in file:
            if not line.startswith('@') and not line.startswith('#'):  
                parts = line.split()
                if len(parts) >= 2:  
                    try:
                        t_val = float(parts[0]) * 1e-15  
                        C_mu_val = float(parts[1])
                        t.append(t_val)
                        C_mu.append(C_mu_val)
                    except ValueError:
                        continue
    return np.array(t), np.array(C_mu)

t, C_mu = read_data('4yfq-acf100-final.xvg')

N = len(C_mu)
dt = t[1] - t[0]  
freqs = np.fft.fftfreq(N, d=dt)  


C_mu_fft = np.fft.fft(C_mu)


positive_freqs = freqs[freqs >= 0]
absorption_spectrum = np.abs(C_mu_fft[freqs >= 0])


enhanced_absorption = absorption_spectrum * (positive_freqs ** 2)


selected_indices = (positive_freqs >= 0) & (positive_freqs <= 2.25e12)
selected_freqs_THz = positive_freqs[selected_indices] / 1e12  
selected_enhanced_absorption = enhanced_absorption[selected_indices]

window_length = 3  
poly_order = 1  
smoothed_absorption = savgol_filter(selected_enhanced_absorption, window_length, poly_order)


#np.savetxt('m9re-5-acf100-spec-smoothed.txt', np.column_stack((selected_freqs_THz, smoothed_absorption)), header='Frequency(THz) Smoothed Enhanced Absorption')

plt.plot(selected_freqs_THz, smoothed_absorption, label='Smoothed Enhanced Absorption Spectrum')
plt.xlabel('Frequency (THz)')
plt.ylabel('Intensity')
plt.title('Smoothed THz Absorption Spectrum with Power-law Enhancement')
plt.legend()
plt.show()

