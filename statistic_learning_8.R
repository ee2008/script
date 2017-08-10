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

## regression tree -Boston
library(MASS)
set.seed(1)
train <- sample(1:nrow(Boston),nrow(Boston)/2)
tree.boston <- rpart(medv~.,Boston,subset=train)
summary(tree.boston)
# plot(tree.boston) -- figure margins too large
text(tree.boston,pretty = 0)


##  bagging and random forest
library(randomForest)
set.seed(1)
b=Boston
bag.boston=randomForest(medv~.,data=Boston,subset=train,mtry=13,importance=TRUE)
bag.boston
yhat.bag <- predict(bag.boston,newdata=Boston[-train,])
plot(yhat.bag,boston.test)

set.seed(1)
rf.boston <- randomForest(medv~.,data=Boston,subset=train,mtry=6,importance=TRUE)
yhat.rf <- predict(rf.boston,newdata=Boston[-train,])
mean((yhat.rf-boston.test)^2)



### new test
## data prepare
loc <- "http://archive.ics.uci.edu/ml/machine-learning-databases/"
ds <- "breast-cancer-wisconsin/breast-cancer-wisconsin.data"
url <- paste(loc,ds,sep="")
breast <- read.table(url,sep=",",header=FALSE,na.strings = "?")
names(breast) <- c("ID","clumoThickness","sizeUniformity","shapeUniformity","maginalAdhesion","singleEpithelialCellSize","bareNuclei","blandChromatin","normalNucleoli","mitosis","class")
df <- breast[-1]
df$class <- factor(df$class,levels=c(2,4),labels=c("benign","malignant"))
set.seed(1234)
train <- sample(nrow(df),0.7*nrow(df))
df.train <- df[train,]
df.validate <- df[-train,]
table(df.train$class)
table(df.validate$class)

library("rpart")
set.seed(1234)
dtree <- rpart(class~.,data=df.train,method="class",parms = list(split="information"))
dtree$cptable
plotcp(dtree)

dtree.pruned <- prune(dtree,cp=0.0125)

library("rpart.plot")
prp(dtree.pruned,type=2,extra=104,fallen.leaves=TRUE,main="Discision Tree")

dtree.pred <- predict(dtree.pruned,df.validate,type="class")
dtree.pref <- table(df.validate$class,dtree.pred,dnn=c("Actual","Predicted"))


library(randomForest)
set.seed(1234)
fit.forest <- randomForest(class~.,data=df.train,na.action=na.roughfix,importance=TRUE)




