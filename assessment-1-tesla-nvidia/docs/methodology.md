# Methodology

[← Return to the case study](../README.md)

## 1. Sampling and returns

- Historical window: **2 January 2020–31 December 2024**. The price files contain **1,258 observations per asset**, generating **1,257 log returns** per asset.
- For close prices \(P_t\), the continuously compounded percent return is \(r_t = 100[\ln(P_t)-\ln(P_{t-1})]\).
- Daily factors and the risk-free rate are read as **percent units**. The response in both CAPM and FF3 is \(r_t-RF_t\) in the same units.
- Trading dates are explicitly matched. There were 1,257 matching factor and stock-return dates; no 2025 data enter the estimation sample.

## 2. Descriptive statistics

Daily mean, standard deviation, minimum, maximum, skewness and Pearson kurtosis (normal distribution = 3) show the return and risk profiles. Small differences in kurtosis from R's `moments` package are attributable to finite-sample bias conventions.

## 3. Random-walk hypothesis

The study uses the Ljung–Box test of zero return autocorrelation, plus Lo–MacKinlay variance-ratio tests and the joint Chow–Denning test. Failure to reject a test **does not prove market efficiency**, nor does evidence of serial dependence establish exploitable trading profits after transaction costs and risk adjustment.

Ljung–Box tests were independently recomputed in Python; the variance-ratio values in the portfolio table are **transcribed from the original report** and were not independently reproduced with `vrtest` in the current environment.

## 4. Factor regressions

**CAPM:** \(r_{i,t}-RF_t = \alpha_i + \beta_i(MKT_t-RF_t)+\varepsilon_{i,t}\).

**Fama–French 3-factor:** \(r_{i,t}-RF_t = \alpha_i + \beta_i(MKT_t-RF_t)+s_iSMB_t+h_iHML_t+\varepsilon_{i,t}\).

Estimation is OLS on **1,257 aligned daily observations**, with a constant. Market beta measures exposure to the market factor, SMB to small versus large capitalisation returns, and HML to value versus growth returns. A more negative HML coefficient indicates a stronger **growth factor tilt**. In-sample R² is explanatory fit, not proof of predictive accuracy or realised abnormal risk-adjusted performance.

## Data and limitations

The original price series appear to account for historical stock splits, but the exported `Price` column is not necessarily dividend-adjusted. For actual investment performance, verify dividend, corporate-action and delisting adjustments. OLS standard errors assume the model error specification is appropriate; robust standard errors could alter inferential statements. The stock-factor relationship may be regime dependent. No forecasts or trading strategy backtest are claimed.

All 2020–2024 results in this portfolio are **historical**, not live analysis, and are not investment advice.
