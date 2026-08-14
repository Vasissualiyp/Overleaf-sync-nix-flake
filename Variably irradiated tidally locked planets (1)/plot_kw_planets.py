#!/usr/bin/env python3
"""
Plot observed planetary systems in K-W parameter space, overlaid on the
first-order amplitude response from the shallow-water theory.

K = tau_wave^2 / (tau_rad * tau_eff)   [heat redistribution efficiency]
W = omega * tau_rad                      [nondimensional forcing frequency]
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import matplotlib.ticker as mticker

# ── Grid ─────────────────────────────────────────────────────────────────────
K_arr = np.logspace(-1.5, 1.5, 600)
W_arr = np.logspace(-2.5, 1.5, 600)
KK, WW = np.meshgrid(K_arr, W_arr)
A1 = 1.0 / np.sqrt((1.0 + 1.0 / KK) ** 2 + WW ** 2)

# ── Observed systems ──────────────────────────────────────────────────────────
# Labels omit the category letter; category is encoded in marker shape.
# Marker key: ○ pulsating (C), □ gravity-dark. (B), ◇ eccentric (A), △ circumbinary (D).

pulsating = [
    dict(label=r"WASP-33b ($\delta$-Scuti)",
         K=1.0,  K_lo=0.30, K_hi=3.0,
         W=3.0,  W_lo=1.0,  W_hi=6.0,
         marker="o", color="#d62728"),
]

gravity_dark = [
    dict(label=r"KELT-9b (grav. dark.)",
         K=1.0,  K_lo=0.30, K_hi=10.0,
         W=0.04, W_lo=0.02, W_hi=0.10,
         marker="s", color="#2166ac"),
    dict(label=r"KELT-20b (grav. dark.)",
         K=1.0,  K_lo=0.30, K_hi=5.0,
         W=0.31, W_lo=0.10, W_hi=0.80,
         marker="s", color="#74add1"),
]

eccentric = [
    dict(label=r"HD 80606b ($e=0.93$)",
         K=0.30, K_lo=0.10, K_hi=1.0,
         W=0.011, W_lo=0.005, W_hi=0.020,
         marker="D", color="#1a7837"),
    dict(label=r"HD 17156b ($e=0.68$)",
         K=0.40, K_lo=0.10, K_hi=1.5,
         W=0.053, W_lo=0.025, W_hi=0.12,
         marker="D", color="#4dac26"),
    dict(label=r"HAT-P-34b ($e=0.54$)",
         K=0.45, K_lo=0.12, K_hi=1.8,
         W=0.12,  W_lo=0.05,  W_hi=0.25,
         marker="D", color="#7fbf7b"),
    dict(label=r"HAT-P-2b ($e=0.52$)",
         K=0.60, K_lo=0.18, K_hi=2.5,
         W=0.14,  W_lo=0.07,  W_hi=0.32,
         marker="D", color="#b8e186"),
]

systems = pulsating + gravity_dark + eccentric

# Cat D — circumbinary (W >> 1); plotted as upward arrows at chart top
circumbinary = [
    dict(label=r"Kepler-47b (circ.)",
         K=0.50, K_lo=0.10, K_hi=2.0,  color="#762a83", marker="^"),
    dict(label=r"TOI-1338b (circ.)",
         K=0.25, K_lo=0.05, K_hi=1.0,  color="#9970ab", marker="^"),
    dict(label=r"Kepler-35b (circ.)",
         K=0.15, K_lo=0.04, K_hi=0.60, color="#c994c7", marker="^"),
]

# ── Figure layout: axes + colorbar placed manually; legend goes below ─────────
fig = plt.figure(figsize=(9.2, 11))
# Main plot panel
ax  = fig.add_axes([0.09, 0.22, 0.77, 0.75])
# Colorbar panel (same vertical extent as ax)
cax = fig.add_axes([0.88, 0.22, 0.022, 0.75])

# ── Background: grayscale, muted (low alpha so coloured markers pop)
# Use contourf (filled contours) instead of pcolormesh
# Levels must be log-spaced to match the LogNorm below (levels starting at
# 0 are undefined under a log norm and collapse the colorbar to one tick).
levels = np.logspace(np.log10(0.02), 0, 30)
pcm = ax.contourf(
    KK, WW, A1,
    levels=levels,
    cmap="gray",
    norm=mcolors.LogNorm(vmin=0.02, vmax=1.0),
    alpha=0.38,
)

# # Isoamplitude contours in dark grey for structure without dominating colour
# ax.contour(
#     KK, WW, A1,
#     levels=[0.07, 0.15, 0.30, 0.55, 0.80],
#     colors="0.25", linewidths=0.70, alpha=0.55,
# )

# ── Colorbar ─────────────────────────────────────────────────────────────────
cbar = fig.colorbar(pcm, cax=cax)
cbar.set_label(
    r"$\Delta h_{\rm amp}\,/\,(F\,\Delta h_{\rm eq})$",
    fontsize=20,
)
cbar.ax.yaxis.set_major_locator(mticker.LogLocator(base=10, numticks=10))
cbar.ax.yaxis.set_minor_locator(
    mticker.LogLocator(base=10, subs=[2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0], numticks=10)
)
cbar.ax.yaxis.set_minor_formatter(mticker.NullFormatter())
cbar.ax.tick_params(which="major", direction="in", labelsize=26, length=7, width=1.3)
cbar.ax.tick_params(which="minor", direction="in", length=4, width=1.0)

# ── Plot on-chart systems ─────────────────────────────────────────────────────
MS  = 13    # marker size
MEW = 1.0   # marker edge width

for s in systems:
    Kc, Wc = s["K"], s["W"]
    ax.errorbar(
        Kc, Wc,
        xerr=[[Kc - s["K_lo"]], [s["K_hi"] - Kc]],
        yerr=[[Wc - s["W_lo"]], [s["W_hi"] - Wc]],
        fmt=s["marker"], color=s["color"],
        mec="k", mew=MEW,
        ms=MS, lw=1.4, capsize=4, capthick=1.4,
        zorder=10, label=s["label"],
    )

# ── Category D: circumbinary — upward arrows at top edge ─────────────────────
W_top  = W_arr.max()
y_tip  = W_top * 0.93
y_base = W_top * 0.50

for cb in circumbinary:
    Kc = cb["K"]
    ax.annotate(
        "", xy=(Kc, y_tip), xytext=(Kc, y_base),
        arrowprops=dict(arrowstyle="->", color=cb["color"], lw=2.2),
        zorder=10,
    )
    ax.plot(
        Kc, y_base, cb["marker"],
        color=cb["color"], mec="k", mew=MEW, ms=MS,
        zorder=11, label=cb["label"],
    )
    ax.errorbar(
        Kc, y_base,
        xerr=[[Kc - cb["K_lo"]], [cb["K_hi"] - Kc]],
        fmt="none", color=cb["color"], lw=1.4, capsize=4, capthick=1.4,
        zorder=9,
    )

# ── Axes formatting ───────────────────────────────────────────────────────────
ax.set_xscale("log")
ax.set_yscale("log")
ax.set_xlim(K_arr.min(), K_arr.max())
ax.set_ylim(W_arr.min(), W_arr.max())
ax.set_xlabel(
    r"$K = \tau_{\rm wave}^2 / (\tau_{\rm rad}\,\tau_{\rm eff})$",
    fontsize=20,
)
ax.set_ylabel(r"$W = \omega\,\tau_{\rm rad}$", fontsize=20)
ax.tick_params(which="major", direction="in",
               top=True, right=True, labelsize=26, length=7, width=1.3)
ax.tick_params(which="minor", direction="in",
               top=True, right=True, length=4, width=1.0)

# ── Legend: below the figure, entries wrapped into 3 columns ────────────────
handles, lab = ax.get_legend_handles_labels()
ncol = 2
fig.legend(
    handles, lab,
    loc="lower center",
    bbox_to_anchor=(0.46, -0.05),   # bottom-centre in figure coordinates
    bbox_transform=fig.transFigure,
    ncol=ncol,
    fontsize=18,
    framealpha=0.95,
    edgecolor="0.50",
    borderpad=0.70,
    labelspacing=0.40,
    handletextpad=0.45,
    handlelength=1.50,
    columnspacing=0.70,
)

for outfile in ("kw_planets.pdf", "kw_planets.png"):
    plt.savefig(outfile, dpi=150, bbox_inches="tight")
    print(f"Saved {outfile}")
