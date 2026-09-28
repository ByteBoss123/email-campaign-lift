# Email Campaign Lift Analysis (R)

Randomized email experiment on the Kevin Hillstrom MineThatData E-Mail Analytics dataset (2008):
64,000 customers randomly assigned to a Mens e-mail, a Womens e-mail, or no e-mail (control),
with visit, conversion, and spend outcomes over the following two weeks.

The analysis is written in base R (`R/email_lift.R`) and cross-checked in Python (`validation/crosscheck.py`).

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
