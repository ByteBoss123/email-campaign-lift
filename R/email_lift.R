# Hillstrom (MineThatData, 2008) randomized email experiment, analysed in base R.
# 64,000 customers randomized to Mens E-Mail, Womens E-Mail, or No E-Mail (control).
# Outputs results/results.json. No packages beyond base R + jsonlite-free writer.
d <- read.csv("data/hillstrom.csv", stringsAsFactors = FALSE)
stopifnot(nrow(d) == 64000)
d$treated <- as.integer(d$segment != "No E-Mail")

# 1. Randomization QA: sample-ratio test against a 1/3 split per arm
arm_n <- table(d$segment)
srm <- chisq.test(as.numeric(arm_n), p = rep(1/3, 3))

# 2. Covariate balance: standardized mean differences, any email vs control
smd <- function(x, g) (mean(x[g == 1]) - mean(x[g == 0])) / sqrt((var(x[g == 1]) + var(x[g == 0])) / 2)
covs <- c("recency", "history", "mens", "womens", "newbie")
balance <- sapply(covs, function(v) smd(d[[v]], d$treated))

# 3. Conversion lift, any email vs control (two-proportion test, no continuity correction)
x <- c(sum(d$conversion[d$treated == 1]), sum(d$conversion[d$treated == 0]))
n <- c(sum(d$treated == 1), sum(d$treated == 0))
pt <- prop.test(x, n, correct = FALSE)
p_t <- x[1] / n[1]; p_c <- x[2] / n[2]

# 4. Incremental revenue among emailed customers, with a bootstrap 95% CI
diff_spend <- mean(d$spend[d$treated == 1]) - mean(d$spend[d$treated == 0])
set.seed(42)
boot <- replicate(2000, {
  i <- sample.int(nrow(d), replace = TRUE); b <- d[i, ]
  (mean(b$spend[b$treated == 1]) - mean(b$spend[b$treated == 0])) * n[1]
})

# 5. Per-arm lift
arms <- lapply(c("Mens E-Mail", "Womens E-Mail"), function(s) {
  a <- d$conversion[d$segment == s]
  list(arm = s, conversion_rate = mean(a), relative_lift = mean(a) / p_c - 1)
})

# 6. Propensity score matching check (1:1 nearest neighbour with replacement, base R)
ps_model <- glm(treated ~ recency + history + mens + womens + newbie + factor(zip_code) + factor(channel),
                data = d, family = binomial())
d$ps <- fitted(ps_model)
ctrl <- d[d$treated == 0, ]; ctrl <- ctrl[order(ctrl$ps), ]
trt <- d[d$treated == 1, ]
pos <- findInterval(trt$ps, ctrl$ps)
lo <- pmax(pos, 1); hi <- pmin(pos + 1, nrow(ctrl))
pick <- ifelse(abs(ctrl$ps[lo] - trt$ps) <= abs(ctrl$ps[hi] - trt$ps), lo, hi)
att_conv <- mean(trt$conversion) - mean(ctrl$conversion[pick])

res <- list(
  customers = nrow(d),
  arm_sizes = as.list(setNames(as.integer(arm_n), names(arm_n))),
  srm_chisq = unname(srm$statistic), srm_p = srm$p.value,
  max_abs_smd = max(abs(balance)),
  treated_conversion = p_t, control_conversion = p_c,
  relative_lift = p_t / p_c - 1,
  abs_lift_ci95 = unname(pt$conf.int),
  z = sqrt(unname(pt$statistic)), p_value = pt$p.value,
  incremental_revenue = diff_spend * n[1],
  incremental_revenue_ci95 = unname(quantile(boot, c(0.025, 0.975))),
  arms = arms,
  psm_att_conversion = att_conv,
  unadjusted_diff_conversion = p_t - p_c
)
dir.create("results", showWarnings = FALSE)
# minimal JSON writer (keeps the script dependency-free)
to_json <- function(v) {
  if (is.list(v)) {
    if (!is.null(names(v)) && all(names(v) != ""))
      return(paste0("{", paste0('"', names(v), '": ', sapply(v, to_json), collapse = ", "), "}"))
    return(paste0("[", paste(sapply(v, to_json), collapse = ", "), "]"))
  }
  if (is.character(v)) return(if (length(v) == 1) paste0('"', v, '"') else paste0("[", paste0('"', v, '"', collapse = ", "), "]"))
  f <- format(v, digits = 15, scientific = FALSE)
  if (length(v) == 1) f else paste0("[", paste(f, collapse = ", "), "]")
}
writeLines(to_json(res), "results/results.json")
cat(sprintf("lift %.1f%%  p=%.3g  z=%.2f  incr revenue $%.0f (95%% CI %.0f to %.0f)  PSM ATT %.4f vs raw %.4f  SRM p=%.3f  max|SMD|=%.3f\n",
            100 * res$relative_lift, res$p_value, res$z, res$incremental_revenue,
            res$incremental_revenue_ci95[1], res$incremental_revenue_ci95[2],
            att_conv, p_t - p_c, res$srm_p, res$max_abs_smd))
