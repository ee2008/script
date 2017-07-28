# 8 tree
library(rpart)
library(ISLR)
attach(Carseats)
library(rpart.plot)
a=Carseats
High <- ifelse(Sales <= 8,"No","Yes")
Carseats <- data.frame(Carseats,High)
tree.carseats <- rpart(High~.-Sales,Carseats)
summary(tree.carseats)
plot(tree.carseats)
#text(tree.carseats,pretty=0)
set.seed(2)
train <- sample(1:nrow(Carseats),200)
Carseats.test <- Carseats[-train,]
High.test <- High[-train]
tree.carseats <- rpart(High~.-Sales,Carseats,subset = train)
tree.pred <- predict(tree.carseats,Carseats.test,type="class")
table(tree.pred,High.test)

## trim the tree
library(mlbench)
library(caret)
set.seed(3)
cv.carseats <- rpart.control(xval=10, minsplit=20, cp=0.1)
#cv.tree(tree.carseats,FUN=prune.misclass)


