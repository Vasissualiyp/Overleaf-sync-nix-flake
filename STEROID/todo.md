# STEROID — Publication Checklist

**Paper:** Dimensional reduction on STEROIDs: Geometric Characterization of Feasible Parameter Spaces in Buckingham Pi  
**Template:** SIAM 2017 · `methods.tex` · 1107 lines

---

## Authors & Metadata

- [ ] **Resolve co-author list** — `line 29` · `\note{co-authors?}` — confirm names, affiliations, and contribution order
- [ ] **Add funding sources and acknowledgements** — `line 1066` · `\note{Funding sources, compute resources, collaborators}`
- [ ] **Add code repository URL** — `line 1073` · `\note{repository URL}` in Appendix A — upload to GitHub/Zenodo and fill in
- [ ] **Fill hardware specification block** — `line 714` · `\note{CPU model, RAM, OS, compiler version}` — include GCC/Clang, CGAL, PPL versions

---

## Scientific Content & Correctness

- [ ] **Fix sign error in Limitations** — `line 1011` · "feasible set {p : Λp ≥ c}" contradicts the problem formulation Λp ≤ c in eq. (1)
- [ ] **Add proof for Proposition 3 (nonlinear case)** — `lines 584–588` · "vertices of P map to extreme points of f(P)" stated without proof — add proof or cite a reference
- [ ] **Verify robot application log-linearity claim** — `lines 858–860` · "the log-linearity should be verified from the specific group definitions in each application" — cannot leave unverified for the race car case
- [ ] **Implement UMIM application numerically** — `line 847` · `\note{If time permits}` — the paper's most concrete application; a sensitivity surface figure significantly strengthens the contribution
- [ ] **Validate GPU FLOPs table with hardware benchmarks** — `line 649` · Table 2 caption `\note{Verify with hardware benchmarks}` — currently theoretical estimates; add at least one CUDA data point or explicitly label as projected
- [ ] **Address degenerate projection case** — `lines 319–326` · Vertex-merge within ε_merge "left for future implementation" — either implement or move explicitly to future work so it doesn't read as an open hole
- [ ] **Add a summary timing table** — Section 8 (Results) · Heatmap figures exist but no tabular summary of key numbers — reviewers typically ask for this
- [ ] **Empirical CUDA validation of spatial hashing** *(optional)* — `lines 677–678` · GPU warp-divergence argument is deferred to future work — even one timing measurement would make Section 7 an empirical contribution
- [ ] **Prototype C^k spline interpolation** *(optional)* — `lines 566–567` · Deferred to future work — a 1D illustration of cross-simplex smoothness would strengthen the sensitivity claim

---

## Writing & Structure

- [ ] **Restore and finalize the Contributions list** — `lines 136–153` · Entire block commented out — SIAM papers conventionally require an explicit numbered contributions paragraph; uncomment and revise to match current scope
- [ ] **Decide on "When to use STEROID" intro block** — `lines 115–134` · Commented out — restore to Introduction or consolidate with Table 4 in Discussion; don't leave both half-present
- [ ] **Clear all remaining `\note{}` red markers** — 6 open calls at lines 29, 649, 714, 847, 1066, 1073 — none should appear in the final PDF
- [ ] **Verify section road-map paragraph matches actual sections** — `lines 154–164` · Confirm every `\ref{}` resolves and described content matches what's in each section after edits
- [ ] **Resolve commented-out UMIM abstract sentence** — `lines 61–63` · If UMIM demo is completed, restore it; if deferred, remove and adjust the abstract's claim of "concrete application"
- [ ] **Check target venue requirements** — Page limit, abstract word count, supplementary material policy, data sharing requirements — no target journal/conference specified yet

---

## Code & Reproducibility

- [ ] **Publish benchmark repository** — Appendix A names `gen_param_sweep.py`, `run_suite.py`, `plot_heatmaps.py`, `flake.nix` — must be publicly available (GitHub + Zenodo DOI) before submission
- [ ] **Verify Nix flake reproduces all benchmark results** — Run a clean `nix develop` build and confirm all C++ binaries compile and produce numbers matching the paper's figures
- [ ] **Pin library versions in `flake.nix`** — Confirm exact versions of CGAL, PPL, HiGHS used in benchmarks are pinned and cited with version numbers in the paper
- [ ] **Verify `.sprj` binary format documentation** *(optional)* — Ensure the layout table in Appendix B matches the actual file writing code; include a Python reader script in the repository

---

## Pre-Submission Checks

- [ ] **Run `latexmk` clean build with zero warnings** — Check `.log` for undefined references, multiply-defined labels, and overfull hboxes; confirm all four heatmap `.pdf` figures resolve
- [ ] **Verify all bibliography entries are complete** — 30 entries in `methods.bib` — check for missing DOI, volume, or page numbers; confirm zero warnings in `.blg`
- [ ] **Confirm all figures are vector / high-DPI** — `plots/` contains `.pdf` and `.png` — ensure `.pdf` versions are used in LaTeX source (currently correct); check heatmap text is legible at journal column width
- [ ] **Check abstract is self-contained** — STEROID acronym introduced in abstract — verify full expansion appears and abstract reads standalone without the body
- [ ] **Co-author review pass** — Once author list is finalized, all authors must review the final PDF before submission
