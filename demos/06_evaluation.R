# =============================================================================
# DEMO 6 · Evaluation  (Session 7 · ~20 min live)
# ONE idea: accuracy lies when a disease is rare. Read the confusion matrix, look at the ROC
# curve, and CHOOSE a decision threshold on purpose.
# Full version (calibration, SMOTE, SHAP, decision curves, exercises): tutorials/06_evaluation.qmd
# =============================================================================

source("R/prep_nhms.R")

# Fit one sensible model, predict on the untouched test set.
xgb <- boost_tree(trees = 500, learn_rate = 0.03, tree_depth = 3) |>
  set_engine("xgboost") |> set_mode("classification")
fit   <- workflow(dm_rec, xgb) |> fit(dm_train)
preds <- augment(fit, dm_test)

# 1 | Accuracy HIDES the problem: most people don't have the disease, so "predict No" scores well.
preds |> conf_mat(undx_dm, .pred_class)       # look - almost everyone is predicted "No"
preds |> accuracy(undx_dm, .pred_class)       # looks great...
preds |> sensitivity(undx_dm, .pred_class)    # ...but we miss most of the real cases

# 2 | The ROC curve shows performance across ALL possible thresholds, and AUC summarises it.
preds |> roc_curve(undx_dm, .pred_Yes) |> autoplot()
preds |> roc_auc(undx_dm, .pred_Yes)

# 3 | A screening programme wants to CATCH cases, so lower the threshold on purpose (0.5 -> 0.15):
preds |>
  mutate(flag = if_else(.pred_Yes > 0.15, "Yes", "No")) |>
  count(flag, undx_dm)
# Flagging more people finds more true cases (higher sensitivity) at the cost of more false alarms.
# The right threshold is a programme decision, not a default.
