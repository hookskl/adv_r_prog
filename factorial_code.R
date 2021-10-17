# compute factorial using a loop
Factorial_loop <- function(n) {
        # check input is numeric and positive
        stopifnot(is.numeric(n) & n >= 0)
        # round down to nearest integer value
        n <- floor(n)
        
        result <- 1
        if(n == 0) {
                result
        } else {
                for(i in 1:n) {
                     result <- result * i   
                }
                result
        }
}

# compute factorial using reduction
Factorial_reduce <- function(n) {
        # check input is numeric and positive
        stopifnot(is.numeric(n) & n >= 0)
        # round down to nearest integer value
        n <- floor(n)
        
        if(n == 0) {
                1
        } else{
                purrr::reduce(1:n, function(x, y) {x * y})
        }
}


# compute factorial using recursions
Factorial_func <- function(n) {
        # check input is numeric and positive
        stopifnot(is.numeric(n) & n >= 0)
        # round down to nearest integer value
        n <- floor(n)
        
        # base case 1: n = 0
        if(n == 0) {
                1
        # else do recursive case
        } else {
                n * Factorial_func(n - 1)
        }
}


# compute factorial using recursions and 
# memoization

# initialize table to store results
factorial_tbl <- c(1, rep(NA, 23))

Factorial_mem <- function(n) {
        # check input is numeric and positive
        stopifnot(is.numeric(n) & n >= 0)
        # round down to nearest integer value
        n <- floor(n)
        # check if memoization table size 
        # needs to be increased
        if(n > length(factorial_tbl)) {
                length(factorial_tbl) <<- n
        }
        # if n = 0, return 1
        if(n == 0){
                1
        }
        # check if n! has already been computed
        else if(!is.na(factorial_tbl[n])) {
                factorial_tbl[n]
        } else { # compute and save to memoization tbl
                factorial_tbl[n - 1] <<- Factorial_mem(n - 1)
                factorial_tbl[n] <<- n * factorial_tbl[n - 1]
                factorial_tbl[n]
        }
}