library(tm)
library(SnowballC)
library(pdftools)
library(ggplot2)
library(lsa)

# Directory of this script (works with Rscript, source() and RStudio; falls back to the working directory)
get_script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) > 0) {
    return(dirname(normalizePath(sub("^--file=", "", file_arg[1]))))
  }
  for (frame in rev(sys.frames())) {
    if (!is.null(frame$ofile)) return(dirname(normalizePath(frame$ofile)))
  }
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    path <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(path)) return(dirname(normalizePath(path)))
  }
  getwd()
}
script_dir <- get_script_dir()

# Folders with documents are located next to this script
cname1 <- file.path(script_dir, "оспаривание действий судебных приставов")
docs1 <- Corpus(DirSource(cname1), readerControl = list(reader = readPDF))
cname2 <- file.path(script_dir, "оспаривание решений антимонопольных органов")
docs2 <- Corpus(DirSource(cname2), readerControl = list(reader = readPDF))
cname3 <- file.path(script_dir, "поставка")
docs3 <- Corpus(DirSource(cname3), readerControl = list(reader = readPDF))
cname4 <- file.path(script_dir, "привлечение к ответственности за нарушение условий лицензирования")
docs4 <- Corpus(DirSource(cname4), readerControl = list(reader = readPDF))
docs <- c(docs1, docs2, docs3, docs4)

# Corpus preprocessing function
preprocessing <- function(doc_corpus) {
  doc_corpus <- tm_map(doc_corpus, content_transformer(tolower)) # convert to lower case
  # replace typographic quotes and dashes that removePunctuation may miss
  doc_corpus <- tm_map(doc_corpus, content_transformer(function(x) gsub("[«»“”„–—−]", " ", x)))
  doc_corpus <- tm_map(doc_corpus, removePunctuation)
  doc_corpus <- tm_map(doc_corpus, removeNumbers) # MAY NOT BE NEEDED IN THE FUTURE!!!
  doc_corpus <- tm_map(doc_corpus, removeWords, stopwords("russian")) # remove stop words before stemming
  doc_corpus <- tm_map(doc_corpus, stripWhitespace) # remove extra whitespace
  doc_corpus <- tm_map(doc_corpus, stemDocument, language = "russian") # stemming
  doc_corpus
}

docs <- preprocessing(docs)

docs_TD_Matrix <- as.matrix(TermDocumentMatrix(docs))

docs_TD_Matrix.lsa <- lw_bintf(docs_TD_Matrix) * gw_idf(docs_TD_Matrix)
lsaSpace_docs <- lsa(docs_TD_Matrix.lsa)
distnce_matrix_lsa_docs <- dist(t(as.textmatrix(lsaSpace_docs)))

fit <- cmdscale(distnce_matrix_lsa_docs, eig = TRUE, k = 2)
points <- data.frame(x = fit$points[, 1], y = fit$points[, 2])
write.csv(points, file = "points.csv")
#ggplot(points, aes(x = x, y = y)) + geom_point(data = points, aes(x = x, y = y, size=5, color = names(docs))) + geom_text(data = points, aes(x = x, y = y - 0.2, label = row.names(docs)))
