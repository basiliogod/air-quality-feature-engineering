# UCI Air Quality - Feature Analysis and Engineering Pipeline

**Authors:** Guilherme Camacho Basílio (2100123) & Carlos Santos (2128623) <br>
**Institution:** University of Madeira <br>
**Course:** Artificial Neural Networks (2026/2027) <br>
**Date:** October 2026

---

An end-to-end data engineering and exploratory framework implemented in **MATLAB** to clean, analyze, filter, and engineer predictive features from the public **UCI Air Quality Dataset**. 

The pipeline prepares sensory and atmospheric observations collected in an Italian urban setting for downstream predictive modeling via Artificial Neural Networks (ANNs), focusing specifically on predicting hourly Ground Truth Carbon Monoxide concentrations: **`CO(GT)`**.

## Project Scope & Engineering Framework

### 1. Problem Formulation & Objectives
Urban air monitoring stations utilizing low-cost metal oxide semiconductor chemical sensors suffer from non-linearities, sensor cross-sensitivities, drift, and frequent acquisition failures. This project establishes a robust data pre-modeling pipeline covering:
- **Baseline Exploration:** Assessing statistical dispersions, data types, missing value mechanisms, and linear correlations across all physical attributes.
- **Data Cleansing & Preprocessing:** Handling sensor failure codes, isolating the supervised target variable, mitigating extreme transients via percentile clipping, and bounding feature spaces using Min-Max scaling.
- **Exploratory Data Analysis (EDA) & PCA:** Mapping functional non-linearities, evaluating diurnal pollutant cycles, and diagnosing spectral redundancy via Principal Component Analysis (PCA).
- **Feature Selection:** Pruning uninformative atmospheric noise and collinear sensory duplicates through statistical filtering ($\vert{}r\vert{} < 0.15$ and $\vert{}r_{ij}\vert{} > 0.85$).
- **Feature Engineering:** Deriving physically grounded composite features and cyclical temporal embeddings to improve neural network training dynamics.

---

### 2. Methodological Phases

#### Phase 1: Data Import & Exploration
- **Acquisition Artifact Handling:** Mapped the UCI sentinel failure value `-200` to `NaN`, exposing $16,701$ missing observations across $9,358$ records.
- **Target Distribution Diagnostics:** Identified strong positive skewness ($1.37$) in `CO(GT)`, characterized by heavy right-tail emission peaks reaching up to $11.9\text{ mg/m}^3$.
- **Critical Feature Isolation:** Identified severe data loss in `NMHC(GT)` ($90.23\%$ missing), marking it for removal.

#### Phase 2: Data Cleaning & Preprocessing
- **Supervised Ground Truth Integrity:** Removed all instances with missing target entries without synthetic imputation, preserving a validated benchmark of $7,674$ records.
- **Autoregressive Imputation:** Applied continuous linear interpolation across predictor features to preserve physical dynamics across consecutive hourly steps.
- **Outlier Mitigation:** Winsorized feature bounds between the $1\text{st}$ and $99\text{th}$ percentiles to suppress sensor saturation spikes while retaining real peak variances.
- **Domain Normalization:** Scaled predictors linearly to the interval $[0, 1]$ via Min-Max scaling to prevent gradient explosion and dominant weight updates in dense neural layers.

#### Phase 3: Exploratory Data Analysis (EDA)
- **Non-Linear Dynamics:** Observed convex saturation curves in tin and titania oxide sensors (`PT08.S1`, `PT08.S2`) and hyperbolic inverse responses in tungsten oxide (`PT08.S3`).
- **Circadian Profile Modeling:** Extracted a clear bimodal diurnal pollution curve peaking during morning ($09:00$) and evening ($19:00$) commuter rush hours.
- **Dimensionality Analysis (PCA):** Demonstrated that the first two orthogonal principal components ($\text{PC}_1$ and $\text{PC}_2$) account for **$76.1\%$** of total variance, validating the potential for dimensional compression.

#### Phase 4: Feature Selection
- **Weak Relevance Exclusion:** Discarded ambient weather variables (`T`, `RH`, `AH`) based on linear independence with the target ($\vert{}r\vert{} \le 0.0577$).
- **Multicollinearity Pruning:** Removed redundant transductor channels (`PT08.S2`, `PT08.S5`, `PT08.S4`, `NO2(GT)`) exhibiting cross-correlations exceeding $r = 0.85$.
- **Parsimonious Baseline Subset:** Retained a core 4-variable predictive space:
  - `C6H6(GT)` ($r = 0.9074$): Primary combustion hydrocarbon benchmark.
  - `PT08.S1(CO)` ($r = 0.8587$): Physical tin oxide CO transducer.
  - `PT08.S3(NOx)` ($r = -0.7086$): Complementary inverse semiconductor signal.
  - `NOx(GT)` ($r = 0.7896$): High-temperature vehicle emission indicator.

#### Phase 5: Feature Engineering
Synthesized three domain-driven features:
1. **Continuous Cyclical Time:** Encoded the 24-hour cycle onto the unit trigonometric circle via $\text{Hour\_Sin}$ ($r = -0.3570$) and $\text{Hour\_Cos}$ ($r = -0.1653$), resolving edge discontinuities between $23:00$ and $00:00$.
2. **Differential Chemical Ratio ($\text{Ratio\_S1\_S3}$):** Formulated an opposition index between reducing and oxidizing sensors:
   $$\text{Ratio}_{\text{S1/S3}} = \frac{\text{PT08.S1}}{\text{PT08.S3} + \epsilon}$$
   Achieved a Pearson correlation of **$r = 0.8594$** and Spearman rank correlation of **$\rho = 0.8577$**, linearizing sensor response and mitigating common environmental drift.

---

## Final Space Comparison

| Analytical Dimension | Raw Input Data | Post-Selection Baseline | Final Engineered Subset |
| :--- | :---: | :---: | :---: |
| **Valid Observations** | 9,357 (Corrupted) | 7,674 (Clean) | **7,674 (Clean)** |
| **Missing Values (`NaN`)** | 16,701 | 0 | **0** |
| **Input Dimensionality** | 12 features | 4 features | **7 features** |
| **Extreme Multicollinearity ($r > 0.85$)** | Severe (Multiple pairs) | Mitigated | **None** |
| **Temporal Context** | Discrete/Discontinuous | None | **Continuous Circular ($\sin, \cos$)** |
| **Non-Linear Linearization** | Saturation Curves | Mild | **High ($\text{Ratio}_{\text{S1/S3}}$, $r=0.86$)** |

---

## Repository Structure

```text
air-quality-feature-engineering/
│
├── AirQualityUCI.xlsx             # Raw UCI dataset spreadsheet
├── main.m                         # Master execution script orchestrating the pipeline
│
├── DataImportExploration.m        # Phase 1: Ingestion, NaN handling, and initial EDA
├── DataCleaningPreProcessing.m    # Phase 2: Imputation, clipping, and normalization
├── ExploratoryDataAnalysis.m      # Phase 3: Bivariate analysis, PCA, and 20-plot matrix
├── FeatureSelection.m             # Phase 4: Relevance ranking and collinearity filtering
├── FeatureEngineering.m           # Phase 5: Trigonometric encoding and chemical ratios
│
├── images/                        # Figures generated for the IEEE report
│   ├── distribuicao_target.png
│   ├── correlacao_features_target.png
│   ├── antes_depois_limpeza.png
│   ├── antes_depois_normalizacao.png
│   ├── eda_scatter_relations.png
│   ├── eda_pca_analysis.png
│   ├── eda_multivariada.png
│   ├── eda_features_distributions.png
│   ├── eda_temporal_patterns.png
│   ├── eda_redundancy_loadings.png
│   ├── feature_selection_summary.png
│   └── feature_engineering_analysis.png
│
├── Report_RNA.pdf                 # Final 10-page IEEE formatted report
├── Presentation_RNA.pdf           # Powerpoint presentation
│
└── README.md                      # Project documentation

```