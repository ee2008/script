library(ISLR)
names(Smarket)
a=Smarket
dim(Smarket)
cor(Smarket[,-9])
plot(Smarket$Volume)
attach(Smarket)
glm.fit = glm(Direction~Lag1+Lag2+Lag3+Lag4+Lag5+Volume,family = binomial)
summary(glm.fit)
glm.probs = predict(glm.fit,type="response")
contrasts(Direction)
glm.pred = rep("Down",1250)
glm.pred[glm.probs>.5]="up"
table(glm.pred,Direction)

## LDA model
train = (Year<2005)
Smarket.2005=Smarket[!train,]
Direction.2005=Direction[!train]
lda.fit=lda(Direction~Lag1+Lag2,data=Smarket,subset=train)
plot(lda.fit)
lda.pred=predict(lda.fit,Smarket.2005)
lda.class=lda.pred$class
table(lda.class,Direction.2005)

qda.fit = qda(Direction~Lag1+Lag2,subset = train)
qda.pred = predict(qda.fit,Smarket.2005)

library(class)
train.X=cbind(Lag1,Lag2)[train,]
test.X=cbind(Lag1,Lag2)[!train,]
