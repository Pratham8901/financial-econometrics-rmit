# Source provenance and model audit

[← Assessment 3](../README.md)

## Source files examined for the portfolio reconstruction

- `Pratham_Kurele_Report.docx`: primary report whose VaR and ARIMA model labels are used **when attributed**.
- `Assessment3_Report(1).docx`: a separate report version using a different Coca-Cola mean-model and VaR estimate.
- `Investment Recommendation Tesla and Coca-Cola, Calendar Year 2025(1).docx`: a shorter comparative draft, with yet another VaR estimate; excluded from unqualified headline findings.
- `Pratham_Presentation(1).pptx`: supplied investment-committee pitch; slide model labels and speaker notes do not always agree.
- `Assignment 3(2).R`: Tesla–Coca-Cola submission-style source code, with model and VAR diagnostics; not republished verbatim.
- `Financial econometrics assignment 3 Rcode.R`: **NVIDIA/Exxon Mobil**, with missing associated NVDA/XOM data files, and incompatible with this case. Excluded as unrelated study.
- Four split-consistent Tesla/Coca-Cola pre-2025 and 2025 price-history CSVs: locally used to **independently reproduce weights and the realised 2025 price-only evaluation**; not distributed.

## Material findings

1. **Different stock pair from Assessment 1.** Assessment 1 analysed Tesla/NVIDIA, but Assessments 2–3 analysed Tesla/Coca-Cola. The brief requests the same two companies across the sequence. Portfolio project titles must not imply compliance with that requirement.
2. **Model-selection variant.** The primary report lists Tesla ARIMA(0,0,0) and Coca-Cola ARIMA(5,0,4); an alternate report retains Coca-Cola ARIMA(6,0,2). The latter has higher AIC/BIC under the reported comparison. The presentation displays (5,0,4) on a slide but its speaker narration mentions (6,0,2). Forecast and VaR inputs can consequently differ.
3. **Conditional VaR not reconciled.** Primary report: 95% VaR **A$20,533 / A$53,001** (recommended/equal). Alternate report: approximately **A$21,050 / A$53,414**. Presentation: rounded **A$21.1k / A$53.4k**. The shorter comparative draft uses different figures again. None is independently verified by executing the original R package code in this environment. Do not show one as an audited live risk measure.
4. **VAR lag-selection variants.** The primary report cites the student's earlier R selection AIC/FPE 9 and HQ/SC 1. The presentation instead says HQ/BIC 0; whether the zero-lag alternative was admitted in a different implementation affects comparability. VAR(1) Granger p-values 0.182 and 0.452 were nonsignificant, while VAR(9) Tesla→Coca-Cola p≈0.027 was reported as significant **despite failing residual-whiteness testing (p≈0.014)**. This is model-sensitive statistical prediction, not financial causation.
5. **Portfolios independently validated.** 1,258 pre-2025 prices, 1,257 returns, correlation ~0.171302, minimum-variance Tesla weight ~0.044430736, and rounded-weight 2025 terminal values of approximately **A$1,683,696** vs **A$1,677,361** matched the principal report/presentation. Annualised realised volatilities depend modestly on precise weight and return convention; output JSON documents our independent calculation.
6. **No actual FX handling.** The mandate is denominated in A$ but the underlying stocks trade in USD. Investment values are calculated from *unconverted USD share-price relatives* on an illustrative same-currency notional. They are **not realised, FX-adjusted AUD results**.
7. **Cash dividends and trading frictions excluded.** Original data are listed as historical 'Price', without a clear adjusted-close guarantee. The 2025 result is **price-only, before fees/taxes/currency effects**, and should not be claimed as total return.
8. **Methodological limits.** Two-stock sector concentration, historical-covariance instability, model uncertainty, fat tails, normal conditional VaR, constant conditional correlation, one-year evaluation sample, and possible look-ahead errors if the date cut-off is not enforced.
9. **AI restriction in the original assessment.** The assignment explicitly prohibited use of generative AI except to debug code in R. This package is a **new post-submission, AI-assisted portfolio presentation**, not part of the assessed submission. Do not upload it to Canvas as if it were original assessed work or misrepresent authorship of newly produced code.

## Verification status

| Component | Verification | Status |
|---|---|---|
| Dataset dates, prices, positive values, duplicates | Independently checked using supplied CSV files | **Verified** |
| Descriptive return volatility and correlation | Independent arithmetic from pre-2025 CSVs | **Verified** |
| Minimum-variance weights and 2025 terminal values | Independent arithmetic and synthetic unit tests | **Verified** |
| Conditional GARCH forecasts, VaR values | Reports and R code reviewed; native R execution unavailable | **Report-based / not independently refitted** |
| VAR(1)/VAR(9) significance and diagnostics | Reported by documents; no native R replication | **Report-based / not independently refitted** |

**Publication:** Original student reports, assessment questions, raw downloaded prices, R workspaces, videos, and R-code files from another study are all intentionally omitted. The public-facing portfolio presents derived aggregate results and newly prepared scripts with clear attribution.
