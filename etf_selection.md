---
title: "Selecting ETFs for each asset class"
output: github_document
---



## Introduction
Part 1 determined which lazy portfolios were the best performers.  Part 2 will determine which ETFs are the best choices for these lazy portfolios.  The selection basis will be contingent on the expense ratio and their alpha.    

356 stock instruments across 10 asset classes were hand scraped from ETFdb.com.  The following is a jitter overlaid by a box and whisker of the expense ratios of each ETF separating according to asset class.  It's definitely a busy graph, but it provides an unadulterated view of the entire data set.  Let's dive deeper.  



```
## Error: 'etfdb_data.xls' does not exist in current working directory ('/Volumes/DATA/Github').
```

```
## Error in `colnames<-`(`*tmp*`, value = c("symbol", "name", "etfdb.category", : attempt to set 'colnames' on an object with less than two dimensions
```

```
## Error in df$inception.date: object of type 'closure' is not subsettable
```

```
## Error in df$name: object of type 'closure' is not subsettable
```

```
## Error in subset.default(df, etfdb.category == "All Cap Equities"): object 'etfdb.category' not found
```

```
## Error in subset.default(df, etfdb.category == "Large Cap Blend Equities"): object 'etfdb.category' not found
```

```
## Error in subset.default(df, etfdb.category == "Large Cap Growth Equities"): object 'etfdb.category' not found
```

```
## Error in subset.default(df, etfdb.category == "Large Cap Value Equities"): object 'etfdb.category' not found
```

```
## Error in subset.default(df, etfdb.category == "Mid Cap Blend Equities"): object 'etfdb.category' not found
```

```
## Error in subset.default(df, etfdb.category == "Mid Cap Growth Equities"): object 'etfdb.category' not found
```

```
## Error in subset.default(df, etfdb.category == "Mid Cap Value Equities"): object 'etfdb.category' not found
```

```
## Error in subset.default(df, etfdb.category == "Small Cap Blend Equities"): object 'etfdb.category' not found
```

```
## Error in subset.default(df, etfdb.category == "Small Cap Growth Equities"): object 'etfdb.category' not found
```

```
## Error in subset.default(df, etfdb.category == "Small Cap Value Equities"): object 'etfdb.category' not found
```


## Including Code

You can include R code in the document as follows:


```
## Error in fortify(data): object 'df.lcb' not found
```

```
## Error in fortify(data): object 'df.lcg' not found
```

```
## Error in fortify(data): object 'df.lcv' not found
```

```
## Error in fortify(data): object 'df.mcb' not found
```

```
## Error in fortify(data): object 'df.mcg' not found
```

```
## Error in fortify(data): object 'df.mcv' not found
```

```
## Error in fortify(data): object 'df.scb' not found
```

```
## Error in fortify(data): object 'df.scg' not found
```

```
## Error in fortify(data): object 'df.scv' not found
```

## Including Plots

You can also embed plots, for example:


```
## Error in if (is.waive(data) || empty(data)) return(cbind(data, PANEL = integer(0))): missing value where TRUE/FALSE needed
```

![plot of chunk plot](/figure/./etf_selection/plot-1.png)

```
## Error in arrangeGrob(...): object 'plot.lcv' not found
```
