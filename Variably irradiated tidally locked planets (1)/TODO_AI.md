# TODO: Independent reproduction of the K–W/X–W "target survey" results

**Context.** A referee/collaborator asked for an independent reproduction of the
"Where do planets fall in K–W space?" results (the survey of 68 observed systems in
three variability categories, and the table of nondimensional parameters) computed
**from scratch from the NASA Exoplanet Archive**, using only a carefully structured
prompt and **without access to the paper** (no paper text, no paper table, no figure,
no plotting script). The agent is then compared against the manuscript to find mistakes.

**Setup.** The agent runs in an **isolated directory** that contains its tools and
everything it is allowed to see (see §0 of the prompt). The paper is kept out of that
directory entirely.

Use the prompt below as-is. It is fully self-contained: it encodes the data source,
selection criteria, constants and every formula the pipeline needs — the only
paper-derived material the agent receives is this distilled methodology. It
deliberately does **not** contain the paper's numbers, so the comparison is honest.

---

## PROMPT FOR THE AI AGENT — BEGIN

You are an independent reproduction pipeline. Your job is to recompute a published
"target survey" of variably irradiated, tidally locked exoplanets **entirely from the
NASA Exoplanet Archive** and the methodology in this prompt. You do **not** have access
to the paper, its figures, or its tables. Do not try to guess or reproduce the paper's
numbers from memory. Work only from this prompt + the archive + the literature values
stated here. If anything is ambiguous or a planet sits on a selection boundary, compute
it anyway and **flag it explicitly** in your edge-case report rather than silently
deciding.

### 0. Environment and materials (read this first)

You run in an **isolated working directory**. Everything in it is yours to use; nothing
else (no other folders, no network search for the paper) is allowed.

**Provided to you (paper-derived):**
- This prompt. It is a distilled, value-free specification of the methodology taken
  from the paper's methods/appendix: the sample-selection rules (§3), the physical
  constants (§4), every formula (§5), and the literature-adopted values that cannot be
  derived from the archive (pulsation periods in §3, forcing amplitudes in §5). **It
  contains no results** — no per-system values, no counts, no rankings. Treat any
  number in this prompt as *input to the calculation*, never as an output to match.
- Working code for retrieving the NASA Exoplanet Archive composite-parameters table
  (see §2) and any generic scientific tooling (Python, NumPy, SciPy, Matplotlib, etc.).
- This is the **only** paper-derived material you receive.

**Explicitly withheld (off-limits, even from memory):**
- The paper itself and any verbatim part of it — including its prose, the appendix
  text, its figures, its results tables, and any hardcoded values in plotting scripts.
- Any per-system values, counts, rankings, or figures from the paper.

Do **not** attempt to match remembered or guessed numbers from the paper. Your outputs
are the ground truth for this run; discrepancies between your outputs and any claimed
"expected" values are exactly what this exercise is designed to surface. Report them
rather than "correcting" your pipeline toward them.

### 1. Deliverables

1. **`systems.csv`** — one row per system in the final sample, columns listed in §6,
   ordered by category (A, then B, then C) and within category by descending `FA`
   (systems with missing `F` go last in their category).
2. **`summary.json`** (or a printed block) with the statistics listed in §7.
3. **`kw_planets_reproduced.png`** — the two-panel figure described in §8.
4. **`edge_cases.md`** — the edge-case report described in §9.
5. A header line in `summary.json` recording **the archive snapshot date** of your query
   and the exact TAP query you used.

### 2. Data source

You already have working code for retrieving data from the **NASA Exoplanet Archive**
composite-parameters table (`pscomppars`) via its TAP service — reuse it rather than
writing a new fetcher. If the existing code does not already request every column you
need, extend it to fetch **all** of:

```
pl_name, pl_radj, pl_massj, pl_orbper, pl_eqt, pl_orbeccen,
tran_flag, cb_flag, discoverymethod, default_flag
```

Verify the fetched columns and record the exact query and the archive snapshot date
(the retrieval code may log these already).

Notes:
- Units: `pl_radj` in Jupiter radii, `pl_massj` in Jupiter masses, `pl_orbper` in days,
  `pl_eqt` in Kelvin, `pl_orbeccen` dimensionless.
- `tran_flag = 1` means the planet has transit observations. **Use `tran_flag`, not
  `discoverymethod`**, to define "transiting": some transiting systems were discovered
  by radial velocity (e.g. HD 80606 b, HD 17156 b, HD 118203 b) and would otherwise be
  dropped.
- If a `pl_name` appears more than once, keep the default/best-composite row
  (`default_flag` if present, otherwise the first) and note the duplication.
- Convert every value exactly as published; **no dayside or periastron rescaling** of
  `T_eq`.

### 3. Sample selection — three variability categories

Assign every system to exactly one category (its **dominant forcing**). Total sample
should be ~68 systems.

**Category A — eccentric orbits.** All planets with `tran_flag = 1`,
`cb_flag = 0` (not circumbinary), and simultaneously:
- `pl_orbeccen >= 0.25`
- `pl_radj >= 0.8`
- `pl_eqt >= 800` K
- `3 d <= pl_orbper <= 25 d`

Then **explicitly add** HD 80606 b (`P_orb ≈ 111 d`) as a documented exception: it is
kept because its pseudo-synchronous rotation is established observationally, even
though its period is far outside the 3–25 d window.

**Category B — gravity-darkened hosts.** Exactly these five systems, all on **polar**
orbits (planet sweeps pole-to-pole, seeing the full gravity-darkening contrast twice
per orbit):
- KELT-9 b
- MASCARA-1 b
- MASCARA-4 b
- TOI-1518 b
- WASP-189 b

Note: other gravity-darkened hosts exist in the archive but are intentionally **excluded
by the methodology** because their orbits are aligned with the stellar equator and they
therefore see no gravity-darkening variation (e.g. KELT-20 b = MASCARA-2 b). This is a
literature-based selection; you cannot derive it from the archive. Use the five listed.

**Category C — pulsating hosts.** Exactly these three systems, with their published
pulsation periods (the forcing period for this category):
- WASP-33 b — δ Scuti, pulsation period **0.0476 d**
- WASP-118 b — pulsation period **1.9 d**
- WASP-167 b — pulsation period **0.167 d**

**Category assignment rule:** if a system is a pulsating host **and** eccentric
(e.g. HAT-P-56 b, `e ≈ 0.29`, also a γ Doradus pulsator), it belongs in the category of
its **dominant forcing** — here the eccentricity wins, so it is category A.

### 4. Physical constants

- Universal gas constant: `R = 8.314462618 kJ kmol^-1 K^-1`
- Mean molecular weight (solar-composition H/He): `mu = 2.3 g mol^-1`
  → specific gas constant `R_sp = R / mu = 3614.98 J kg^-1 K^-1`
- Jupiter mass `M_Jup = 1.89813e27 kg`; Jupiter radius `R_Jup = 7.1492e7 m`
  (the archive conventions)
- Stefan–Boltzmann constant `sigma = 5.670374419e-8 W m^-2 K^-4`
- Weather-layer thickness `dP = 1.0e5 Pa`
- Specific heat at constant pressure `c_p = 14,304 J kg^-1 K^-1`
- `G = 6.67430e-11 m^3 kg^-1 s^-2`

### 5. Formulas (SI units; convert period to seconds)

For each system, with `M = M_Jup * pl_massj`, `Rp = R_Jup * pl_radj`,
`g = G * M / Rp^2`:

- Active-layer (equivalent) depth: `H = R_sp * T_eq / g`  (report in km)
- Gravity-wave speed: `c = sqrt(R_sp * T_eq)` (independent of g)
- Wave timescale: `tau_wave = Rp / c`
- Radiative timescale: `tau_rad = (dP / g) * (c_p / (4 * sigma * T_eq^3))`
- `X = tau_wave / tau_rad`

**Rotation rate Ω:**
- Category A: pseudo-synchronous spin (Hut 1981),
  `Omega_ps / n = (1 + 2.5 e^2 + 1.875 e^4 + 0.3125 e^6) /
  ((1 + 3 e^2 + 0.375 e^4) * (1 - e^2)^1.5)`, with `n = 2*pi / P_orb`.
- Categories B and C: synchronous, `Omega = 2*pi / P_orb`.

**Heat-retention parameter** (drag-free limit, i.e. `tau_drag -> infinity`, which is a
strict lower bound because drag can only shorten the effective damping time):
- `K = X * tau_wave * Omega`
- `Z = K / X = tau_wave * Omega`

**Forcing period** `T_instel` (report in days):
- Category A: `P_orb`
- Category B: `P_orb / 2` (two pole-to-pole passages per orbit)
- Category C: the pulsation period listed in §3

**Nondimensional forcing frequency:** `W = 2*pi * tau_rad / T_instel`

**Normalized amplitude** (from the linear theory):
- `A = sqrt(K^2 + W^2 * X^4) / sqrt((1 + K - W^2 * X^2)^2 + W^2 * (X^2 + K)^2)`
- (Also compute the first-order limit `A_1 = 1/sqrt((1 + 1/K)^2 + W^2)` — used only for
  the figure background in §8.)

**Forcing amplitude F** (fractional semi-amplitude of instellation variation):
- Category A: from the orbit, `rho = (1 + e)/(1 - e)`,
  `F = (sqrt(rho) - 1)/(sqrt(rho) + 1)`
- Category B: `F = 0.10` for KELT-9 b (flux contrast swept along the transit chord,
  Jones et al. 2022). **No published value** for MASCARA-1 b, MASCARA-4 b, TOI-1518 b,
  WASP-189 b → report `F = NA`.
- Category C: `F = 3e-3` for WASP-33 b (von Essen et al. 2020),
  `F = 2e-4` for WASP-118 b (Temple et al. 2017). **No published value** for
  WASP-167 b → report `F = NA`.

**Predicted observable modulation:** `FA = F * A` (NA if F is NA).

**Distance from resonance:** resonance sits at `W = 1/X`; compute `W/W_res = W * X`.

### 6. `systems.csv` schema

```
pl_name, paper_name, category, T_eq, Rp_RJ, Mp_MJ, g, e, P_orb_d, T_instel_d,
H_km, tau_wave_d, tau_rad_d, X, Omega, K, W, A, A_1, F, FA, WWres
```
- `paper_name`: a canonical short name with the planet letter attached, e.g.
  `TOI-150b` (the archive spells it `TOI-150.01`), `HD 80606b`, `WASP-33b`.
  Report both names where they differ.
- `NA` where a quantity is missing/upper limit (e.g. `pl_massj` upper limit →
  `g`, `tau_rad`, `X`, `K` are correspondingly directionally biased; note it).

### 7. Summary statistics (report exact values, 3 significant figures)

1. Total count of systems and the count per category (A / B / C).
2. Range (min–max) and median of `Z = K/X = tau_wave * Omega` across the **whole**
   sample (this ratio is depth-independent and measures distance from the `K = X`
   regime boundary).
3. Count and fraction of systems with `0.5 <= W/W_res <= 2` (within a factor of two
   of resonance).
4. `W/W_res` for each of these named systems (must all appear in the sample):
   HATS-11 b, HATS-51 b, HATS-40 b, HAT-P-56 b, WASP-189 b, KELT-9 b, MASCARA-4 b,
   WASP-118 b, WASP-167 b, WASP-33 b, XO-3 b, HATS-41 b, TOI-1994 b, HAT-P-2 b.
   Also state which of these fall inside the factor-of-two band.
5. `FA` ranking: the top 15 systems by `FA` with their categories and ranks; the
   highest-ranked non-A system, its `FA` and its overall rank; the number of category-A
   systems that beat it.
6. List systems with `F = NA` (these are placed on the diagram but excluded from the
   `FA` ranking).

### 8. Figure

Two log–log panels:
- **(a) K–W plane**: all systems as markers (circles = C, squares = B, diamonds = A),
  overlaid on the first-order amplitude field `A_1(K,W)` as a gray shading
  (log levels from ~0.02 to 1). Draw the `K = X` line for reference (it moves per X;
  if you plot per-system X you may draw the boundary line at a representative value and
  note it).
- **(b) W–X plane**: same markers. Draw the resonance line `W = 1/X` (slope −1 in
  log–log) and shade the band `0.5 <= W*X <= 2`. Label the named systems of §7.4.
- A shared caption stating what each marker encodes and what the shading means.

### 9. Edge-case report (`edge_cases.md`)

List and explain every judgment call:
- Systems that pass/fail each cut only marginally (values within a few % of a
  threshold), e.g. a planet with `P_orb` just below 3 d or just above 25 d.
- Systems in the archive meeting all category-A criteria that you kept, and any that
  meet them but you suspect may be new to the archive.
- Systems with upper-limit masses or missing `T_eq`/`pl_radj`/`pl_orbeccen`.
- The five category-B and three category-C systems: report their archive parameters as
  retrieved (they are literature-selected, so just confirm the archive values).
- Any ambiguity in name matching (`TOI-150.01` vs `TOI-150b`, etc.).

### 10. Robustness cross-check (required second run)

Recompute the **entire** pipeline a second time using an alternative radiative-timescale
scaling instead of the formula in §5:

```
tau_rad = 0.1 * (1600 K / T_eq)^3 days
```

(Perez-Becker & Showman 2013, fitted relation). Everything else unchanged. Save as
`systems_scalingB.csv` and repeat the §7 statistics. In `edge_cases.md`, report where
the two runs disagree: how many systems change `FA` order, and how many change
resonance-band membership. Do **not** assume either is correct — just report the
differences.

### 11. Quality bar

- Exact counts everywhere; no silent approximations.
- State every literature-adopted value with its citation.
- If a formula or column is ambiguous, make a defensible choice, implement it, and flag
  it — do not ask for clarification mid-run.
- Run everything in one reproducible script (e.g. `reproduce.py`) that you can hand
  over with the outputs, **reusing the existing archive-retrieval code** rather than
  re-implementing it.

## PROMPT FOR THE AI AGENT — END
