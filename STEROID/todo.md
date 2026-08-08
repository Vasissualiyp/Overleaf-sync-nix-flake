# STEROID — Publication Checklist

**Paper:** Dimensional reduction on STEROIDs: Geometric Characterization of Feasible Parameter Spaces in Buckingham Pi  
**Template:** SIAM 2017 · `methods.tex` · 1290 lines

**Reference-verification pass (2026-08-07):** Every citation was checked against the
Zotero library (excerpt + section/page recorded as `% VERIFIED` comments), the `changes`
package was added for tracked edits, and the `\note{}` markers were resolved. Details in
`/tmp/opencode/steroid_refcheck_ledger.md`.

> **Full submission-readiness task list:** `~/research/Obsidian/VasVault1/projects/STEROID/Paper1/tasks.md`
> (paper) and `~/research/Obsidian/VasVault1/projects/STEROID/Code/tasks.md` (code).
> This file tracks quick paper-specific items; the vault pages are the authoritative
> path to submission.

---

## Authors & Metadata

- [ ] **Resolve co-author list** — `line 29` · `\note{co-authors?}` — confirm names, affiliations, and contribution order
- [ ] **Add funding sources and acknowledgements** — `line 1066` · `\note{Funding sources, compute resources, collaborators}`
- [ ] **Add code repository URL** — `line 1073` · `\note{repository URL}` in Appendix A — upload to GitHub/Zenodo and fill in
- [ ] **Fill hardware specification block** — `line 714` · `\note{CPU model, RAM, OS, compiler version}` — include GCC/Clang, CGAL, PPL versions

---

## Scientific Content & Correctness

- [x] **Fix sign error in Limitations** — `Λp ≥ c` → `Λp ≤ c` corrected to match eq. (1)
- [x] **Verify robot application log-linearity claim** — race car has **6** dimensionless groups (length/time scalings), not 5 ("mass ratios and traction") — corrected to match Girard2024 §III-B p.13; Theorem 1 is about the policy map, not monomials — flagged in a `% NOTE`
- [x] **Fix HiGHS citation** — undefined `HiGHS2022` replaced with verified `HiGHS2018`
- [x] **Resolve all `\note{Not checked yet}` markers** — 37 converted to `\comment[id=VP]{checked}`; flagged unresolved facts (ADMM O(1/ε) rate, LP complexity exponents, UMIM box bounds) as `% NOTE`s
- [x] **Verify every citation against Zotero PDFs** — 26 `% VERIFIED` comments with excerpt + section/page; added PDF-backed refs (Fuchs2010 for BST point location, Berger2023 for Z-order, Avis1992 for vertex enumeration)
- [ ] **Add proof for Proposition 3 (nonlinear case)** — `lines 584–588` · "vertices of P map to extreme points of f(P)" stated without proof — add proof or cite a reference
- [ ] **Implement UMIM application numerically** — `line 847` · the paper's most concrete application; a sensitivity surface figure significantly strengthens the contribution
- [ ] **Validate GPU FLOPs table with hardware benchmarks** — currently theoretical estimates (`\comment` flag); add at least one CUDA data point or explicitly label as projected
- [ ] **Confirm UMIM box bounds from source** — the 22.5 µm lower bound, U_t ≤ 5 s, IF ≤ 4000 N are not stated in SalazarMeza2023 (tested ranges differ) — re-derive or reword
- [ ] **Address degenerate projection case** — Vertex-merge within ε_merge "left for future implementation" — either implement or move explicitly to future work
- [ ] **Add a summary timing table** — Section 8 (Results) · no tabular summary of key numbers yet
- [ ] **Empirical CUDA validation of spatial hashing** *(optional)* — deferred to future work
- [ ] **Prototype C^k spline interpolation** *(optional)* — deferred to future work

---

## Writing & Structure

- [ ] **Restore and finalize the Contributions list** — `lines 136–153` · Entire block commented out — SIAM papers conventionally require an explicit numbered contributions paragraph; uncomment and revise to match current scope
- [ ] **Decide on "When to use STEROID" intro block** — `lines 115–134` · Commented out — restore to Introduction or consolidate with Table 4 in Discussion; don't leave both half-present
- [x] **Clear all remaining `\note{}` red markers** — only author-input ones remain (co-authors, hardware, funding, repo URL); content ones resolved
- [ ] **Verify section road-map paragraph matches actual sections** — Confirm every `\ref{}` resolves and described content matches what's in each section after edits
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
- [x] **Verify all bibliography entries are complete** — 30 entries cited, all resolve; `HiGHS2022` undefined ref fixed; new verified entries (Fuchs2010, Berger2023, Avis1992) added
- [ ] **Accept/reject the `changes` markup** — `\listofchanges` is active; use `pyMergeChanges.py` to fold the edits once reviewed
- [ ] **Confirm all figures are vector / high-DPI** — `plots/` contains `.pdf` and `.png` — ensure `.pdf` versions are used in LaTeX source (currently correct); check heatmap text is legible at journal column width
- [ ] **Check abstract is self-contained** — STEROID acronym introduced in abstract — verify full expansion appears and abstract reads standalone without the body
- [ ] **Co-author review pass** — Once author list is finalized, all authors must review the final PDF before submission
