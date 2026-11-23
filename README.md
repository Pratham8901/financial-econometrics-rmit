# Financial econometrics | Equity returns and portfolio risk

**Pratham Kurele · RMIT University · Master of Finance · ECON1195**

Three individual projects use US equity prices to examine different decisions. The portfolio study fixes the allocation at the end of 2024 and evaluates it on the following year's prices.

| Study | Finding | Inspect the evidence |
|---|---|---|
| **[Tesla and Coca-Cola · Portfolio allocation](assessment-3-portfolio-investment-analysis/README.md)** | The minimum-variance mix held 4.4% Tesla and 95.6% Coca-Cola. In 2025 its realised annualised volatility was 16.87%, compared with 27.07% for a 50/50 buy-and-hold portfolio. | [Verified results](assessment-3-portfolio-investment-analysis/results/verified_portfolio_summary.json) · [Python calculation](assessment-3-portfolio-investment-analysis/scripts/verify_portfolio.py) |
| **[Tesla and NVIDIA · Equity factor exposure](assessment-1-tesla-nvidia/README.md)** | A unit-consistent Fama–French three-factor regression explained 34.7% of Tesla's daily return variation and 62.0% of NVIDIA's. | [Factor estimates](assessment-1-tesla-nvidia/results/factor_regressions.csv) · [Return-unit reconciliation](assessment-1-tesla-nvidia/docs/model-audit.md) |
| **[Tesla and Coca-Cola · Return and volatility models](assessment-2-tesla-coca-cola/README.md)** | Coca-Cola's ARMA(5,4) had the lowest reported AIC and BIC. The report selected the simpler ARMA(6,2). The case shows how model selection affects the interpretation of volatility forecasts. | [Model comparison](assessment-2-tesla-coca-cola/results/mean_model_comparison_reported.csv) · [Diagnostics and model choices](assessment-2-tesla-coca-cola/docs/validation-and-audit.md) |

## Reading the performance figures

The 2025 evaluation uses US share prices and buy-and-hold weights. It excludes dividends, currency conversion, fees and taxes. The A$1.5m figure in the mandate is an illustrative notional. The return series measures price performance in the stocks' trading currency. Conditional value-at-risk and some time-series specifications differ across report versions and are attributed individually. [Portfolio model audit](assessment-3-portfolio-investment-analysis/docs/model-audit-and-limitations.md)

Run the aggregate and synthetic checks from the repository root with `python -m unittest discover -s tests -v`. Each case documents the private inputs needed for a full historical rerun.

The first project used NVIDIA as the second stock. The next two used Coca-Cola, a departure from the original course brief. The original work was individual coursework. These portfolio pages and companion code were prepared after submission with AI assistance. [Attribution and data rights](NOTICE.md)
