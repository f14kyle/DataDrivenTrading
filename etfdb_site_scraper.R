# 10/01/2016
# ETFdb Scraper
# This program downloads all 

rm(list=ls()) 
directory = "D:/Github/DataDrivenTrading"
setwd(directory)

# Load libraries
library(readxl)
library(rvest) # for read_html

# Load list of ETFs
# Source: http://www.nasdaq.com/etfs/list
# Only first two columns have relevant information
#df = read.csv(file="ETFList.csv", sep=",")[,1:2]

# Load list of ETFs
df <- data.frame(read_excel("etfdb_data.xls"))
colnames(df) = c("symbol","name","etfdb.category","inception.date","expense.ratio","commission.free","expenses.rating")

# Avoid Warning Message: XML content does not seem to be XML by 
# prepending "http://" to url.
url.list <- paste("http://etfdb.com/etf/", df$symbol, sep="")                 

# Determine how many loops to perform web crawling for
# ETFdb seems to cut the connection after 163 calls
n.loops = ceiling(nrow(df)/160)
# Save all web content first

all.sites = vector("list",nrow(df))
for (i in 1:n.loops){
  for (j in (160*i - 159):(160 * i)){
    all.sites[[j]] = try(read_html(url.list[j]))
  }
  Sys.sleep(2)
}

save(all.sites,file = paste(Sys.Date(),"_etfdb_allsites.rda"))
