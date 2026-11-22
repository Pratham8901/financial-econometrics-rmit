# How to supply the source data

This portfolio repository **does not redistribute** the raw stock-price exports or the original Kenneth French CSV, and does not contain the university report or student identifiers.

Place three input files under `assessment-1-tesla-nvidia/data/private/`:

```
Tesla Stock Price History.csv
NVIDIA Stock Price History.csv
FF model.csv
```

The first two are the original Investing.com downloads for trading dates **2 January 2020 to 31 December 2024**; they contain date and price columns. They are **split-adjusted price extracts as identified in the original student analysis**, not verified dividend-reinvested total-return series. The third is the **daily Fama–French three-factor file** obtained from the [Kenneth French Data Library](https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html); the version analysed here contains one row for every return date, 3 January 2020–31 December 2024.

Run from the assessment directory:

```bash
Rscript scripts/run_analysis.R
```

The script matches the three datasets by **calendar date**, checks coverage and outputs CSVs to `results/generated/`. The data files are ignored by Git; keep them local and observe each source's reuse terms.

**Important:** This R workflow has been source-reviewed, but native R was not available in the build environment. The static charts and aggregate CSVs were independently recalculated in Python from the supplied files. The R output should be reconciled after running it in a local R installation.
