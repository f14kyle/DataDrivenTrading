# updownratio for everything

setwd("/Volumes/DATA/Github/DataDrivenTrading")
#

# Load libraries
library(readxl)
library(rPref)  # for psel
library(ggplot2)
library(scales)  # for percent
library(ggrepel)  # for geom_text_repel
library(gridExtra) # for grid.arrange
library(quantmod)

# Load list of ETFs
df <- data.frame(read_excel("etfdb_data.xls"))
colnames(df) = c("symbol","name","etfdb.category","inception.date","expense.ratio","commission.free","expenses.rating")
# Correct Excel format date for inception date
df$inception.date = as.Date(df$inception.date,origin = "1899-12-30")
df["c.issuer"] = gsub( " .*$", "", df$name )


updown.matrix = matrix(nrow = ncol(all.lazy.stocks),ncol = 2)

returns.GSPC = Return.calculate(GSPC[,6])

for (j in 1:28){
  updown.matrix[j,1] = UpDownRatios(returns.lazy.stocks[[1]][,j], returns.GSPC, method = c("Capture"),side = c("Up"))
  updown.matrix[j,2] = UpDownRatios(returns.lazy.stocks[[1]][,j], returns.GSPC, method = c("Capture"),side = c("Down"))
}

df.updown = data.frame(cbind(tickers.lazy.symbs,updown.matrix),stringsAsFactors = FALSE)




getSymbols("^GSPC")
getSymbols("AGG")

UpDownRatios(VTI[,6], GSPC[,6], method = c("Percent"),side = c("Up", "Down"))


