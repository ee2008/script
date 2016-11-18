#!/nfs2/pipe/Re/Software/miniconda/bin/Rscript --vanilla
# @wxian2016Agu14

library("ggplot2")

argv <- commandArgs(TRUE)
if (length(argv) < 4) {
  cat ("Usage: $0 -i <beta,binom,cauchy,chisq,exp,norm> -o <out_dir>")
  q()
}

#input="beta"\
#out_dir="./"
input <- as.character(argv[2])
out_dir <- as.character(argv[4])
if (!file.exists(out_dir) ) {
  stop("! no such dir: ", out_dir)
}

distribution <- strsplit(input, ',')[[1]]


n <- 100
# generate random data
beta <- function (n, beta1 = 1, beta2 = 2) {
  if ((beta1 < 0) || (beta2 < 0)) {
    stop ("! non-negative parameters of the Beta distribution")
  }
  rbeta(n, beta1, beta2)
}

binom <- function (n, size = 1, prob = 0.5) {
  if (( size < 0 ) || ( prob <0 ) || ( prob > 1 )) {
    stop ("! wrong parameters: size(zero or more); prob[0-1]")
  }
  rbinom(n, size, prob)
}

cauchy <- function (n, location = 0, scale = 1) {
    rcauchy (n, location, scale)
}

chisq <- function (n, df = 2, ncp = 0) {
  if ((df < 0 ) || (ncp < 0 )) {
    stop ("! wrong parameters: non-negative")
  }
  rchisq (n, df, ncp)
}

exp <-  function (n, rate = 1) {
  if (rate < 0) {
    stop ("! wrong parameters: rate(positive)")
  }
  rexp (n, rate)
}

norm <- function (n, mean =  0, sd = 1) {
  if (sd < 0) {
    stop ("! wrong parameters: sd(non-negative)")
  }
  rnorm (n, mean, sd)
}

unif <-  function (n, min = 0, max = 1) {
  runif (n, min, max)
}

# plot for the data
plot  <- function(data,name) {
  no <- c(1:n)
  data_f <- data.frame(no,data)
  ggplot(data_f, aes(no,data))+
    geom_violin()+ theme(panel.background = element_rect(fill = "transparent", colour = "black"))+
    geom_boxplot()+theme(panel.background = element_rect(fill = "transparent", colour = "black"))+
    geom_point(position = "identity", size = data) + geom_point(position = "jitter") + theme(panel.background = element_rect(fill = "transparent", colour = "black"))+
    ylab("x") + xlab("n") + ggtitle(paste0(name, " distribution"))
}

Distributions <- c("Mean", "Median", "Var", "10th")
static <-  sapply (distribution, function(x) {
  dis <- paste0(x, "(n)")
  random_data <- eval(parse(text = dis))
  name_dis <- as.character(x)
  png(paste0(out_dir,"/",name_dis,"_plot.png"))
  print (plot(random_data,name_dis))
  dev.off()
  mean <- mean(random_data)
  median <- median(random_data)
  var <- var(random_data)
  sort <- sort(random_data)
  sort10 <- sort[10]
  info <- c(mean, median, var, sort10)
}, simplify = "array")

result <- data.frame(Distributions, static)
print (result)







