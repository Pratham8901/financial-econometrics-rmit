# Financial Econometrics | Assessment 1 | RMIT University
# Companion reconstruction of a completed individual academic project.
# Source price CSVs: Tesla / NVIDIA Investing.com exports, 2020-01-02 through 2024-12-31.
# Source factors: Kenneth French Data Library daily three-factor series.
# Units: all log returns, RF and factors are PERCENTAGE POINTS (not decimals).
# Original submitted script differed in factor scaling; see docs/model-audit.md.
# Requires R 4.2+, packages: moments, vrtest (for optional VR tests).

required_files <- c('data/private/Tesla Stock Price History.csv',
                    'data/private/NVIDIA Stock Price History.csv',
                    'data/private/FF model.csv')
missing <- required_files[!file.exists(required_files)]
if (length(missing) > 0) {
  stop(paste('Missing source CSVs:', paste(missing, collapse=', '),
             '\nSee data/README.md for sourcing. Raw third-party files are not included.'))
}

parse_mixed_dates <- function(d) {
  d <- trimws(as.character(d))
  out <- as.Date(rep(NA_character_, length(d)))
  f1 <- grepl('^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$', d)
  f2 <- grepl('^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$', d)
  f3 <- grepl('^[0-9]{4}-[0-9]{2}-[0-9]{2}$', d)
  out[f1] <- as.Date(d[f1], format='%m-%d-%y')
  out[f2] <- as.Date(d[f2], format='%m/%d/%Y')
  out[f3] <- as.Date(d[f3], format='%Y-%m-%d')
  if (anyNA(out)) stop('Unrecognised date values in price file')
  out
}

read_prices <- function(path, ticker) {
  x <- read.csv(path, fileEncoding='UTF-8-BOM', check.names=FALSE,
                stringsAsFactors=FALSE)
  stopifnot(all(c('Date','Price') %in% names(x)))
  x$Date <- parse_mixed_dates(x$Date)
  x$Price <- as.numeric(gsub(',', '', as.character(x$Price)))
  if (anyNA(x$Price) || any(x$Price <= 0)) stop(paste('Invalid prices:', ticker))
  x <- x[order(x$Date), c('Date','Price')]
  if (anyDuplicated(x$Date)) stop(paste('Duplicate dates:', ticker))
  if (nrow(x) < 2) stop(paste('Too few observations:', ticker))
  # Date t is the DATE OF THE SECOND CLOSE in each pair.
  data.frame(Date=x$Date[-1], ticker=ticker,
             return_pct=100*diff(log(x$Price)))
}

read_factors <- function(path) {
  x <- read.csv(path, check.names=FALSE, fileEncoding='UTF-8-BOM',
                stringsAsFactors=FALSE)
  date_col <- names(x)[1]
  x$Date <- as.Date(as.character(x[[date_col]]), format='%Y%m%d')
  factor_names <- c('Mkt-RF','SMB','HML','RF')
  if (anyNA(x$Date) || !all(factor_names %in% names(x)))
    stop('Invalid French factor file: check dates and column names')
  for (nm in factor_names) x[[nm]] <- as.numeric(as.character(x[[nm]]))
  if (anyNA(x[factor_names])) stop('Missing factor values')
  x <- x[order(x$Date), c('Date',factor_names)]
  if (anyDuplicated(x$Date)) stop('Duplicate factor dates')
  x
}

stock_paths <- c(TSLA=required_files[1], NVDA=required_files[2])
stocks <- lapply(names(stock_paths), function(sym) read_prices(stock_paths[[sym]], sym))
names(stocks) <- names(stock_paths)
ff <- read_factors(required_files[3])

# Match on date BEFORE any hypothesis test or factor regression.
joined <- do.call(rbind, lapply(stocks, function(x) merge(x, ff, by='Date')))
joined <- joined[joined$Date <= as.Date('2024-12-31'),]
if (any(joined$Date > as.Date('2024-12-31'))) stop('2025 look-ahead in training sample')
for (sym in names(stocks)) {
  stopifnot(nrow(joined[joined$ticker==sym,]) == 1257)
}

if (!requireNamespace('moments', quietly=TRUE))
  stop('Please install the moments R package: install.packages("moments")')

stat_rows <- list(); factor_rows <- list(); lb_rows <- list()
for (sym in names(stocks)) {
  dat <- joined[joined$ticker==sym,]
  y <- dat$return_pct
  stat_rows[[sym]] <- data.frame(ticker=sym,observations=length(y),
    mean_daily_pct=mean(y),sd_daily_pct=sd(y),variance_decimal=var(y/100),
    min_pct=min(y),max_pct=max(y),
    skewness=moments::skewness(y), kurtosis=moments::kurtosis(y))
  lags <- if (sym=='TSLA') c(1,9) else c(1,7)
  lb_rows[[sym]] <- do.call(rbind,lapply(lags,function(lg) {
    test <- Box.test(y, lag=lg, type='Ljung-Box')
    data.frame(ticker=sym,lag=lg,statistic=unname(test$statistic),
      p_value=test$p.value)
  }))
  dat$excess_return_pct <- dat$return_pct - dat$RF
  dat$market_excess <- dat[['Mkt-RF']]
  capm <- lm(excess_return_pct ~ market_excess, data=dat)
  ff3 <- lm(excess_return_pct ~ market_excess + SMB + HML, data=dat)
  for (nm in c('CAPM','FF3')) {
    fit <- if (nm=='CAPM') capm else ff3
    co <- coef(fit);sm <- summary(fit)
    factor_rows[[paste(sym,nm,sep='_')]] <- data.frame(
      ticker=sym,model=nm,observations=nrow(dat),
      alpha_daily_pct=unname(co['(Intercept)']),
      market_beta=unname(co['market_excess']),
      smb_loading=if ('SMB' %in% names(co)) unname(co['SMB']) else NA_real_,
      hml_loading=if ('HML' %in% names(co)) unname(co['HML']) else NA_real_,
      r_squared=sm$r.squared,adj_r_squared=sm$adj.r.squared)
  }
  # Optional tests from the original assignment; not needed for CAPM/FF3.
  if (requireNamespace('vrtest',quietly=TRUE)) {
    cat('\n',sym,'Lo–MacKinlay / Chow–Denning tests\n')
    print(vrtest::Lo.Mac(y/100,kvec=c(2,4,8)))
    print(vrtest::Chow.Denning(y/100,k=c(2,5,20)))
  } else {
    message('Optional variance-ratio tests skipped (install.packages("vrtest"))')
  }
}

dir.create('results/generated',recursive=TRUE,showWarnings=FALSE)
write.csv(do.call(rbind,stat_rows),'results/generated/descriptive_statistics.csv',row.names=FALSE)
write.csv(do.call(rbind,factor_rows),'results/generated/factor_regressions.csv',row.names=FALSE)
write.csv(do.call(rbind,lb_rows),'results/generated/ljung_box.csv',row.names=FALSE)
cat('\nCompleted: dates aligned, factor units corrected, no observations after 2024.\n')
