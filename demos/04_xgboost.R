# =============================================================================
# DEMO 4 · Gradient boosting with XGBoost - and the bake-off  (Session 5 · ~20 min live)
# ONE idea: boosting builds small trees in sequence, each fixing the last one's mistakes;
# then we line up the families we've met on the SAME folds and see who wins.
# Full version (learning rate, early stopping, native NA, exercises): tutorials/04_xgboost.qmd
# =============================================================================

source("R/prep_nhms.R")

# XGBoost: many shallow trees, each correcting the errors so far. learn_rate = how big each step is.
xgb <- boost_tree(trees = 500, learn_rate = 0.03, tree_depth = 3) |>
  set_engine("xgboost") |> set_mode("classification")

set.seed(2026)
xgb_cv <- fit_resamples(workflow(dm_rec, xgb), dm_folds, metrics = cls_metrics)
collect_metrics(xgb_cv) |> filter(.metric == "roc_auc")

# THE BAKE-OFF: three families, the SAME folds, one table. (Add svm_rbf() the same way - it's just slower.)
models <- list(
  logistic      = logistic_reg(),
  random_forest = rand_forest(trees = 500) |> set_engine("ranger")  |> set_mode("classification"),
  xgboost       = xgb
)

set.seed(2026)
bakeoff <- workflow_set(list(rec = dm_rec), models) |>
  workflow_map("fit_resamples", resamples = dm_folds, metrics = cls_metrics, seed = 2026)

rank_results(bakeoff, rank_metric = "roc_auc", select_best = TRUE) |>
  filter(.metric == "roc_auc") |>
  select(wflow_id, mean, std_err)
# Often the top few are within one std_err of each other - then you choose on speed,
# interpretability and calibration, not on AUC alone. (Session 7.)
