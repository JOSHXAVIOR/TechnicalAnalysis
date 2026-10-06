# TechnicalAnalysis — BDA400 Assignment 2
Student: Joseph Tenneti

## Run
1. Install R from https://cran.r-project.org/ and RStudio Desktop from https://posit.co/download/rstudio-desktop/.
2. Extract the package. Open Assignment2/Assignment2.Rproj in RStudio.
3. Run source("01_setup.R") in the console.
4. Run source("05_check_statistics.R") to check known statistics.
5. Run source("04_run_analysis.R") with internet access.
6. Check output/download_failures.csv; the final submission should include all five stocks. Correct failures and rerun before submitting.
7. Insert your genuine screenshots, actual output table/charts, student ID, instructor, submission date and repository URL into the Word report.
8. Create a GitHub repository named TechnicalAnalysis and upload this folder structure. Include future course assignments in their own folders.

## Files
01_setup.R: dependencies and versions
02_functions.R: downloads and statistics
03_display.R: tables and charts
04_run_analysis.R: main workflow and output export
05_check_statistics.R: offline known-value checks
portfolio.txt: five US stock symbols
Assignment2.Rproj: RStudio project
JosephTenneti_BDA400_A02.docx: editable report and cover page

## Scope and validation
The analysis period is 2025-01-01 to 2026-01-01 (Yahoo end date is exclusive), with a 20-observation SMA. Data are Yahoo Finance daily OHLCV and adjusted prices; no live data or analysis output is included in this prepared package. R was unavailable in the preparation environment, so R scripts and checks have not been executed. Do not claim local installation or completed runs until you have done them. Screenshot boxes in the report are instructions, not evidence.

Statistics use adjusted prices. Mode uses prices rounded to cents, returns all ties, and says No mode when all values are unique. SD is sample SD (n-1). Missing adjusted prices are excluded; SMA uses valid trading observations rather than calendar days. Stocks are independent data frames in a named list. Comparison charts align dates before normalizing each series to 100. Descriptive price statistics are not return volatility or portfolio-weighted results.
