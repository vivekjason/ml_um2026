# =============================================================================
# install_packages.R  —  run ONCE before the workshop (needs internet, ~10-15 min)
# Predictive Intelligence in R · CePH Workshop Series 5 · 11-12 Nov 2026
#
# Requirements: R >= 4.3 (4.4 or 4.5 recommended), RStudio >= 2024.04, Quarto >= 1.4
# Windows users: install Rtools matching your R version first (https://cran.r-project.org/bin/windows/Rtools/)
# =============================================================================

if (getRversion() < "4.3.0") stop("Please update R to 4.3 or newer: https://cran.r-project.org/")

# Fast binary installs where available (Posit Public Package Manager)
options(repos = c(PPM = "https://packagemanager.posit.co/cran/latest", CRAN = "https://cloud.r-project.org"))

core <- c(
  "tidymodels",     # rsample, recipes, parsnip, workflows, tune, dials, yardstick, workflowsets, broom, dplyr, ggplot2 ...
  "finetune",       # racing + simulated annealing tuning
  "probably",       # calibration plots, threshold analysis
  "themis",         # class-imbalance recipe steps (SMOTE, down/up-sampling)
  "future",         # parallel processing backend used by tune >= 1.3
  "skimr", "naniar", "patchwork"            # EDA + plotting helpers
)

engines <- c(
  "ranger",         # random forest
  "xgboost",        # gradient boosting
  "kernlab",        # SVM
  "nnet",           # single-hidden-layer neural network (ships with R, listed for completeness)
  "glmnet",         # penalised logistic regression
  "rpart", "rpart.plot"   # single decision tree + plotting
)

explain <- c(
  "DALEX", "DALEXtra",   # model-agnostic explanations (permutation importance, PDP, break-down)
  "kernelshap", "shapviz" # SHAP values for any model + plots
)

optional <- c(
  "dcurves",        # decision curve analysis (clinical net benefit)
  "brulee"          # multi-layer neural nets via torch (see torch step below)
)

pkgs <- c(core, engines, explain, optional)
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing)) install.packages(missing, dependencies = TRUE) else message("All CRAN packages already installed.")

# ---- OPTIONAL but recommended: torch backend for brulee (multi-layer networks, Day 2 afternoon) ----
# This downloads ~250 MB of libtorch the first time. Do it on good Wi-Fi BEFORE the workshop.
if (!requireNamespace("torch", quietly = TRUE)) install.packages("torch")
tryCatch({
  torch::install_torch()          # no-op if already installed
  message("torch backend OK: ", torch::torch_is_installed())
}, error = function(e) message("torch install failed (that is OK - the nnet engine covers the core content): ", conditionMessage(e)))

message("\nDone. Now run setup/check_setup.R to confirm everything works.")
