# Offline checks with known values; does not download market data.
source("02_functions.R")
stopifnot(identical(price_modes(c(1, 2, 2, 3)), 2),
          identical(price_modes(c(1, 1, 2, 2)), c(1, 2)),
          length(price_modes(1:4)) == 0L)
d <- data.frame(Date = as.Date("2025-01-01") + 0:3, Adjusted = c(1, 2, 2, 3))
r <- calculate_statistics(d, "TEST", 2L)
stopifnot(r$summary$Mean == 2, r$summary$Median == 2,
          abs(r$summary$SD - sqrt(2/3)) < 1e-10,
          isTRUE(all.equal(r$data$SMA, c(NA_real_, 1.5, 2, 2.5))))
cat("Statistics checks passed.\n")
