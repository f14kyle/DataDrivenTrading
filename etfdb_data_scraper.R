# 9/24/2016
# ETF Metadata Scraper
# This program scrapes ETF metadata from ETFDB

rm(list=ls()) 
directory = "D:/Github/DataDrivenTrading"
setwd(directory)

# Load libraries
library(readxl)
library(quantmod)
#library(rvest) # for read_html
library(rPref)
library(ggplot2)
library(ggrepel)
library(scales)
library(gridExtra)

# Load list of ETFs
# Source: http://www.nasdaq.com/etfs/list
# Only first two columns have relevant information
#df = read.csv(file="ETFList.csv", sep=",")[,1:2]

# Load list of ETFs
df <- data.frame(read_excel("etfdb_data.xls"))
colnames(df) = c("symbol","name","etfdb.category","inception.date","expense.ratio","commission.free","expenses.rating")
# Correct Excel format date for inception date
df$inception.date = as.Date(df$inception.date,origin = "1899-12-30")

df["c.issuer"] = NA

# Load latest set of scraped sites from ETFdb.com
#load("20160930_allsites.rda")

# Create requisite columns
df["c.issuer"] = gsub( " .*$", "", df$name )
df["c.structure"] = NA
df["c.expense.ratio"] = NA
df["c.inception.date"] = NA
df["c.tax.form"] = NA
df["c.tracking.index"] = NA

n.top = 10

df.ac = psel(subset(df,etfdb.category == "All Cap Equities"),low(expense.ratio),top = n.top)
df.lcb = psel(subset(df,etfdb.category == "Large Cap Blend Equities"),low(expense.ratio),top = n.top)
df.lcg = psel(subset(df,etfdb.category == "Large Cap Growth Equities"),low(expense.ratio),top = n.top)
df.lcv = psel(subset(df,etfdb.category == "Large Cap Value Equities"),low(expense.ratio),top = n.top)
df.mcb = psel(subset(df,etfdb.category == "Mid Cap Blend Equities"),low(expense.ratio),top = n.top)
df.mcg = psel(subset(df,etfdb.category == "Mid Cap Growth Equities"),low(expense.ratio),top = n.top)
df.mcv = psel(subset(df,etfdb.category == "Mid Cap Value Equities"),low(expense.ratio),top = n.top)
df.scb = psel(subset(df,etfdb.category == "Small Cap Blend Equities"),low(expense.ratio),top = n.top)
df.scg = psel(subset(df,etfdb.category == "Small Cap Growth Equities"),low(expense.ratio),top = n.top)
df.scv = psel(subset(df,etfdb.category == "Small Cap Value Equities"),low(expense.ratio),top = n.top)


# Plot box-whisker for each category

plot.box = ggplot(df,aes(x = etfdb.category,y = expense.ratio)) + 
  geom_boxplot(outlier.colour = "black", outlier.size = ) +
  geom_jitter(aes(colour = etfdb.category)) + 
  scale_y_continuous(labels = percent,breaks = scales::pretty_breaks(n = 10)) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))  


# Plot cheapest 10 ETFs per category
plot.allcap = ggplot() + 
  geom_point(data = df.ac,aes(x = c.issuer,y = expense.ratio)) + 
  geom_text_repel(data = df.ac,aes(x = c.issuer,y = expense.ratio,label = df.ac$symbol)) + 
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))

plot.lcb = ggplot() + 
  geom_point(data = df.lcb,aes(x = c.issuer,y = expense.ratio)) + 
  geom_text_repel(data = df.lcb,aes(x = c.issuer,y = expense.ratio,label = df.lcb$symbol)) + 
  ggtitle("Large Cap Blend") +
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))

plot.lcg = ggplot() + 
  geom_point(data = df.lcg,aes(x = c.issuer,y = expense.ratio)) + 
  geom_text_repel(data = df.lcg,aes(x = c.issuer,y = expense.ratio,label = df.lcg$symbol)) + 
  ggtitle("Large Cap Growth") +
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))

plot.lcv = ggplot() + 
  geom_point(data = df.lcv,aes(x = c.issuer,y = expense.ratio)) + 
  geom_text_repel(data = df.lcv,aes(x = c.issuer,y = expense.ratio,label = df.lcv$symbol)) + 
  ggtitle("Large Cap Value") + 
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))

plot.mcb = ggplot() + 
  geom_point(data = df.mcb,aes(x = c.issuer,y = expense.ratio)) + 
  geom_text_repel(data = df.mcb,aes(x = c.issuer,y = expense.ratio,label = df.mcb$symbol)) + 
  ggtitle("Small Cap Blend") + 
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))

plot.mcg = ggplot() + 
  geom_point(data = df.mcg,aes(x = c.issuer,y = expense.ratio)) + 
  geom_text_repel(data = df.mcg,aes(x = c.issuer,y = expense.ratio,label = df.mcg$symbol)) + 
  ggtitle("Mid Cap Growth") + 
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))

plot.mcv = ggplot() + 
  geom_point(data = df.mcv,aes(x = c.issuer,y = expense.ratio)) +
  geom_text_repel(data = df.mcv,aes(x = c.issuer,y = expense.ratio,label = df.mcv$symbol)) + 
  ggtitle("Mid Cap Value") + 
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))

  
plot.scb = ggplot() + 
  geom_point(data = df.scb,aes(x = c.issuer,y = expense.ratio)) + 
  geom_text_repel(data = df.scb,aes(x = c.issuer,y = expense.ratio,label = df.scb$symbol)) + 
  ggtitle("Small Cap Blend") + 
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))
  
  
plot.scg = ggplot() + 
  geom_point(data = df.scg,aes(x = c.issuer,y = expense.ratio)) + 
  geom_text_repel(data = df.scg,aes(x = c.issuer,y = expense.ratio,label = df.scg$symbol)) + 
  ggtitle("Small Cap Growth") + 
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))

plot.scv = ggplot() + 
  geom_point(data = df.scv,aes(x = c.issuer,y = expense.ratio)) + 
  geom_text_repel(data = df.scv,aes(x = c.issuer,y = expense.ratio,label = df.scv$symbol)) + 
  ggtitle("Small Cap Value") + 
  scale_y_continuous(labels = percent) + 
  theme(legend.title=element_blank(),
        legend.position = "top",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.3))

grid.arrange(plot.lcv,plot.lcb,plot.lcg,plot.mcv,plot.mcb,plot.mcg,plot.scv,plot.scb,plot.scg,ncol = 3)

#for (i in 1:nrow(df)){
#  cast <- html_nodes(all.sites[[i]], ".pull-right")
#  df$c.issuer[i] = html_text(cast)[6]
#  df$c.structure[i] = html_text(cast)[7]
#  df$c.expense.ratio[i] = html_text(cast)[8]
#  df$c.inception.date[i] = html_text(cast)[10]
#  df$c.tax.form[i] = html_text(cast)[11]
#  df$c.tracking.index[i] = html_text(cast)[12]
#}


#for (i in 1:nrow(df)){
  #cast <- try(html_nodes(all.sites[[i]], "span"))
  #df$c.issuer[i] = try(html_text(cast)[6])
  #df$c.structure[i] = try(html_text(cast)[7])
##  df$c.expense.ratio[i] = try(html_text(cast)[8])
#  df$c.inception.date[i] = try(html_text(cast)[10])
#  df$c.tax.form[i] = try(html_text(cast)[11])
#  df$c.tracking.index[i] = try(html_text(cast)[12])
#}



save(df,file = "etfdb_data.rda")

