//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=1> n;  #participants
  int<lower=1> T;  #timestamp
  
  matrix[n, T] Y;  #independent variables
  matrix[n, T] X;  #mediator
  matrix[n, T] M;  #dependent variables
  
  real a0; #initial value
  real b0;
  real c0;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  
  vector[T] a; // coefficient for X
  vector[T] b; // coefficient for M
  vector[T] c; // direct effect of X on Y
  vector[T] mu_a; // mean of a
  vector[T] mu_b; // mean of b
  vector[T] mu_c; // mean of c

  
  
  # initial parameters
  real alpha_0; # path a
  real alpha_1;
  real alpha_2;
  real beta_0; # path b
  real beta_1;
  real gamma_0; # path c'
  real gamma_1;
  
  real muaa;
  real mubb;
  real mucc;

  # standard deviation
  real<lower=0> tau_a; // standard deviation of a
  real<lower=0> tau_b; // standard deviation of b
  real<lower=0> tau_c; // standard deviation of c
  
  real<lower=0> tau_Y; // standard deviation of Y
  real<lower=0> tau_M; // standard deviation of M
  
  # mean of parameters in time = 1 
  vector[n] mu_y; // mean of Y for each subject and time point
  vector[n] mu_m; // mean of M for each subject and time point
  
  # 
}

transformed parameters {
  matrix[n, T] muy; // predicted mean of Y
  matrix[n, T] mum; // predicted mean of M
  vector[T] me; // mediation effect

  for (t in 1:T) {
    me[t] = a[t] * b[t]; // mediation effect
    
    for (i in 1:n) {
      muy[i, t] = c[t] * X[i, t] + b[t] * M[i, t]; #Y的估计均值
      mum[i, t] = a[t] * X[i, t]; #M的估计均值
    }
    
  }
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  
  // Priors for parameters
  muaa ~ normal(a0, tau_a);
  mubb ~ normal(b0, tau_b);
  mucc ~ normal(c0, tau_c);
 
  alpha_0 ~ normal(0, 0.001);
  alpha_1 ~ uniform(-1, 1);
  alpha_2 ~ normal(0, 0.001);
  
  
  beta_0 ~ normal(0, 0.001);
  beta_1 ~ uniform(-1, 1);
  
  
  gamma_0 ~ normal(0, 0.001);
  gamma_1 ~ uniform(-1, 1);


  tau_a ~ gamma(0.001, 0.001);
  tau_b ~ gamma(0.001, 0.001);
  tau_c ~ gamma(0.001, 0.001);
  tau_Y ~ gamma(0.001, 0.001);
  tau_M ~ gamma(0.001, 0.001);
  
  mu_a[1] = a0;
  mu_b[1] = b0;
  mu_c[1] = c0;
  
  a[1] = muaa;
  b[1] = mubb;
  c[1] = mucc;
  
  
  // Likelihood 
  for (t in 2:T) {
    
    mu_a[t] = alpha_0 + alpha_1 * a[t - 1] + alpha_2*(t-1);
    mu_b[t] = beta_0 + beta_1 * b[t - 1];
    mu_c[t] = gamma_0 + gamma_1 * c[t - 1];
    
    a[t] ~ normal(mu_a[t], tau_a);
    b[t] ~ normal(mu_b[t], tau_b);
    c[t] ~ normal(mu_c[t], tau_c);
    
    for (i in 1:n) {
      
      Y[i, t] ~ normal(muy[i, t], tau_Y);
      M[i, t] ~ normal(mum[i, t], tau_M);
      
    }
  }

  
}

