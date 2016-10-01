# 9/24/2016
# ETF Metadata Scraper
# This program scrapes ETF metadata from ETFDB

rm(list=ls()) 
directory = "D:/Github/DataDrivenTrading"
setwd(directory)

# Load libraries
library(XML)
library(RCurl)
library(readxl)
library(rvest) # for read_html

# Load list of ETFs
# Source: http://www.nasdaq.com/etfs/list
# Only first two columns have relevant information
#df = read.csv(file="ETFList.csv", sep=",")[,1:2]

# Load list of ETFs
df <- data.frame(read_excel("etfdb_data.xls"))
colnames(df) = c("symbol","name","etfdb.category","inception.date","expense.ratio","commission.free","expenses.rating")
# Correct Excel format date for inception date
df$inception.date = as.Date(df$inception.date,origin = "1899-12-30")

# Create requisite columns
df["c.issuer"] = gsub( " .*$", "", df$name )
df["c.structure"] = NA
df["c.expense.ratio"] = NA
df["c.inception"] = NA
df["c.tax.form"] = NA
df["c.tracking.index"] = NA

# Avoid Warning Message: XML content does not seem to be XML by 
# prepending "http://" to url.
url.list <- paste("http://etfdb.com/etf/", df$symbol, sep="")

# ETFDB only allows 163 pings at a time.  We'll break down the crawling by issuer.


# Save all web content first
all.sites = vector("list",nrow(df))

# Determine how many loops to perform web crawling for
# ETFdb seems to cut the connection after 163 calls

n.loops = ceiling(nrow(df)/160)

for (i in 1:n.loops){
  for (j in (160*i - 159):(160 * i)){
  all.sites[[j]] = read_html(url.list[j])
  }
  Sys.sleep(2)
}



  for (j in 297: 356){
    all.sites[[j]] = read_html(url.list[j])
  }
  Sys.sleep(2)


#270, 297

for (i in 1:nrow(df)){
  cast <- try(html_nodes(all.sites[[i]], ".pull-right"))
  df$c.issuer[i] = try(html_text(cast)[6])
  df$c.structure[i] = try(html_text(cast)[7])
  df$c.expense.ratio[i] = try(html_text(cast)[8])
  df$c.inception.date[i] = try(html_text(cast)[10])
  df$c.tax.form[i] = try(html_text(cast)[11])
  df$c.tracking.index[i] = try(html_text(cast)[12])
}

save(df,file = "etf_data.rda")
