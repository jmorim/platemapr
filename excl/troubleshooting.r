library(dplyr)

test.df = data.frame(a = c(1, 2, 3), b = c(4, 5, 6))
# desired output is c(1, 4, 2, 5, 3, 6)
t(test.df)

test.list = c()
k = 1
for(i in 1:nrow(test.df)){
  print(paste0('i = ', i))
  for(j in 1:ncol(test.df)){
    print(paste0('j = ', j))
    test.list[k] = test.df[i, j]
    k = k + 1
  }
}
test.df[2,1]

test.list
test.list2 = c(test.list, c(7, 8, 9))
test.list2
