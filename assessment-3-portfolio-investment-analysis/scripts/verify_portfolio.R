# Portfolio reproduction with permitted local CSVs.
# Post-submission, AI-assisted verification script; NOT the RMIT-submitted assessment code.
# Computes portfolio weights and 2025 performance, not native GARCH or VAR estimation.
# R base only, deliberately has no install.packages() side-effects.

args <- commandArgs(trailingOnly = TRUE)
script_paths <- commandArgs(trailingOnly = FALSE)
file_arg <- script_paths[startsWith(script_paths, "--file=")]
if (length(file_arg)) {
  this_file <- normalizePath(sub("^--file=", "", file_arg[1]))
  root <- dirname(dirname(this_file))
} else {
  root <- getwd()
}
data_dir <- if (length(args)) args[1] else file.path(root, "data", "private")
read_prices <- function(filename) {
  path <- file.path(data_dir, filename)
  if (!file.exists(path)) stop(paste("Required local file missing:", path))
  df <- read.csv(path, fileEncoding = "UTF-8-BOM", check.names = FALSE)
  if (!all(c("Date", "Price") %in% names(df))) stop("Missing Date or Price column")
  strings <- trimws(as.character(df$Date))
  dates <- as.Date(rep(NA_character_,length(strings)))
  fmts <- c("%m-%d-%y", "%m/%d/%Y", "%Y-%m-%d")
  for (fmt in fmts) {
    missing <- is.na(dates)
    dates[missing] <- as.Date(strings[missing], format=fmt)
  }
  if (anyNA(dates)) stop(paste("Unparseable dates in", filename))
  prices <- as.numeric(gsub(",", "", as.character(df$Price)))
  if (anyNA(prices) || any(prices<=0)) stop(paste("Invalid prices in", filename))
  x <- data.frame(Date=dates,Price=prices)
  x <- x[order(x$Date),,drop=FALSE]
  if(anyDuplicated(x$Date)) stop(paste("Duplicate dates in", filename))
  rownames(x) <- NULL
  x
}
align <- function(x,y) {
  if(!identical(x$Date,y$Date)) stop("Price-history dates are not aligned")
  invisible(TRUE)
}
t <- read_prices("Tesla Stock Price History(3).csv")
c <- read_prices("Coca-Cola Stock Price History(2).csv")
align(t,c)
stopifnot(nrow(t)==1258, min(t$Date)==as.Date("2020-01-02"),
          max(t$Date)==as.Date("2024-12-31"))
rt <- 100 * diff(log(t$Price))
rc <- 100 * diff(log(c$Price))
vt <- var(rt); vc <- var(rc); covtc <- cov(rt,rc)
w <- (vc - covtc) / (vt + vc - 2*covtc)
w <- max(0, min(1, w))
cat(sprintf("Minimum-variance Tesla weight: %.8f\n",w))
cat(sprintf("Return correlation: %.6f\n",cor(rt,rc)))

t25 <- read_prices("Tesla Stock Price History 2025(1).csv")
c25 <- read_prices("Coca-Cola Stock Price History 2025(1).csv")
align(t25,c25)
stopifnot(nrow(t25)==251, min(t25$Date)==as.Date("2024-12-31"),
          max(t25$Date)==as.Date("2025-12-31"))
stopifnot(t25$Price[1]==tail(t$Price,1), c25$Price[1]==tail(c$Price,1))
buy_hold <- function(weight) 1500000 * (weight*t25$Price/t25$Price[1] +
                                        (1-weight)*c25$Price/c25$Price[1])
for (label in c("Recommended 4.4% TSLA", "Equal-weighted")) {
  weight <- if(grepl("Recommended", label)) .044 else .5
  v <- buy_hold(weight)
  annual_risk <- sd(weight*rt + (1-weight)*rc)*sqrt(250)
  realized_risk <- sd(100*diff(log(v)))*sqrt(250)
  mdd <- min(v/cummax(v)-1)*100
  cat(sprintf("%s: final A$%.2f, return %.4f%%, hist vol %.4f%%, 2025 vol %.4f%%, max DD %.4f%%\n",
              label,tail(v,1),100*(tail(v,1)/1500000-1),annual_risk,realized_risk,mdd))
}
