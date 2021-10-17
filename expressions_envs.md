Expressions & Environments
================

## Expressions

Expressions are encapsulated operations that can be executed by R. This
allows you to manipulate code with code. You can create an expression
using `quote()` and passing to it the same thing you would have typed in
the console.

``` r
two_plus_two <- quote(2 + 2)
two_plus_two
```

    ## 2 + 2

In order to execute the expression, pass it to `eval()`.

``` r
eval(two_plus_two)
```

    ## [1] 4

If the R code is stored as a string, we can repeate this process but use
`parse()` instead of `quote()`.

``` r
tpt_string <- "2 + 2"
tpt_expression <- parse(text = tpt_string)
eval(tpt_expression)
```

    ## [1] 4

`deparse()` will reverse this process and transform an expression into a
string.

``` r
deparse(two_plus_two)
```

    ## [1] "2 + 2"

Contents of expressions can be accessed and modified much like a list.
This means you can change the values in an expression, or even the
function executed before it’s evaluated.

``` r
sum_expr <- quote(sum(1, 5))

eval(sum_expr)
```

    ## [1] 6

``` r
sum_expr[[1]]
```

    ## sum

``` r
sum_expr[[2]]
```

    ## [1] 1

``` r
sum_expr[[3]]
```

    ## [1] 5

``` r
sum_expr[[1]] <- quote(paste0)
sum_expr[[2]] <- quote(4)
sum_expr[[3]] <- quote(6)

eval(sum_expr)
```

    ## [1] "46"

Expressions can be composed using the `call()` function. The first
argument is the name of a function, represented as a string. The
remaining arguments are the arguments of the function provided.

``` r
sum_40_50_expr <- call("sum", 40, 50)
sum_40_50_expr
```

    ## sum(40, 50)

``` r
sum(40, 50)
```

    ## [1] 90

``` r
eval(sum_40_50_expr)
```

    ## [1] 90

`match.call()` is used to capture the expression of a function executed
in the R console by a user.

``` r
return_expression <- function(...){
  match.call()
}

return_expression(2, col = "blue", FALSE)
```

    ## return_expression(2, col = "blue", FALSE)

``` r
return_expression(2, col = "blue", FALSE)
```

    ## return_expression(2, col = "blue", FALSE)

This means you can manipulate this expression inside of a function
you’re writing. This example first uses `match.call()` to capture the
expression entered by the user. The first argument of the function is
then extracted and evaluated.

``` r
first_arg <- function(...){
  expr <- match.call()
  first_arg_expr <- expr[[2]]
  first_arg <- eval(first_arg_expr)
  if(is.numeric(first_arg)){
    paste("The first argument is", first_arg)
  } else {
    "The first argument is not numeric."
  }
}

first_arg(2, 4, "seven", FALSE)
```

    ## [1] "The first argument is 2"

``` r
first_arg("two", 4, "seven", FALSE)
```

    ## [1] "The first argument is not numeric."

## Environments

Environments are data structures in R that have special properties with
regard to their role in how R code is executed and how memory in R is
organized. The environment most R users are familiar with is the global
environment. Environments formalize the relationships between variable
names and values.

The `new.env()` function allows you to create a new environment.
Assigning values in that new environment is much like assigning values
to elements of a named list, or use `assign()`. Retrieving a named value
in the environment is similar, using either `env$x` or `get()`.

``` r
my_new_env <- new.env()
my_new_env$x <- 4
my_new_env$x
```

    ## [1] 4

``` r
assign("y", 9, envir = my_new_env)
get("y", envir = my_new_env)
```

    ## [1] 9

``` r
my_new_env$y
```

    ## [1] 9

Calling `ls()` on an environment will list all the variables in a an
environment. You can use `rm()` to remove the association between a
variable name and its value. Additionally, you can check to see if a
variable name has been assigned using `exists()`.

``` r
ls(my_new_env)
```

    ## [1] "x" "y"

``` r
rm(y, envir = my_new_env)
exists("y", envir = my_new_env)
```

    ## [1] FALSE

``` r
exists("x", envir = my_new_env)
```

    ## [1] TRUE

``` r
my_new_env$x
```

    ## [1] 4

``` r
my_new_env$y
```

    ## NULL

Environments are organized in parent/child relationships such that every
environment keeps track of its parent, but parents are unware of which
environments are their children. Generally, these relationships are not
something you should try to control. To view the parents of the global
environment, use the `search()` function.

``` r
search()
```

    ## [1] ".GlobalEnv"        "package:stats"     "package:graphics" 
    ## [4] "package:grDevices" "package:utils"     "package:datasets" 
    ## [7] "package:methods"   "Autoloads"         "package:base"

Now if I load the `ggplot2` package:

``` r
library(ggplot2)
search()
```

    ##  [1] ".GlobalEnv"        "package:ggplot2"   "package:stats"    
    ##  [4] "package:graphics"  "package:grDevices" "package:utils"    
    ##  [7] "package:datasets"  "package:methods"   "Autoloads"        
    ## [10] "package:base"

`ggplot2` has now become the parent of the global environment.

## Execution Environments

Whenever a function is executed, a new environment is created, referred
to as an execution environment. These are environments that exist only
temporarily within the scope of a function that is being executed.

``` r
x <- 10

my_func <- function() {
        x <- 5
        return(x)
        
}

my_func()
```

    ## [1] 5

Here we have assigned the `x <- 10` in the global environment. We have
then created a function `my_func()`. When this function is executed, a
new environment is created that exists only while `my_func` is running.
Inside of this new environment we assign `x <- 5` and return `x`. When
`x` is returned, the value is first looked up in the execution
environment. Contrast this behavior with the code below:

``` r
x <- 10

another_func <- function() {
        return(x)
        
}

another_func()
```

    ## [1] 10

Now when the function is run, the value for `x` is still first searched
in the execution environment. Since a value can’t be found, the search
is continued in the global environment where `x <- 10` and that value is
then returned.

The `<<-`, called the complex assignment operator, allows you to
manipulate the global environment while inside an execution environment.

``` r
x <- 10
x
```

    ## [1] 10

``` r
assign1 <- function() {
        x <<- "Wow!"
}
assign1()
x
```

    ## [1] "Wow!"

It is also possible to create a new variable in the global environment
within an execution environment.

``` r
exists("a_variable_name")
```

    ## [1] FALSE

``` r
assign2 <- function() {
        a_variable_name <<- "Magic!"
}

assign2()
exists("a_variable_name")
```

    ## [1] TRUE

``` r
a_variable_name
```

    ## [1] "Magic!"
