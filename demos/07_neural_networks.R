# =============================================================================
# DEMO 7 · Neural networks - and the final verdict  (Session 8 · ~20 min live)
# ONE idea: a neural network is logistic regressions stacked in layers. Fit one the same
# tidymodels way, then line up ALL four families on the one held-out test set.
# Full version (backprop by hand, from scratch in base R, torch, SHAP): tutorials/07_neural_networks.qmd
# =============================================================================

source("R/prep_nhms.R")

# Each "hidden unit" is a little logistic regression; the next layer combines them.
# mlp() + the nnet engine fits a one-hidden-layer network. penalty = weight decay (keeps it simple).
nn <- mlp(hidden_units = 8, penalty = 0.01, epochs = 200) |>
  set_engine("nnet", MaxNWts = 5000) |> set_mode("classification")

nn_fit <- workflow(dm_rec, nn) |> fit(dm_train)
augment(nn_fit, dm_test) |> roc_auc(undx_dm, .pred_Yes)

# THE VERDICT: every family we built, scored once on the SAME locked test set (last_fit).
fit_one <- function(spec) last_fit(workflow(dm_rec, spec), dm_split, metrics = cls_metrics)

models <- list(
  logistic      = logistic_reg(),
  random_forest = rand_forest(trees = 500) |> set_engine("ranger")  |> set_mode("classification"),
  xgboost       = boost_tree(trees = 500, learn_rate = 0.03, tree_depth = 3) |> set_engine("xgboost") |> set_mode("classification"),
  neural_net    = nn
)

set.seed(2026)
verdict <- lapply(models, \(s) collect_metrics(fit_one(s))) |>
  bind_rows(.id = "model") |>
  filter(.metric == "roc_auc") |>
  select(model, roc_auc = .estimate) |>
  arrange(desc(roc_auc))
verdict
# On tabular health data the simple models hold their own - that is the honest headline of the two days.
