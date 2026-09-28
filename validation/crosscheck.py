"""Independent Python recompute of the R results (pandas + statsmodels + scipy). Exits 1 on mismatch."""
import json, pandas as pd
from statsmodels.stats.proportion import proportions_ztest
from scipy.stats import chisquare
d = pd.read_csv("data/hillstrom.csv"); r = json.load(open("results/results.json"))
t = d[d.segment != "No E-Mail"]; c = d[d.segment == "No E-Mail"]
z, p = proportions_ztest([t.conversion.sum(), c.conversion.sum()], [len(t), len(c)])
srm = chisquare(d.segment.value_counts().sort_index().values)
checks = {
    "relative_lift": (t.conversion.mean() / c.conversion.mean() - 1, r["relative_lift"], 1e-12),
    "z": (z, r["z"], 1e-9),
    "p_value": (p, r["p_value"], 1e-15),
    "incremental_revenue": ((t.spend.mean() - c.spend.mean()) * len(t), r["incremental_revenue"], 1e-6),
    "srm_p": (srm.pvalue, r["srm_p"], 1e-12),
}
bad = {k: v for k, v in checks.items() if abs(v[0] - v[1]) > v[2] * max(1, abs(v[0]))}
for k, (a, b, _) in checks.items(): print(f"{k:20} python={a:.6g}  R={b:.6g}")
print("mismatches:", bad or "none"); raise SystemExit(1 if bad else 0)
