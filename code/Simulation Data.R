library(V8)
library(rstan)


# simulation data
set.seed(123)
# time range
T <- 12

#number of participant
n <- 30

# define model parameter
alpha_0 <- 0.34 #
alpha_1 <- 0.7  # alpha autoregression
alpha_2 <- 0.104 #small time trend
beta_0 <- 0.688 #
beta_1 <- 0.5  # beta autoregression
gamma_0 <- 1.039 
gamma_1 <- 0.4 # gamma autoregression 
sigma <- 0.1  # sd of white noise

# generate AR(1) sequence 
a_t <- arima.sim(n = T, list(ar = alpha_1), sd = sigma)
b_t <- arima.sim(n = T, list(ar = beta_1), sd = sigma)
c_t <- arima.sim(n = T, list(ar = gamma_1), sd = sigma)
a_t <- as.vector(a_t)
b_t <- as.vector(b_t)
c_t <- as.vector(c_t)

# add time trend and intercept to a path
for(i in 1:T){
  temp_alpha_2 <- rnorm(1,alpha_2,0.005)
  a_t[i] <- a_t[i] + temp_alpha_2*(i-1)+ alpha_0 + rnorm(1,0,0.005) 
}

# add intercept to b path
for (i in 1:T) {
  b_t[i] <- b_t[i] + beta_0 + rnorm(1,0,0.005)
}

# c path is divined into two part: c'(indirect) and c(direct)
# c'(indirect)
c1_t_mu <- a_t*b_t

# c(direct) -- this can't be get by multipying at*bt
for (i in 1:T) {
  c_t[i] <- c_t[i] + gamma_0 + rnorm(1,0,0.005)
}

# generate X Y M
# X is a matrix()
# Y is a matrix()
X <- matrix(runif(n*T, 3,5.5),nrow= n,T)
M <- sweep(X, 2, a_t, "*") + matrix(rnorm(n*T, 0,0.5),nrow= n,T)
Y <- sweep(X, 2, c_t, "*") + sweep(M, 2, b_t, "*") + matrix(rnorm(n*T, 0, 0.5),nrow= n,T)

# begin to fit model
data1 <- list (n=n,T=T,X=X,M=M,Y=Y, a0=1, b0=0.5, c0=3)
fit1<-stan(file= "E:/phd申请/Research Proposal/timestamp.stan",data=data1)
