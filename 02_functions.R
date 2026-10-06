# Every stock is a separate data frame in a named list (stocks[["AAPL"]]).
load_stock_data <- function(portfolio_file = "portfolio.txt",
                            from = "2025-01-01", to = "2026-01-01") {
  if (!requireNamespace("quantmod", quietly = TRUE)) stop("Run 01_setup.R first.")
  if (!file.exists(portfolio_file)) stop("Portfolio file not found.")
  from <- as.Date(from); to <- as.Date(to)
  if (is.na(from) || is.na(to) || from >= to) stop("Invalid date range.")
  symbols <- unique(toupper(trimws(readLines(portfolio_file, warn = FALSE))))
  symbols <- symbols[nzchar(symbols) & !startsWith(symbols, "#")]
  if (!length(symbols)) stop("Portfolio is empty.")
  stocks <- list(); failures <- character()
  for (symbol in symbols) {
    tryCatch({
      x <- quantmod::getSymbols(symbol, src = "yahoo", from = from,
                               to = to, auto.assign = FALSE)
      if (!NROW(x)) stop("No observations returned.")
      d <- data.frame(Date = as.Date(zoo::index(x)),
                      Open = as.numeric(quantmod::Op(x)),
                      High = as.numeric(quantmod::Hi(x)),
                      Low = as.numeric(quantmod::Lo(x)),
                      Close = as.numeric(quantmod::Cl(x)),
                      Volume = as.numeric(quantmod::Vo(x)),
                      Adjusted = as.numeric(quantmod::Ad(x)))
      d <- d[order(d$Date), ]
      d <- d[!duplicated(d$Date), ]
      stocks[[symbol]] <- d
    }, error = function(e) {
      failures[symbol] <<- conditionMessage(e)
      warning(paste(symbol, conditionMessage(e)), call. = FALSE)
    })
  }
  if (!length(stocks)) stop("All downloads failed. Check symbols and internet access.")
  attr(stocks, "failures") <- failures
  stocks
}

# R's mode() returns storage type; this utility computes statistical modes.
# Round prices to cents. Return all tied modes; all-unique data has no mode.
price_modes <- function(x) {
  x <- round(x[is.finite(x)], 2)
  if (!length(x)) return(numeric())
  values <- sort(unique(x)); counts <- tabulate(match(x, values))
  if (max(counts) == 1L) return(numeric())
  values[counts == max(counts)]
}

calculate_statistics <- function(stock_df, symbol = "Stock", window = 20L) {
  if (!all(c("Date", "Adjusted") %in% names(stock_df))) stop("Missing required columns.")
  if (length(window) != 1L || !is.finite(window) || window < 1 || window != floor(window))
    stop("Window must be a positive integer.")
  if (is.unsorted(stock_df$Date)) stop("Sort the data by Date first.")
  # Missing prices are excluded; SMA uses the last window valid trading observations.
  valid <- is.finite(stock_df$Adjusted)
  prices <- stock_df$Adjusted[valid]
  if (!length(prices)) stop("No valid adjusted prices.")
  sma <- rep(NA_real_, nrow(stock_df))
  if (length(prices) >= window) sma[valid] <- as.numeric(TTR::SMA(prices, n = window))
  modes <- price_modes(prices)
  output <- stock_df; output$SMA <- sma
  summary <- data.frame(Symbol = symbol, Observations = length(prices),
    MissingPrices = sum(!valid), StartDate = min(stock_df$Date[valid]),
    EndDate = max(stock_df$Date[valid]), Mean = mean(prices),
    Mode = if (length(modes)) paste(format(modes, nsmall = 2), collapse = "; ") else "No mode",
    Median = median(prices), SD = if (length(prices) > 1) sd(prices) else NA_real_,
    SMAWindow = window, LatestSMA = tail(sma[valid], 1),
    stringsAsFactors = FALSE)
  list(summary = summary, data = output)
}
