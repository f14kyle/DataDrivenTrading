fetchOHLC = function(df.target){

# Save all target stocks as merged XTS
all.stocks.list = vector("list",nrow(df.target))


# Save all target stocks into list.  The list will also include the failures.
for (i in 1:nrow(df.target)){
  data = try(read.csv(paste(data_path,df.target$symbol[i],".csv",sep = ""),header = TRUE,sep = ",",stringsAsFactors = FALSE))
  all.stocks.list[[i]] = try(xts(x = data,order.by = as.Date(data$Index)))
}


return(all.stocks.list)

}
