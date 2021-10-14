Functions
================

## Code

Often data analysis starts by writing R code to accomplish a very
specific task. For example, the code below downloads logs from RStudio
that contains information about their CRAN mirror. Here we are counting
the number of times the `filehash` library was downloaded on July 20,
2016.

``` r
library(readr)
library(dplyr)

## Download data from RStudio (if we haven't already)
if(!file.exists("data/2016-07-20.csv.gz")) {
        download.file("http://cran-logs.rstudio.com/2016/2016-07-20.csv.gz", 
                      "data/2016-07-20.csv.gz")
}
cran <- read_csv("data/2016-07-20.csv.gz", col_types = "ccicccccci")
cran %>% filter(package == "filehash") %>% nrow
```

While simple, this highlights a couple of shortcomings of the code if we
decide to analyze counts from a different day, or a different package.
From this starting point we can begin to modify this code to be more
general.

## Function Interface

Using the above code as a starting point, we can create the function
`num_download` with two arguments:

-   `pkgname`: the name of the package as a character string
-   `date`: a character string representing the date of interest (note
    the expected format is YYYY-MM-DD)

``` r
library(dplyr)
library(readr)

## pkgname: package name (character)
## date: YYYY-MM-DD format (character)
num_download <- function(pkgname, date) {
        ## Construct web URL
        year <- substr(date, 1, 4)
        src <- sprintf("http://cran-logs.rstudio.com/%s/%s.csv.gz",
                       year, date)

        ## Construct path for storing local file
        dest <- file.path("data", basename(src))

        ## Don't download if the file is already there!
        if(!file.exists(dest))
                download.file(src, dest, quiet = TRUE)

        cran <- read_csv(dest, col_types = "ccicccccci", progress = FALSE)
        cran %>% filter(package == pkgname) %>% nrow
}

num_download("filehash", "2016-07-20")
num_download("Rcpp", "2016-07-19")
```

## Default Values

Sometimes there are logical default values for function arguments. When
this occurs, it’s very straightforward to specify a default value, for
example below we set `date = "2016-07-20` in the `num_download`
definition.

``` r
num_download <- function(pkgname, date = "2016-07-20") {
        year <- substr(date, 1, 4)
        src <- sprintf("http://cran-logs.rstudio.com/%s/%s.csv.gz",
                       year, date)
        dest <- file.path("data", basename(src))
        if(!file.exists(dest))
                download.file(src, dest, quiet = TRUE)
        cran <- read_csv(dest, col_types = "ccicccccci", progress = FALSE)
        cran %>% filter(package == pkgname) %>% nrow
}

num_download("Rcpp")
```

## Re-factoring Code

The `num_download()` function is now accomplishing the original task in
a more general manner. However, it is worth asking whether it is written
in the most useful manner. For one, this function is doing many tasks at
once:

1.  Create the path to the remote and local log file
2.  Download the log file (conditional on if it already exists locally)
3.  Read in the log file
4.  Filter the log file for the package specified and return the number
    of downloads

One approach would be to remove 1. and 2. and add this functionality to
a separate function.

``` r
check_for_logfile <- function(date) {
        year <- substr(date, 1, 4)
        src <- sprintf("http://cran-logs.rstudio.com/%s/%s.csv.gz",
                       year, date)
        dest <- file.path("data", basename(src))
        if(!file.exists(dest)) {
                val <- download.file(src, dest, quiet = TRUE)
                if(!val)
                        stop("unable to download file ", src)
        }
        dest
}
```

Most of the code for `check_for_logfile()` is unchanged from
`num_download()`, with the added error checking if the file download was
unsuccessful. We can now rewrite `num_download` with the new function.

``` r
num_download <- function(pkgname, date = "2016-07-20") {
        dest <- check_for_logfile(date)
        cran <- read_csv(dest, col_types = "ccicccccci", progress = FALSE)
        cran %>% filter(package == pkgname) %>% nrow
} 
```

`num_download()` is now simpler to read and doesn’t need to know
anything about downloading files or URLs.

## Dependency Checking

`num_download()` depends on `readr` and `dplyr` packages to be installed
in order to run. We can write another function to check if these are
installed (and install them if now), as well as give the user a message
notifying them the packages are required.

``` r
check_pkg_deps <- function() {
        if(!require(readr)) {
                message("installing the 'readr' package")
                install.packages("readr")
        }
        if(!require(dplyr))
                stop("the 'dplyr' package needs to be installed first")
}
```

This function makes use of `require()`, which is similar to the
`library(function)`. One key difference is if `library()` is called on a
package not installed, it will issue an error whereas `require()`
returns `TRUE` or `FALSE` depending on whether the package can be loaded
or not. In both cases the package is loaded if available.

`require()` is typically more suited for programming vs. interactive
work as it allows for directing different behaviors if certain packages
aren’t available.

The `check_pkg_dps()` function highlights this ability, by installing
`readr` if it is not available and erroring if `dplyr` is not available.

Updating `num_download()` to include this dependency check:

``` r
num_download <- function(pkgname, date = "2016-07-20") {
        check_pkg_deps()
        dest <- check_for_logfile(date)
        cran <- read_csv(dest, col_types = "ccicccccci", progress = FALSE)
        cran %>% filter(package == pkgname) %>% nrow
}
```

## Vectorization

Currently the `num_download` function is not *vectorized*, the inputs
are single values. We can update the function so that it takes multiple
package names at once fairly easily.

``` r
## 'pkgname' can now be a character vector of names
num_download <- function(pkgname, date = "2016-07-20") {
        check_pkg_deps()
        dest <- check_for_logfile(date)
        cran <- read_csv(dest, col_types = "ccicccccci", progress = FALSE)
        cran %>% filter(package %in% pkgname) %>% 
                group_by(package) %>%
                summarize(n = n())
}  

num_download(c("filehash", "weathermetrics"))
```

While not shown, it is also possible to due the same for the `date`
argument, it is just a bit more complicated.

## Argument Checking

Our function is assuming that a user will supply the correct inputs, a
character vector of package names and a character string representing a
date. However, there is nothing to stop the user from inputing these in
a different format and causing the function to throw an error.
Unfortunately, the error thrown will most likely not be very useful.

To control this we can add a series of checks to ensure the inputs match
the correct format before passing them to the body of the function.

``` r
num_download <- function(pkgname, date = "2016-07-20") {
        check_pkg_deps()

        ## Check arguments
        if(!is.character(pkgname))
                stop("'pkgname' should be character")
        if(!is.character(date))
                stop("'date' should be character")
        if(length(date) != 1)
                stop("'date' should be length 1")

        dest <- check_for_logfile(date)
        cran <- read_csv(dest, col_types = "ccicccccci", 
                         progress = FALSE)
        cran %>% filter(package %in% pkgname) %>% 
                group_by(package) %>%
                summarize(n = n())
}    
```

If any of the checks fail we throw a more informative error message via
the `stop()` function. Note that another approach would be to coerce the
arguments (notifying the user of this happening) and continue running
the function.

## When to Write a Function?

There are no hard and fast rules when it is a good idea to turn code
written in an interactive style into a set of functions, but here are
some rules of thumb:

-   When writing code to do something once, document it very well. The
    most important thing here is the code works and you understand what
    it does, that way if you ever need to revisit it and reproduce the
    results you can do so.
-   When repeating something twice, write a function.
-   When repeating something three or more times, write a small package.
    Don’t worry about it making commercial grade software, just
    something that can encapsulate the set of operations needed to
    perform the analysis at hand. At this point it is also important to
    write some real documentation so that others can understand what is
    going on and apply it to other situations if suited.
