import fitbit
from pathlib import Path
import pandas as pd
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

from config import const


def my_hr():
    csv_path_list = list(Path(const.DATA_DIR / "raw" / "hr").iterdir())

    for csv_path in csv_path_list:
        hr_df = pd.read_csv(csv_path, index_col=0)
        # hr_df.plot(y="value", figsize=(20, 5))
        # plt.show()
        break
    return hr_df


def rr_interval():
    myarray = np.fromfile('/Users/koiketomoya/Downloads/Subject10_SpO2HR.dat', dtype="float")
    rri_df = pd.DataFrame(myarray, columns=["rri"])
    rri_df.to_csv('/Users/koiketomoya/Downloads/01911.csv')
    return rri_df


def fft(df):
    n = len(df)
    dt = 0.001
    fs = 1 / dt
    t = list(range(len(df)))
    # y = np.sin(2 * np.pi * f1 * t) + 2 * np.sin(2 * np.pi * f2 * t) + 0.1 * np.random.randn(t.size)

    freq1, P1 = signal.periodogram(df["value"], fs)
    freq2, P2 = signal.welch(df["value"], fs)
    freq3, P3 = signal.welch(df["value"], fs, nperseg=n / 2)
    freq4, P4 = signal.welch(df["value"], fs, nperseg=n / 8)

    plt.figure()
    plt.plot(freq1, 10 * np.log10(P1), "b", label="periodogram")
    plt.plot(freq2, 10 * np.log10(P2), "r", linewidth=2, label="nseg=n/4")
    # plt.plot(freq3, 10 * np.log10(P3), "c", linewidth=2, label="nseg=n/2")
    # plt.plot(freq4, 10 * np.log10(P4), "y", linewidth=2, label="nseg=n/8")
    plt.ylim(-60, 0)
    plt.legend(loc="upper right")
    plt.xlabel("Frequency[Hz]")
    plt.ylabel("Power/frequency[dB/Hz]")
    plt.savefig(const.DATA_DIR / "reports" / "figures" / "")


if __name__ == "__main__":
    hr_df = my_hr()

    fft(hr_df)

    pass
