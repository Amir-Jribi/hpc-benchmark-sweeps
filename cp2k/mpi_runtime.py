import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("cp2k-H2O256-n32-c4.csv")


operations = ["MPI_Allreduce", "MPI_Alltoallv"]

data = [
    df.loc[df["operation"] == op, "duration_ms"].dropna()
    for op in operations
]

fig, ax = plt.subplots(figsize=(8, 5))

ax.boxplot(
    data,
    tick_labels=operations,
    showfliers=True,
    whis=1.5,
)

ax.set_ylabel("MPI collective duration (ms)")
ax.set_title("CP2K H2O-256-nodes32-openmp4 — MPI Collective Duration Distribution")
ax.set_yscale("log")
ax.grid(axis="y", alpha=0.3)

plt.tight_layout()
plt.savefig("cp2k-H2O256-n32-c4.png", dpi=300)
plt.savefig("cp2k-H2O256-n32-c4.pdf")
