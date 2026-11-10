# =============================================================================
# DEMO 3 · Support vector machines  (Session 4 · ~15 min live)
# ONE idea: an SVM finds the widest "street" between the two classes; the RBF kernel lets
# that street bend. SVMs only work when the predictors share one scale.
# Full version (margins, soft margins, three kernels, exercises): tutorials/03_svm.qmd
# =============================================================================

source("R/prep_nhms.R")

# Our recipe already puts every predictor on one scale (step_normalize) - that is what an SVM needs.
svm <- svm_rbf(cost = 1, rbf_sigma = 0.01) |> set_engine("kernlab") |> set_mode("classification")

svm_fit <- workflow(dm_rec, svm) |> fit(dm_train)          # ~10 seconds
augment(svm_fit, dm_test) |> roc_auc(undx_dm, .pred_Yes)   # how well it ranks patients on the test set

# `cost` and `rbf_sigma` are the two knobs. We picked them by hand here;
# in the tuning demo (Session 6) we let the computer search for the best pair.
