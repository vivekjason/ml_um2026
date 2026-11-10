# =============================================================================
# DEMO 1 · The pipeline  (Session 2 · ~15 min live)
# ONE idea: every model follows the same five steps -> split, recipe, workflow, fit, predict.
# This is the short live-coding version. The full walk-through (missingness, codes, leakage,
# your-turn exercises) is in tutorials/01_pipeline.qmd.
# =============================================================================

library(tidymodels)

# The question for the two days: who has UNDIAGNOSED diabetes? (5,000 synthetic adults.)
nhms <- readr::read_csv("data/nhms_synthetic.csv", show_col_types = FALSE)

# Make the outcome a factor with "Yes" first, so "Yes" is the event we score.
dm <- nhms |>
  mutate(
    undx_dm   = factor(undx_dm,   levels = c(1, 0), labels = c("Yes", "No")),
    sex       = factor(sex,       levels = 1:2,     labels = c("Female", "Male")),
    fam_hx_dm = factor(fam_hx_dm, levels = 1:2,     labels = c("Yes", "No"))
  ) |>
  select(undx_dm, age, sex, bmi, waist, fam_hx_dm)      # a few honest predictors to start with

dm |> count(undx_dm)                                     # ~12% are cases - keep that imbalance in mind

# 1 | SPLIT  -  lock a test set away and do not touch it until the very end
set.seed(2026)
split <- initial_split(dm, prop = 0.8, strata = undx_dm)
train <- training(split)
test  <- testing(split)

# 2 | RECIPE  -  the preprocessing, written down (nothing is computed yet)
rec <- recipe(undx_dm ~ ., data = train) |>
  step_impute_median(all_numeric_predictors()) |>       # fill missing numbers with the median
  step_impute_mode(all_nominal_predictors()) |>         # fill missing categories with the most common
  step_dummy(all_nominal_predictors())                  # turn categories into 0/1 columns

# 3 | WORKFLOW  -  bundle the recipe together with a model (start with plain logistic regression)
wf <- workflow(rec, logistic_reg())

# 4 | FIT  -  learn from the TRAINING data only
fit <- fit(wf, train)

# 5 | PREDICT  -  on the untouched test set, and look
preds <- augment(fit, test)
preds |> conf_mat(undx_dm, .pred_class)                 # who it got right and wrong
preds |> roc_auc(undx_dm, .pred_Yes)                    # one honest number (1 = perfect, 0.5 = coin flip)

# That is the whole pattern:  split -> recipe -> workflow -> fit -> predict.
# We've saved the full version (all predictors, the same split and 5 folds) in R/prep_nhms.R.
# Every later demo just runs  source("R/prep_nhms.R")  to get those pieces back.
