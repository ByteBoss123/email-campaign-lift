# Email Campaign Lift Analysis

**Stack:** R (base), Python (statsmodels) cross-check

## Business Problem
A retailer emails customers every campaign, but **does the email itself cause purchases, and how much
revenue does it add?** Customers who open emails were likely to buy anyway, so comparing openers with
non-openers overstates the effect. Only a randomized holdout gives the true causal lift, and it also
tells marketing which email version to send.

## Steps Taken to Resolve
1. **Used a real randomized experiment:** 64,000 customers split into a men's merchandise email, a women's merchandise email, and no email, with visits, conversions and spend tracked for two weeks.
2. **Checked the randomization:** a sample-ratio test on the three arms and a covariate balance check on customer history.
3. **Estimated the causal effect:** a two-proportion z-test on conversion and a bootstrap 95% confidence interval for incremental revenue, all in base R.
4. **Compared the email versions:** conversion lift for each arm against the no-email control.
5. **Stress-tested the result:** a propensity score matching estimate compared with the raw difference, plus an independent Python recompute of the headline statistics.

## Achievements
- Email raised conversion by **86.5%** (1.07% vs 0.57%, z = 6.24, p = 4.27e-10).
- Added **$25,480** in incremental revenue (95% CI $16,119 to $34,782).
- The men's email lifted conversion **118.8%** vs **54.3%** for the women's email.
- Confirmed a clean experiment: no sample-ratio mismatch (p = 0.904), balanced covariates (max standardized difference 0.007), and matching agreed with the raw estimate (0.48 vs 0.50 pp); Python recompute: **0 mismatches**.

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
