# =============================================================================
# check_setup.R  —  run this the day before the workshop (takes ~1 minute)
# It prints PASS/FAIL for each requirement. Bring the output to the setup clinic if anything fails.
# Run from the project root (open ml_um2026.Rproj first, or setwd() to the folder).
# =============================================================================

ok <- function(test, msg) cat(sprintf("[%s] %s\n", if (isTRUE(test)) "PASS" else "FAIL", msg))

cat("R version:", R.version.string, "\n")
ok(getRversion() >= "4.3.0", "R >= 4.3")

need <- c("tidymodels", "finetune", "probably", "themis", "future", "ranger", "xgboost", "kernlab",
          "nnet", "glmnet", "rpart", "rpart.plot", "DALEX", "DALEXtra", "kernelshap",
          "shapviz", "skimr", "naniar", "patchwork")
inst <- need %in% rownames(installed.packages())
for (i in seq_along(need)) ok(inst[i], paste("package", need[i]))

pv <- function(p, v) tryCatch(packageVersion(p) >= v, error = function(e) FALSE)
ok(pv("tune", "1.2.0"), "tune >= 1.2 (select_best(metric = ...) syntax)")
ok(pv("dials", "1.3.0"), "dials >= 1.3 (grid_space_filling())")

# --- data ---------------------------------------------------------------------
ok(file.exists("data/nhms_synthetic.csv"), "data/nhms_synthetic.csv found (are you in the project folder? open ml_um2026.Rproj)")
if (file.exists("data/nhms_synthetic.csv")) {
  d <- readr::read_csv("data/nhms_synthetic.csv", show_col_types = FALSE)
  ok(nrow(d) == 5000 && ncol(d) == 41, sprintf("data has 5000 x 41 (got %d x %d)", nrow(d), ncol(d)))
}

# --- a tiny end-to-end fit with each engine -----------------------------------
suppressPackageStartupMessages(library(tidymodels))
set.seed(1)
toy <- modeldata::two_class_dat   # 791 rows, 2 predictors, Class
try_fit <- function(spec, label) {
  res <- tryCatch({
    wf <- workflow(Class ~ ., spec)
    f  <- fit(wf, toy)
    p  <- predict(f, toy[1:5, ], type = "prob")
    all(c(".pred_Class1", ".pred_Class2") %in% names(p))
  }, error = function(e) { message("   ", conditionMessage(e)); FALSE })
  ok(res, paste("fit + predict:", label))
}
try_fit(logistic_reg() |> set_engine("glm"), "logistic_reg (glm)")
try_fit(rand_forest(trees = 50) |> set_engine("ranger") |> set_mode("classification"), "rand_forest (ranger)")
try_fit(boost_tree(trees = 20) |> set_engine("xgboost") |> set_mode("classification"), "boost_tree (xgboost)")
try_fit(svm_rbf() |> set_engine("kernlab") |> set_mode("classification"), "svm_rbf (kernlab)")
try_fit(mlp(hidden_units = 4, epochs = 50) |> set_engine("nnet") |> set_mode("classification"), "mlp (nnet)")

# --- optional: torch / brulee -------------------------------------------------
if (requireNamespace("torch", quietly = TRUE) && requireNamespace("brulee", quietly = TRUE)) {
  t_ok <- tryCatch(torch::torch_is_installed(), error = function(e) FALSE)
  ok(t_ok, "OPTIONAL torch backend installed (needed only for the brulee demo)")
  if (isTRUE(t_ok)) try_fit(mlp(hidden_units = 4, epochs = 20) |> set_engine("brulee") |> set_mode("classification"), "OPTIONAL mlp (brulee)")
} else {
  cat("[SKIP] OPTIONAL torch/brulee not installed - the nnet engine covers the core neural-network content\n")
}

# --- parallel -----------------------------------------------------------------
cat("Cores available:", parallel::detectCores(), "(we will use", max(1, parallel::detectCores() - 1), "workers)\n")
cat("\nIf everything above says PASS you are ready. See you on 11 November.\n")
