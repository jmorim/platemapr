library(dplyr)

test.df = data.frame(a = c(1, 2, 3), b = c(4, 5, 6))
# desired output is c(1, 4, 2, 5, 3, 6)
t(test.df)

test.list = c()
for(i in 1:ncol(test.df)){
  print(i)
  
}
