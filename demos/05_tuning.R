# =============================================================================
# DEMO 5 · Resampling and tuning  (Session 6 · ~20 min live)
# ONE idea: so far we PICKED the hyperparameters by hand. Mark them tune(), let the computer
# try a grid of values on the folds, and keep the best.
# Full version (racing, one-SE rule, Bayesian search, exercises): tutorials/05_tuning.qmd
# =============================================================================

source("R/prep_nhms.R")

# Mark the two knobs we want the computer to choose, with tune():
xgb_tune <- boost_tree(trees = 500, learn_rate = tune(), tree_depth = tune()) |>
  set_engine("xgboost") |> set_mode("classification")

# A small grid of value-combinations to try (3 x 3 = 9 here, to keep the demo quick):
grid <- grid_regular(
  learn_rate(range = c(-2, -0.5)),   # 0.01 .. ~0.3  (dials works on the log10 scale)
  tree_depth(range = c(2, 6)),
  levels = 3
)
grid

# Try every combination on the 5 folds (this is the part that takes a minute - talk through the grid):
set.seed(2026)
tuned <- tune_grid(workflow(dm_rec, xgb_tune), resamples = dm_folds, grid = grid, metrics = cls_metrics)

show_best(tuned, metric = "roc_auc", n = 5)       # the best combinations
best <- select_best(tuned, metric = "roc_auc")
best

# Lock the winning values into the workflow - ready to fit on all the training data.
final_wf <- finalize_workflow(workflow(dm_rec, xgb_tune), best)
final_wf
