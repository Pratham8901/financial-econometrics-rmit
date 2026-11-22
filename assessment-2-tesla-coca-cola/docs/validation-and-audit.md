# Model audit and validation status

[← Assessment 2 overview](../README.md)

## Independently confirmed from the uploaded CSVs

- Both companies have **1,258 aligned daily closing prices** from **2020-01-02** to **2024-12-31**, producing **1,257 aligned log returns** per company.
- Percentage-point log-return means: TSLA **0.21040722**, KO **0.00987811**; standard deviations: TSLA **4.22075908**, KO **1.31791789**.
- Return correlation: **0.17130171**.
- Ljung–Box: Tesla lag 1 Q=**0.06687991**, p=**0.795935**; lag 9 Q=**12.84769259**, p=**0.169620**. Coca-Cola lag 1 Q=**0.98311796**, p=**0.321430**; lag 2 Q=**10.80999439**, p=**0.004494**.
- Independently checked with Python NumPy and `statsmodels` against the raw user-uploaded CSVs. These figures agree with the original report to rounding.

## Taken from the original submitted RMIT report, pending native R confirmation

- Tesla selected mean **ARMA(1,1)**; reported AIC **7194.11** and BIC **7214.65**. Among its four reported candidates, ARMA(2,3) achieved a lower AIC **7189.75**, but was more complex.
- Coca-Cola selected mean **ARMA(6,2)**, AIC **4220.38**, BIC **4271.75**. ARMA(5,4) did better on both criteria (AIC **4206.33**, BIC **4262.83**); the student justified ARMA(6,2) through parsimony and residual checks. A lower-parameter solution is not automatically preferable when information criteria differ materially.
- Residual ARCH-LM(12) before variance fitting: TSLA **73.101**; KO **397.530** (both significant, as submitted).
- Tesla reported preferred **GARCH(1,1)**, alpha **0.0598**, beta **0.9101**, persistence ~**0.970**.
- Coca-Cola reported preferred **GJR-GARCH(1,1)**, alpha **0.0278**, gamma **0.1007**, beta **0.9010**; its negative-shock leverage response should be judged jointly with model parameterisation.
- Student-reported selected-model GARCH AIC (per observation): TSLA **5.6253**; KO **2.9856**.

**Native R package execution of the refitted models was not available for this portfolio construction pass.** A clean R reconstruction is included to make that validation possible. The reported coefficients, conditional-volatility diagnostics and likelihoods are **not described as independently reproduced**.

## Material issues and improvement opportunities

1. **Assessment brief compliance:** Assessment 1 analysed Tesla and NVIDIA; Assessment 2 was required to continue the same two companies. The submitted report instead used Coca-Cola, explaining the change. This is a documented deviation, not an error silently repaired in the portfolio.
2. **Filename mismatch:** The original submitted R script expects `Tesla Stock Price History.csv` and `Coca-Cola Stock Price History.csv`, but the newly uploaded copies have `(2)` suffixes. The companion script uses clearly named local files and validates them.
3. **Source dates and units:** The original script calls `diff(log(Price))*100` on file row order without explicit date matching. The companion script sorts by date and checks identical trading days, with log returns in percentage points.
4. **Model order sensitivity:** Tesla AR and MA terms nearly cancel; compare ARMA(0,0) in a future robustness analysis. For KO, ARMA(5,4) wins the selected report's information criteria while ARMA(6,2) is chosen based on parameter count; not all its coefficients are significant.
5. **Ljung–Box degrees of freedom:** The report uses `forecast::checkresiduals()` whereas the companion code explicitly uses a 20-lag Ljung–Box with `fitdf=p+q`. Resulting p-values may differ; compare like with like before making claims of exact reproduction.
6. **Volatility distributions:** The original `rugarch::ugarchspec` defaults to normal innovations. The submitted return kurtosis (6.22 for Tesla and 12.09 for Coca-Cola) motivates Student-t/other heavy-tail robustness testing.
7. **Out-of-sample validation:** In-sample AIC/BIC and residual tests alone do not establish predictive performance; rolling-window forecast loss and VaR backtesting would strengthen a hiring portfolio.
8. **No private workspace dumps:** `.RData`, `.Rhistory`, original assessed submission, and restricted raw feeds are excluded from GitHub; chart and CSV aggregates are independently generated or explicitly labelled as transcribed.

## Source basis

Student-provided **`Assignment2_Report.docx`**, **`Assignment 2.R`**, **`Tesla Stock Price History(2).csv`**, **`Coca-Cola Stock Price History(2).csv`**. All historical dates through 2024. The R script included in GitHub is a separately authored, AI-assisted companion reconstruction, not the original unassisted file.
