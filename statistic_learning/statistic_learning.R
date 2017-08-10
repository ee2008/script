#fix(Boston)

library("MASS")
a=Boston

names(Boston)

attach(Boston)

lm.fit=lm(medv~lstat)
summary(lm.fit)
names(lm.fit)
coef(lm.fit)


predict(lm.fit,data.frame(lstat=c(5,10,15)),interval="prediction")

predict(lm.fit,data.frame(lstat=c(5,10,15)),interval="confidence")
plot(lstat,medv)
abline(lm.fit)
par(mfrow=c(2,2))
plot(lm.fit)

plot(predict(lm.fit),residuals(lm.fit))
plot(predict(lm.fit),rstudent(lm.fit))
plot(hatvalues(lm.fit))
which.max(hatvalues(lm.fit))


summary(lm(medv~lstat*age+nox))
lm.fit2=lm(medv~lstat+I(lstat^2))
anova(lm.fit,lm.fit2)

#加入5多项式阶阶多项式多项式
lm.fit5=lm(medv~poly(lstat,5))

summary(lm(medv~log(rm)))

attach(Carseats)
b=Carseats
lm.fit=lm(Sales~.+Income:Advertising+Price:Age,data=Carseats)
summary(lm.fit)
contrasts(ShelveLoc)
abline(lm.fit)















