# Pre-workshop email to participants — send ~7 days before (4 Nov) and again 2 days before

**Subject:** Predictive Intelligence in R (11–12 Nov) — 15-minute setup to do before you arrive

Dear participant,

Thank you for registering for *R Workshop Series 5: Predictive Intelligence* (11–12 November, 9.00–17.00, SPM Conference Room, Level 1, Block J, Faculty of Medicine, UM).

The workshop is fully hands-on. To make sure we spend the two days modelling rather than installing, please complete the setup below **before the day**. It takes about 15 minutes on a good connection. The room's Wi-Fi will not cope with 25 people installing packages at once.

**1. Software.** R 4.3 or newer, RStudio 2024.04 or newer, Quarto 1.4 or newer. Windows users also need Rtools matching their R version; Mac users need the Xcode command-line tools (`xcode-select --install`). Links are in the attached `setup` page.

**2. Workshop folder.** Download and unzip the attached workshop folder `ml_um2026_participants_<date>.zip` (or clone the repository). Read `README_PARTICIPANTS.md`, then open `ml_um2026.Rproj` in RStudio.

**3. Packages.** Open `setup/install_packages.R` and click *Source*. Accept the optional *torch* download (~250 MB) if you can — it is only needed for one advanced demo.

**4. Check.** Open `setup/check_setup.R` and click *Source*. Every line should say `PASS`. If anything says `FAIL`, reply to this email with the full output and we will sort it out before the day; failing that, come to the **setup clinic at 8.30 on 11 November**.

**Bring:** your laptop and charger. Basic familiarity with `dplyr` and `ggplot2` is assumed; if you attended the Refresher Course last week you are more than ready.

**Programme in brief**

- *Day 1 — Build:* what machine learning is (and isn't); the tidymodels pipeline and target leakage; decision trees and **random forests**; **support vector machines**.
- *Day 2 — Trust, then go deeper:* **XGBoost** and the bake-off; resampling and hyperparameter tuning; evaluation the way a clinician needs it (sensitivity, specificity, PPV at real prevalence, ROC, precision–recall, calibration, decision thresholds); explaining models (importance, partial dependence, SHAP); **neural networks** from first principles to tidymodels and torch; TRIPOD+AI reporting.

Every session has a self-guided tutorial with all the code, outputs and solutions, so you can redo it at home.

Optional pre-reading: *Tidy Modeling with R*, chapters 1–3 (https://www.tmwr.org/).

See you on the 11th.

Dr Vivek Jason Jayaraj
Centre for Population Health, Department of Social and Preventive Medicine, Universiti Malaya
