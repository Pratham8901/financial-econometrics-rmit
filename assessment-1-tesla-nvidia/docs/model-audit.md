# Original assessment vs. corrected portfolio analysis

[← Return to the case study](../README.md)

## A material unit-consistency issue

The originally submitted R script computed stock returns as *decimals* (`diff(log(price))`) while directly subtracting the Fama–French `RF` value in *percentage points*. It then used factor regressors on that latter scale. The resulting coefficients and R² are **not the correctly specified CAPM/FF3 regressions**.

The original report noted a factor rescaling step and showed larger/alternative rounded values in its executive summary, but much of its regression interpretation and model-fit table correspond to the uncorrected script. This portfolio version uses `100 * diff(log(price))`, factor values unchanged in percentage points, `excess_return = return_pct - RF`, and joins rows explicitly on their dates.

| Stock | Model | Original report R² | Corrected R² |
| --- | --- | ---: | ---: |
| Tesla | CAPM | 0.275 | **0.289** |
| Tesla | FF3 | 0.328 | **0.347** |
| NVIDIA | CAPM | 0.482 | **0.506** |
| NVIDIA | FF3 | 0.582 | **0.620** |

The corrected **market beta estimates** from the consistent-unit models are approximately **1.647 (Tesla CAPM)** and **1.740 (NVIDIA CAPM)**. Both are systematically more exposed to the market than a beta-one benchmark. In FF3, Tesla's HML is **−0.760**, and NVIDIA's HML is **−0.980**, both consistent with a growth-style tilt.

The corrected Tesla FF3 intercept is not statistically significant at 5% (p ≈ 0.202), while NVIDIA's is significant (p ≈ 0.014). Neither should be described as guaranteed tradable alpha.

## Data verification

- 1,258 prices in each original file, dates from **2020-01-02** through **2024-12-31**.
- 1,257 calculated returns for each, all 1,257 aligning with the factor file.
- Raw CSVs contain UTF-8 byte-order marks and mixed date formats (early records `MM-DD-YY`, later records `MM/DD/YYYY`), which the replacement R script handles.
- The original Ljung–Box statistics were independently confirmed to rounding: Tesla lag-1 p ≈ **0.7959** and lag-9 p ≈ **0.1696**; NVIDIA lag-1 p ≈ **0.0011** and lag-7 p ≈ **0.0002**.

## Verification status

The aggregation and OLS numbers were independently recalculated with Python, SciPy and statsmodels from the student-supplied CSV files. The reconstructed R code was reviewed but not natively executed (R was not available in the preparation environment). The original variance-ratio test numbers have not been rerun; they are clearly labelled as source-report results.

These corrections are disclosed to show **model-validation discipline**, not to claim that the original submitted work was error-free.
