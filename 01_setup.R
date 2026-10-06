# Run once in RStudio with Assignment2 as the working directory.
packages <- c("quantmod", "TTR", "xts", "zoo")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
for (p in packages) cat(p, as.character(packageVersion(p)), "\n")
sessionInfo()
