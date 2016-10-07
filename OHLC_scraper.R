# This R script downloads stock tickers and saves each as a CSV file
# http://www.thertrader.com/2015/12/13/maintaining-a-database-of-price-files-in-r/
# 10/02/2016
# ETF Metadata Scraper
# This program scrapes ETF metadata from ETFDB

rm(list=ls())
library(readxl)
library(quantmod)
library(R.utils) # for countlines

directory = "D:/Github/DataDrivenTrading/"
data_path = "D:/Github/DataDrivenTrading/Data/OHLC/"

setwd(directory)

# Reads in last update information
#df.log = read.table("log.csv",header = TRUE,sep = ",", stringsAsFactors=F)

# Load list of target instruments
df.source <- data.frame(read_excel("etfdb_data.xls"))

# Delete all irrelevant columns
df.target = within(df.source,rm(name,etfdb.category,inception.date,expense.ratio,commission.free,expenses.rating))

# Create another column to keep track of its existence in folder
df.target["exists"] = rep(NA,nrow(df.target))

# Check folder to determine which instruments have been scraped
existing.files = list.files("./Data/OHLC",full.names = FALSE) # fetch list of all files from folder
existing.files = gsub(".csv","",existing.files) # remove ".csv" from vector of characters

# Perform comparisons to determine if target instrument exists and if it is updated
for (i in 1:nrow(df.target)){
  df.target$exists[i] = df.target$symbol[i] %in% existing.files
}

# Recreate log
df.log = data.frame("fetched.symbol" = character(),
                   "fetched.date" = as.Date(character()),
                  "fetched.status" = character(),
                 stringsAsFactors=FALSE)

# For each symbol among the target symbols, perform teh following action according to the situation:

# If target exists and the target is updated, do nothing
# If target exists and the target is not updated, append data to existing CSV from last fetched date
# If target does not exist, scrape
for (i in 1:nrow(df.target)){
  tryCatch({
    ticker = df.target$symbol[i]
    target.exists = df.target$exists[i]
    file_path = paste(data_path,ticker,".csv",sep = "")
    skipLines = countLines(file_path)
    date.fetched = try(as.Date(as.matrix(read.csv(file_path,nrows = 1,skip = skipLines-1, header = FALSE)[1])))
    
    if (target.exists == TRUE & (Sys.Date() - 1) != date.fetched){
      startDate = date.fetched
      data = getSymbols(Symbols = ticker,
                        src = "yahoo",
                        from = startDate,
                        auto.assign = FALSE)
      write.zoo(data,paste(data_path,ticker,".csv",sep = ""), append = TRUE, sep = ",",col.names = FALSE)
      #df.log[nrow(df.log) + 1,] =c(df.target$symbol[i],as.character(Sys.Date()),"success")
    }
    
    if (target.exists == FALSE){
      ticker = df.target$symbol[i]
      data = getSymbols(Symbols = ticker,
                        src = "yahoo",
                        auto.assign = FALSE)
      colnames(data) = c("open","high","low","close","volume","adjusted")
      write.zoo(data,paste(data_path,ticker,".csv",sep = ""),sep=",",row.names=FALSE) # sep = "" to get rid of space in paste operations
      
      # when successful write status to log
      #df.log[nrow(df.log) + 1,] =c(df.target$symbol[i],as.character(Sys.Date()),"success")
    }
    
  },
  # when there is an error, write error 
  error = function(e) {
    df.log[nrow(df.log) + 1,] =c(df.target$symbol[i],as.character(Sys.Date()),"failure")
  })
}


# write.csv(df.log,file = "log.csv",row.names=FALSE)