# =============================================================================
# DEMO 5 · Resampling and tuning  (Session 6 · ~25 min live)
# ONE idea: so far we PICKED the hyperparameters by hand. Mark them tune(), let the computer
# try a grid of values on the folds, and keep the best. The PATTERN is identical for every
# family - only WHICH knobs you tune changes.
# Full version (racing, one-SE rule, Bayesian search, exercises): tutorials/05_tuning.qmd
# =============================================================================

source("R/prep_nhms.R")

# The pattern (watch it repeat four times):
#   1. spec with tune() on the knobs     2. a small grid of values
#   3. tune_grid() over the 5 folds       4. show_best() -> select_best()

# ---- 1 | XGBoost: tune the learning rate and tree depth -------------------------------------
xgb_spec <- boost_tree(trees = 500, learn_rate = tune(), tree_depth = tune()) |>
  set_engine("xgboost") |> set_mode("classification")
xgb_grid <- grid_regular(learn_rate(range = c(-2, -0.5)),   # 0.01 .. ~0.3 (dials uses the log10 scale)
                         tree_depth(range = c(2L, 6L)), levels = 3)   # 3 x 3 = 9 combinations
set.seed(2026)
xgb_tuned <- tune_grid(workflow(dm_rec, xgb_spec), dm_folds, grid = xgb_grid, metrics = cls_metrics)
show_best(xgb_tuned, metric = "roc_auc", n = 3)

# ---- 2 | Random forest: tune mtry (columns per split) and min_n (leaf size) -----------------
rf_spec <- rand_forest(trees = 500, mtry = tune(), min_n = tune()) |>
  set_engine("ranger") |> set_mode("classification")
rf_grid <- grid_regular(mtry(range = c(2L, 8L)), min_n(range = c(5L, 40L)), levels = 3)
set.seed(2026)
rf_tuned <- tune_grid(workflow(dm_rec, rf_spec), dm_folds, grid = rf_grid, metrics = cls_metrics)
show_best(rf_tuned, metric = "roc_auc", n = 3)

# ---- 3 | SVM (RBF): tune cost and rbf_sigma -------------------------------------------------
# SVM is the SLOW family - this grid is deliberately tiny (2 x 2 = 4). Start it, then talk.
svm_spec <- svm_rbf(cost = tune(), rbf_sigma = tune()) |>
  set_engine("kernlab") |> set_mode("classification")
svm_grid <- grid_regular(cost(range = c(-3, 3)), rbf_sigma(range = c(-4, -1)), levels = 2)
set.seed(2026)
svm_tuned <- tune_grid(workflow(dm_rec, svm_spec), dm_folds, grid = svm_grid, metrics = cls_metrics)
show_best(svm_tuned, metric = "roc_auc", n = 3)

# ---- 4 | Neural network (nnet): tune hidden_units (width) and penalty (weight decay) --------
nn_spec <- mlp(hidden_units = tune(), penalty = tune(), epochs = 200) |>
  set_engine("nnet", MaxNWts = 5000) |> set_mode("classification")
nn_grid <- grid_regular(hidden_units(range = c(2L, 12L)), penalty(range = c(-4, -0.5)), levels = 3)
set.seed(2026)
nn_tuned <- tune_grid(workflow(dm_rec, nn_spec), dm_folds, grid = nn_grid, metrics = cls_metrics)
show_best(nn_tuned, metric = "roc_auc", n = 3)

# ---- Lock in a winner (example: the tuned XGBoost) -----------------------------------------
best_xgb  <- select_best(xgb_tuned, metric = "roc_auc")
best_xgb
final_wf  <- finalize_workflow(workflow(dm_rec, xgb_spec), best_xgb)   # ready to fit on all training data
final_wf

# Same four knobs, four models, one pattern. In practice you'd tune them all at once in a
# workflow_set() with racing (tune_race_anova) - that's Tutorial 5 - but the idea is exactly this.
