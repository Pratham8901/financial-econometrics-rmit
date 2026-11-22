# Reproducing the original price data locally

The supplied raw data files and original assessed submissions are **not bundled** with this GitHub-facing repository: review source-provider terms and university requirements before any redistribution.

Save authorised local Investing.com CSV exports in `assessment-2-tesla-coca-cola/data/private/` under **exactly** these names:

- `Tesla Stock Price History.csv` (from the supplied `Tesla Stock Price History(2).csv`)
- `Coca-Cola Stock Price History.csv` (from the supplied `Coca-Cola Stock Price History(2).csv`)

The historical window is **2 January 2020 – 31 December 2024** (1,258 aligned closes, 1,257 returns). CSV files include mixed date formats and some UTF-8 byte-order marks; the supplied companion R script normalises these and explicitly sorts/aligns dates.

`FF model(1).csv` and its Excel equivalent, plus the NVIDIA stock-history file, were also included in the upload. **They are not used in the Assessment 2 ARMA/GARCH models**, and are deliberately not copied into the publishable package. NVIDIA and the Fama–French factors were relevant to Assessment 1.

Do not commit `.RData` or `.Rhistory`, which can contain unrelated workspace details or sensitive information.

See `../docs/rights-and-attribution.md` for reuse and copyright considerations.
