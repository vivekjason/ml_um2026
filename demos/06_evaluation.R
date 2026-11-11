# =============================================================================
# DEMO 6 · Evaluation  (Session 7 · ~20 min live)
# ONE idea: accuracy lies when a disease is rare. Read the confusion matrix, look at the ROC
# curve, and CHOOSE a decision threshold on purpose - plus how to get nice tables and plots in one line.
# Full version (calibration, SMOTE, SHAP, decision curves, exercises): tutorials/06_evaluation.qmd
# =============================================================================

source("R/prep_nhms.R")
library(patchwork)   # to place two plots side by side (optional)

# Fit one sensible model, predict on the untouched test set.
xgb <- boost_tree(trees = 500, learn_rate = 0.03, tree_depth = 3) |>
  set_engine("xgboost") |> set_mode("classification")
fit   <- workflow(dm_rec, xgb) |> fit(dm_train)
preds <- augment(fit, dm_test)

# 1 | Accuracy HIDES the problem: most people don't have the disease, so "predict No" scores well.
preds |> conf_mat(undx_dm, .pred_class)       # look - almost everyone is predicted "No"
preds |> accuracy(undx_dm, .pred_class)       # looks great...
preds |> sensitivity(undx_dm, .pred_class)    # ...but we miss most of the real cases

# 2 | NICE TABLE: bundle the metrics you care about into one metric_set, get them all in one tidy row.
eval_metrics <- metric_set(accuracy, sensitivity, specificity, roc_auc, pr_auc, brier_class)
preds |> eval_metrics(truth = undx_dm, estimate = .pred_class, .pred_Yes)
# (want it prettier for a slide?  ... |> gt::gt()   or   ... |> knitr::kable(digits = 3))

# 3 | NICE PLOTS, one line each:
preds |> conf_mat(undx_dm, .pred_class) |> autoplot(type = "heatmap")   # confusion matrix as a heatmap

roc <- preds |> roc_curve(undx_dm, .pred_Yes) |> autoplot()            # ROC curve
pr  <- preds |> pr_curve(undx_dm, .pred_Yes)  |> autoplot()            # precision-recall curve (better when rare)
roc + pr                                                               # patchwork puts them side by side

# 4 | A screening programme wants to CATCH cases, so lower the threshold on purpose (0.5 -> 0.15):
preds |>
  mutate(flag = if_else(.pred_Yes > 0.15, "Yes", "No")) |>
  count(flag, undx_dm)
# Flagging more people finds more true cases (higher sensitivity) at the cost of more false alarms.
# The right threshold is a programme decision, not a default.
