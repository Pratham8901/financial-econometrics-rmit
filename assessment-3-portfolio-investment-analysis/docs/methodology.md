# Methodology | Portfolio construction and 2025 review

[← Assessment 3](../README.md)

## Estimation set and information boundary

The two 2020–2024 input files have 1,258 matching dates (2 January 2020–31 December 2024). Let prices be `P_{i,t}`, and let **percentage-point daily log returns** be `r_{i,t}=100·ln(P_{i,t}/P_{i,t−1})`. The sample covariance matrix is estimated with an `n−1` divisor from 1,257 matched returns. The portfolio is constructed before accessing any 2025 returns.

Annualised volatilities use **250 trading days**. A different convention (e.g. 252) would shift reported annualised statistics without changing portfolio weights.

## Long-only minimum-variance optimisation

For Tesla weight `w` and Coca-Cola weight `1−w`:

`σ²_p = w²σ²_T + (1−w)²σ²_C + 2w(1−w)Cov(T,C)`.

The unconstrained minimiser is:

`w*_T = (σ²_C−Cov(T,C))/(σ²_T + σ²_C−2Cov(T,C))`.

Using the matched pre-2025 data, `w*≈0.044430736`, which is already within `[0,1]`; the published allocation uses a **rounded 4.4%** Tesla weight. The original report specified a **minimum-variance mandate**, not a maximum-return or risk-parity mandate. Historical sample volatility is estimated from fixed ex-ante weights (constant weights in return space).

## 2025 buy-and-hold evaluation

At the 31 December 2024 decision price `P_{i,0}`, invest `w_i × A₀` in each security, with *constant quantities*. For each subsequent date `t`:

`V_t = A₀ [ w·(P_T,t / P_T,0) + (1−w)·(P_C,t / P_C,0) ]`.

Thus `R_2025 = V_2025-12-31 / A₀ − 1`, annualised realised volatility is the sample standard deviation of `ln(V_t/V_{t−1})` multiplied by `√250`, and maximum drawdown is `min_t [V_t/max_{s≤t}V_s − 1]`. The position **is not rebalanced** during 2025; weights drift as the stock prices change. Values in the JSON result are calculated directly from uploaded prices by an independent Python implementation.

## Econometric models described in the original report

- ARIMA(p,0,q) conditional mean is fit to pre-2025 log returns; BIC was used in the student's main report for Tesla parsimony, and Coca-Cola ARIMA(5,0,4) versus (6,0,2) requires reconciliation.
- GARCH(1,1) and asymmetric GJR-GARCH(1,1) estimate the one-day conditional variance. One-day VaR uses `max(0, −A₀[μ̂_p+z_α σ̂_p]/100)` under a **conditional normality assumption**. For a two-asset portfolio, `σ̂_p` incorporates contemporaneous correlation; uncertainty in dynamic correlation is omitted.
- VAR(p) and Granger tests investigate whether lagged stock returns have incremental predictive content. Granger significance cannot establish economic or structural causation. If residual serial correlation remains, asymptotic test interpretations require caution.

**Only the covariance-based allocation and 2025 price performance were independently verified in the current package.** Alternative source reports contain different one-day VaR estimates; do not conflate those with the independently verified outcomes.
