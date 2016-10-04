# This R script downloads stock tickers and saves each as a CSV file
# http://www.thertrader.com/2015/12/13/maintaining-a-database-of-price-files-in-r/
# 10/02/2016
# ETF Metadata Scraper
# This program scrapes ETF metadata from ETFDB

rm(list=ls()) 
library(readxl)
library(quantmod)

directory = "D:/Github/DataDrivenTrading/"
data_path = "D:/Github/DataDrivenTrading/Data/OHLC/"

setwd(directory)

# Reads in last update information
df.existing = read.table("log.csv",header = TRUE,sep = ",", stringsAsFactors=F)
  
# Load list of target instruments
df.target <- data.frame(read_excel("etfdb_data.xls"))
colnames(df.target) = c("symbol","name","etfdb.category","inception.date","expense.ratio","commission.free","expenses.rating")

# Create a dataframe that contains information on what data to fetch
df.comparison = data.frame("target.symbol" = df.target$symbol,
                           "target.exists" = rep(NA,nrow(df.target)),
                           "target.updated" = rep(NA,nrow(df.target)),
                           stringsAsFactors=FALSE)

# Perform comparisons to determine if target instrument exists and if it is updated
for (i in 1:nrow(df.comparison)){
  df.comparison$target.exists[i] = df.target$symbol[i] %in% df.existing$fetched.symbol
  df.comparison$target.updated[i] = Sys.Date() == df.existing$fetched.date[grep(df.target$symbol[100],df.existing$fetched.symbol)]
}


# Check file checker to determine which instruments need to be updated
#existing.files = list.files("./Data/OHLC",full.names = FALSE) # fetch list of all files from folder
#existing.files = gsub(".csv","",existing.files) # remove ".csv" from vector of characters


# Recreate log
df.log = data.frame("fetched.symbol" = character(),
                    "fetched.date" = as.Date(character()),
                    "fetched.status" = character(),
                    stringsAsFactors=FALSE)

# For each symbol among the target symbols, perform teh following action according to the situation:

# If target exists and the target is updated, do nothing
# If target exists and the target is not updated, append data to existing CSV from last fetched date
# If target does not exist, scrape
for (i in 1:nrow(df.comparison)){
  tryCatch({
    target.exists = df.comparison$target.exists[i]
    target.updated = df.comparison$target.updated[i]
    
    if (target.exists == TRUE & target.updated == FALSE){
      startDate = df.existing$fetched.date[grep(df.target$symbol[i],df.existing$fetched.symbol)]
      ticker = df.comparison$target.symbol[i]
      data = getSymbols(Symbols = ticker,
                        src = "yahoo",
                        from = startDate,
                        auto.assign = FALSE)
      write.table(data,paste(data_path,ticker,".csv",sep = ""), append = TRUE, sep = ",")
      df.log[nrow(df.log) + 1,] =c(i,as.character(Sys.Date()),"success")
    }
    
    if (target.exists == FALSE){
      ticker = df.comparison$target.symbol[i]
      data = getSymbols(Symbols = ticker,
                        src = "yahoo",
                        auto.assign = FALSE) 
      colnames(data) = c("open","high","low","close","volume","adjusted")
      write.zoo(data,paste(data_path,ticker,".csv",sep = ""),sep=",",row.names=FALSE) # sep = "" to get rid of space in paste operations
      
      # when successful write status to log
      df.log[nrow(df.log) + 1,] =c(i,as.character(Sys.Date()),"success")
    }

          }, 
  # when there is an error, write error  
  error = function(e) {
    df.log[nrow(df.log) + 1,] =c(i,as.character(Sys.Date()),"failure")
  })
}

write.csv(df.log,file = "log.csv",row.names=FALSE)
