# =============================================================================
# R/prep_nhms.R
# One place for the data preparation that every tutorial (and the take-home challenge) starts from.
#   source("R/prep_nhms.R")
# Tutorial 1 walks through every one of these steps; later tutorials just source this file so
# everyone is working from identical objects (same split, same folds, same recipe).
#
# Objects created:
#   nhms_raw   - as read from CSV (41 columns)
#   nhms       - cleaned: -9 -> NA, categorical codes -> labelled factors, outcomes with "Yes" first
#   leaky_vars - the measurements that DEFINE the outcomes (never use as predictors)
#   dm_data    - honest predictor set for undiagnosed diabetes (+ the outcome)
#   dm_split, dm_train, dm_test, dm_folds
#   dm_rec     - the base recipe (impute -> dummy -> zero-variance -> normalise)
#   cls_metrics- the metric set we use throughout
# =============================================================================

suppressPackageStartupMessages(library(tidymodels))
tidymodels_prefer()     # resolve name clashes (e.g. kernlab::alpha vs ggplot2::alpha) in favour of tidymodels

nhms_raw <- readr::read_csv("data/nhms_synthetic.csv", show_col_types = FALSE)

nhms <- nhms_raw |>
  # 1. sentinel codes: -9 means "not measured", NOT minus nine mmHg
  mutate(across(c(sys, dys, rbs, rchol), \(x) na_if(x, -9))) |>
  # 2. codes -> labelled factors. For the OUTCOMES the event ("Yes") is the FIRST level,
  #    because yardstick treats the first level as the event of interest by default.
  mutate(
    undx_dm     = factor(undx_dm,   levels = c(1, 0), labels = c("Yes", "No")),
    undx_hpt    = factor(undx_hpt,  levels = c(1, 0), labels = c("Yes", "No")),
    undx_chol   = factor(undx_chol, levels = c(1, 0), labels = c("Yes", "No")),
    sex         = factor(sex,         levels = 1:2, labels = c("Female", "Male")),
    age_cat     = factor(age_cat,     levels = 1:5, labels = c("18-29", "30-39", "40-49", "50-59", "60+")),
    ethnic      = factor(ethnic,      levels = 1:5, labels = c("Malay", "Chinese", "Indian", "Other Bumiputera", "Others")),
    residential = factor(residential, levels = 1:2, labels = c("Rural", "Urban")),
    married     = factor(married,     levels = 1:3, labels = c("Single", "Married", "Widowed/Divorced")),
    education   = factor(education,   levels = 1:4, labels = c("None", "Primary", "Secondary", "Tertiary")),
    income      = factor(income,      levels = c(3, 1, 2), labels = c("B40", "M40", "T20")),   # odd coding in source file
    occupation  = factor(occupation,  levels = 1:5, labels = c("Government", "Private", "Self-employed", "Homemaker", "Not working")),
    cons_fv     = factor(cons_fv,     levels = 1:2, labels = c("Adequate", "Inadequate")),
    alcohol     = factor(alcohol,     levels = 1:2, labels = c("Yes", "No")),
    smoke       = factor(smoke,       levels = 1:3, labels = c("Current", "Former", "Never")),
    pa          = factor(pa,          levels = 1:2, labels = c("Active", "Inactive")),
    pa_3cat     = factor(pa_3cat,     levels = 1:3, labels = c("Low", "Moderate", "High")),
    fam_hx_dm   = factor(fam_hx_dm,   levels = 1:2, labels = c("Yes", "No")),
    fam_hx_hpt  = factor(fam_hx_hpt,  levels = 1:2, labels = c("Yes", "No")),
    bmi_cat     = factor(bmi_cat,     levels = 1:3, labels = c("<25", "25-29.9", "30+"))
  )

# 3. the measurements that DEFINE "undiagnosed" in NHMS. Using them to predict the outcome is
#    target leakage (Tutorial 1 shows what happens if you do).
leaky_vars <- c("rbs", "sys", "dys", "rchol")

# 4. honest predictor set for the Day-1 question: who has undiagnosed diabetes?
#    (things a community health volunteer could collect without a blood test or a BP cuff)
#    `pa` is an exact recode of `pa_3cat` (Inactive == Low) - keeping both makes the GLM rank-deficient
#    ("prediction from rank-deficient fit" warnings). Keep the 3-level version. (recipes::step_lincomb()
#    would catch this automatically - see Slides 02 and Tutorial 1.)
redundant_vars <- c("pa")

dm_data <- nhms |>
  select(-id, -undx_hpt, -undx_chol, -all_of(leaky_vars), -all_of(redundant_vars))

# 5. ONE stratified split and ONE set of folds, used everywhere
set.seed(2026)
dm_split <- initial_split(dm_data, prop = 0.80, strata = undx_dm)
dm_train <- training(dm_split)
dm_test  <- testing(dm_split)

set.seed(2026)
dm_folds <- vfold_cv(dm_train, v = 5, strata = undx_dm)   # 5 folds keeps the workshop fast; Tutorial 5 discusses 10 x repeats

# 6. the base recipe. Order matters: impute BEFORE dummy/normalise; zero-variance AFTER dummies.
dm_rec <- recipe(undx_dm ~ ., data = dm_train) |>
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_zv(all_predictors()) |>            # drops dm / hpt / chol (all zero)
  step_normalize(all_numeric_predictors())

# 7. the metrics we report everywhere (probability metrics first; accuracy is there to be distrusted)
cls_metrics <- metric_set(roc_auc, pr_auc, brier_class, accuracy, sensitivity, specificity)

invisible(TRUE)
