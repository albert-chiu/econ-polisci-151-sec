data {
  int<lower=1> N;  // number of observations
  int<lower=1> K;  // number of variables
  int<lower=1> G;  // number of groups
  int<lower=1> Ti;  // number of time periods
  int<lower=1, upper=G> gg[N];  // groups
  int<lower=1, upper=Ti> tt[N];  // times
  vector[N] y;  // response
  vector[N] d;  // treatment
  matrix[N, K] x;  // covariates
  
}

parameters {
  vector[G] alpha_G;  // group intercepts
  vector[Ti] alpha_T;  // time intercepts
  real mu_raw;  // untransformed mean slope for d
  real<lower=-pi() / 2, upper=pi() / 2> sigma_mu_unif; // untransformed variance of mu
  vector[G] tau_G_raw;  // untransformed group specific slopes for d
  vector[Ti] tau_T_raw;  // untransformed time specific slopes for d
  real<lower=-pi() / 2, upper=pi() / 2> sigma_G_unif;  // untransformed variance for group level slopes 
  real<lower=-pi() / 2, upper=pi() / 2> sigma_T_unif;  // untransformed variance for time level slopes 
  vector[K] beta;  // slopes for x
  real<lower=0> sigma;  // variance for errors
  
}

transformed parameters {
  real<lower=0> sigma_mu; // variance of mu
  real<lower=0> sigma_G;  // variance for group level slopes 
  real<lower=0> sigma_T;  // variance for time level slopes 
  
  real mu;  // mean slope for d
  vector[G] tau_G;  // group specific slopes for d
  vector[Ti] tau_T;  // time specific slopes for d
  
  sigma_mu = fabs(2.5*tan(sigma_mu_unif)); // sigma_mu ~ cauchy(0, 2.5)
  sigma_G = fabs(2.5*tan(sigma_G_unif)); // sigma_G ~ cauchy(0, 2.5)
  sigma_T = fabs(2.5*tan(sigma_T_unif)); // sigma_T ~ cauchy(0, 2.5)
  
  mu = sigma_mu*mu_raw; // mu ~ normal(0, sigma_mu)
  tau_G = sigma_G*tau_G_raw; // tau_G ~ normal(0, sigma_G)
  tau_T = sigma_T*tau_T_raw; // tau_T ~ normal(0, sigma_T)
  
}

model {
  sigma ~ gamma(2, .1);  // prior for the variance of the response
  
  // not necessary to specify uniform priors; stan assumes unspecified=uniform
  sigma_mu_unif ~ uniform(-pi() / 2, pi() / 2);  // (hyper)prior for the untransformed variance of the grand mean treatment effect
  sigma_G_unif ~ uniform(-pi() / 2, pi() / 2); // (hyper)prior for the untransformed variance of the group-specific treatment effects
  sigma_T_unif ~ uniform(-pi() / 2, pi() / 2); // (hyper)prior for the untransformed variance of the time-specific treatment effects
  
  mu_raw ~ std_normal();  // prior for the untransformed grand mean of the treatment effect
  tau_G_raw ~ std_normal(); // prior for the untransformed group-specific treatment effect
  tau_T_raw ~ std_normal(); // prior for the untransformed time-specific treatment effect
  
  {
    vector[N] m;
    for (n in 1:N) {
      // mean of the response: sum of group- and time-specific intercepts, linear combination of controls, and treatment effect
      m[n] = alpha_G[gg[n]] + alpha_T[tt[n]] + x[n]*beta + (mu + tau_G[gg[n]] + tau_T[tt[n]])*d[n];
    }  
    // likelihood of the response
    y ~ normal(m, sigma);
  }
  
}

