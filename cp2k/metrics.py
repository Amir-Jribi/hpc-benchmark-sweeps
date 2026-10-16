
import numpy as np
import matplotlib.pyplot as plt

# ============================================
# CP2K H2O-DFT-LS benchmark data
# ============================================

nodes = np.array([4, 8, 16, 32])

# Runtime in seconds
runtime = {
    1: np.array([1430.796, 868.447, 484.087, 334.302]),
    2: np.array([1329.961, 698.418, 445.792, 243.811]),
    4: np.array([1307.446, 673.987, 364.694, 237.017]),
    8: np.array([1205.479, 618.274, 392.752, 214.069]),
}

# ============================================
# Strong-scaling calculations
# ============================================

baseline_nodes = nodes[0]

ideal_speedup = nodes / baseline_nodes

speedup = {
    omp: times[0] / times
    for omp, times in runtime.items()
}

efficiency = {
    omp: speedup[omp] / ideal_speedup * 100
    for omp in runtime
}

# ============================================
# Plot settings
# ============================================

plt.rcParams.update({
    "font.size": 11,
    "axes.labelsize": 12,
    "legend.fontsize": 10,
    "figure.figsize": (7, 4.5),
    "savefig.bbox": "tight",
    "pdf.fonttype": 42,
})

markers = ["o", "s", "^", "D"]

# ============================================
# Figure 1: Speedup
# ============================================

fig, ax = plt.subplots()

ax.plot(
    nodes,
    ideal_speedup,
    "k--",
    linewidth=1.8,
    label="Ideal scaling"
)

for (omp, values), marker in zip(speedup.items(), markers):
    ax.plot(
        nodes,
        values,
        marker=marker,
        linewidth=2,
        markersize=6,
        label=f"{omp} OMP threads"
    )

ax.set_xlabel("Number of nodes")
ax.set_ylabel("Speedup")
ax.set_xticks(nodes)
ax.set_ylim(bottom=0)
ax.grid(True, linestyle=":", alpha=0.6)
ax.legend()
fig.tight_layout()

fig.savefig("cp2k_speedup.pdf")
fig.savefig("cp2k_speedup.png", dpi=300)

plt.close(fig)

# ============================================
# Figure 2: Scaling efficiency
# ============================================

fig, ax = plt.subplots()

ax.axhline(
    y=100,
    color="black",
    linestyle="--",
    linewidth=1.8,
    label="Ideal efficiency"
)

for (omp, values), marker in zip(efficiency.items(), markers):
    ax.plot(
        nodes,
        values,
        marker=marker,
        linewidth=2,
        markersize=6,
        label=f"{omp} OMP threads"
    )

ax.set_xlabel("Number of nodes")
ax.set_ylabel("Parallel efficiency (%)")
ax.set_xticks(nodes)
ax.set_ylim(0, 110)
ax.grid(True, linestyle=":", alpha=0.6)
ax.legend()
fig.tight_layout()

fig.savefig("cp2k_efficiency.pdf")
fig.savefig("cp2k_efficiency.png", dpi=300)

plt.close(fig)

print("Figures generated successfully.")

