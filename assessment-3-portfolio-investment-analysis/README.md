# A two-stock portfolio for a simulated A$1.5m mandate

**Individual investment fund analysis · Pratham Kurele · RMIT Financial Econometrics · Assessment 3**

My allocation at 31 December 2024 was **4.4% Tesla and 95.6% Coca-Cola**. The report used 2020–2024 returns to choose a long-only minimum-variance allocation before evaluating it on calendar-year 2025 prices.

| Position | Recommended allocation | Equal-weight comparison |
| --- | ---: | ---: |
| Tesla | A$66,000 (4.4%) | 50% |
| Coca-Cola | A$1,434,000 (95.6%) | 50% |

Tesla’s higher daily volatility limited its weight, even though the two stocks’ return correlation was only 0.171. I compared the recommended portfolio with a 50/50 allocation and estimated the loss threshold each might exceed on one trading day in twenty.

## Inside the R analysis

My script combines each stock’s forecast volatility with the correlation between their returns. The excerpt shows how the two weights enter that calculation and how the 5% return quantile becomes a dollar value-at-risk estimate. It uses forecasts and correlation calculated earlier in the assignment script. [Read the five original lines of R](exhibits/portfolio-risk.R).

For the 2025 evaluation, the report used US closing prices and assumed a constant exchange rate for its Australian-dollar illustration. Dividends, fees and tax are outside the case.

*From my individual investment recommendation for Tesla and Coca-Cola, the executive summary and 2025 performance section, and the recommended-weight calculation in my assignment R script.*

[Financial econometrics projects](../README.md)
