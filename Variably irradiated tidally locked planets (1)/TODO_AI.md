# TODO: Reproduce the K–W / W–X target survey from public sources

For every eligible exoplanet — all eccentric-orbit planets, all pulsating-host planets, and all gravity-darkened-host planets (the latter only when the planet is on a **polar** orbit, so it sweeps pole-to-pole and sees the full gravity-darkening contrast twice per orbit) — pull the system parameters from available online sources (NASA Exoplanet Archive, arXiv/ApJ), compute the three nondimensional numbers, and locate each system on the K–W and W–X planes. Define:

- **X** = τ_wave / τ_rad — the ratio of the gravity-wave travel timescale to the radiative (cooling) timescale;
- **K** = X · τ_wave · Ω — the heat-retention parameter, i.e. the efficiency of thermal inertia relative to the (pseudo-)synchronous rotation rate Ω;
- **W** = 2π · τ_rad / T_instel — the dimensionless forcing frequency, with T_instel the instellation-variation period (orbital period for eccentric, half the orbital period for polar gravity-darkened, pulsation period for pulsating hosts).

The constituent timescales are: **τ_rad** from Appendix A of Banik et al. 2025, under the standard assumptions there (radiative cooling of the active weather layer); **τ_wave** = R_p / √(gH), the gravity-wave crossing time, with scale height H = R·T/g and T ≈ T_eq; and **τ_drag** is treated as infinite — the zero-drag limit — so any point in K–W space is a strict lower bound on the damped/drag contribution and the error bar extends upward from there if needed.

Two regime boundaries matter: **K = X separates the inertial regime (K ≫ X) from the damped regime (K ≪ X)**, and **W = 1/X is the resonance**. Categorize every planet according to which side of the K = X boundary it falls on and how far it sits from resonance, then report how many systems — and which ones — lie within a chosen percentage of resonance (W·X ∈ [1−f, 1+f], f ~ 0.1), with counts per category (eccentric / pulsating / polar gravity-darkened) and an edge-case list for any system on the selection boundaries.
