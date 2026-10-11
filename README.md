# Arbitration Court Document Classification: TF-IDF vs Doc2Vec

Comparison of text classification approaches for arbitration court documents (~28k documents (Russian language), 15 classes).

## Notebooks

| Notebook | Features | Models |
|---|---|---|
| `tfidf_svm_models_metrics_en.ipynb` | TF-IDF (unigrams + bigrams) | Logistic Regression, Linear SVM, Naive Bayes (Multinomial / Complement), SGD, Decision Tree, Random Forest, Extra Trees, LightGBM |
| `classification_doc2vec_models_metrics_en.ipynb` | Doc2Vec (DBOW, 100-dim) | Logistic Regression, Linear SVM, Gaussian Naive Bayes, Decision Tree, Random Forest, AdaBoost, LightGBM |

Both notebooks use the same stratified train/test split and report Accuracy, Macro/Weighted Precision, Recall and F1, macro One-vs-Rest ROC-AUC, per-class reports, a confusion matrix and misclassified examples.

## Data

Place `df2.csv` next to the notebooks (`;` separator, `windows-1251` encoding) with columns:
- `text` - document text
- `class` - target label

The dataset is not included in this repository.The dataset can be collected from documents downloaded from https://ras.arbitr.ru/
The dataset generation script 'pdf_corpus_to_csv.R' produces `df2.csv` containing the document ID, document text, and class label ("doc_id", "text", "class").

## Setup

```bash
pip install pandas numpy matplotlib scikit-learn nltk gensim
pip install lightgbm  # optional
```

## Notes

- Notebooks are tuned for limited RAM: the TF-IDF vocabulary is capped, tree models use chi-squared feature selection, and the CSV is read in chunks. Adjust `MAX_FEATURES`, `TREE_FEATURES` and `N_JOBS` in the settings cell if needed.
- Doc2Vec test vectors are inferred with `infer_vector`, so test texts never take part in training.
- Random splits can overestimate quality if documents from the same case are similar; split by case ID if you have one.
