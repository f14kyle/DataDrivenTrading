---
title: "Lazy Porfolio Selection"
output: github_document
---




```r
# Load libraries
setwd("/Volumes/DATA/Github/DataDrivenTrading")
#

library(ggplot2) # for ggplot
library(scales) # for percent
load("df_lazy.rda")
```
## Introduction

The purpose of the Lazy Portfolio Analytics project is to provide the user with the information he or she needs to craft his or her passively managed retirement portfolio.  Very simply, these questions include:

1) Which lazy portfolio should I choose?
2) And which stock instruments should I pick?

I answered the first question by analyzing as many different lazy portfolios as I could find--18 to date.  Each is ranked according to risk and return metrics for various investment periods and ranked.  A rebalancing period of 1 year was assumed after studying the sensitivity of CAGR to various rebalance periods.

I answered the second question by looking at every ETF available on ETFdb.com, and ranking each according to cost and performance against the market.

The desired retirement portfolio is thus 

My motivations:
1) I know almost nothing about the investment world.  It's time to take control of personal finances.
2) I am relatively young and have a long investment outlook.  Every day I keep my head buried under the sand is one more day my money doesn't grow according to my own will.  
3) Through my random self-learnings about retirement portfolios on Google, I found that I was dissatisfied with most of what I read because of the lack of rigor and thoroughness in the analysis.  But I also just have a heard time taking other people at their word when it comes to my money. 
I have been dissatisfied with most 

Very simply, this study compares the risk and return performance of 18 lazy portfolios evaluated at 1, 3, 5, 7, and 9 year timeframes.  There are many different risk metrics available, but my favorite is maximum drawdown (MDD), which quantifies the largest single loss a portoflio suffers in value from peak to trough (before a new peak is achieved).  This is a particularly 






