# =============================================================================
# DEMO 6 · Evaluation  (Session 7 · ~25 min live)
# ONE idea: accuracy lies when a disease is rare. Read the confusion matrix, look at the ROC
# curve, CHOOSE a threshold on purpose - then two extras: rebalancing (SMOTE/downsample) and SHAP.
# Full version (calibration, decision curves, exercises): tutorials/06_evaluation.qmd
# =============================================================================

source("R/prep_nhms.R")
library(patchwork)   # to place two plots side by side
library(themis)      # class-imbalance recipe steps (SMOTE, downsampling)
library(shapviz)     # SHAP plots

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


# =============================================================================
# EXTRA 1 · Rebalancing the training data: SMOTE vs downsampling
# Our outcome is imbalanced (~12% cases). Two ways to make the model "see" more cases:
#   step_downsample() - throw away majority-class rows until balanced (fast, loses data)
#   step_smote()      - synthesise new minority rows from their nearest neighbours (keeps all data)
# Both go in the RECIPE, after dummy-coding, and both are skip = TRUE by default: they rebalance the
# TRAINING folds only and are skipped at test time, so we still evaluate on the real 12% prevalence.
# =============================================================================

rec_smote <- dm_rec |> step_smote(undx_dm)        # add SMOTE to the pipeline we already built
rec_down  <- dm_rec |> step_downsample(undx_dm)   # add downsampling instead

score_recipe <- function(rec, label) {
  f <- workflow(rec, xgb) |> fit(dm_train)
  augment(f, dm_test) |> eval_metrics(truth = undx_dm, estimate = .pred_class, .pred_Yes) |>
    mutate(rebalance = label, .before = 1)
}

bind_rows(
  score_recipe(dm_rec,    "none"),
  score_recipe(rec_smote, "smote"),
  score_recipe(rec_down,  "downsample")
) |>
  filter(.metric %in% c("sensitivity", "specificity", "roc_auc", "brier_class")) |>
  tidyr::pivot_wider(names_from = .metric, values_from = .estimate)
# Watch the trade-off: rebalancing lifts SENSITIVITY (we catch more cases) but usually makes the
# probabilities worse-calibrated (BRIER goes up) while AUC barely moves. Rebalancing is a way to shift
# the decision, not to improve ranking - and a chosen threshold (section 4) often does the same job more honestly.


# =============================================================================
# EXTRA 2 · SHAP: which features drive each prediction (XGBoost, TreeSHAP)
# TreeSHAP reads exact Shapley values straight off the fitted trees - instant, no background sample.
# (KernelSHAP does the same for ANY model, just slower - that's how we explain the network in Tutorial 7.)
# =============================================================================

X_demo  <- dm_test |> select(-undx_dm) |> slice_sample(n = 500)   # people to explain
rec_fit <- extract_recipe(fit)                                    # the recipe as trained inside the workflow
X_baked <- bake(rec_fit, new_data = X_demo, all_predictors(), composition = "matrix")

# fold each factor's dummy columns back together so SHAP reads ONE value per original variable
dummy_step <- tidy(rec_fit) |> filter(type == "dummy") |> pull(number)
facs       <- tidy(rec_fit, number = dummy_step) |> pull(terms) |> unique()
collapse   <- setNames(lapply(facs, \(f) grep(paste0("^", f, "_"), colnames(X_baked), value = TRUE)), facs)
collapse   <- collapse[lengths(collapse) > 0]

sv <- shapviz(extract_fit_engine(fit), X_pred = X_baked, X = X_demo, collapse = collapse)

sv_importance(sv, kind = "beeswarm", max_display = 12)   # GLOBAL: which features matter, and which way they push
sv_dependence(sv, "bmi", color_var = "fam_hx_dm")        # how BMI pushes risk, coloured by family history
sv_waterfall(sv, row_id = 1)                              # LOCAL: one patient - the pieces that build their score
# SHAP explains the model, not biology: it says what the model learned, which is where you AUDIT it against
# what you already know (agrees -> trust goes up; disagrees -> either you learned something or it's cheating).
