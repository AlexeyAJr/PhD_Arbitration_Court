# Load required library
library(readtext)

# Folder containing this script (RStudio or Rscript), fallback: working directory
script_dir <- tryCatch(
  dirname(rstudioapi::getSourceEditorContext()$path),
  error = function(e) {
    f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
    if (length(f)) dirname(normalizePath(f)) else getwd()
  }
)
if (!nzchar(script_dir)) script_dir <- getwd()

corpus_dir <- file.path(script_dir, "Categories")
output_csv <- file.path(script_dir, "df2.csv")

# All folders (also nested ones) whose name starts with a number and that contain PDFs 
# from https://ras.arbitr.ru/
all_dirs   <- list.dirs(corpus_dir, recursive = TRUE, full.names = TRUE)
class_dirs <- all_dirs[grepl("^[0-9]", basename(all_dirs)) &
                       vapply(all_dirs, function(d) length(list.files(d, pattern = "\\.pdf$", ignore.case = TRUE)) > 0, logical(1))]

# Class label = leading number from the folder name: "1", "1.1", "1.2.1", ...
# (kept as text, so "1.10" is not confused with "1.1")
class_labels <- sub("^([0-9]+(\\.[0-9]+)*).*$", "\\1", basename(class_dirs))

# Read PDFs of every class folder and assign the label to each document
df <- do.call(rbind, Map(function(dir_path, label) {
  docs <- as.data.frame(readtext(file.path(dir_path, "*.pdf")), stringsAsFactors = FALSE)
  docs$class <- label
  docs[, c("doc_id", "text", "class")]
}, class_dirs, class_labels))
rownames(df) <- NULL

# Save: separator ";", encoding windows-1251
write.table(df, output_csv, sep = ";", row.names = FALSE, fileEncoding = "windows-1251")
