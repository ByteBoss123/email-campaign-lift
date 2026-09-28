# Email Campaign Lift Analysis

**Stack:** R (base), Python (statsmodels) cross-check

## Business problem
A retailer emails customers every campaign, but **does the email itself cause purchases, and how
much revenue does it add?** Customers who open emails were likely to buy anyway, so comparing
openers with non-openers overstates the effect. A randomized holdout gives the true causal lift,
and it tells marketing which email version to send.

## STAR summary
| | |
|---|---|
| **Situation** | A retailer randomly split 64,000 recent customers into three groups: a men's merchandise email, a women's merchandise email, and no email, then tracked visits, conversions and spend for two weeks. |
| **Task** | Estimate the causal conversion lift and incremental revenue from the email, confirm the randomization held, and compare the two email versions. |
| **Action** | Ran a sample-ratio test and covariate balance check, a two-proportion z-test, a bootstrap confidence interval for incremental revenue, and a propensity score matching check, all in base R; recomputed the headline statistics in Python. |
| **Result** | Email raised conversion **86.5%** (1.07% vs 0.57%, z = 6.24, p = 4.27e-10) and added **$25,480** in revenue (95% CI $16,119 to $34,782). The men's email lifted conversions **118.8%** vs **54.3%** for the women's email. Randomization held (SRM p = 0.904), and matching agreed with the raw estimate (0.48 vs 0.50 pp). |

## Results (`results/results.json`)
| Metric | Value |
|---|---|
| Arms | 21,307 Mens / 21,387 Womens / 21,306 control |
| Sample-ratio check (chi-square vs 1/3 each) | p = 0.904, no mismatch |
| Covariate balance, max absolute standardized difference | 0.007 |
| Conversion rate, any e-mail vs control | 1.07% vs 0.57% |
| Relative conversion lift | **+86.5%** (z = 6.24, p = 4.27e-10) |
| Per arm | Mens +118.8%, Womens +54.3% |
| Incremental revenue among the 42,694 e-mailed customers | **$25,480** (bootstrap 95% CI $16,119 to $34,782) |
| Propensity score matching check (1:1 nearest neighbour) | ATT 0.48 pp vs unadjusted 0.50 pp, consistent with randomization |

## Verification
| Check | Result |
|---|---|
| `Rscript R/email_lift.R` | writes `results/results.json` |
| `python validation/crosscheck.py` (statsmodels, scipy) | 0 mismatches on lift, z, p-value, revenue, SRM |

## Data
`data/hillstrom.csv` is not committed. Original source: minethatdata.com (Kevin Hillstrom, 2008).
`fetch_data.sh` pulls a pinned GitHub mirror and checks the row count and SHA-256.

## Run
```bash
./fetch_data.sh
Rscript R/email_lift.R
pip install pandas statsmodels scipy && python validation/crosscheck.py
```
