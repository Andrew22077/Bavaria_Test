---

# Introduction

This project focuses on analyzing customer purchasing behavior within the beer category and building a predictive model to estimate the probability that a customer will purchase a specific brand (**Marca 0**).

Using transactional data (`compras.csv`) and product metadata (`productos.csv`), the objective is to uncover **behavioral patterns**, identify **distinct customer profiles**, and translate these insights into a **data-driven model** that supports commercial decision-making.

The approach combines **exploratory analysis**, **customer segmentation**, and **machine learning**, with a strong emphasis on **business interpretability** and **actionable insights**.

---

# Project Overview

## 1️⃣ Data Preparation and Cleaning

Both datasets were processed and standardized to ensure data quality:

* Fixed formatting issues (e.g., delimiter inconsistencies)
* Standardized categorical variables (brand names, text fields)
* Converted data types (dates, numeric variables)
* Stored results as structured tables in Databricks

**Result:** A clean, consistent, and reliable dataset ready for analysis.

---

## 2️⃣ Exploratory Data Analysis & Customer Profiling

An exploratory analysis was conducted to understand:

* Customer purchasing frequency and spending behavior
* Brand diversity and loyalty patterns
* Distribution of volume and transactions

### Customer Segmentation

Two complementary approaches were applied:

### 🔹 K-Means Clustering

Cluster Strategy
<img width="616" height="442" alt="image" src="https://github.com/user-attachments/assets/6ad2c670-a9ca-4a25-ac29-e0904aafe8e5" />


Customers were grouped based on:

* Purchase frequency
* Total spend
* Average ticket
* Brand diversity

This revealed distinct behavioral profiles such as:

* **High-value customers**
* **Medium-frequency buyers**
* **Occasional buyers**
* **Heavy buyers with high volume and spend**

---

### 🔹 RFM + Brand Affinity Segmentation

A business-oriented segmentation was developed using:

* **RFM (Recency, Frequency, Monetary)** scoring
* **Brand affinity (HHI index)** to measure loyalty vs exploration

This resulted in actionable segments such as:

* **Champions**
* **Loyal customers**
* **At-risk customers**
* **Monogamous vs Explorer customers**

**Key insight:** Customer behavior is strongly influenced by both **purchase frequency** and **brand loyalty**.

---

## 3️⃣ Feature Engineering & Dataset Construction

A modeling dataset was built at the **customer level**, combining:

* Behavioral metrics (frequency, spend, activity)
* RFM scores and segments
* Brand affinity indicators
* Diversity metrics (brands and SKUs)

### Target Variable

A binary target was defined:

* **1 → Customer purchased Marca 0**
* **0 → Customer did not purchase Marca 0**

This transforms the problem into a **binary classification task**.

---

## 4️⃣ Predictive Modeling

A machine learning model (**XGBoost**) was trained to estimate purchase probability.

### Key modeling decisions:

* **Stratified train-test split** to preserve class distribution
* **Handling class imbalance** using class weighting
* **Feature encoding** for categorical variables
* **Threshold optimization** to balance precision and recall

The model outputs probabilities, enabling flexible business applications depending on campaign strategy.

---

## 5️⃣ Model Evaluation and Interpretation

The model was evaluated using:

* **AUC-ROC** for overall discrimination power
* **Precision and Recall** for business trade-offs
* **F1-score** for balanced performance
* **Confusion matrix** for detailed error analysis

Additionally, **feature importance analysis** was performed to identify the key drivers of purchase behavior.

---

# Key Takeaway

> **Customer purchase behavior is primarily driven by brand affinity and historical behavior, rather than purely transactional value.**

By combining segmentation and predictive modeling, this solution provides:

* **Strategic understanding of customer behavior**
* **Actionable insights for marketing and commercial teams**
* **A scalable framework for targeted campaigns and customer growth**

---

# Results and Conclusions

## Model Performance

The trained XGBoost model shows **excellent performance** for predicting purchase probability of **Marca 0**:

| Metric | Value |
|---------|-------|
| **AUC-ROC** | **95.4%** |
| Precision @ 0.50 | 88.7% |
| Recall @ 0.50 | 90.7% |
| F1-Score @ 0.50 | 89.7% |
| Optimal F1-Score | 90.0% |

**Interpretation:**
- **AUC-ROC = 95.4%**: The model discriminates extremely well between buyers and non-buyers
- **High Precision (88.7%)**: Of the customers the model predicts will buy, 88.7% actually do
- **High Recall (90.7%)**: The model correctly identifies 90.7% of actual buyers

---

## Most Relevant Variables

The **top 10 variables** that most influence Marca 0 purchase probability are:

| Ranking | Variable | Importance | Interpretation |
|---------|----------|------------|----------------|
| **1** | **`brand_code`** | **37.1%** | **Customer's favorite brand** |
| 2 | `brand_variety` | 9.7% | Number of different brands purchased |
| 3 | `wallet_hhi` | 7.1% | Concentration index (1 = monogamous) |
| 4 | `frequency` | 4.5% | Total number of purchases |
| 5 | `f_score` | 4.0% | RFM frequency score (1-3) |
| 6 | `active_days` | 2.5% | Days with purchase activity |
| 7 | `top_brand_share` | 2.4% | % of purchases in their main brand |
| 8 | `rfm_total` | 2.0% | Total RFM score (3-9) |
| 9 | `brands_bought` | 1.8% | Total different brands purchased |
| 10 | `affinity_Monogamo` | 1.8% | If customer is monogamous to one brand |

---

## Key Insights

### 1️⃣ **Current favorite brand is the strongest predictor (37%)**
➡️ If Marca 0 is already the customer's main brand (`top_brand`), purchase probability is very high.

**Business implication:** Focus on **retention** of current Marca 0 customers - they are the most valuable segment.

### 2️⃣ **Brand variety matters (9.7%)**
➡️ Customers who buy **many different brands** have lower probability of buying Marca 0.

**Business implication:** "Explorer" customers require **conversion and trial** strategies, while monogamous customers require **loyalty** strategies.

### 3️⃣ **Wallet concentration (HHI) is key (7.1%)**
➡️ Customers with **high HHI** (monogamous) are more predictable - if their favorite brand is Marca 0, they will buy; if not, they won't.

**Business implication:** Identify monogamous customers of **other brands** for **switching** campaigns.

### 4️⃣ **Frequency and engagement matter (4.5% + 2.5%)**
➡️ **Frequent and active** customers have higher purchase probability.

**Business implication:** **Loyalty and rewards** programs can increase frequency and, therefore, Marca 0 purchase probability.

---

## Business Recommendations

1. **Customer segmentation:**
   - **High probability (>70%)**: Current Marca 0 customers → Retention campaigns
   - **Medium probability (30-70%)**: Mixed customers → Product promotion and trial
   - **Low probability (<30%)**: Customers loyal to other brands → Aggressive switching campaigns

2. **Focus on retention**: Most Marca 0 buyers are already loyal customers. Protecting this base is critical.

3. **Inactive customer activation**: Customers with low frequency but who historically bought Marca 0 are reactivation opportunities.

4. **Cross-selling**: Customers with high brand variety are less loyal but more open to trying - offer bundles or discounts.

---
