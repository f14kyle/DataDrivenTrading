# This R script downloads stock tickers and saves each as a CSV file
# http://www.thertrader.com/2015/12/13/maintaining-a-database-of-price-files-in-r/
# 10/02/2016
# ETF Metadata Scraper
# This program scrapes ETF metadata from ETFDB

scrapeOHLC = function(df.target){

rm(list=ls())
library(readxl)
library(quantmod)
library(R.utils) # for countlines

directory = "/Volumes/DATA/Github/LazyPortfolioAnalytics"
data_path = "/Volumes/DATA/Dropbox/Data/LazyPortfolioAnalytics/OHLC/"

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
df.log = data.frame("fetched.symbol" = "",
                   "fetched.date" = "",
                  "fetched.status" = "",
                 stringsAsFactors=FALSE)

# For each symbol among the target symbols, perform the following action according to the situation:

# If target exists and if data is recent, do nothing
# If target exists and the target is not updated, append data to existing CSV from last fetched date
# If target does not exist, scrape
for (i in 1:nrow(df.target)){
  tryCatch({
    ticker = df.target$symbol[i]
    target.exists = df.target$exists[i]
  
    # If the target instrument does not exist, download it from Quantmod.    
    if (target.exists == FALSE){
      ticker = df.target$symbol[i]
      data = getSymbols(Symbols = ticker,
                        src = "yahoo",
                        auto.assign = FALSE)
      colnames(data) = c("open","high","low","close","volume","adjusted")
      
      # If last fetched date is not equal to the last date, the ticker probably does not exist anymore, so discard.
      if ((Sys.Date() - 3) <= last(index(data))){
        write.zoo(data,paste(data_path,ticker,".csv",sep = ""),sep=",",row.names=FALSE)
      } else {
        rm(data)
        df.log = rbind(df.log,c(df.target$symbol[i],as.character(Sys.Date()),"ticker does not exist anymore poop"))
      }
    }
    
    # If the target instrument does exist, check to see what the last date is
    
    if (target.exists == TRUE){
      file_path = paste(data_path,ticker,".csv",sep = "")
      skipLines = countLines(file_path)
      date.fetched = try(as.Date(as.matrix(read.csv(file_path,nrows = 1,skip = skipLines-1, header = FALSE)[1])))
      
      # If the last date is not equal to the day before yesterday (because today's market may not have closed), fetch data from that day onwards
      if (Sys.Date() - 1 != date.fetched){
      start.date = date.fetched
      data = getSymbols(Symbols = ticker,
                        src = "yahoo",
                        from = start.date,
                        auto.assign = FALSE)

      # If last fetched date is not equal to the last date, the ticker probably does not exist anymore, so discard.
        if ((Sys.Date() - 3) <= last(index(data))){
          write.zoo(data,paste(data_path,ticker,".csv",sep = ""), append = TRUE, sep = ",",col.names = FALSE)
        } else {
          rm(data)
          df.log = rbind(df.log,c(df.target$symbol[i],as.character(Sys.Date()),"ticker does not exist anymore"))
        }
      }
    }
  },
      
  # when there is an error, write error 
  error = function(e) {
    df.log[nrow(df.log) + 1,] =c(df.target$symbol[i],as.character(Sys.Date()),"failure")
  })
}


}

