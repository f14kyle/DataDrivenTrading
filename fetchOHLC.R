fetchOHLC = function(df.target){

# Save all target stocks as merged XTS
all.stocks.list = vector("list",nrow(df.target))


# Save all target stocks into list.  The list will also include the failures.
for (i in 1:nrow(df.target)){
  data = try(read.csv(paste(data_path,df.target$symbol[i],".csv",sep = ""),header = TRUE,sep = ",",stringsAsFactors = FALSE))
  # Make sure to include the [,-1] in order to avoid the date column when constructing the xts.  The xts file structure is inherently a matrix, which assumes one data type.  If dates and numerics are mixed, they will all be coerced into characters.
  all.stocks.list[[i]] = try(xts(x = data[,-1],order.by = as.Date(data$Index)))
}


return(all.stocks.list)

}
