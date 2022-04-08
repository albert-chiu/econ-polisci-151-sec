R Review (ECON/POLISCI 151)
================

## Basics

Recommended IDE is [RStudio](https://www.rstudio.com/products/rstudio/)

Useful file types:

-   R script: Basic file containing only code (and comments)
-   Markdown files: Mix of text and code (e.g., this file was made using
    markdown)
    -   Code from other languages besides R
    -   Multiple output options: HTML, pdf, etc.
    -   Include LaTeX code for math:
        ![\\forall x\\in \\mathbb{R}^n, c\\in \\mathbb{R}, f(cx)=c^kf(x)](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%5Cforall%20x%5Cin%20%5Cmathbb%7BR%7D%5En%2C%20c%5Cin%20%5Cmathbb%7BR%7D%2C%20f%28cx%29%3Dc%5Ekf%28x%29 "\forall x\in \mathbb{R}^n, c\in \mathbb{R}, f(cx)=c^kf(x)")

## Packages

Install packages from CRAN:

``` r
## Comment out code using '#'
#install.packages("PackageName")
```

To use the package, you must first attach/load it:

``` r
#require(PackageName)
# or, equivalently,
#library(PackageName)
```

You can use functions from an installed package without attaching it
(also a good way to specify package):

``` r
#PackageName::function()
#DifferentPackage::function()

# if you do not specify the package from which a function is from, R will assume
# it is from the package last loaded. When loading the package, it will notify you
# that some functions are being "masked"
require(dplyr)
```

    ## Loading required package: dplyr

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
# if you call lag(), R will assume you mean dplyr::lag(). If you want to call
# stats::lag(), you must specify
```

Install packages from github:

``` r
#devtools::install_github("DeveloperName/PackageName")
```

## Functions

``` r
# ?function will open the documentation for function in the "help" pane in RStudio
#?mean

# can also press the tab key inside the parenthesis after a function
#mean()
```

“Usage” will give you the order of arguments and their default values
(if any).

You can specify function the argument and the value it should take by
using <tt>argument=value</tt>, e.g.,

``` r
set.seed(123)
rnorm(n=5, mean = 1, sd = 10)
```

    ## [1] -4.604756 -1.301775 16.587083  1.705084  2.292877

You can also specify arguments out of order:

``` r
set.seed(123)
rnorm(mean = 1, sd = 10, n=5)
```

    ## [1] -4.604756 -1.301775 16.587083  1.705084  2.292877

If you do not specify the argument, R will assume they are entered in
the order in which they appear in “Usage.”

``` r
set.seed(123)
rnorm(5, 1, 10)
```

    ## [1] -4.604756 -1.301775 16.587083  1.705084  2.292877

If you do not supply a value for an argument with a default value, R
will use the default value. If you do not supply a value when there is
no default, R will return an error.

``` r
rnorm(5)
```

    ## [1]  1.7150650  0.4609162 -1.2650612 -0.6868529 -0.4456620

``` r
#rnorm()
```

### Defining your own functions

``` r
foo <- function(x, y) {
  if ( x < y) {
    return(x)
  } else {
    return(x + y)
  }
}
foo(10, 2)
```

    ## [1] 12

``` r
foo(y=2, x=10)
```

    ## [1] 12

## Objects and data types

Instantiate new objects:

``` r
a1 <- 1
print(a1)
```

    ## [1] 1

``` r
a1  # can omit "print()"
```

    ## [1] 1

``` r
# can include multiple commands on one line by separating with ";"
a2 = 2; print(a2)
```

    ## [1] 2

### Logicals/booleans:

``` r
typeof(TRUE)
```

    ## [1] "logical"

``` r
T  # TRUE
```

    ## [1] TRUE

``` r
# checking (in)equality
1 == 1
```

    ## [1] TRUE

``` r
1 != 1
```

    ## [1] FALSE

``` r
1 <= 1
```

    ## [1] TRUE

``` r
1 > 1
```

    ## [1] FALSE

``` r
# can treat as a number
1+TRUE
```

    ## [1] 2

``` r
1+FALSE
```

    ## [1] 1

### Numbers

``` r
typeof(1)
```

    ## [1] "double"

``` r
typeof(1L)
```

    ## [1] "integer"

``` r
typeof(as.integer(1))
```

    ## [1] "integer"

``` r
# "is.integer()" does not check for whole numbers
is.integer(1)
```

    ## [1] FALSE

Vectors:

``` r
v1 <- c(1,2,3); v1
```

    ## [1] 1 2 3

``` r
v2 <- 1:3; v2
```

    ## [1] 1 2 3

``` r
# different data types
typeof(v1); typeof(v2)
```

    ## [1] "double"

    ## [1] "integer"

``` r
# sequence, with step size other than 1
seq(from=1, to=10, by=3)
```

    ## [1]  1  4  7 10

Matrices:

``` r
## white space does not delimit code; use it for readability
# bad:
mat <- rbind(1:3,           4:6,
             
             

             
                     7:9)
mat
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6
    ## [3,]    7    8    9

``` r
# better:
mat <- rbind(1:3,
             4:6,
             7:9)
mat
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6
    ## [3,]    7    8    9

``` r
typeof(mat)
```

    ## [1] "integer"

``` r
matrix(1:9, nrow=3, byrow = T)
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6
    ## [3,]    7    8    9

``` r
# Matrix operations:
t(mat)  # transpose
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    4    7
    ## [2,]    2    5    8
    ## [3,]    3    6    9

``` r
mat * 2  # elementwise multiplication
```

    ##      [,1] [,2] [,3]
    ## [1,]    2    4    6
    ## [2,]    8   10   12
    ## [3,]   14   16   18

``` r
mat * mat  
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    4    9
    ## [2,]   16   25   36
    ## [3,]   49   64   81

``` r
mat %*% mat  # matrix multiplication
```

    ##      [,1] [,2] [,3]
    ## [1,]   30   36   42
    ## [2,]   66   81   96
    ## [3,]  102  126  150

``` r
mat + mat
```

    ##      [,1] [,2] [,3]
    ## [1,]    2    4    6
    ## [2,]    8   10   12
    ## [3,]   14   16   18

``` r
mat + 1
```

    ##      [,1] [,2] [,3]
    ## [1,]    2    3    4
    ## [2,]    5    6    7
    ## [3,]    8    9   10

### Characters/strings

``` r
s1 <- "this is a string"; cat(s1)
```

    ## this is a string

``` r
typeof(s1)
```

    ## [1] "character"

``` r
# some special symbols need to be escaped:
cat("s \ ")
```

    ## s

``` r
cat("s \\ ")
```

    ## s \

### Factors

Discrete variables

``` r
f1 <- factor(1:3)
sort(f1)  # default order is alpha-numerical
```

    ## [1] 1 2 3
    ## Levels: 1 2 3

``` r
# can specify different order
f2 <- factor(1:3, levels=c(2, 1, 3))
sort(f2)
```

    ## [1] 2 1 3
    ## Levels: 2 1 3

### Dataframes

``` r
# can accomodate multiple data types
df <- cbind.data.frame(numbers=1:4, words=as.character(1:4))
df
```

    ##   numbers words
    ## 1       1     1
    ## 2       2     2
    ## 3       3     3
    ## 4       4     4

``` r
# if we try to do the same with matrices, everything is coerced to char:
cbind(numbers=1:4, words=as.character(1:4))
```

    ##      numbers words
    ## [1,] "1"     "1"  
    ## [2,] "2"     "2"  
    ## [3,] "3"     "3"  
    ## [4,] "4"     "4"

### Lists

``` r
# can store basically any data together in one object
list(c("a", "b"), 1:3,  # vectors of different sizes
     lm(1~1))  # other classes of objects
```

    ## [[1]]
    ## [1] "a" "b"
    ## 
    ## [[2]]
    ## [1] 1 2 3
    ## 
    ## [[3]]
    ## 
    ## Call:
    ## lm(formula = 1 ~ 1)
    ## 
    ## Coefficients:
    ## (Intercept)  
    ##           1

## Manipulating data

### Subsetting and appending

Subsetting by location:

``` r
df[1, 1]  # element in row 1, column 1
```

    ## [1] 1

``` r
df[1, ]  # entire first row
```

    ##   numbers words
    ## 1       1     1

``` r
df[, 1]  # entire first column
```

    ## [1] 1 2 3 4

By name:

``` r
df[, "numbers"]
```

    ## [1] 1 2 3 4

``` r
df$numbers
```

    ## [1] 1 2 3 4

``` r
df[["numbers"]]
```

    ## [1] 1 2 3 4

Appending data:

``` r
# this does not add a column to the object "df"
# instead, it creates a new object with an additional column
cbind(df, new_column1=df$numbers+1)  
```

    ##   numbers words new_column1
    ## 1       1     1           2
    ## 2       2     2           3
    ## 3       3     3           4
    ## 4       4     4           5

``` r
df  # the same as before
```

    ##   numbers words
    ## 1       1     1
    ## 2       2     2
    ## 3       3     3
    ## 4       4     4

``` r
# to add the column to "df", you have to assign the new object to the variable "df"
df <- cbind(df, new_column=df$numbers+1)  
df
```

    ##   numbers words new_column
    ## 1       1     1          2
    ## 2       2     2          3
    ## 3       3     3          4
    ## 4       4     4          5

``` r
# equivalently:
df$new_column1 <- df$numbers+1
df
```

    ##   numbers words new_column new_column1
    ## 1       1     1          2           2
    ## 2       2     2          3           3
    ## 3       3     3          4           4
    ## 4       4     4          5           5

Useful package:

``` r
require(dplyr)  # also tidyr
df <- df %>% mutate(new_column2 = (numbers <= 2),
                    new_column3 = ifelse(numbers <= 2,
                      yes="at most 2", no="greater than 2"))
df
```

    ##   numbers words new_column new_column1 new_column2    new_column3
    ## 1       1     1          2           2        TRUE      at most 2
    ## 2       2     2          3           3        TRUE      at most 2
    ## 3       3     3          4           4       FALSE greater than 2
    ## 4       4     4          5           5       FALSE greater than 2

``` r
# summarize by different groups
df %>% group_by(new_column3) %>% summarize(avg=mean(numbers))
```

    ## # A tibble: 2 × 2
    ##   new_column3      avg
    ##   <chr>          <dbl>
    ## 1 at most 2        1.5
    ## 2 greater than 2   3.5

``` r
# maintain original structure
df %>% group_by(new_column3) %>% mutate(avg=mean(numbers))
```

    ## # A tibble: 4 × 7
    ## # Groups:   new_column3 [2]
    ##   numbers words new_column new_column1 new_column2 new_column3      avg
    ##     <int> <chr>      <dbl>       <dbl> <lgl>       <chr>          <dbl>
    ## 1       1 1              2           2 TRUE        at most 2        1.5
    ## 2       2 2              3           3 TRUE        at most 2        1.5
    ## 3       3 3              4           4 FALSE       greater than 2   3.5
    ## 4       4 4              5           5 FALSE       greater than 2   3.5

### <tt>apply()</tt>

Collection of functions for applying the same function many times. The
<tt>apply()</tt> function applies the same function to each row
(<tt>MARGIN=1</tt>) or column (<tt>MARGIN=2</tt>) of a matrix/dataframe.

``` r
## Take the average of each column:
x <- matrix(rnorm(1000), ncol=10)

# for loop
avgs <- c()
for ( i in 1:ncol(x) ) {
  avgs[i] <- mean(x[, i])
}
avgs
```

    ##  [1]  0.04335854 -0.03683855  0.06841222 -0.04319859  0.09057756 -0.03052820
    ##  [7] -0.15081839  0.18176056  0.06960665 -0.04642077

``` r
# apply()
apply(x, MARGIN=2, FUN=mean)
```

    ##  [1]  0.04335854 -0.03683855  0.06841222 -0.04319859  0.09057756 -0.03052820
    ##  [7] -0.15081839  0.18176056  0.06960665 -0.04642077

``` r
## Something a bit more complicated
vals <- c()
for ( i in 1:ncol(x) ) {
  vals[i] <- (x[, i] %*% x[, i])/sd(x[, i])
}
vals 
```

    ##  [1]  89.71451  98.92074  96.14482  99.48911 101.09679  91.46128 103.87732
    ##  [8] 102.39315 104.46416 105.63818

``` r
apply(x, MARGIN=2, FUN=function(xi) xi %*% xi / sd(xi) )
```

    ##  [1]  89.71451  98.92074  96.14482  99.48911 101.09679  91.46128 103.87732
    ##  [8] 102.39315 104.46416 105.63818

Similar function for other data structures:

``` r
# lapply and sapply can both be used on either a list or a vector
lst <- list( x, x%*%t(x) )
vec <- 1:3

# lapply returns a list
lapply(lst, FUN = mean)
```

    ## [[1]]
    ## [1] 0.0145911
    ## 
    ## [[2]]
    ## [1] 0.08170272

``` r
lapply(vec, FUN=function(y) y+1)
```

    ## [[1]]
    ## [1] 2
    ## 
    ## [[2]]
    ## [1] 3
    ## 
    ## [[3]]
    ## [1] 4

``` r
# sapply returns a vector
sapply(lst, FUN=mean)
```

    ## [1] 0.01459110 0.08170272

``` r
sapply(vec, FUN=function(y) y+1)
```

    ## [1] 2 3 4

<tt>tapply()</tt> allows you to apply a function to subsets of a vector:

``` r
set.seed(123)
group <- c("a", "b")[rbinom(10, size=1, prob=.5)+1]

# averages of entries in groups a and b
tapply(rnorm(10), INDEX = group, mean)
```

    ##          a          b 
    ## 0.27956110 0.03327823

## Random variables and probability distributions

Generate random numbers:

``` r
set.seed(123)  # set seed to ensure reproducibility
runif(n=3, min=0, max=1) # uniform(0, 1)
```

    ## [1] 0.2875775 0.7883051 0.4089769

``` r
rnorm(n=3, mean=0, sd=1) # normal(0, 1)
```

    ## [1]  1.190207 -1.689556  1.239496

Quantiles of a distribution:

``` r
qnorm(.025, mean=0, sd=1)  # 2.5th quantile of N(0,1)
```

    ## [1] -1.959964

CDF:

``` r
pnorm(0, mean=0, sd=1) # F(0) = P( N(0,1) < 0 )
```

    ## [1] 0.5

PDF:

``` r
dnorm(0, 0, 1) # f(0)
```

    ## [1] 0.3989423

## Regression

``` r
set.seed(123)
x1 <- rnorm(n=10)
x2 <- rnorm(n=10)

Y <- x1 + 2*x2 + rnorm(n=10)

# Estimate the model Y = beta1*x1 + beta2*x2 + error
# can pass lm() vectors
out <- lm(Y ~ x1 + x2)
out$residuals  # model has many things you can extract
```

    ##          1          2          3          4          5          6          7 
    ## -0.2612187  0.2393729 -0.3453045 -0.3486716 -0.5366225 -0.3672157  1.4361617 
    ##          8          9         10 
    ## -0.5498960 -0.5801461  1.3135405

``` r
summary(out)
```

    ## 
    ## Call:
    ## lm(formula = Y ~ x1 + x2)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -0.5802 -0.4943 -0.3470  0.1142  1.4362 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)   
    ## (Intercept)  -0.3226     0.2794  -1.155  0.28611   
    ## x1            0.8854     0.3696   2.396  0.04776 * 
    ## x2            1.5521     0.3396   4.571  0.00257 **
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.8632 on 7 degrees of freedom
    ## Multiple R-squared:  0.8939, Adjusted R-squared:  0.8635 
    ## F-statistic: 29.48 on 2 and 7 DF,  p-value: 0.0003895

``` r
coef(out)
```

    ## (Intercept)          x1          x2 
    ##  -0.3225640   0.8853996   1.5520955

``` r
confint(out)
```

    ##                   2.5 %    97.5 %
    ## (Intercept) -0.98312436 0.3379963
    ## x1           0.01150657 1.7592926
    ## x2           0.74916076 2.3550303

``` r
# data can also pass it a dataframe
df <- cbind.data.frame(Y, Var1=x1, Var2=x2)
head(df)
```

    ##            Y        Var1       Var2
    ## 1  0.8198642 -0.56047565  1.2240818
    ## 2  0.2714752 -0.23017749  0.3598138
    ## 3  1.3342468  1.55870831  0.4007715
    ## 4 -0.4370174  0.07050839  0.1106827
    ## 5 -1.6074338  0.12928774 -0.5558411
    ## 6  3.6021979  1.71506499  1.7869131

``` r
fm <- formula(Y~Var1+Var2)
lm(fm, data=df)
```

    ## 
    ## Call:
    ## lm(formula = fm, data = df)
    ## 
    ## Coefficients:
    ## (Intercept)         Var1         Var2  
    ##     -0.3226       0.8854       1.5521

``` r
lm(Y~., data=df)  # regress Y on all other variables in df
```

    ## 
    ## Call:
    ## lm(formula = Y ~ ., data = df)
    ## 
    ## Coefficients:
    ## (Intercept)         Var1         Var2  
    ##     -0.3226       0.8854       1.5521

``` r
# can transform data
Y <- x1^2 + log(abs(x2)) + rnorm(n=10)
lm(Y ~ Var1^2 + log(abs(Var2)), data=df)
```

    ## 
    ## Call:
    ## lm(formula = Y ~ Var1^2 + log(abs(Var2)), data = df)
    ## 
    ## Coefficients:
    ##    (Intercept)            Var1  log(abs(Var2))  
    ##       -0.09783         1.85627        -0.05252

``` r
# many other functions take the same formula
df$Y <- rbinom(n=10, size=1, prob=.5)  # binary outcome
glm(fm, data=df, family = binomial(link=probit))  # probit 
```

    ## 
    ## Call:  glm(formula = fm, family = binomial(link = probit), data = df)
    ## 
    ## Coefficients:
    ## (Intercept)         Var1         Var2  
    ##     0.03340     -0.73792     -0.07593  
    ## 
    ## Degrees of Freedom: 9 Total (i.e. Null);  7 Residual
    ## Null Deviance:       13.86 
    ## Residual Deviance: 11.57     AIC: 17.57

## Plots

Dot plot:

``` r
plot(x=x1, y=Y, pch=16,
     xlab="x axis", ylab="y axis")
```

![](r-review_w1_files/figure-gfm/unnamed-chunk-32-1.png)<!-- -->

Line

``` r
plot(x=sort(x1), y=Y[order(x1)], type = "l")
```

![](r-review_w1_files/figure-gfm/unnamed-chunk-33-1.png)<!-- -->

Histogram and density

``` r
x <- rnorm(1000)
hist(x)
```

![](r-review_w1_files/figure-gfm/unnamed-chunk-34-1.png)<!-- -->

``` r
plot(density(x)) 
```

![](r-review_w1_files/figure-gfm/unnamed-chunk-34-2.png)<!-- -->
