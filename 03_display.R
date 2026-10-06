display_stock_data <- function(stocks, rows = 6L) {
  for (symbol in names(stocks)) {
    cat("\n", symbol, "—", nrow(stocks[[symbol]]), "observations\n")
    print(head(stocks[[symbol]], rows)); print(tail(stocks[[symbol]], rows))
    str(stocks[[symbol]])
  }
  invisible(stocks)
}

display_statistics <- function(results) {
  table <- do.call(rbind, lapply(results, function(x) x$summary))
  rownames(table) <- NULL
  print(table, row.names = FALSE, digits = 4)
  invisible(table)
}

plot_stock_data <- function(results, output_dir = "output") {
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  for (symbol in names(results)) {
    d <- results[[symbol]]$data
    png(file.path(output_dir, paste0(symbol, "_price_SMA.png")),
        width = 1400, height = 850, res = 140)
    tryCatch({
      plot(d$Date, d$Adjusted, type = "l", col = "#245C85", lwd = 2,
           main = paste(symbol, "Adjusted price and moving average"),
           xlab = "Trading date", ylab = "Adjusted price (USD)")
      lines(d$Date, d$SMA, col = "#D96B28", lwd = 2)
      legend("topleft", c("Adjusted price", paste0(results[[symbol]]$summary$SMAWindow, "-observation SMA")),
             col = c("#245C85", "#D96B28"), lty = 1, bty = "n")
      grid()
    }, finally = dev.off())
  }
  png(file.path(output_dir, "portfolio_normalized.png"), width = 1400, height = 850, res = 140)
  tryCatch({
    series <- lapply(results, function(x) x$data[c("Date", "Adjusted")])
    for (i in seq_along(series)) names(series[[i]])[2] <- names(results)[i]
    aligned <- Reduce(function(a, b) merge(a, b, by = "Date"), series)
    aligned <- aligned[complete.cases(aligned), ]
    if (nrow(aligned) < 2) stop("Too few common dates for comparison.")
    prices <- as.matrix(aligned[-1])
    if (any(prices[1, ] == 0)) stop("Cannot normalize a zero starting price.")
    normalized <- sweep(prices, 2, prices[1, ], "/") * 100
    colors <- grDevices::hcl.colors(ncol(prices), "Dark 3")
    matplot(aligned$Date, normalized, type = "l", lty = 1, lwd = 2, col = colors,
            main = "Portfolio comparison on common trading dates", xlab = "Date",
            ylab = "Adjusted price index (first common date = 100)")
    legend("topleft", names(results), col = colors, lty = 1, bty = "n"); grid()
  }, finally = dev.off())
}
