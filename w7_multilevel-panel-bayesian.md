Multilevel and Panel Data and Bayesian Statistics (ECON/POLISCI 151,
Week 7 Section)
================
Albert Chiu

## Data with Structure

This week will introduce models for multilevel and panel data. Each of
these types of data have unique structures for which you may need to
account. Many of the models we will consider today will be a sort middle
ground between the setting where all observations belong to the lower
level and we treat them as independent (which gives us the largest
effective N, but which may not be a realistic assumption) and the
setting where all observations are agglomerated into a higher level
(which gives us the smallest effective N, but which allows arbitrary
dependence between lower level units).

<!-- Typically, the goal is to control for confounders that you otherwise may be not be able to address using data without such structure, or for increasing efficiency (by pooling or borrowing information) compared to setting where we analyze . -->

## Multi-level Modelling

Sometimes our data has multiple “levels,” e.g., each observation is a
student, who belongs to a class, which is part of a school. For our
example, we will use data from LAPOP. Each observation is a respondent,
and each respondent lives in a province, which in turn belongs to a
country.

``` r
load("cleaned_data.RData")
df2010 <- df[df$wave==2010, ]  # subset to observations from the 2010 survey wave
colnames(df2010)
```

    ##  [1] "country"              "prov"                 "wave"                
    ##  [4] "year"                 "office"               "marriage"            
    ##  [7] "education"            "age"                  "rel_importance"      
    ## [10] "evangelical"          "ideology"             "rural"               
    ## [13] "poli_attendance"      "household_income"     "news"                
    ## [16] "male"                 "weight1500"           "household_income_old"
    ## [19] "household_income_new" "cname"                "legal_marry"         
    ## [22] "legal_marry_lag1"     "legal_union"          "legal_union_lag1"    
    ## [25] "LARI"                 "LARI_lead1"           "LARI_lag0"           
    ## [28] "LARI_lag1"            "LARI_lag2"            "LARI_lag3"           
    ## [31] "LARI_lag4"            "LARI_lag5"            "adm_office"          
    ## [34] "adm_marriage"

``` r
cyr2010 <- cyr[cyr$wave==2010, ]  # aggregated to country-year
```

Our outcome of interest will be the variable <tt>marriage</tt>, which is
the respondent’s approval of same-sex marraige (10=strongly approve,
1=strongly disapprove). Consider the two extreme models, one where we
ignore the country and one where we aggregate to the country level, that
estimate the relationship between religiosity and approval.

``` r
## individual observations
m1 <- lm(marriage ~ rel_importance, data=df2010)
## aggregated to country level
m2 <- lm(marriage ~ rel_importance, data=cyr2010)

confint(m1)  # much tighter 
```

    ##                    2.5 %    97.5 %
    ## (Intercept)    2.0797690 2.2295725
    ## rel_importance 0.7584374 0.8389646

``` r
confint(m2)
```

    ##                    2.5 %    97.5 %
    ## (Intercept)    -2.770279 0.8421447
    ## rel_importance  1.637191 3.7866935

Notice that the confidence interval is much tighter for the first model.
This is because the N is much larger. These are asking fundamentally
different questions (effect of an individual’s religiousity on her
approval vs. effect of country-year average religiosity on average
approval), but in a sense the latter is a bit more flexible. The former
assumes constant effects of religiosity on each individual’s approval,
while the latter only assumes constant effects of an average on an
average. Note that the former assumption implies the latter, but the
latter does not imply the former. The latter model allows effects to be
arbitrarily heterogeneous accross individuals, so long as the aggregated
effects end up being constant.

Multilevel models can be a middle ground between the two, allowing for
specific forms of heterogeneity. E.g., the slope can vary additivly by
country.

``` r
m3 <- lme4::lmer(marriage ~ LARI + (0 + LARI | country), data=df2010)
summary(m3)
```

    ## Linear mixed model fit by REML ['lmerMod']
    ## Formula: marriage ~ LARI + (0 + LARI | country)
    ##    Data: df2010
    ## 
    ## REML criterion at convergence: 146098.8
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -1.7366 -0.6807 -0.4562  0.6513  2.6996 
    ## 
    ## Random effects:
    ##  Groups   Name Variance Std.Dev.
    ##  country  LARI 0.2583   0.5082  
    ##  Residual      8.9307   2.9884  
    ## Number of obs: 29042, groups:  country, 17
    ## 
    ## Fixed effects:
    ##             Estimate Std. Error t value
    ## (Intercept)   2.9190     0.4906   5.950
    ## LARI          0.1810     0.2718   0.666
    ## 
    ## Correlation of Fixed Effects:
    ##      (Intr)
    ## LARI -0.890

There are a number of ways to fit this model. The <tt>lme4</tt> package
uses mixed effects models, which are composed of “fixed effects” and
“random effects.”

``` r
## some minor variations
# random intercept
lme4::lmer(marriage ~ LARI + (1 + LARI | country), data=df2010)
```

    ## Linear mixed model fit by REML ['lmerMod']
    ## Formula: marriage ~ LARI + (1 + LARI | country)
    ##    Data: df2010
    ## REML criterion at convergence: 146089
    ## Random effects:
    ##  Groups   Name        Std.Dev. Corr 
    ##  country  (Intercept) 2.470         
    ##           LARI        1.056    -0.99
    ##  Residual             2.988         
    ## Number of obs: 29042, groups:  country, 17
    ## Fixed Effects:
    ## (Intercept)         LARI  
    ##      1.2705       0.7601

``` r
lme4::lmer(marriage ~ LARI + (LARI | country), data=df2010)
```

    ## Linear mixed model fit by REML ['lmerMod']
    ## Formula: marriage ~ LARI + (LARI | country)
    ##    Data: df2010
    ## REML criterion at convergence: 146089
    ## Random effects:
    ##  Groups   Name        Std.Dev. Corr 
    ##  country  (Intercept) 2.470         
    ##           LARI        1.056    -0.99
    ##  Residual             2.988         
    ## Number of obs: 29042, groups:  country, 17
    ## Fixed Effects:
    ## (Intercept)         LARI  
    ##      1.2705       0.7601

``` r
# random intercept independent of slope
lme4::lmer(marriage ~ LARI + (1 | country) + (0 + LARI | country), data=df2010)
```

    ## Linear mixed model fit by REML ['lmerMod']
    ## Formula: marriage ~ LARI + (1 | country) + (0 + LARI | country)
    ##    Data: df2010
    ## REML criterion at convergence: 146092.3
    ## Random effects:
    ##  Groups    Name        Std.Dev.
    ##  country   (Intercept) 0.8892  
    ##  country.1 LARI        0.1148  
    ##  Residual              2.9884  
    ## Number of obs: 29042, groups:  country, 17
    ## Fixed Effects:
    ## (Intercept)         LARI  
    ##      1.9819       0.5961

## Bayesian Statistics

Another way of doing multilevel modelling is using Bayesian statistics.
In general, Bayesians assume that there is a prior distribution over the
parameters and a distribution of the data given the parameters
(likelihood), and combine these to get a posterior.

### <tt>brms</tt>

``` r
df2010_unlabelled <- apply(df2010, MARGIN=2, as.numeric)
```

    ## Warning in apply(df2010, MARGIN = 2, as.numeric): NAs introduced by coercion

``` r
out_brm <- brms::brm(marriage ~ LARI + (1 + LARI | country),
                     data=df2010_unlabelled[sample(nrow(df2010), 1000), ])
```

    ## Warning: Rows containing NAs were excluded from the model.

    ## Compiling Stan program...

    ## Trying to compile a simple C file

    ## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
    ## clang -mmacosx-version-min=10.13 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DBOOST_NO_AUTO_PTR  -include '/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/usr/local/include   -fPIC  -Wall -g -O2  -c foo.c -o foo.o
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:88:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:1: error: unknown type name 'namespace'
    ## namespace Eigen {
    ## ^
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:16: error: expected ';' after top level declarator
    ## namespace Eigen {
    ##                ^
    ##                ;
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:96:10: fatal error: 'complex' file not found
    ## #include <complex>
    ##          ^~~~~~~~~
    ## 3 errors generated.
    ## make: *** [foo.o] Error 1

    ## Start sampling

    ## 
    ## SAMPLING FOR MODEL 'f75585a5268cc771e71de172118af2c6' NOW (CHAIN 1).
    ## Chain 1: 
    ## Chain 1: Gradient evaluation took 0.000199 seconds
    ## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 1.99 seconds.
    ## Chain 1: Adjust your expectations accordingly!
    ## Chain 1: 
    ## Chain 1: 
    ## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 1: 
    ## Chain 1:  Elapsed Time: 6.0161 seconds (Warm-up)
    ## Chain 1:                6.10945 seconds (Sampling)
    ## Chain 1:                12.1255 seconds (Total)
    ## Chain 1: 
    ## 
    ## SAMPLING FOR MODEL 'f75585a5268cc771e71de172118af2c6' NOW (CHAIN 2).
    ## Chain 2: 
    ## Chain 2: Gradient evaluation took 0.000113 seconds
    ## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 1.13 seconds.
    ## Chain 2: Adjust your expectations accordingly!
    ## Chain 2: 
    ## Chain 2: 
    ## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 2: 
    ## Chain 2:  Elapsed Time: 6.70193 seconds (Warm-up)
    ## Chain 2:                4.86862 seconds (Sampling)
    ## Chain 2:                11.5706 seconds (Total)
    ## Chain 2: 
    ## 
    ## SAMPLING FOR MODEL 'f75585a5268cc771e71de172118af2c6' NOW (CHAIN 3).
    ## Chain 3: 
    ## Chain 3: Gradient evaluation took 0.000107 seconds
    ## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 1.07 seconds.
    ## Chain 3: Adjust your expectations accordingly!
    ## Chain 3: 
    ## Chain 3: 
    ## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 3: 
    ## Chain 3:  Elapsed Time: 7.59656 seconds (Warm-up)
    ## Chain 3:                5.16158 seconds (Sampling)
    ## Chain 3:                12.7581 seconds (Total)
    ## Chain 3: 
    ## 
    ## SAMPLING FOR MODEL 'f75585a5268cc771e71de172118af2c6' NOW (CHAIN 4).
    ## Chain 4: 
    ## Chain 4: Gradient evaluation took 0.000114 seconds
    ## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 1.14 seconds.
    ## Chain 4: Adjust your expectations accordingly!
    ## Chain 4: 
    ## Chain 4: 
    ## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 4: 
    ## Chain 4:  Elapsed Time: 6.94975 seconds (Warm-up)
    ## Chain 4:                6.10765 seconds (Sampling)
    ## Chain 4:                13.0574 seconds (Total)
    ## Chain 4:

    ## Warning: There were 346 divergent transitions after warmup. See
    ## https://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
    ## to find out why this is a problem and how to eliminate them.

    ## Warning: Examine the pairs() plot to diagnose sampling problems

    ## Warning: The largest R-hat is 1.09, indicating chains have not mixed.
    ## Running the chains for more iterations may help. See
    ## https://mc-stan.org/misc/warnings.html#r-hat

    ## Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
    ## Running the chains for more iterations may help. See
    ## https://mc-stan.org/misc/warnings.html#bulk-ess

    ## Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
    ## Running the chains for more iterations may help. See
    ## https://mc-stan.org/misc/warnings.html#tail-ess

``` r
summary(out_brm)
```

    ## Warning: Parts of the model have not converged (some Rhats are > 1.05). Be
    ## careful when analysing the results! We recommend running more iterations and/or
    ## setting stronger priors.

    ## Warning: There were 346 divergent transitions after warmup. Increasing
    ## adapt_delta above 0.8 may help. See http://mc-stan.org/misc/
    ## warnings.html#divergent-transitions-after-warmup

    ##  Family: gaussian 
    ##   Links: mu = identity; sigma = identity 
    ## Formula: marriage ~ LARI + (1 + LARI | country) 
    ##    Data: df2010_unlabelled[sample(nrow(df2010), 1000), ] (Number of observations: 949) 
    ##   Draws: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
    ##          total post-warmup draws = 4000
    ## 
    ## Group-Level Effects: 
    ## ~country (Number of levels: 17) 
    ##                     Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## sd(Intercept)           0.72      0.48     0.03     2.01 1.07      100       34
    ## sd(LARI)                0.33      0.22     0.02     0.88 1.08       41       50
    ## cor(Intercept,LARI)    -0.26      0.58    -0.98     0.89 1.05       75       49
    ## 
    ## Population-Level Effects: 
    ##           Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## Intercept     2.01      0.58     0.90     3.12 1.02      237     2095
    ## LARI          0.59      0.25     0.10     1.04 1.03      173      363
    ## 
    ## Family Specific Parameters: 
    ##       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## sigma     3.04      0.07     2.91     3.18 1.02     2873     1647
    ## 
    ## Draws were sampled using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

### <tt>rstan</tt>

One of the most flexibe ways of fitting Bayesian models is to use
<tt>rstan</tt>. Stan models are infinitely customizable and more
transparent than <tt>brms</tt>.

#### Simple model

``` r
N <- 100

set.seed(123)
mu <- rnorm(N)
sigma <- abs(rcauchy(N))
y <- rnorm(N, mean=mu, sd=sigma)

simple <-"
//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N;
  vector[N] y;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real mu;
  real<lower=0> sigma;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  y ~ normal(mu, sigma);
}
"

dat <- list("N"=N, "y"=y)

out_simple <- rstan::stan(model_code=simple, data=dat, verbose = F)
```

    ## Trying to compile a simple C file

    ## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
    ## clang -mmacosx-version-min=10.13 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DBOOST_NO_AUTO_PTR  -include '/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/usr/local/include   -fPIC  -Wall -g -O2  -c foo.c -o foo.o
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:88:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:1: error: unknown type name 'namespace'
    ## namespace Eigen {
    ## ^
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:16: error: expected ';' after top level declarator
    ## namespace Eigen {
    ##                ^
    ##                ;
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:96:10: fatal error: 'complex' file not found
    ## #include <complex>
    ##          ^~~~~~~~~
    ## 3 errors generated.
    ## make: *** [foo.o] Error 1
    ## 
    ## SAMPLING FOR MODEL '9d111088d7e6f1c47e3c963d5d71e6bb' NOW (CHAIN 1).
    ## Chain 1: 
    ## Chain 1: Gradient evaluation took 2.6e-05 seconds
    ## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.26 seconds.
    ## Chain 1: Adjust your expectations accordingly!
    ## Chain 1: 
    ## Chain 1: 
    ## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 1: 
    ## Chain 1:  Elapsed Time: 0.014424 seconds (Warm-up)
    ## Chain 1:                0.012003 seconds (Sampling)
    ## Chain 1:                0.026427 seconds (Total)
    ## Chain 1: 
    ## 
    ## SAMPLING FOR MODEL '9d111088d7e6f1c47e3c963d5d71e6bb' NOW (CHAIN 2).
    ## Chain 2: 
    ## Chain 2: Gradient evaluation took 3e-06 seconds
    ## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.03 seconds.
    ## Chain 2: Adjust your expectations accordingly!
    ## Chain 2: 
    ## Chain 2: 
    ## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 2: 
    ## Chain 2:  Elapsed Time: 0.013909 seconds (Warm-up)
    ## Chain 2:                0.008736 seconds (Sampling)
    ## Chain 2:                0.022645 seconds (Total)
    ## Chain 2: 
    ## 
    ## SAMPLING FOR MODEL '9d111088d7e6f1c47e3c963d5d71e6bb' NOW (CHAIN 3).
    ## Chain 3: 
    ## Chain 3: Gradient evaluation took 4e-06 seconds
    ## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.04 seconds.
    ## Chain 3: Adjust your expectations accordingly!
    ## Chain 3: 
    ## Chain 3: 
    ## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 3: 
    ## Chain 3:  Elapsed Time: 0.013808 seconds (Warm-up)
    ## Chain 3:                0.00954 seconds (Sampling)
    ## Chain 3:                0.023348 seconds (Total)
    ## Chain 3: 
    ## 
    ## SAMPLING FOR MODEL '9d111088d7e6f1c47e3c963d5d71e6bb' NOW (CHAIN 4).
    ## Chain 4: 
    ## Chain 4: Gradient evaluation took 3e-06 seconds
    ## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.03 seconds.
    ## Chain 4: Adjust your expectations accordingly!
    ## Chain 4: 
    ## Chain 4: 
    ## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 4: 
    ## Chain 4:  Elapsed Time: 0.014091 seconds (Warm-up)
    ## Chain 4:                0.01103 seconds (Sampling)
    ## Chain 4:                0.025121 seconds (Total)
    ## Chain 4:

``` r
print(out_simple)
```

    ## Inference for Stan model: 9d111088d7e6f1c47e3c963d5d71e6bb.
    ## 4 chains, each with iter=2000; warmup=1000; thin=1; 
    ## post-warmup draws per chain=1000, total post-warmup draws=4000.
    ## 
    ##          mean se_mean   sd    2.5%     25%     50%     75%   97.5% n_eff Rhat
    ## mu      -1.42    0.03 1.51   -4.36   -2.41   -1.41   -0.43    1.57  2650    1
    ## sigma   15.23    0.02 1.09   13.29   14.46   15.15   15.93   17.51  3474    1
    ## lp__  -318.65    0.02 0.99 -321.22 -319.03 -318.34 -317.95 -317.69  1626    1
    ## 
    ## Samples were drawn using NUTS(diag_e) at Fri May 13 11:35:21 2022.
    ## For each parameter, n_eff is a crude measure of effective sample size,
    ## and Rhat is the potential scale reduction factor on split chains (at 
    ## convergence, Rhat=1).

``` r
print(out_simple)
```

    ## Inference for Stan model: 9d111088d7e6f1c47e3c963d5d71e6bb.
    ## 4 chains, each with iter=2000; warmup=1000; thin=1; 
    ## post-warmup draws per chain=1000, total post-warmup draws=4000.
    ## 
    ##          mean se_mean   sd    2.5%     25%     50%     75%   97.5% n_eff Rhat
    ## mu      -1.42    0.03 1.51   -4.36   -2.41   -1.41   -0.43    1.57  2650    1
    ## sigma   15.23    0.02 1.09   13.29   14.46   15.15   15.93   17.51  3474    1
    ## lp__  -318.65    0.02 0.99 -321.22 -319.03 -318.34 -317.95 -317.69  1626    1
    ## 
    ## Samples were drawn using NUTS(diag_e) at Fri May 13 11:35:21 2022.
    ## For each parameter, n_eff is a crude measure of effective sample size,
    ## and Rhat is the potential scale reduction factor on split chains (at 
    ## convergence, Rhat=1).

#### Simple Regression

``` r
simple_reg <- "
data {
  int<lower=0> N;
  vector[N] y;
  vector[N] x;
}

parameters {
  real<lower=0> sigma;
  real beta;
}

model {
  y ~ normal(x*beta, sigma);
}

generated quantities {
  real sim_y;
  sim_y = beta*100; // value of y if x=100
}
"

x <- rnorm(N)
beta <- rnorm(N)
y <- x*beta

out_simple_reg <- rstan::stan(model_code=simple_reg, 
                              data=list("N"=N, "y"=y, "x"=x), verbose=F)
```

    ## Trying to compile a simple C file

    ## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
    ## clang -mmacosx-version-min=10.13 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DBOOST_NO_AUTO_PTR  -include '/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/usr/local/include   -fPIC  -Wall -g -O2  -c foo.c -o foo.o
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:88:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:1: error: unknown type name 'namespace'
    ## namespace Eigen {
    ## ^
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:16: error: expected ';' after top level declarator
    ## namespace Eigen {
    ##                ^
    ##                ;
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:96:10: fatal error: 'complex' file not found
    ## #include <complex>
    ##          ^~~~~~~~~
    ## 3 errors generated.
    ## make: *** [foo.o] Error 1
    ## 
    ## SAMPLING FOR MODEL 'f0f230962e09cf3cbc6a6f02b3d4e46f' NOW (CHAIN 1).
    ## Chain 1: 
    ## Chain 1: Gradient evaluation took 0.000124 seconds
    ## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 1.24 seconds.
    ## Chain 1: Adjust your expectations accordingly!
    ## Chain 1: 
    ## Chain 1: 
    ## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 1: 
    ## Chain 1:  Elapsed Time: 0.023106 seconds (Warm-up)
    ## Chain 1:                0.025165 seconds (Sampling)
    ## Chain 1:                0.048271 seconds (Total)
    ## Chain 1: 
    ## 
    ## SAMPLING FOR MODEL 'f0f230962e09cf3cbc6a6f02b3d4e46f' NOW (CHAIN 2).
    ## Chain 2: 
    ## Chain 2: Gradient evaluation took 6e-06 seconds
    ## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.06 seconds.
    ## Chain 2: Adjust your expectations accordingly!
    ## Chain 2: 
    ## Chain 2: 
    ## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 2: 
    ## Chain 2:  Elapsed Time: 0.024723 seconds (Warm-up)
    ## Chain 2:                0.019067 seconds (Sampling)
    ## Chain 2:                0.04379 seconds (Total)
    ## Chain 2: 
    ## 
    ## SAMPLING FOR MODEL 'f0f230962e09cf3cbc6a6f02b3d4e46f' NOW (CHAIN 3).
    ## Chain 3: 
    ## Chain 3: Gradient evaluation took 9e-06 seconds
    ## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.09 seconds.
    ## Chain 3: Adjust your expectations accordingly!
    ## Chain 3: 
    ## Chain 3: 
    ## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 3: 
    ## Chain 3:  Elapsed Time: 0.023811 seconds (Warm-up)
    ## Chain 3:                0.024564 seconds (Sampling)
    ## Chain 3:                0.048375 seconds (Total)
    ## Chain 3: 
    ## 
    ## SAMPLING FOR MODEL 'f0f230962e09cf3cbc6a6f02b3d4e46f' NOW (CHAIN 4).
    ## Chain 4: 
    ## Chain 4: Gradient evaluation took 1e-05 seconds
    ## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.1 seconds.
    ## Chain 4: Adjust your expectations accordingly!
    ## Chain 4: 
    ## Chain 4: 
    ## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 4: 
    ## Chain 4:  Elapsed Time: 0.023885 seconds (Warm-up)
    ## Chain 4:                0.024275 seconds (Sampling)
    ## Chain 4:                0.04816 seconds (Total)
    ## Chain 4:

``` r
print(out_simple_reg)
```

    ## Inference for Stan model: f0f230962e09cf3cbc6a6f02b3d4e46f.
    ## 4 chains, each with iter=2000; warmup=1000; thin=1; 
    ## post-warmup draws per chain=1000, total post-warmup draws=4000.
    ## 
    ##         mean se_mean   sd   2.5%    25%    50%    75%  97.5% n_eff Rhat
    ## sigma   0.96    0.00 0.07   0.84   0.91   0.96   1.00   1.10  3721    1
    ## beta   -0.09    0.00 0.10  -0.28  -0.15  -0.09  -0.02   0.10  3118    1
    ## sim_y  -8.78    0.17 9.59 -27.70 -15.08  -8.90  -2.31   9.73  3118    1
    ## lp__  -45.38    0.03 1.02 -48.14 -45.72 -45.06 -44.68 -44.43  1610    1
    ## 
    ## Samples were drawn using NUTS(diag_e) at Fri May 13 11:35:35 2022.
    ## For each parameter, n_eff is a crude measure of effective sample size,
    ## and Rhat is the potential scale reduction factor on split chains (at 
    ## convergence, Rhat=1).

#### Multilevel Regression

``` r
simple_ml <- "
data {
  int<lower=0> N;
  vector[N] y;
  vector[N] x;
  int<lower=0> G;  // number of groups
  int<lower=1, upper=G> group[N];  // ID for group 
}

parameters {
  real<lower=0> sigma;  // variance for response
  
  real beta;
  real<lower=0> sigma_b;  // variance for slope
  
  vector[G] beta_g;  // group-specific component of slope
  real<lower=0> sigma_bg;  // variance for group-specific slope
}

model {
  sigma ~ gamma(2, .1);  // prior
  
  sigma_b ~ cauchy(0, 2.5); // hyperprior 
  beta ~ normal(0, sigma_b);
  
  sigma_bg ~ cauchy(0, 2.5); // hyperprior 
  for (g in 1:G) {
    beta_g[g] ~ normal(0, sigma_bg);  // prior 
  }
  
{  // variable declarations have to come at top of block
  vector[N] mu;
  for (i in 1:N) {
    mu[i] = (beta + beta_g[group[i]])*x[i];
  }
  y ~ normal(mu, sigma);
}

}
"

group <- rep(1:5, each=N/5)
out_simple_ml <- rstan::stan(model_code=simple_ml, 
                             data=list("N"=N, "y"=y, "x"=x,
                                       "G"=5, "group"=group),
                             verbose=F)
```

    ## Trying to compile a simple C file

    ## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
    ## clang -mmacosx-version-min=10.13 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DBOOST_NO_AUTO_PTR  -include '/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/usr/local/include   -fPIC  -Wall -g -O2  -c foo.c -o foo.o
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:88:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:1: error: unknown type name 'namespace'
    ## namespace Eigen {
    ## ^
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:16: error: expected ';' after top level declarator
    ## namespace Eigen {
    ##                ^
    ##                ;
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:96:10: fatal error: 'complex' file not found
    ## #include <complex>
    ##          ^~~~~~~~~
    ## 3 errors generated.
    ## make: *** [foo.o] Error 1
    ## 
    ## SAMPLING FOR MODEL 'b33f42eeb9a9bfc015be87b259869ed9' NOW (CHAIN 1).
    ## Chain 1: 
    ## Chain 1: Gradient evaluation took 4.5e-05 seconds
    ## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.45 seconds.
    ## Chain 1: Adjust your expectations accordingly!
    ## Chain 1: 
    ## Chain 1: 
    ## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 1: 
    ## Chain 1:  Elapsed Time: 0.15018 seconds (Warm-up)
    ## Chain 1:                0.177294 seconds (Sampling)
    ## Chain 1:                0.327474 seconds (Total)
    ## Chain 1: 
    ## 
    ## SAMPLING FOR MODEL 'b33f42eeb9a9bfc015be87b259869ed9' NOW (CHAIN 2).
    ## Chain 2: 
    ## Chain 2: Gradient evaluation took 1.1e-05 seconds
    ## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.11 seconds.
    ## Chain 2: Adjust your expectations accordingly!
    ## Chain 2: 
    ## Chain 2: 
    ## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 2: 
    ## Chain 2:  Elapsed Time: 0.157534 seconds (Warm-up)
    ## Chain 2:                0.109867 seconds (Sampling)
    ## Chain 2:                0.267401 seconds (Total)
    ## Chain 2: 
    ## 
    ## SAMPLING FOR MODEL 'b33f42eeb9a9bfc015be87b259869ed9' NOW (CHAIN 3).
    ## Chain 3: 
    ## Chain 3: Gradient evaluation took 1.4e-05 seconds
    ## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.14 seconds.
    ## Chain 3: Adjust your expectations accordingly!
    ## Chain 3: 
    ## Chain 3: 
    ## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 3: 
    ## Chain 3:  Elapsed Time: 0.149644 seconds (Warm-up)
    ## Chain 3:                0.110585 seconds (Sampling)
    ## Chain 3:                0.260229 seconds (Total)
    ## Chain 3: 
    ## 
    ## SAMPLING FOR MODEL 'b33f42eeb9a9bfc015be87b259869ed9' NOW (CHAIN 4).
    ## Chain 4: 
    ## Chain 4: Gradient evaluation took 1.2e-05 seconds
    ## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.12 seconds.
    ## Chain 4: Adjust your expectations accordingly!
    ## Chain 4: 
    ## Chain 4: 
    ## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 4: 
    ## Chain 4:  Elapsed Time: 0.172578 seconds (Warm-up)
    ## Chain 4:                0.125171 seconds (Sampling)
    ## Chain 4:                0.297749 seconds (Total)
    ## Chain 4:

    ## Warning: There were 92 divergent transitions after warmup. See
    ## https://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
    ## to find out why this is a problem and how to eliminate them.

    ## Warning: Examine the pairs() plot to diagnose sampling problems

    ## Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
    ## Running the chains for more iterations may help. See
    ## https://mc-stan.org/misc/warnings.html#bulk-ess

    ## Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
    ## Running the chains for more iterations may help. See
    ## https://mc-stan.org/misc/warnings.html#tail-ess

``` r
print(out_simple_ml)
```

    ## Inference for Stan model: b33f42eeb9a9bfc015be87b259869ed9.
    ## 4 chains, each with iter=2000; warmup=1000; thin=1; 
    ## post-warmup draws per chain=1000, total post-warmup draws=4000.
    ## 
    ##             mean se_mean   sd   2.5%    25%    50%    75%  97.5% n_eff Rhat
    ## sigma       0.95    0.00 0.07   0.83   0.90   0.95   1.00   1.11  1827 1.00
    ## beta        0.00    0.02 0.23  -0.34  -0.11  -0.02   0.06   0.48   188 1.02
    ## sigma_b     1.18    0.08 3.04   0.02   0.17   0.45   1.22   5.95  1485 1.00
    ## beta_g[1]  -0.23    0.02 0.27  -0.83  -0.34  -0.19  -0.07   0.11   200 1.02
    ## beta_g[2]   0.05    0.02 0.26  -0.44  -0.05   0.04   0.17   0.53   283 1.01
    ## beta_g[3]  -0.05    0.02 0.26  -0.60  -0.14  -0.02   0.07   0.35   223 1.01
    ## beta_g[4]   0.15    0.01 0.27  -0.30   0.01   0.12   0.29   0.71   395 1.01
    ## beta_g[5]  -0.04    0.02 0.26  -0.58  -0.13  -0.01   0.08   0.38   243 1.02
    ## sigma_bg    0.30    0.02 0.27   0.04   0.14   0.24   0.38   0.99   198 1.02
    ## lp__      -40.76    0.20 3.14 -47.73 -42.56 -40.52 -38.73 -35.04   250 1.02
    ## 
    ## Samples were drawn using NUTS(diag_e) at Fri May 13 11:35:50 2022.
    ## For each parameter, n_eff is a crude measure of effective sample size,
    ## and Rhat is the potential scale reduction factor on split chains (at 
    ## convergence, Rhat=1).

``` r
set.seed(123)
keep <- complete.cases(df2010[, c("marriage", "rel_importance", "country")])
sub_df2010 <- df2010[keep, ] %>%
  .[sample(nrow(.), 1000), ]
out_simple_ml_LAPOP <- rstan::stan(model_code=simple_ml, 
                             data=list("N"=nrow(sub_df2010), 
                                       "y"=sub_df2010$marriage,
                                       "x"=sub_df2010$rel_importance,
                                       "G"=length(unique(sub_df2010$country)),
                                       "group"=as.numeric(factor(sub_df2010$country))),
                             verbose=F)
```

    ## 
    ## SAMPLING FOR MODEL 'b33f42eeb9a9bfc015be87b259869ed9' NOW (CHAIN 1).
    ## Chain 1: 
    ## Chain 1: Gradient evaluation took 9.7e-05 seconds
    ## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.97 seconds.
    ## Chain 1: Adjust your expectations accordingly!
    ## Chain 1: 
    ## Chain 1: 
    ## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 1: 
    ## Chain 1:  Elapsed Time: 0.893855 seconds (Warm-up)
    ## Chain 1:                0.906325 seconds (Sampling)
    ## Chain 1:                1.80018 seconds (Total)
    ## Chain 1: 
    ## 
    ## SAMPLING FOR MODEL 'b33f42eeb9a9bfc015be87b259869ed9' NOW (CHAIN 2).
    ## Chain 2: 
    ## Chain 2: Gradient evaluation took 6.2e-05 seconds
    ## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.62 seconds.
    ## Chain 2: Adjust your expectations accordingly!
    ## Chain 2: 
    ## Chain 2: 
    ## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 2: 
    ## Chain 2:  Elapsed Time: 0.928738 seconds (Warm-up)
    ## Chain 2:                0.925203 seconds (Sampling)
    ## Chain 2:                1.85394 seconds (Total)
    ## Chain 2: 
    ## 
    ## SAMPLING FOR MODEL 'b33f42eeb9a9bfc015be87b259869ed9' NOW (CHAIN 3).
    ## Chain 3: 
    ## Chain 3: Gradient evaluation took 6.9e-05 seconds
    ## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.69 seconds.
    ## Chain 3: Adjust your expectations accordingly!
    ## Chain 3: 
    ## Chain 3: 
    ## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 3: 
    ## Chain 3:  Elapsed Time: 0.949162 seconds (Warm-up)
    ## Chain 3:                0.810494 seconds (Sampling)
    ## Chain 3:                1.75966 seconds (Total)
    ## Chain 3: 
    ## 
    ## SAMPLING FOR MODEL 'b33f42eeb9a9bfc015be87b259869ed9' NOW (CHAIN 4).
    ## Chain 4: 
    ## Chain 4: Gradient evaluation took 5.8e-05 seconds
    ## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.58 seconds.
    ## Chain 4: Adjust your expectations accordingly!
    ## Chain 4: 
    ## Chain 4: 
    ## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
    ## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
    ## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    ## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    ## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
    ## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
    ## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
    ## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
    ## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 4: 
    ## Chain 4:  Elapsed Time: 0.856587 seconds (Warm-up)
    ## Chain 4:                0.827627 seconds (Sampling)
    ## Chain 4:                1.68421 seconds (Total)
    ## Chain 4:

``` r
print(out_simple_ml_LAPOP)
```

    ## Inference for Stan model: b33f42eeb9a9bfc015be87b259869ed9.
    ## 4 chains, each with iter=2000; warmup=1000; thin=1; 
    ## post-warmup draws per chain=1000, total post-warmup draws=4000.
    ## 
    ##                mean se_mean   sd     2.5%      25%      50%      75%    97.5%
    ## sigma          3.10    0.00 0.07     2.98     3.06     3.10     3.15     3.24
    ## beta           1.74    0.00 0.15     1.44     1.64     1.74     1.83     2.03
    ## sigma_b        3.40    0.10 4.45     0.82     1.54     2.33     3.75    12.29
    ## beta_g[1]      0.55    0.01 0.26     0.03     0.38     0.55     0.72     1.07
    ## beta_g[2]     -0.02    0.00 0.28    -0.55    -0.20    -0.02     0.17     0.54
    ## beta_g[3]     -0.51    0.01 0.27    -1.05    -0.71    -0.51    -0.33     0.02
    ## beta_g[4]     -0.04    0.01 0.26    -0.53    -0.21    -0.04     0.14     0.47
    ## beta_g[5]     -0.38    0.01 0.28    -0.94    -0.56    -0.37    -0.19     0.16
    ## beta_g[6]     -0.48    0.00 0.23    -0.93    -0.63    -0.47    -0.32    -0.05
    ## beta_g[7]      0.11    0.00 0.25    -0.39    -0.05     0.11     0.28     0.60
    ## beta_g[8]      0.20    0.01 0.25    -0.27     0.03     0.20     0.37     0.68
    ## beta_g[9]     -0.35    0.00 0.20    -0.76    -0.49    -0.35    -0.22     0.05
    ## beta_g[10]    -0.04    0.00 0.22    -0.49    -0.19    -0.04     0.11     0.40
    ## beta_g[11]     0.10    0.01 0.25    -0.38    -0.07     0.09     0.26     0.60
    ## beta_g[12]    -0.13    0.00 0.26    -0.65    -0.31    -0.13     0.04     0.38
    ## beta_g[13]     0.39    0.01 0.21    -0.01     0.24     0.38     0.52     0.81
    ## beta_g[14]    -0.21    0.00 0.20    -0.61    -0.34    -0.21    -0.08     0.18
    ## beta_g[15]     1.09    0.01 0.24     0.63     0.92     1.08     1.25     1.58
    ## beta_g[16]    -0.64    0.00 0.23    -1.10    -0.78    -0.63    -0.49    -0.19
    ## beta_g[17]     0.55    0.01 0.23     0.10     0.40     0.55     0.70     1.02
    ## sigma_bg       0.54    0.00 0.13     0.34     0.45     0.52     0.61     0.82
    ## lp__       -1628.42    0.09 3.44 -1636.22 -1630.46 -1628.10 -1626.01 -1622.80
    ##            n_eff Rhat
    ## sigma       5977    1
    ## beta         999    1
    ## sigma_b     1940    1
    ## beta_g[1]   2261    1
    ## beta_g[2]   3291    1
    ## beta_g[3]   2685    1
    ## beta_g[4]   2588    1
    ## beta_g[5]   2677    1
    ## beta_g[6]   2150    1
    ## beta_g[7]   2636    1
    ## beta_g[8]   2341    1
    ## beta_g[9]   1958    1
    ## beta_g[10]  2004    1
    ## beta_g[11]  2442    1
    ## beta_g[12]  2813    1
    ## beta_g[13]  1720    1
    ## beta_g[14]  1751    1
    ## beta_g[15]  2162    1
    ## beta_g[16]  2141    1
    ## beta_g[17]  2109    1
    ## sigma_bg    2820    1
    ## lp__        1409    1
    ## 
    ## Samples were drawn using NUTS(diag_e) at Fri May 13 11:35:57 2022.
    ## For each parameter, n_eff is a crude measure of effective sample size,
    ## and Rhat is the potential scale reduction factor on split chains (at 
    ## convergence, Rhat=1).

``` r
rstan::plot(out_simple_ml_LAPOP, pars="beta")
```

    ## ci_level: 0.8 (80% intervals)

    ## outer_level: 0.95 (95% intervals)

![](w7_multilevel-panel-bayesian_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

``` r
rstan::plot(out_simple_ml_LAPOP, pars=paste0("beta_g[", 1:17, "]")) +
  ggplot2::geom_vline(xintercept=0) +
  ggplot2::theme_bw()
```

    ## ci_level: 0.8 (80% intervals)

    ## outer_level: 0.95 (95% intervals)

![](w7_multilevel-panel-bayesian_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

#### Multilevel Model with Time Dimension

The main independent variable of interest is the <tt>LARI</tt>, which is
an index of the number of LGBTQ rights in that country-year. We allow
the slope to vary additively by country and year. Religious importance
is now a control instead, along with an indicator for evangelicalism,
and their slopes are constant.

``` r
set.seed(123)
keep <- complete.cases(df[, c("marriage", "rel_importance", "evangelical", "LARI", "country", "year")])
sub_df<- df[keep, ] %>%
  .[sample(nrow(.), 1000), ]
dat <- list(y = sub_df$marriage,
            x = sub_df[, c("rel_importance", "evangelical")],
            d = sub_df$LARI,
            gg = as.numeric(factor(sub_df$country)),  # group
            tt = as.numeric(factor(sub_df$year)),  # time
            Ti = length(unique(sub_df$year)),  # number of time periods
            G = length(unique(sub_df$country)),  # number of groups
            N = nrow(sub_df),
            K = 2)  # number of controls
out_ml <- rstan::stan(file="multilevel.stan", data = dat,
                      seed=123, iter=2000, cores = 4, chains = 4)
```

    ## Trying to compile a simple C file

    ## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
    ## clang -mmacosx-version-min=10.13 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.1/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DBOOST_NO_AUTO_PTR  -include '/Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/usr/local/include   -fPIC  -Wall -g -O2  -c foo.c -o foo.o
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:88:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:1: error: unknown type name 'namespace'
    ## namespace Eigen {
    ## ^
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:16: error: expected ';' after top level declarator
    ## namespace Eigen {
    ##                ^
    ##                ;
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/StanHeaders/include/stan/math/prim/mat/fun/Eigen.hpp:13:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## /Library/Frameworks/R.framework/Versions/4.1/Resources/library/RcppEigen/include/Eigen/Core:96:10: fatal error: 'complex' file not found
    ## #include <complex>
    ##          ^~~~~~~~~
    ## 3 errors generated.
    ## make: *** [foo.o] Error 1

    ## Warning: There were 1 divergent transitions after warmup. See
    ## https://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
    ## to find out why this is a problem and how to eliminate them.

    ## Warning: There were 3999 transitions after warmup that exceeded the maximum treedepth. Increase max_treedepth above 10. See
    ## https://mc-stan.org/misc/warnings.html#maximum-treedepth-exceeded

    ## Warning: Examine the pairs() plot to diagnose sampling problems

    ## Warning: The largest R-hat is 1.98, indicating chains have not mixed.
    ## Running the chains for more iterations may help. See
    ## https://mc-stan.org/misc/warnings.html#r-hat

    ## Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
    ## Running the chains for more iterations may help. See
    ## https://mc-stan.org/misc/warnings.html#bulk-ess

    ## Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
    ## Running the chains for more iterations may help. See
    ## https://mc-stan.org/misc/warnings.html#tail-ess

``` r
print(out_ml)
```

    ## Inference for Stan model: multilevel.
    ## 4 chains, each with iter=2000; warmup=1000; thin=1; 
    ## post-warmup draws per chain=1000, total post-warmup draws=4000.
    ## 
    ##                   mean se_mean     sd     2.5%      25%      50%      75%
    ## alpha_G[1]     -122.48  183.48 329.19  -611.47  -391.28  -196.89   170.81
    ## alpha_G[2]     -124.02  183.51 329.23  -613.77  -392.60  -198.42   169.46
    ## alpha_G[3]     -124.85  183.47 329.18  -614.25  -393.17  -198.96   169.08
    ## alpha_G[4]     -123.60  183.51 329.26  -612.33  -392.03  -197.75   170.33
    ## alpha_G[5]     -124.08  183.52 329.29  -613.22  -393.33  -198.46   169.72
    ## alpha_G[6]     -124.12  183.54 329.32  -612.42  -393.71  -198.69   170.23
    ## alpha_G[7]     -124.32  183.44 329.14  -614.40  -393.33  -198.50   169.57
    ## alpha_G[8]     -121.43  183.49 329.21  -611.76  -390.14  -195.74   172.47
    ## alpha_G[9]     -125.31  183.45 329.15  -613.60  -395.09  -199.08   167.87
    ## alpha_G[10]    -124.02  183.49 329.19  -612.94  -392.82  -197.83   169.11
    ## alpha_G[11]    -123.65  183.45 329.14  -611.50  -392.30  -197.41   169.84
    ## alpha_G[12]    -124.26  183.47 329.20  -613.92  -393.13  -198.76   169.77
    ## alpha_G[13]    -122.69  183.45 329.18  -612.63  -391.59  -196.26   171.17
    ## alpha_G[14]    -125.22  183.39 329.08  -614.25  -394.46  -198.75   167.29
    ## alpha_G[15]    -123.86  183.46 329.15  -613.83  -392.90  -197.55   169.84
    ## alpha_G[16]    -124.48  183.49 329.19  -614.71  -393.15  -198.18   168.83
    ## alpha_G[17]    -121.90  183.50 329.14  -612.68  -391.41  -195.60   171.41
    ## alpha_T[1]      126.19  183.49 329.22  -534.53  -167.71   200.17   394.89
    ## alpha_T[2]      125.90  183.49 329.22  -534.52  -168.05   200.09   394.29
    ## alpha_T[3]      125.97  183.48 329.20  -534.66  -168.50   200.16   394.42
    ## alpha_T[4]      127.60  183.47 329.18  -532.61  -166.28   202.22   396.11
    ## alpha_T[5]      126.15  183.46 329.18  -534.48  -167.09   199.87   394.99
    ## mu_raw            0.23    0.03   0.54    -0.82    -0.02     0.16     0.46
    ## sigma_mu_unif     0.00    0.03   0.48    -1.06    -0.25     0.01     0.26
    ## tau_G_raw[1]     -0.14    0.04   0.88    -1.90    -0.71    -0.14     0.43
    ## tau_G_raw[2]      0.10    0.04   0.99    -1.77    -0.58     0.08     0.77
    ## tau_G_raw[3]     -0.04    0.04   0.99    -1.95    -0.72    -0.02     0.63
    ## tau_G_raw[4]     -0.63    0.04   0.94    -2.44    -1.27    -0.65    -0.01
    ## tau_G_raw[5]     -0.01    0.04   1.01    -1.93    -0.69    -0.04     0.68
    ## tau_G_raw[6]     -0.03    0.04   1.01    -2.02    -0.71    -0.03     0.67
    ## tau_G_raw[7]      0.00    0.04   1.01    -2.00    -0.67     0.02     0.67
    ## tau_G_raw[8]     -0.89    0.03   0.67    -2.36    -1.29    -0.84    -0.44
    ## tau_G_raw[9]      0.24    0.04   0.86    -1.43    -0.33     0.28     0.82
    ## tau_G_raw[10]     0.17    0.03   0.75    -1.32    -0.33     0.17     0.65
    ## tau_G_raw[11]    -0.22    0.04   0.88    -1.95    -0.79    -0.22     0.35
    ## tau_G_raw[12]     0.03    0.05   1.00    -1.96    -0.65     0.05     0.71
    ## tau_G_raw[13]     0.63    0.03   0.71    -0.77     0.18     0.64     1.10
    ## tau_G_raw[14]     0.72    0.04   0.93    -1.13     0.09     0.74     1.35
    ## tau_G_raw[15]     0.65    0.03   0.68    -0.76     0.25     0.66     1.07
    ## tau_G_raw[16]     0.01    0.03   0.79    -1.56    -0.51     0.02     0.51
    ## tau_G_raw[17]     0.15    0.04   0.74    -1.41    -0.30     0.17     0.63
    ## tau_T_raw[1]     -0.48    0.04   0.83    -2.18    -1.01    -0.48     0.05
    ## tau_T_raw[2]     -0.06    0.04   0.80    -1.69    -0.56    -0.04     0.46
    ## tau_T_raw[3]      0.29    0.04   0.77    -1.28    -0.20     0.27     0.78
    ## tau_T_raw[4]     -0.25    0.04   0.79    -1.85    -0.76    -0.26     0.24
    ## tau_T_raw[5]      0.55    0.04   0.79    -1.01     0.03     0.56     1.06
    ## sigma_G_unif      0.01    0.03   0.22    -0.36    -0.17     0.02     0.18
    ## sigma_T_unif      0.00    0.00   0.10    -0.21    -0.06     0.00     0.06
    ## beta[1]           0.43    0.00   0.12     0.19     0.35     0.43     0.52
    ## beta[2]          -0.38    0.01   0.28    -0.91    -0.58    -0.38    -0.19
    ## sigma             3.06    0.00   0.07     2.92     3.01     3.06     3.11
    ## sigma_mu          1.28    0.12   2.40     0.02     0.28     0.65     1.47
    ## sigma_G           0.49    0.01   0.27     0.07     0.29     0.45     0.64
    ## sigma_T           0.19    0.01   0.16     0.01     0.07     0.15     0.26
    ## mu                0.16    0.01   0.25    -0.29    -0.01     0.12     0.31
    ## tau_G[1]         -0.08    0.02   0.45    -1.09    -0.31    -0.05     0.16
    ## tau_G[2]          0.06    0.02   0.55    -1.07    -0.22     0.02     0.33
    ## tau_G[3]         -0.03    0.02   0.55    -1.22    -0.30    -0.01     0.25
    ## tau_G[4]         -0.37    0.02   0.55    -1.76    -0.64    -0.26     0.00
    ## tau_G[5]          0.00    0.02   0.56    -1.11    -0.27    -0.01     0.27
    ## tau_G[6]         -0.01    0.02   0.54    -1.13    -0.29    -0.01     0.27
    ## tau_G[7]         -0.02    0.02   0.55    -1.23    -0.27     0.00     0.27
    ## tau_G[8]         -0.39    0.01   0.30    -1.03    -0.58    -0.36    -0.17
    ## tau_G[9]          0.13    0.02   0.45    -0.75    -0.12     0.09     0.36
    ## tau_G[10]         0.09    0.01   0.35    -0.56    -0.12     0.06     0.29
    ## tau_G[11]        -0.11    0.02   0.43    -1.05    -0.35    -0.08     0.13
    ## tau_G[12]         0.02    0.02   0.56    -1.17    -0.25     0.01     0.29
    ## tau_G[13]         0.31    0.02   0.35    -0.28     0.06     0.27     0.53
    ## tau_G[14]         0.41    0.03   0.57    -0.41     0.02     0.28     0.70
    ## tau_G[15]         0.31    0.01   0.31    -0.23     0.09     0.29     0.51
    ## tau_G[16]         0.00    0.01   0.36    -0.75    -0.21     0.01     0.20
    ## tau_G[17]         0.09    0.02   0.34    -0.58    -0.11     0.06     0.27
    ## tau_T[1]         -0.09    0.01   0.17    -0.50    -0.17    -0.06     0.00
    ## tau_T[2]         -0.01    0.01   0.15    -0.32    -0.08     0.00     0.06
    ## tau_T[3]          0.06    0.01   0.13    -0.18    -0.02     0.03     0.12
    ## tau_T[4]         -0.04    0.01   0.15    -0.38    -0.11    -0.02     0.02
    ## tau_T[5]          0.12    0.01   0.17    -0.12     0.00     0.07     0.20
    ## lp__          -1627.30    0.17   5.11 -1638.00 -1630.62 -1627.00 -1623.73
    ##                  97.5% n_eff Rhat
    ## alpha_G[1]      539.85     3 2.51
    ## alpha_G[2]      535.97     3 2.50
    ## alpha_G[3]      536.23     3 2.50
    ## alpha_G[4]      538.18     3 2.50
    ## alpha_G[5]      536.21     3 2.50
    ## alpha_G[6]      539.55     3 2.50
    ## alpha_G[7]      536.83     3 2.50
    ## alpha_G[8]      540.36     3 2.50
    ## alpha_G[9]      536.04     3 2.50
    ## alpha_G[10]     538.01     3 2.51
    ## alpha_G[11]     537.51     3 2.50
    ## alpha_G[12]     536.92     3 2.50
    ## alpha_G[13]     538.21     3 2.50
    ## alpha_G[14]     534.03     3 2.50
    ## alpha_G[15]     537.59     3 2.50
    ## alpha_G[16]     536.57     3 2.50
    ## alpha_G[17]     538.85     3 2.51
    ## alpha_T[1]      615.13     3 2.50
    ## alpha_T[2]      615.85     3 2.50
    ## alpha_T[3]      615.27     3 2.50
    ## alpha_T[4]      616.81     3 2.50
    ## alpha_T[5]      615.47     3 2.50
    ## mu_raw            1.48   315 1.01
    ## sigma_mu_unif     1.00   275 1.01
    ## tau_G_raw[1]      1.67   589 1.00
    ## tau_G_raw[2]      2.06   648 1.00
    ## tau_G_raw[3]      1.85   768 1.00
    ## tau_G_raw[4]      1.23   526 1.00
    ## tau_G_raw[5]      1.97   504 1.00
    ## tau_G_raw[6]      1.89   711 1.00
    ## tau_G_raw[7]      1.94   628 1.01
    ## tau_G_raw[8]      0.28   510 1.01
    ## tau_G_raw[9]      1.92   573 1.01
    ## tau_G_raw[10]     1.65   654 1.01
    ## tau_G_raw[11]     1.48   571 1.01
    ## tau_G_raw[12]     1.98   465 1.01
    ## tau_G_raw[13]     1.99   453 1.01
    ## tau_G_raw[14]     2.51   530 1.01
    ## tau_G_raw[15]     1.95   557 1.01
    ## tau_G_raw[16]     1.57   652 1.00
    ## tau_G_raw[17]     1.59   414 1.01
    ## tau_T_raw[1]      1.17   526 1.01
    ## tau_T_raw[2]      1.48   512 1.01
    ## tau_T_raw[3]      1.83   381 1.01
    ## tau_T_raw[4]      1.33   489 1.01
    ## tau_T_raw[5]      2.12   380 1.01
    ## sigma_G_unif      0.39    71 1.05
    ## sigma_T_unif      0.20   400 1.01
    ## beta[1]           0.67   641 1.01
    ## beta[2]           0.14   657 1.00
    ## sigma             3.21   495 1.01
    ## sigma_mu          5.85   411 1.01
    ## sigma_G           1.13   541 1.00
    ## sigma_T           0.61   513 1.00
    ## mu                0.71   316 1.02
    ## tau_G[1]          0.79   702 1.00
    ## tau_G[2]          1.22   798 1.00
    ## tau_G[3]          1.04   914 1.00
    ## tau_G[4]          0.45   624 1.00
    ## tau_G[5]          1.20   579 1.00
    ## tau_G[6]          1.10   757 1.00
    ## tau_G[7]          1.11   785 1.01
    ## tau_G[8]          0.11   631 1.01
    ## tau_G[9]          1.10   663 1.01
    ## tau_G[10]         0.87   699 1.01
    ## tau_G[11]         0.74   802 1.01
    ## tau_G[12]         1.20   550 1.01
    ## tau_G[13]         1.10   441 1.01
    ## tau_G[14]         1.82   440 1.01
    ## tau_G[15]         0.98   511 1.01
    ## tau_G[16]         0.72   685 1.00
    ## tau_G[17]         0.86   417 1.01
    ## tau_T[1]          0.18   452 1.01
    ## tau_T[2]          0.31   608 1.01
    ## tau_T[3]          0.37   461 1.00
    ## tau_T[4]          0.25   610 1.00
    ## tau_T[5]          0.51   484 1.00
    ## lp__          -1618.23   947 1.00
    ## 
    ## Samples were drawn using NUTS(diag_e) at Fri May 13 11:47:11 2022.
    ## For each parameter, n_eff is a crude measure of effective sample size,
    ## and Rhat is the potential scale reduction factor on split chains (at 
    ## convergence, Rhat=1).

## Panel Data

### Two-way Fixed Effects

Panel (or time series cross sectional (TSCS)) data consists of the same
observations over time. The most popular model in econ/polisci is the
two-way fixed effects model. This model allows you to control for
unobserved confounders that are either time invariant or unit invariant
(though as a consequence, you also cannot estimate the coefficients for
variables that are unit/time invariant).

``` r
fm <- formula(marriage ~ LARI + rel_importance | country + year | 0 | country)
out_2fe <- lfe::felm(fm, data=df)
summary(out_2fe)
```

    ## 
    ## Call:
    ##    lfe::felm(formula = fm, data = df) 
    ## 
    ## Residuals:
    ##    Min     1Q Median     3Q    Max 
    ## -7.460 -2.084 -1.049  2.349  8.181 
    ## 
    ## Coefficients:
    ##                Estimate Cluster s.e. t value Pr(>|t|)    
    ## LARI            0.06720      0.08802   0.764    0.456    
    ## rel_importance  0.61183      0.05036  12.149 1.72e-09 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 3.096 on 118578 degrees of freedom
    ##   (92804 observations deleted due to missingness)
    ## Multiple R-squared(full model): 0.1924   Adjusted R-squared: 0.1922 
    ## Multiple R-squared(proj model): 0.02691   Adjusted R-squared: 0.02671 
    ## F-statistic(full model, *iid*): 1177 on 24 and 118578 DF, p-value: < 2.2e-16 
    ## F-statistic(proj model): 85.53 on 2 and 16 DF, p-value: 2.866e-09

You should cluster at the level of “treatment assignment,” in this case
country. This allows for arbitrary dependence between observations in
the same group but assumes independence between groups.

There are some pretty strong assumptions made by this model, including
<a href="https://papers.ssrn.com/sol3/Papers.cfm?abstract_id=3979613">strict
exogeneity</a> and
<a href="https://www.nber.org/system/files/working_papers/w25904/w25904.pdf">homogeneous
effects</a>.

Strict exogeneity implies the following:

-   No unobserved time-varying confounders,
-   No anticipation (future treatments cannot affect current outcome),
-   No lagged dependent variables (past outcomes do not affect current
    outcome),
-   No feedback (past outcomes do not affect current treatment),
-   And no carryover (past treatments do not affect current outcome) .

Synthetic controls is a popular alternative for when you have only one
treated unit and the treatment is binary. Some newer methods include
generalized synthetic control and matrix completion (all of which also
assume strict exogeneity). The literature in this area is fast growing,
though our understanding of the setting with continuous treatment is
still quite limited.

### Bootstrapping

You should bootstrap to calculate standard errors,
<a href="https://direct.mit.edu/rest/article-pdf/90/3/414/1614600/rest.90.3.414.pdf">especially
when the number of clusters is small</a>.

``` r
out_boot <- lfe::felm(fm, weights = df$weight1500, data=df,
                      Nboot=999, bootexpr=quote(est$coef), bootcluster="model",
                      nostats=structure(FALSE, boot=TRUE))
sds <- apply(out_boot$boot[, , ], MARGIN=1, FUN=sd)
sds
```

    ##           LARI rel_importance 
    ##     0.10100746     0.04719788

### Random Effects

``` r
out_re_time <- lme4::lmer(office ~ LARI_lag1 + 
                            (LARI_lag1 | country) + 
                            (LARI_lag1 | year),
                          data=df)
```

    ## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
    ## Model failed to converge with max|grad| = 0.0130696 (tol = 0.002, component 1)

``` r
confint(out_re_time, method="Wald")
```

    ##                   2.5 %    97.5 %
    ## .sig01               NA        NA
    ## .sig02               NA        NA
    ## .sig03               NA        NA
    ## .sig04               NA        NA
    ## .sig05               NA        NA
    ## .sig06               NA        NA
    ## .sigma               NA        NA
    ## (Intercept)  3.98282918 5.3077943
    ## LARI_lag1   -0.03901697 0.3459806
