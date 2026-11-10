# =============================================================================
# DEMO 2 · Decision trees and random forests  (Session 3 · ~15 min live)
# ONE idea: one tree is a simple flowchart but jumpy; a FOREST of many trees, each on a
# random slice of the data, votes together and is far steadier.
# Full version (OOB error, mtry, importance, exercises): tutorials/02_random_forests.qmd
# =============================================================================

source("R/prep_nhms.R")   # dm_train, dm_test, dm_folds, dm_rec, cls_metrics  (built in Session 1)
library(rpart.plot)

# 1 | ONE decision tree: a flowchart the computer learns from the data
tree <- decision_tree(mode = "classification") |> set_engine("rpart")
tree_fit <- workflow(dm_rec, tree) |> fit(dm_train)
tree_fit |> extract_fit_engine() |> rpart.plot(roundint = FALSE)   # look at the yes/no questions it asks

# 2 | A FOREST = hundreds of trees, each grown on a random slice, then averaged.
#     More trees, steadier answer. We score it with 5-fold cross-validation.
rf <- rand_forest(trees = 500) |> set_engine("ranger") |> set_mode("classification")

set.seed(2026)
rf_cv <- fit_resamples(workflow(dm_rec, rf), dm_folds, metrics = cls_metrics)
collect_metrics(rf_cv)

# 3 | Did the forest beat the logistic baseline from Session 2? (same folds = a fair test)
set.seed(2026)
lr_cv <- fit_resamples(workflow(dm_rec, logistic_reg()), dm_folds, metrics = cls_metrics)

collect_metrics(lr_cv) |> filter(.metric == "roc_auc")   # baseline
collect_metrics(rf_cv) |> filter(.metric == "roc_auc")   # the forest
