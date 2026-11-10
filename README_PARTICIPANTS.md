# Predictive Intelligence in R — participant pack

**CePH R Workshop Series 5 · Universiti Malaya · 11–12 November 2026 · 9.00–17.00 · SPM Conference Room**
Facilitator: Dr Vivek Jason Jayaraj, Centre for Population Health, Department of Social and Preventive Medicine

## Start here (15 minutes, before the workshop, on good Wi-Fi)

1. Unzip this folder somewhere sensible (not inside Downloads). Keep the folder name `ml_um2026`.
2. Install or update: **R 4.3+**, **RStudio 2024.04+**, **Quarto 1.4+** (bundled with recent RStudio).
   Windows: also **Rtools** matching your R version. macOS: `xcode-select --install` in Terminal.
3. Double-click **`ml_um2026.Rproj`** — this opens RStudio in the right folder so every path works.
4. Open `setup/install_packages.R` and click **Source** (10–15 min). Say yes to the optional *torch* download if you can.
5. Open `setup/check_setup.R` and click **Source**. Every line should say `PASS`.
   Anything says `FAIL`? Email the full output to the organisers, or come to the **setup clinic at 8.30 on 11 Nov**.
6. One RStudio setting: **Tools › Global Options › R Markdown › Basic › "Evaluate chunks in directory" → Project**.

Full instructions with troubleshooting: `setup.qmd` (or `docs/setup.html` if the `docs/` folder is present).

## What is in the folder

| Folder / file | What it is |
|---|---|
| `tutorials/01_pipeline.qmd` … `07_neural_networks.qmd` | **The thing to open in the room.** One self-guided tutorial per session: narrative, every line of code we type, the outputs, *Your turn* exercises and their solutions. Redo them at home. |
| `slides/01_…qmd` … `09_wrapup.qmd` | The lecture decks (Quarto revealjs). Open `docs/slides/*.html` if present, or render a deck with `quarto preview slides/01_ml_foundations.qmd`. |
| `demos/*.R` | Short live-coding scripts, one per session — the core of each tutorial in ~20 lines. Good for following along or redoing the essentials. |
| `R/prep_nhms.R` | Shared data cleaning, train/test split, folds, recipe and metric set. Every tutorial starts by sourcing it. |
| `data/nhms_synthetic.csv`, `data/data_dictionary.md` | The dataset (5,000 simulated Malaysian adults, NHMS-style) and its dictionary. **Synthetic: no row is a person.** |
| `setup/install_packages.R`, `setup/check_setup.R` | Package installation and the pre-flight check. |
| `agenda.qmd` | The two-day programme, minute by minute. |
| `index.qmd`, `setup.qmd`, `_quarto.yml`, `styles.scss`, `images/` | The workshop website's source and figures. `quarto render` rebuilds everything into `docs/` (20–40 min the first time). |
| `docs/` (if present) | The rendered website: open `docs/index.html` in a browser for the agenda, tutorials with outputs, and slides. |

## The two days in brief

| | Day 1 · Wednesday 11 Nov · *Build* | Day 2 · Thursday 12 Nov · *Trust, then go deeper* |
|---|---|---|
| 09.00 | Welcome · S1 Learning how the machine learns | Recap · S5 Gradient boosting and XGBoost · the bake-off (T4) |
| 10.50 | S2 The pipeline: split, recipe, workflow, target leakage (T1) | S6 Resampling and tuning (T5) |
| 11.50 | *(continues)* Your turn · debrief | S7 Evaluation, calibration and explanation (T6) |
| 14.00 | S3 Decision trees and random forests (T2) | S8 Neural networks, part 1 — theory and a network from scratch (T7) |
| 15.50 | S4 Support vector machines (T3) | S8 Neural networks, part 2 · 16.40 Verdict and where next |

Tea 10.30 and 15.30 · Lunch 13.00. The take-home challenge (undiagnosed hypertension) closes Tutorial 7.

## Before you arrive

- Bring your laptop and charger. Basic `dplyr` and `ggplot2` are assumed.
- Optional reading: *Tidy Modeling with R*, chapters 1–3 and 5–8 — <https://www.tmwr.org/>
- Phones and AI assistants are allowed in the room — but you must be able to explain every line you paste.
