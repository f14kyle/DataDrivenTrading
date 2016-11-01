# This calculates all risk and return metrics and saves it as df.lazy.  Formerly known as stock_screener3

rm(list=ls())

# Load libraries
library(quantmod)
library(PerformanceAnalytics)
library(openxlsx)
library(ggplot2)
library(gridExtra)
library(scales)
library(RColorBrewer)
library(reshape2)
library(rPref)

setwd("/Volumes/DATA/Github/DataDrivenTrading")
#setwd("C:/UserData/DataDrivenTrading/portfolio_selection")

filename.lazy = "lazy_portfolios.xlsx"

# Set timeframes
timeframe.codes = c("2016","2015","2014","2013","2012","2011","2010","2009","2008","2007")
timeframe.count = length(timeframe.codes)

# Set rebalance periods
rebalance.periods = c("None","Monthly","Quarterly","Yearly")
rebalance.count = length(rebalance.periods)

# Set lazy portfolio names
portfolio.lazy.names = c("Aronson Family Taxable","Fundadvice Ultimate Buy & Hold","Coffeehouse","Margaritaville","Dr. Bernstein's No Brainer","Second Graders Starter","Dr. Bernstein's Smart Money","Yale Us Unconventional","Bogleheads 3 Funds","Bogleheads 4 Funds","Harry Browne Permanent","Swedroe Simple Portfolio","Swedroe Minimize Fat Tails","Mebane Faber Ivy","Rick Ferri Core Four","Scott Burns Couch","Stocks/Bonds 60/40","Stocks/Bonds 40/60")
portfolio.lazy.count = length(portfolio.lazy.names)

#MAR = c(0.00,0.01,0.02,0.03,0.04,0.05,0.06)
#MAR.count = length(MAR)


# Load from Vanguard XLSX
tickers.lazy.symbs = read.xlsx(filename.lazy,sheet = 1,startRow = 1,skipEmptyRows = TRUE,cols = 1)
tickers.lazy.count = nrow(tickers.lazy.symbs)
tickers.lazy.names = read.xlsx(filename.lazy,sheet = 1,startRow = 1,skipEmptyRows = TRUE,cols = 10)

# Load weights of stocks that comprise each portfolio
# rows = weights
# cols = portfolios 
weights.lazy = matrix(0,nrow = tickers.lazy.count, ncol = portfolio.lazy.count)
for (i in 1:portfolio.lazy.count){
  # Create vector of weights of each ticker within each lazy portfolio
  weights.lazy[,i] = unlist(read.xlsx(filename.lazy,sheet = 1,startRow = 1,skipEmptyRows = FALSE,cols = 1 + i))
}




# Obtain all stock closing prices for holdings within lazy portfolio
for (i in 1:tickers.lazy.count){
  try(getSymbols(tickers.lazy.symbs[i,], src = "yahoo"))
}

# Create data matrix statement for lazy portfolios
tickers.lazy.zoo = "merge("
for (i in 1:tickers.lazy.count){
  tickers.lazy.zoo = paste(tickers.lazy.zoo,tickers.lazy.symbs[i,],"[,6],",sep = "")
}
tickers.lazy.zoo = paste(tickers.lazy.zoo,")",sep = "")
tickers.lazy.zoo = substr(tickers.lazy.zoo,1,nchar(tickers.lazy.zoo)-2)
tickers.lazy.zoo = paste(tickers.lazy.zoo,")",sep = "")

# Save adjusted closing prices to zoo matrix
all.lazy.stocks = eval(parse(text = tickers.lazy.zoo))

# Rename column names to not have the .Adjusted in the back
for (i in 1:tickers.lazy.count){
  names(all.lazy.stocks)[i] = tickers.lazy.symbs[i,]
}

######################################################################################

# Create a list to hold all lazy stock returns for all timeframes
#returns.lazy.stocks.1 = na.omit(Return.calculate(last(all.lazy.stocks,'1 year')))
#returns.lazy.stocks.3 = na.omit(Return.calculate(last(all.lazy.stocks,'3 years')))
#returns.lazy.stocks.5 = na.omit(Return.calculate(last(all.lazy.stocks,'5 years')))
#returns.lazy.stocks.ytd = na.omit(Return.calculate(all.lazy.stocks['::']))
#returns.lazy.stocks = list(returns.lazy.stocks.1,returns.lazy.stocks.3,returns.lazy.stocks.5,returns.lazy.stocks.ytd)

# Create function for calculating the portfolio returns for a given set of weights and rebalancing period

# index.port [1:8] selects the lazy portfolio (loop through column)
# index.ival [1:4] selects the portfolo rebalance interval (loop through list)

# Create lists of all stocks returns for each timeframe.

returns.lazy.stocks = vector("list",10)
returns.lazy.stocks[[1]] = na.omit(last(Return.calculate(all.lazy.stocks),'1 year'))
returns.lazy.stocks[[2]] = na.omit(last(Return.calculate(all.lazy.stocks),'2 year'))
returns.lazy.stocks[[3]] = na.omit(last(Return.calculate(all.lazy.stocks),'3 year'))
returns.lazy.stocks[[4]] = na.omit(last(Return.calculate(all.lazy.stocks),'4 year'))
returns.lazy.stocks[[5]] = na.omit(last(Return.calculate(all.lazy.stocks),'5 year'))
returns.lazy.stocks[[6]] = na.omit(last(Return.calculate(all.lazy.stocks),'6 year'))
returns.lazy.stocks[[7]] = na.omit(last(Return.calculate(all.lazy.stocks),'7 year'))
returns.lazy.stocks[[8]] = na.omit(last(Return.calculate(all.lazy.stocks),'8 year'))
returns.lazy.stocks[[9]] = na.omit(last(Return.calculate(all.lazy.stocks),'9 year'))
returns.lazy.stocks[[10]] = na.omit(last(Return.calculate(all.lazy.stocks),'10 year'))

# Initialize lists of all portfolio returns for each timeframe.
returns.lazy.none = vector("list",3)
returns.lazy.yearly = vector("list",3)
returns.lazy.monthly = vector("list",3)
returns.lazy.quarterly = vector("list",3)
cagr.lazy = vector("list",3)
sd.lazy = vector("list",3)
dd.lazy = vector("list",3)
md.lazy = vector("list",3)
pi.lazy = vector("list",3)


for (i in 1:timeframe.count){
  returns.lazy.none[[i]] = as.xts(matrix(0,nrow = nrow(returns.lazy.stocks[[i]]), ncol = portfolio.lazy.count),order.by = index(returns.lazy.stocks[[i]]))
  returns.lazy.yearly[[i]] = as.xts(matrix(0,nrow = nrow(returns.lazy.stocks[[i]]), ncol = portfolio.lazy.count),order.by = index(returns.lazy.stocks[[i]]))
  returns.lazy.quarterly[[i]] = as.xts(matrix(0,nrow = nrow(returns.lazy.stocks[[i]]), ncol = portfolio.lazy.count),order.by = index(returns.lazy.stocks[[i]]))
  returns.lazy.monthly[[i]] = as.xts(matrix(0,nrow = nrow(returns.lazy.stocks[[i]]), ncol = portfolio.lazy.count),order.by = index(returns.lazy.stocks[[i]]))
  cagr.lazy[[i]] = matrix(0,nrow = portfolio.lazy.count, ncol = 6)
  sd.lazy[[i]] = matrix(0,nrow = portfolio.lazy.count, ncol = 6)
  dd.lazy[[i]] = matrix(0,nrow = portfolio.lazy.count, ncol = 6)
  md.lazy[[i]] = matrix(0,nrow = portfolio.lazy.count, ncol = 6)
  pi.lazy[[i]] = matrix(0,nrow = portfolio.lazy.count, ncol = 6)
}

for (i in 1:timeframe.count){
  
  for (j in 1:portfolio.lazy.count){
    # Calculate daily returns of each lazy portfolio
    # List = timeframes
    # Rows = returns timeseries
    # Cols = portfolios
    returns.lazy.none[[i]][,j]   = Return.portfolio(returns.lazy.stocks[[i]],weights = weights.lazy[,j],geometric = TRUE,rebalance_on = NA)
    returns.lazy.yearly[[i]][,j]    = Return.portfolio(returns.lazy.stocks[[i]],weights = weights.lazy[,j],geometric = TRUE,rebalance_on = "years")
    returns.lazy.quarterly[[i]][,j]   = Return.portfolio(returns.lazy.stocks[[i]],weights = weights.lazy[,j],geometric = TRUE,rebalance_on = "quarters")
    returns.lazy.monthly[[i]][,j] = Return.portfolio(returns.lazy.stocks[[i]],weights = weights.lazy[,j],geometric = TRUE,rebalance_on = "months")
    
    # List = timeframes
    # Rows = portfolios
    # Cols = rebalance periods
    cagr.lazy[[i]][j,1] = Return.annualized(returns.lazy.none[[i]][,j], scale = NA, geometric = TRUE) 
    cagr.lazy[[i]][j,2] = Return.annualized(returns.lazy.yearly[[i]][,j], scale = NA, geometric = TRUE) 
    cagr.lazy[[i]][j,3] = Return.annualized(returns.lazy.quarterly[[i]][,j], scale = NA, geometric = TRUE) 
    cagr.lazy[[i]][j,4] = Return.annualized(returns.lazy.monthly[[i]][,j], scale = NA, geometric = TRUE) 
    cagr.lazy[[i]][j,5] = timeframe.codes[i]
    cagr.lazy[[i]][j,6] = portfolio.lazy.names[j]
    
    # List = timeframes
    # Rows = portfolios
    # Cols = rebalance periods
    sd.lazy[[i]][j,1] = StdDev(returns.lazy.none[[i]][,j])
    sd.lazy[[i]][j,2] = StdDev(returns.lazy.yearly[[i]][,j])
    sd.lazy[[i]][j,3] = StdDev(returns.lazy.quarterly[[i]][,j])
    sd.lazy[[i]][j,4] = StdDev(returns.lazy.monthly[[i]][,j])
    sd.lazy[[i]][j,5] = timeframe.codes[i]
    sd.lazy[[i]][j,6] = portfolio.lazy.names[j]
    
    # List = timeframes
    # Rows = portfolios
    # Cols = rebalance periods
    dd.lazy[[i]][j,1] = DownsideDeviation(returns.lazy.none[[i]][,j], MAR = 0,method = "subset")
    dd.lazy[[i]][j,2] = DownsideDeviation(returns.lazy.yearly[[i]][,j], MAR = 0,method = "subset")
    dd.lazy[[i]][j,3] = DownsideDeviation(returns.lazy.quarterly[[i]][,j], MAR = 0,method = "subset")
    dd.lazy[[i]][j,4] = DownsideDeviation(returns.lazy.monthly[[i]][,j], MAR = 0,method = "subset")
    dd.lazy[[i]][j,5] = timeframe.codes[i]
    dd.lazy[[i]][j,6] = portfolio.lazy.names[j]
    
    # List = timeframes
    # Rows = portfolios
    # Cols = rebalance periods
    md.lazy[[i]][j,1] = maxDrawdown(returns.lazy.none[[i]][,j], geometric = TRUE, invert = TRUE)
    md.lazy[[i]][j,2] = maxDrawdown(returns.lazy.yearly[[i]][,j], geometric = TRUE, invert = TRUE)
    md.lazy[[i]][j,3] = maxDrawdown(returns.lazy.quarterly[[i]][,j], geometric = TRUE, invert = TRUE)
    md.lazy[[i]][j,4] = maxDrawdown(returns.lazy.monthly[[i]][,j], geometric = TRUE, invert = TRUE)
    md.lazy[[i]][j,5] = timeframe.codes[i]
    md.lazy[[i]][j,6] = portfolio.lazy.names[j]
    
    # List = timeframes
    # Rows = portfolios
    # Cols = rebalance periods
    pi.lazy[[i]][j,1] = PainIndex(returns.lazy.none[[i]][,j], geometric = TRUE, invert = TRUE)
    pi.lazy[[i]][j,2] = PainIndex(returns.lazy.yearly[[i]][,j], geometric = TRUE, invert = TRUE)
    pi.lazy[[i]][j,3] = PainIndex(returns.lazy.quarterly[[i]][,j], geometric = TRUE, invert = TRUE)
    pi.lazy[[i]][j,4] = PainIndex(returns.lazy.monthly[[i]][,j], geometric = TRUE, invert = TRUE)
    pi.lazy[[i]][j,5] = timeframe.codes[i]
    pi.lazy[[i]][j,6] = portfolio.lazy.names[j]
    
  }
}

# Save portfolio returns
save(data = returns.lazy.yearly, file = "returns.rda")

# Construct melted dataframe out of cagr.lazy
df.cagr.lazy = data.frame()
for (i in 1:timeframe.count){
  df.cagr.lazy = rbind(df.cagr.lazy,data.frame(cagr.lazy[[i]]))
}
colnames(df.cagr.lazy) = c("None","Yearly","Quarterly","Monthly","Timeframe","Name")
df.cagr.lazy = melt(df.cagr.lazy, id = c("Timeframe","Name"))
colnames(df.cagr.lazy) = c("Timeframe","Name","Rebalance.Period","CAGR")

# Construct melted dataframe out of sd.lazy results
df.sd.lazy = data.frame()
for (i in 1:timeframe.count){
  df.sd.lazy = rbind(df.sd.lazy,data.frame(sd.lazy[[i]]))
}
colnames(df.sd.lazy) = c("None","Yearly","Quarterly","Monthly","Timeframe","Name")
df.sd.lazy = melt(df.sd.lazy, id = c("Timeframe","Name"))
colnames(df.sd.lazy) = c("Timeframe","Name","Rebalance.Period","SD")

# Construct melted dataframe out of dd.lazy results
df.dd.lazy = data.frame()
for (i in 1:timeframe.count){
  df.dd.lazy = rbind(df.dd.lazy,data.frame(dd.lazy[[i]]))
}
colnames(df.dd.lazy) = c("None","Yearly","Quarterly","Monthly","Timeframe","Name")
df.dd.lazy = melt(df.dd.lazy, id = c("Timeframe","Name"))
colnames(df.dd.lazy) = c("Timeframe","Name","Rebalance.Period","DD")

# Construct melted dataframe out of md.lazy results
df.md.lazy = data.frame()
for (i in 1:timeframe.count){
  df.md.lazy = rbind(df.md.lazy,data.frame(md.lazy[[i]]))
}
colnames(df.md.lazy) = c("None","Yearly","Quarterly","Monthly","Timeframe","Name")
df.md.lazy = melt(df.md.lazy, id = c("Timeframe","Name"))
colnames(df.md.lazy) = c("Timeframe","Name","Rebalance.Period","MD")

# Construct melted dataframe out of pi.lazy results
df.pi.lazy = data.frame()
for (i in 1:timeframe.count){
  df.pi.lazy = rbind(df.pi.lazy,data.frame(pi.lazy[[i]]))
}
colnames(df.pi.lazy) = c("None","Yearly","Quarterly","Monthly","Timeframe","Name")
df.pi.lazy = melt(df.pi.lazy, id = c("Timeframe","Name"))
colnames(df.pi.lazy) = c("Timeframe","Name","Rebalance.Period","PI")




# Combine cagr.lazy and dd.lazy datamframes
df.lazy = cbind(df.cagr.lazy,df.sd.lazy$SD,df.dd.lazy$DD,df.md.lazy$MD,df.pi.lazy$PI)
colnames(df.lazy) = c("Timeframe","Name","Rebalance.Period","CAGR","SD","DD","MD","PI")
save(data = df.lazy,file = "df_lazy.rda")

####################################
# Calculate paretos for CAGR vs DD


pareto.dd.yearly = vector("list", 4)
# Select correct timeframe in df.lazy based on timeframe and rebalance period
df.lazy.yearly = subset(df.lazy,Rebalance.Period == "Yearly")
timeframe.selector = sapply(timeframe.codes, function(x) grepl(x,df.lazy.yearly$Timeframe))


for (i in 1:timeframe.count){
    pareto.dd.yearly[[i]] = psel(df.lazy.yearly[as.array(timeframe.selector[,i]),],high(as.numeric(CAGR)) * low(as.numeric(DD)), top_level = 3)
}

df.pareto.dd = data.frame()
for (i in 1:timeframe.count){
  df.pareto.dd = rbind(df.pareto.dd,data.frame(pareto.dd.yearly[[i]]))
}

save(data = df.pareto.dd,file = "df_pareto_dd.rda")

####################################
# Calculate paretos for CAGR vs pi


pareto.pi.yearly = vector("list", 4)
# Select correct timeframe in df.lazy based on timeframe and rebalance period
df.lazy.yearly = subset(df.lazy,Rebalance.Period == "Yearly")
timeframe.selector = sapply(timeframe.codes, function(x) grepl(x,df.lazy.yearly$Timeframe))


for (i in 1:timeframe.count){
  pareto.pi.yearly[[i]] = psel(df.lazy.yearly[as.array(timeframe.selector[,i]),],high(as.numeric(CAGR)) * low(as.numeric(PI)), top_level = 3)
}

df.pareto.pi = data.frame()
for (i in 1:timeframe.count){
  df.pareto.pi = rbind(df.pareto.pi,data.frame(pareto.pi.yearly[[i]]))
}

save(data = df.pareto.pi,file = "df_pareto_pi.rda")

##################################### Calculate cumprod all of the portfolios
cumprod.returns = cumprod(1 + returns.lazy.yearly[[10]])

df.returns = data.frame(date = index(cumprod.returns),cumprod.returns,stringsAsFactors = FALSE)
colnames(df.returns) = c("date",portfolio.lazy.names)

df.returns = df.returns[c('date','Harry Browne Permanent','Rick Ferri Core Four','Scott Burns Couch','Second Graders Starter','Stocks/Bonds 60/40','Stocks/Bonds 40/60','Swedroe Simple Portfolio','Yale Us Unconventional')]

df.returns.melted = melt(df.returns, id = c("date"))

ggplot(data = df.returns.melted) + 
  geom_line(aes(x = date,y = value,color = variable))

