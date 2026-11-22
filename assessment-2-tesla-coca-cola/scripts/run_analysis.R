# ECON1195 | Assessment 2 | Tesla and Coca-Cola | 2020-2024
# Portfolio companion reconstruction from the supplied individual R script.
# Not the original submitted script. See docs/validation-and-audit.md.
# Run from the repository root: Rscript assessment-2-tesla-coca-cola/scripts/run_analysis.R
# Required local CSVs in assessment-2-tesla-coca-cola/data/private/ (ignored by Git).
# Prices must be split-adjusted as appropriate. Percentage-point log returns.

required_pkgs <- c('forecast','tseries','FinTS','rugarch')
missing_pkgs <- required_pkgs[!vapply(required_pkgs, requireNamespace, logical(1), quietly=TRUE)]
if (length(missing_pkgs)) stop(paste('Install these packages first:',paste(missing_pkgs,collapse=', ')))
root <- 'assessment-2-tesla-coca-cola'
raw_dir <- file.path(root,'data','private')
out_dir <- file.path(root,'results','generated')
if (!dir.exists(out_dir)) dir.create(out_dir,recursive=TRUE)
paths <- c(TSLA=file.path(raw_dir,'Tesla Stock Price History.csv'),
           KO=file.path(raw_dir,'Coca-Cola Stock Price History.csv'))
missing_files <- paths[!file.exists(paths)]
if (length(missing_files)) stop(paste('Missing local CSV files:',paste(missing_files,collapse=', '),
    '\nRead data/README.md; source files are intentionally not redistributed.'))
parse_dates <- function(x) {
 x <- trimws(as.character(x))
 result <- as.Date(rep(NA_character_,length(x)))
 i1 <- grepl('^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$',x)
 i2 <- grepl('^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$',x)
 i3 <- grepl('^[0-9]{4}-[0-9]{2}-[0-9]{2}$',x)
 result[i1] <- as.Date(x[i1],format='%m-%d-%y')
 result[i2] <- as.Date(x[i2],format='%m/%d/%Y')
 result[i3] <- as.Date(x[i3],format='%Y-%m-%d')
 if(anyNA(result)) stop('Unrecognized date format')
 result
}
read_returns <- function(path,sym) {
 x <- read.csv(path,fileEncoding='UTF-8-BOM',stringsAsFactors=FALSE,check.names=FALSE)
 if(!all(c('Date','Price') %in% names(x)))stop(paste(sym,'missing Date/Price columns'))
 x$Date <- parse_dates(x$Date)
 x$Price <- as.numeric(gsub(',','',as.character(x$Price),fixed=TRUE))
 if(anyNA(x$Price) || any(x$Price<=0))stop(paste(sym,'has invalid price values'))
 x <- x[order(x$Date),c('Date','Price')]
 if(anyDuplicated(x$Date))stop(paste(sym,'has duplicate dates'))
 if(min(x$Date)!=as.Date('2020-01-02') || max(x$Date)!=as.Date('2024-12-31'))
     stop(paste(sym,'does not span 2020-01-02 to 2024-12-31'))
 if(nrow(x)!=1258)stop(paste(sym,'expected 1258 closes, got',nrow(x)))
 data.frame(Date=x$Date[-1],return_pct=100*diff(log(x$Price)))
}
tesla <- read_returns(paths[['TSLA']],'TSLA')
cola  <- read_returns(paths[['KO']],'KO')
if(!identical(tesla$Date,cola$Date))stop('Price-history dates must be aligned; fix sources first')
returns <- list(TSLA=tesla$return_pct,KO=cola$return_pct)
summary_stats <- do.call(rbind,lapply(names(returns),function(sym){
 x<-returns[[sym]]
 data.frame(symbol=sym,n=length(x),mean_pct=mean(x),sd_pct=sd(x),variance_pct2=var(x),
            min_pct=min(x),max_pct=max(x),LB_lag=if(sym=='TSLA')9 else 2,
            LB_p=Box.test(x,lag=if(sym=='TSLA')9 else 2,type='Ljung-Box')$p.value)
}))
write.csv(summary_stats,file.path(out_dir,'return_summary.csv'),row.names=FALSE)

# Fit the same four candidate ARIMA(p,0,q) models that appear in the final report.
candidates <- list(TSLA=list(c(1,0,1),c(1,0,2),c(2,0,1),c(2,0,3)),
                   KO=list(c(0,0,1),c(5,0,4),c(4,0,7),c(6,0,2)))
fitted_arima <- list(); mean_results <- list(); k <- 1
for(sym in names(returns)) {
  fitted_arima[[sym]] <- list()
  for(order in candidates[[sym]]){
    label<-paste0('ARMA(',order[1],',',order[3],')')
    fit <- tryCatch(forecast::Arima(returns[[sym]],order=order,include.mean=TRUE,method='ML'),
                    error=function(e){warning(paste(sym,label,conditionMessage(e)));NULL})
    if(is.null(fit))next
    fitted_arima[[sym]][[label]]<-fit
    # Diagnostic is explicit and uses fitdf, so may differ from the student's
    # checkresiduals() automatic lag and degrees-of-freedom conventions.
    p <- Box.test(residuals(fit),lag=20,type='Ljung-Box',fitdf=order[1]+order[3])$p.value
    mean_results[[k]]<-data.frame(symbol=sym,model=label,AIC=AIC(fit),BIC=BIC(fit),AICc=fit$aicc,
                                   LB_20_adj_p=p,convergence=if(is.null(fit$code))0 else fit$code)
    k<-k+1
  }
}
write.csv(do.call(rbind,mean_results),file.path(out_dir,'arma_model_candidates.csv'),row.names=FALSE)

# Recommended specifications follow the final submitted report, not a fresh search.
selected <- list(TSLA=c(1,1),KO=c(6,2))
vol_models <- list(
  ARCH1=list(type='sGARCH',pq=c(1,0),archm=FALSE),
  ARCH2=list(type='sGARCH',pq=c(2,0),archm=FALSE),
  GARCH11=list(type='sGARCH',pq=c(1,1),archm=FALSE),
  GJR11=list(type='gjrGARCH',pq=c(1,1),archm=FALSE),
  GARCH11_M=list(type='sGARCH',pq=c(1,1),archm=TRUE)
)
vol_rows<-list();j<-1
for(sym in names(returns)) {
  p<-selected[[sym]][1];q<-selected[[sym]][2]
  mean_fit<-fitted_arima[[sym]][[paste0('ARMA(',p,',',q,')')]]
  if(is.null(mean_fit))stop(paste('Required mean model did not fit:',sym))
  cat(sym,'ARCH-LM on mean residuals (12 lags):\n')
  print(FinTS::ArchTest(residuals(mean_fit),lags=12))
  for(nm in names(vol_models)){
    v<-vol_models[[nm]]
    spec<-rugarch::ugarchspec(variance.model=list(model=v$type,garchOrder=v$pq),
                             mean.model=list(armaOrder=c(p,q),include.mean=TRUE,archm=v$archm),
                             distribution.model='norm')
    fit<-tryCatch(rugarch::ugarchfit(spec=spec,data=returns[[sym]],solver='hybrid'),
      error=function(e){warning(paste(sym,nm,conditionMessage(e)));NULL})
    if(is.null(fit))next
    ic<-rugarch::infocriteria(fit)
    z<-as.numeric(residuals(fit,standardize=TRUE))
    archp<-tryCatch(FinTS::ArchTest(z,lags=12)$p.value,error=function(e)NA_real_)
    vol_rows[[j]]<-data.frame(symbol=sym,model=nm,AIC_per_obs=unname(ic[1]),
                              BIC_per_obs=unname(ic[2]),ARCH_LM_standard_resid_p=archp,
                              convergence=fit@fit$convergence)
    j<-j+1
  }
}
write.csv(do.call(rbind,vol_rows),file.path(out_dir,'volatility_models.csv'),row.names=FALSE)
cat('Done: calculated returns, ARMA candidate rankings, and volatility diagnostics.\n')
cat('For published results, compare generated outputs with source report and note solver/package differences.\n')
