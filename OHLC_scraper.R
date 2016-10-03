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

# Load list of instruments
df <- data.frame(read_excel("etfdb_data.xls"))
colnames(df) = c("symbol","name","etfdb.category","inception.date","expense.ratio","commission.free","expenses.rating")

# Check file checker to determine which instruments need to be updated
existing.files = list.files("./Data/OHLC",full.names = FALSE) # fetch list of all files from folder
existing.files = gsub(".csv","",symbol.lihttps://www.google.com/webhp?hl=en&sa=X&ved=0ahUKEwjnrajXrL3PAhVEmZQKHYE4DVUQPAgDst) # remove ".csv" from vector of characters

# The update list determines if the file needs to be updated
df.updatelist = data.frame(stringsAsFactors=FALSE)

write.zoo()




df.log = data.frame("fetched.symbol" = character(),
                    "fetch.attempted" = as.Date(character()),
                    "fetched.status" = character(),
                    stringsAsFactors=FALSE)


for (i in df$symbol){
  
  tryCatch({
    data = getSymbols(Symbols = i,
                      src = "yahoo",
                      from = startDate,
                      auto.assign = FALSE) 
    colnames(data) = c("open","high","low","close","volume","adjusted")
    write.zoo(data,paste(data_path,i,".csv",sep = ""),sep=",",row.names=FALSE) # sep = "" to get rid of space in paste operations

    # when successful write status to log
    df.log[nrow(df.log) + 1,] =c(i,as.character(Sys.Date()),"success")
          }, 
    
  error = function(e) {
    df.log[nrow(df.log) + 1,] =c(i,as.character(Sys.Date()),"failure")
  })
  
}

write.csv(metadata,file = paste(data_path,".metadata.txt",sep = ""),sep = ",",row.names = FALSE) 
