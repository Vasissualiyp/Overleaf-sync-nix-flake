# STEROID — Publication Checklist

**Paper:** Dimensional reduction on STEROIDs: Geometric Characterization of Feasible Parameter Spaces in Buckingham Pi
**Template:** SIAM 2017 · `methods.tex` · ~1209 lines · 17-page PDF

> **Sync note (2026-08-11):** This checklist is synced from the Obsidian vault
> `projects/STEROID/Paper1/tasks.md` (the more up-to-date source of truth). Line
> numbers in brackets refer to the current `methods.tex` (they were refreshed
> during the 2026-08-11 complexity audit, which added ~45 lines).

---

## Milestones

- [ ] **M1 — Mathematically solid:** every theorem/proposition has a correct proof, every equation is consistent, no open math gaps. (Phase 1)
- [ ] **M2 — Story complete:** Introduction sets up the problem, each section earns its place, no TODOs. (Phase 2)
- [ ] **M3 — Figures & numbers reproducible:** every claim traces to a figure/table produced by the committed code. (Phase 3)
- [ ] **M4 — References airtight:** every citation is real, relevant, and correctly formatted. (Phase 4)
- [ ] **M5 — Publication-ready package:** venue formatting, metadata, code archive, cover materials. (Phase 5)

---

## Phase 1 — Mathematical correctness (do this first)

- [x] **1.1 Prove Proposition `prop:nonlinear`** — *RESOLVED 2026-08-11: shown to be WRONG.* The vertex-extremality proposition for coordinate-monotonic maps is false. Content removed from `methods.tex`: the nonlinear-extension paragraph in Limitations (`methods.tex:1150-1158`) now states STEROID is linear-only; the "phase diagram"/binding-constraint coloring claim was removed from Limitations and the UMIM bullet (`methods.tex:944-946`). `% NOTE` comments document the removals.
- [x] **1.2 Re-check the "same $\mu$ coordinates" claim** (`Obtaining physical values`, `methods.tex:421-449`, eqs `steroid_1`/`steroid_2`). Valid only because the projection $A$ is linear; add a sentence acknowledging this if the claim isn't stated.
- [x] **1.3 Check the volume/sampling Jacobian formula** (`methods.tex:612-628`). Physical-space weight $|\det P_i| \cdot |\det(E_i^\top E_i)|^{1/2}/m!$; confirmed as the correct $m \to n$ change-of-variables distortion factor.
- [x] **1.4 Verify the Delaunay worst-case bound** `S = O(V^{⌈m/2⌉})` (`methods.tex:414`) — *DONE 2026-08-11*: the simplex-count citation was switched from `McMullen1970` to `Seidel1995` (asymptotic UBT, `Comput. Geom. 5(2):115-116`, abstract p.115 — "a convex d-polytope with n vertices has O(n^{⌊d/2⌋}) faces"; lifting to R^{m+1} gives O(V^{⌈m/2⌉})). `McMullen1970` retained only for the vertex bound `V ≤ C(K, ⌊n/2⌋)` (`methods.tex:382`).
- [x] **1.5 Audit every `O(...)` complexity claim** in the Complexity Summary table (`methods.tex:563-590`) — *DONE 2026-08-11*. All 7 rows verified against their derivations and now cited at first occurrence:
  - Simplex `O((n-m)K)` (typical) → `KleeMinty1972` (exponential worst case, chapter p.159: "2^d − 1 iterations may be required") + `PotraWright2000` (worst-case exponential, survey p.3) + `SpielmanTeng2004` (polynomial on typical/smoothed inputs, p.7). Wording softened to "typically performs O(K) pivots (each O(n-m))".
  - IPM `O((n-m)^{3.5} log(1/ε))` → `Karmarkar1984` (O(n^{3.5}L) arithmetic ops, Combinatorica p.373; §1.6 p.377) + `PotraWright2000` (p.3–4, incl. eq. 2.5 O(√n log(n/ε)) iterations).
  - ADMM `O(1/ε)` → `HeYuan2012` (O(1/k) ergodic, SIAM JNA 50(2):700–709) + `MonteiroSvaiter2013` (iteration complexity, SIAM JOPT 23(1):475–507). Wording changed to "ergodic O(1/k) rate, i.e. O(1/ε) iterations".
  - STEROID walk `O(m·S^{1/m})` → `DevillersHemsley2016` (O(√n) worst-case visibility walk, JOCG 7(1):332–359, abstract p.1) + `BoseDevroye2007` (stabbing Θ(√n), CGTA 36(2):89–105, abstract p.89) + `DevroyeLemaireMoreau2004` (expected Θ(√n), CGTA 29(2):61–89, abstract p.61). m>2 is a noted extrapolation.
  - STEROID preprocessing `O(V^{⌈m/2⌉})` → `Seidel1995`.
  - Dykstra `O(C·K·(n-m))`, Kaczmarz `O(C(n-m))`, Chebyshev, `O(nm)` matmul, `O(S m³)` volume, memory columns → derived arithmetically (half-space projection / row projection / matmul) with `% VERIFIED` notes.
  - All 10 new papers pulled into Zotero (2026-08-11); page-level `% VERIFIED` comments added at each cite.
- [x] **1.6 Resolve the ADMM convergence-rate claim** (`methods.tex:334-341`) — *DONE 2026-08-11*: now reads "ADMM converges with an ergodic $O(1/k)$ rate for convex problems \cite{HeYuan2012, MonteiroSvaiter2013}, i.e. O(1/ε) iterations"; the un-cited O(1/ε) NOTE is resolved.
- [x] **1.7 Check the interpolation-error bound** — *DONE 2026-08-11*: the equation was absent from the current text; added the correct general statement to the spline section (`methods.tex:651-660`): for a degree-$r$ piecewise-polynomial on a simplicial mesh of diameter $h$, $\|\sigma-\sigma^*\|_{L^2}=O(h^{r+1})$ (Ern & Guermond, *Finite Elements I*, **Thm 11.13 pp. 108-109**, 1D Thm 5.14 p. 53). Piecewise-linear ($r{=}1$) → $O(h^2)$ ✓; $C^k$ spline of degree $k{+}1$ → $O(h^{k+2})$. **Ciarlet issue fixed**: wrong Zotero attachment (Badia "Aggregated Unfitted FEM", arXiv:1709.09122) deleted; ErnGuermond2021 (Springer 2021, OA HAL PDF in Zotero) added as the verifiable FE-interpolation reference alongside canonical Ciarlet2002.
- [x] **1.8 Re-examine Proposition `prop:nullspace`** (`methods.tex:238-255`) — *done (vault 2026-08-11)*: $A^\dagger\mathbf d + N\mathbf z$ decomposition and reduced-LP form confirmed correct.
- [ ] **1.9 Verify the "degenerate projections" paragraph** (`methods.tex:399-410`). State precisely when $\det P_i \approx 0$; decide whether the $\varepsilon_{\mathrm{merge}}$ remedy is future work or implemented.
- [x] **1.10 Confirm the constraint-sign convention everywhere** — *done (vault 2026-08-11)*: feasible set is $\Lambda\mathbf p \le \mathbf c$ throughout; greps for `\geq \mathbf{c}` / `>= c` clean.
- [x] **1.11 Check the Kaczmarz constant** (`methods.tex:357-364`) — *DONE 2026-08-11*: the paper's $\kappa$ matches Strohmer–Vershynin (scaled condition number $\kappa(A)=\|A\|_F\|A^{-1}\|_2$, §2 p.264; rate $(1-\kappa(A)^{-2})^k$, Thm 2 eq. 5 p.265). Text now states $\kappa = \|\Lambda N\|_F\|(\Lambda N)^+\|_2$ explicitly; `% VERIFIED` note added.

---

## Phase 2 — Story & writing (make it readable)

- [x] **2.1 Write the missing Introduction motivation** (`methods.tex:73-160`) — *DONE 2026-08-12*: added UMIM-motivated inverse-problem paragraph (resolving the `\note{Add examples}` placeholder), kept the Gorard gap, added the STEROID one-sentence description ("precomputes, once per problem, the piecewise-affine deprojection map … O(1) per query") and the honest benchmark finding (Dykstra wins for pure point queries at m≥4); **un-commented and finished the `%\textbf{Contributions.}` block** (5 items, incl. the Dykstra-dominance caveat and exact feasible-volume capability). Paper compiles clean (18 pp).
- [ ] **2.2 Decide & un-comment the "When to use STEROID" block** (`methods.tex:139-147`). Either restore in the Intro or keep only Discussion Table 4 (`methods.tex:1012`).
 - [x] **2.3 Verify the "paper organization" paragraph** (`methods.tex:180-189`) — *DONE 2026-08-12*. All refs resolve (Sections 2–11, 0 `??`); added the previously-omitted Complexity Summary (`sec:complexity`) and Conclusion (`sec:conclusion`); content matches every section.
 - [x] **2.4 Harden the Abstract** (`methods.tex:47-73`) — *DONE 2026-08-12*. 188 words. **Fixed the O(1) claim**: abstract + Intro one-liner now say "locating the containing simplex and evaluating a single matrix-vector product" (no bare O(1) — it contradicted `tab:complexity`'s O(m·S^{1/m}+nm) and the honest Dykstra story). Restored a concrete UMIM sentence as the close; removed the commented duplicate.
  - [x] **2.5 Make the UMIM application section self-contained** (`methods.tex:851-908`) — *DONE 2026-08-12*. Box bounds corrected to the **tested envelope (Table 5)** of SalazarMeza2023 (PDF KMCI9U5V): `A∈[45,56.2] µm` (80–100% of max), `U_t∈[3,6] s`, `IF∈[2,6.5] kN`, `T_M∈[323,373] K`; labeled *illustrative*; threshold `Π₁>10⁻⁹` verified (§4.1). Old values (A≥22.5 µm, U_t≤5 s, IF≤4000 N) were not source numbers. *Flagged:* source is inconsistent on variable count (n=7 vs 8) — user to decide on the 7-variable list wording.
  - [x] **2.6 Fix the robot section's race-car description** (`methods.tex:911-959`) — *DONE 2026-08-12 (verified, no edits needed)*: prose says "m=6 groups (scaled positions/velocities)"; no mass-ratio/traction/5-group leftovers; Girard log-linearity already reworded to Pi-group monomial construction.
  - [x] **2.7 Soften the fusion "self-consistent nonlinear solve" wording** (`methods.tex:962-994`) — *DONE 2026-08-12*: now "a nonlinear constraint-satisfaction solve per design point, not an LP" (justified by verified Sarazin2019 abstract).
  - [x] **2.8 Add explicit definitions of every symbol** ($\mathbf p, \mathbf d, A, \Lambda, \mathbf c, N, A^\dagger, K, n, m, V, S, T_i, P_i, P_i', E_i, \mathbf e_i$) — *DONE 2026-08-12*. `textbf{Notation.}` paragraph added after the Problem Statement (`methods.tex:~229-248`); all 18 symbols defined; forward-links to the nullspace decomposition and the STEROID affine map.
 - [ ] **2.9 Review every `\comment[id=VP]{}`** (~48) — fold with `pyMergeChanges.py`, zero `\comment` output in the final PDF.
 - [ ] **2.10 Remove the remaining `\note{}` red markers** — *BLOCKED 2026-08-12 (all 4 need user/data not verifiable here)*:
   - `\author{... \note{co-authors?}}` (`methods.tex:51`) — needs user (co-authors/affiliations; final list is 5.8).
   - `Hardware: \note{CPU model, RAM, OS, compiler}` (`methods.tex:848`) — machine (this one: Ryzen 5 5500U/12GB/NixOS 26.11/GCC 15.3.0) not confirmed as the benchmark machine; code repo + flake.nix (CGAL/PPL/HiGHS) missing on this machine. **Needs user to confirm benchmark hardware + toolchain versions (ties to 3.8).**
   - `Funding sources...` (`methods.tex:1281`) — needs user/collaborators (5.7).
   - `repository URL` (`methods.tex:1289`) — needs code published (5.4).
- [ ] **2.11 Write the Conclusion properly** (`methods.tex:1138-1170`) — restate results, one line on limitations (m≥6, GPU claims theoretical), name open problems.

---

## Phase 3 — Figures, data & reproducibility

- [ ] **3.1 Reproduce all four heatmaps from a clean checkout** (`plots/speed_heatmaps.pdf`, `preproc_heatmaps.pdf`, `breakeven_heatmap.pdf`, `speedup_heatmaps.pdf`). Record the run in vault `progress.md`.
- [ ] **3.2 Confirm figures are vector PDF (not bitmap)**; ensure `.pdf` (not `.png`) is `\includegraphics`'d.
- [ ] **3.3 Add axis labels, colorbar labels, and units to every heatmap**; update captions to match.
- [ ] **3.4 Decide on the UMIM figure** (`methods.tex:907-908`, "If time permits: implement the UMIM STEROID run...") — implement + figure, or explicitly defer.
- [x] **3.5 Validate the GPU FLOPs table** (`methods.tex:684`, `tab:gpu_flops`, "theoretical estimates") — *RESOLVED 2026-08-12 (two-paper split)*: option (b) — keep "Projected Performance" label + caption "theoretical estimates"; CUDA validation deferred to **Paper 2** (vault `projects/STEROID/Paper2/tasks.md` 2.1–2.3).
- [ ] **3.6 Add a summary timing table** in Results — best/typical per-query times for a few $(n,m)$ pairs from `run_suite.py`.
- [ ] **3.7 Record every headline number's provenance** (Dykstra 0.001–0.013 ms/query, ~7×/~10× at m=2/m=5, crossover m≈3–4, $Q^*$≈100–400/300–1600, preprocessing ~0.09 s at n=6,m=5) as `%` comments pointing at scripts, or in `progress.md`.
- [ ] **3.8 Verify the Nix flake reproduces the environment** — pin CGAL/PPL/HiGHS versions (also needed for 2.10).
- [ ] **3.9 Prototype the C^k spline** (optional) — or say so explicitly in Limitations.

---

## Phase 4 — References (build on the reference pass)

- [ ] **4.1 Accept the reference-verification edits** — fold with `pyMergeChanges.py` (see 2.9); `% VERIFIED` comments can stay or be removed.
 - [ ] **4.2 Resolve each `% NOTE` reference gap** — *updated 2026-08-12* (4 refs now PDF-verified in Zotero; notes → `% VERIFIED`):
   - `Scibilia2009` (Delaunay-for-MPC): **VERIFIED 2026-08-12** — PDF now in Zotero (YSNBXKQZ); "The approximate solution is computed using a procedure based on the Delaunay tessellation" (Abstract) + "Inside each simplex, the approximate controller is an affine feedback state law... obtained by linear interpolation of the exact solution at the vertices" (§I, p.2). All 4.2 gaps now resolved.
   - `McMullen1970` (upper bound theorem): **VERIFIED 2026-08-12** — PDF now in Zotero (SPIR9W3E); UBT proof confirmed (Abstract p.179, Thm p.180); vertex bound `V ≤ C(K,⌊n/2⌋)` confirmed in order via polarity (exact cyclic-polytope formula noted).
   - `MortonCode1966` / `Berger2023`: Morton still not in Zotero (1966 IBM TR, unfindable) — re-checked 2026-08-12; Berger2023 PDF verified (S2U4CP88). Keep both.
   - `LaiSchumaker2007`, `Nesterov1998`, `cgal`: still no PDF (re-checked 2026-08-12); legitimate canonical book/manual refs — double-check bib entries.
   - `Hormann2017`: **VERIFIED 2026-08-12** — PDF now in Zotero (878EJTHL); CRC GBC book confirmed (meshfree coordinates Ch.13, convex-combination property Ch.1).
   - `Ciarlet2002`: **resolved 2026-08-11** — wrong attachment removed; ErnGuermond2021 (HAL PDF) is the verifiable FE-interpolation ref.
   - `BuckinghamPy2021`: **VERIFIED 2026-08-12** — PDF now in Zotero (HCMA2NY4); "automates the traditional approach to generate all possible sets of dimensionless groups" (p.1).
   - `Tondel2003`: **VERIFIED 2026-08-12** — PDF now in Zotero (K2RAU4QP); BST algorithm (Abstract) + "logarithmic in the number of regions" (Conclusions) confirm the O(log R) claim.
   - Bonus (claim-verification): `Girard2024` — Thm 1 is about dimensionless restatement, NOT power-law monomials; `sec:robot` misattribution reworded. `Sarazin2019` — "simple and comprehensive method" computing (R,B,β_N) triplets confirmed; softening is task 2.7.
- [ ] **4.3 Verify the two bib entries that were never cited:** `Avis1992` is cited; `Tibshirani2017` is only in a commented-out line — un-comment or remove.
- [ ] **4.4 Complete every bib entry** (journal, volume, number, pages, year, DOI) — run `bibtex` and check `.blg` for warnings. ~42 entries total in `methods.bib` after the 2026-08-11 additions.
- [ ] **4.5 Check citation style matches the target venue** (SIAM numbered; confirm biblatex output).

---

## Phase 5 — Publication package & submission

- [ ] **5.1 Pick the target venue** — write it into vault `Paper1.md` and this checklist.
- [ ] **5.2 Match the venue template** — SIAM `siamart171218` or current; check page/abstract limits.
- [ ] **5.3 Fix PDF metadata** — `\hypersetup` `pdftitle`/`pdfauthor`/`pdfkeywords` with real title/authors.
- [ ] **5.4 Publish the code** (`/home/vasilii/research/software_src/STEROID`): LICENSE, README, docstrings, fix known typos (`"costraints"`, `"comlumns"`), remove dead code, push + tag + Zenodo DOI → fill `\note{repository URL}` (`methods.tex:1180`).
- [ ] **5.5 Write Code/Data Availability statements.**
- [ ] **5.6 Add unit tests + CI** for `maps.hpp`, `binary_io.hpp`, `solver.hpp`; GitHub Actions build+test.
- [ ] **5.7 Add Acknowledgements & Funding** (`methods.tex:1172`) — say "no external funding" if none.
- [ ] **5.8 Finalize the author list** (`methods.tex:35`) — names, affiliations, order, corresponding author.
- [ ] **5.9 Check for a data-sharing / ethics statement** if the venue requires it.
 - [ ] **5.10 Compile a clean build with zero warnings** — `latexmk -pdf` clean, no undefined cites, `.blg` clean. *PARTIALLY RESOLVED 2026-08-12*: the 4 pre-existing `\cref@override@label@type` errors (SIAM class + cleveref) were **fixed at the root** — cleveref 0.21.4's `\refstepcounter@optarg` (ntheorem optional-arg form) assumes `\cref@currentlabel` is set, which fails with the SIAM class and corrupts the `.aux` with NULs; a preamble patch neutralizes the optional-arg branch (paper never uses `\cref`). Build is now 0 errors, 0 undefined, 0 `.aux` NULs. Remaining: overfull-hbox pass + `.blg` check.
- [ ] **5.11 Run a spell/grammar pass** (`aspell -t -c methods.tex`).
- [ ] **5.12 Read the PDF end-to-end on paper/tablet** — figures near references, no orphan `\note{}/\comment` output.
- [ ] **5.13 Get a fresh-eyes review** (Utkarsh/Shivan if co-authoring).
- [ ] **5.14 Prepare submission materials** — cover letter, PDF, code link + DOI.
- [ ] **5.15 Final acceptance gate:** clean build, no `\note{}`/`\comment{}` output, bib complete, code public with DOI, all authors confirmed.

---

## Automation Log

- 2026-08-07 — Reference-verification pass done (see `% VERIFIED` comments).
- 2026-08-11 — **Complexity audit (task 1.5) done**: every `O(...)` in the Complexity Summary table verified against its derivation and cited at first occurrence; 10 new refs added to `methods.bib` (KleeMinty1972, Karmarkar1984, PotraWright2000, SpielmanTeng2004, HeYuan2012, MonteiroSvaiter2013, Seidel1995, BoseDevroye2007, DevillersHemsley2016, DevroyeLemaireMoreau2004), all pulled into Zotero with PDFs; tasks 1.4 and 1.6 resolved in the process; paper compiles clean (17 pp, 0 undefined refs).
- 2026-08-11 — **Task 1.7 done**: added spline interpolation-error statement `‖σ−σ*‖_{L²}=O(h^{r+1})` (ErnGuermond2021, Thm 11.13 pp. 108-109, OA HAL PDF in Zotero); piecewise-linear case confirmed `O(h²)`; deleted the wrong Ciarlet Zotero attachment (Badia "Aggregated Unfitted FEM"); Ciarlet2002 kept as canonical alongside verifiable ErnGuermond2021. Also added "where the O comes from" `% VERIFIED` notes for Chebyshev `O((n-m)K)`, SVD `O(n²m)`, and BVH `O(m log V)`.
- (Vault `tasks.md` and `progress.md` updated in sync.)
