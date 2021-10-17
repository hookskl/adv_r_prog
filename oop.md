OOP
================

## S3

Everything in R is an object. This includes numbers, functions, strings,
data frames, lists, etc. To see an objects class, use the `class()`
function.

``` r
class(2)
```

    ## [1] "numeric"

``` r
class("is in session.")
```

    ## [1] "character"

``` r
class(class)
```

    ## [1] "function"

In the S3 system you can arbitrarily assign a class to any object, which
goes against object oriented principles. Class assignments can be made
using `structure()` or `class(object) <- "some class"`

``` r
special_num_1 <- structure(1, class = "special_number")
class(special_num_1)
```

    ## [1] "special_number"

``` r
special_num_2 <- 2
class(special_num_2)
```

    ## [1] "numeric"

``` r
class(special_num_2) <- "special_number"
class(special_num_2)
```

    ## [1] "special_number"

While *legal* in R it is safer to use a constructor which returns an S3
object.

``` r
shape_s3 <- function(side_lengths){
  structure(list(side_lengths = side_lengths), class = "shape_S3")
}

square_4 <- shape_s3(c(4, 4, 4, 4))
class(square_4)
```

    ## [1] "shape_S3"

``` r
triangle_3 <- shape_s3(c(3, 3, 3))
class(triangle_3)
```

    ## [1] "shape_S3"

Above we created two different objects that are the same class. Suppose
we wanted to create a method that would return `TRUE` if our class was a
square, `FALSE` if it was not a square, and `NA` if the object provided
is not the `shape_S3` class. We can achieve this with **generic
methods** system. To see this in action, the function `mean()` has
different behaviors its input values.

``` r
mean(c(2, 3, 7))
```

    ## [1] 4

``` r
mean(c(as.Date("2016-09-01"), as.Date("2016-09-03")))
```

    ## [1] "2016-09-02"

To create our own generic method, we need to use the `UseMethod()`
function.

``` r
is_square <- function(x) UseMethod("is_square")
```

We can then add the actual function definition as follows:

``` r
is_square.shape_S3 <- function(x){
  length(x$side_lengths) == 4 &&
    x$side_lengths[1] == x$side_lengths[2] &&
    x$side_lengths[2] == x$side_lengths[3] &&
    x$side_lengths[3] == x$side_lengths[4]
}

is_square(square_4)
```

    ## [1] TRUE

``` r
is_square(triangle_3)
```

    ## [1] FALSE

So far this only handles the cases were the object is of class
`shape_S3`. We can add a default for when there is no method associated
with the object passed to `is_square()`.

``` r
is_square.default <- function(x){
  NA
}
is_square("square")
```

    ## [1] NA

If we try to print the `square_4` object we get a not so pretty output.

``` r
print(square_4)
```

    ## $side_lengths
    ## [1] 4 4 4 4
    ## 
    ## attr(,"class")
    ## [1] "shape_S3"

Luckily, `print()` is a generic method, so we can add a print method for
the `shape_S3` class.

``` r
print.shape_S3 <- function(x){
  if(length(x$side_lengths) == 3){
    paste("A triangle with side lengths of", x$side_lengths[1], 
          x$side_lengths[2], "and", x$side_lengths[3])
  } else if(length(x$side_lengths) == 4) {
    if(is_square(x)){
      paste("A square with four sides of length", x$side_lengths[1])
    } else {
      paste("A quadrilateral with side lengths of", x$side_lengths[1],
            x$side_lengths[2], x$side_lengths[3], "and", x$side_lengths[4])
    }
  } else {
    paste("A shape with", length(x$side_lengths), "slides.")
  }
}

print(square_4)
```

    ## [1] "A square with four sides of length 4"

``` r
print(triangle_3)
```

    ## [1] "A triangle with side lengths of 3 3 and 3"

``` r
print(shape_s3(c(10, 10, 20, 20, 15)))
```

    ## [1] "A shape with 5 slides."

``` r
print(shape_s3(c(2, 3, 4, 5)))
```

    ## [1] "A quadrilateral with side lengths of 2 3 4 and 5"

Unsurprising, lots of objects in R have an associated print method.

``` r
head(methods(print), 10)
```

    ##  [1] "print.acf"     "print.AES"     "print.anova"   "print.aov"    
    ##  [5] "print.aovlist" "print.ar"      "print.Arima"   "print.arima0" 
    ##  [9] "print.AsIs"    "print.aspell"

With S3 objects you can also specify a super class for an object the
same way you assign a class.

``` r
class(square_4)
```

    ## [1] "shape_S3"

``` r
class(square_4) <- c("shape_S3", "square")
class(square_4)
```

    ## [1] "shape_S3" "square"

We can also check if an object is a sub-class of a specific class:

``` r
inherits(square_4, "square")
```

    ## [1] TRUE

## S4

S4 is slightly more restrictive than S3, but is similar in many ways. S4
classes are created with `setClass()`. When creating a S4 class, you
need to specify two or three arguments:

1.  class name as a string
2.  slots, a named list of attributes whose values are the class of the
    attribute
3.  contains, a string specifying a super-class to inherit from
    (optional)

``` r
setClass("bus_S4",
         slots = list(n_seats = "numeric", 
                      top_speed = "numeric",
                      current_speed = "numeric",
                      brand = "character"))
setClass("party_bus_S4",
         slots = list(n_subwoofers = "numeric",
                      smoke_machine_on = "logical"),
         contains = "bus_S4")
```

To create objects from our S4 classes, we can use the `new()` function.
Its arguments are the name of the class and values for each slot
(attribute).

``` r
my_bus <- new("bus_S4", n_seats = 20, top_speed = 80,
              current_speed = 0, brand = "Volvo")

my_bus
```

    ## An object of class "bus_S4"
    ## Slot "n_seats":
    ## [1] 20
    ## 
    ## Slot "top_speed":
    ## [1] 80
    ## 
    ## Slot "current_speed":
    ## [1] 0
    ## 
    ## Slot "brand":
    ## [1] "Volvo"

``` r
my_party_bus <- new("party_bus_S4", n_seats = 10, top_speed = 100,
                    current_speed = 0, brand = "Mercedes-Benz", 
                    n_subwoofers = 2, smoke_machine_on = FALSE)
my_party_bus
```

    ## An object of class "party_bus_S4"
    ## Slot "n_subwoofers":
    ## [1] 2
    ## 
    ## Slot "smoke_machine_on":
    ## [1] FALSE
    ## 
    ## Slot "n_seats":
    ## [1] 10
    ## 
    ## Slot "top_speed":
    ## [1] 100
    ## 
    ## Slot "current_speed":
    ## [1] 0
    ## 
    ## Slot "brand":
    ## [1] "Mercedes-Benz"

The `@` operator lets you access slots in a S4 object:

``` r
my_bus@n_seats
```

    ## [1] 20

Implementing generic methods in the S4 system works as follows:

``` r
setGeneric("is_bus_moving", function(x){
        standardGeneric("is_bus_moving")
})
```

    ## [1] "is_bus_moving"

Now to define the method with `setMethod()`. Its arguments are the name
of the method as a string, the method signature that specifies the class
of each argument for the method, and the function definition.

``` r
setMethod("is_bus_moving",
          c(x = "bus_S4"),
          function(x){
                  x@current_speed > 0
          })

is_bus_moving(my_bus)
```

    ## [1] FALSE

``` r
my_bus@current_speed <- 1
is_bus_moving(my_bus)
```

    ## [1] TRUE

As before, we can use existing generic methods to create a method for
your new class.

``` r
setGeneric("print")
```

    ## [1] "print"

``` r
setMethod("print",
          c(x = "bus_S4"),
          function(x){
            paste("This", x@brand, "bus is traveling at a speed of", x@current_speed)
          })

print(my_bus)
```

    ## [1] "This Volvo bus is traveling at a speed of 1"

``` r
print(my_party_bus)
```

    ## [1] "This Mercedes-Benz bus is traveling at a speed of 0"

## Reference Classes

Reference classes follow a different philosphy than that of S3/S4, more
aligned with other OOP languages.

``` r
Student <- setRefClass("Student",
                      fields = list(name = "character",
                                    grad_year = "numeric",
                                    credits = "numeric",
                                    id = "character",
                                    courses = "list"),
                      methods = list(
                        hello = function(){
                          paste("Hi! My name is", name)
                        },
                        add_credits = function(n){
                          credits <<- credits + n
                        },
                        get_email = function(){
                          paste0(id, "@jhu.edu")
                        }
                      ))
```

Our Student class has five fields and three methods. To create a Student
object, we can use the `new()` method.

``` r
brooke <- Student$new(name = "Brooke", grad_year = 2019, credits = 40,
                    id = "ba123", courses = list("Ecology", "Calculus III"))
roger <- Student$new(name = "Roger", grad_year = 2020, credits = 10,
                    id = "rp456", courses = list("Puppetry", "Elementary Algebra"))
```

To access fields or methods, use `$`.

``` r
brooke$credits
```

    ## [1] 40

``` r
roger$hello()
```

    ## [1] "Hi! My name is Roger"

``` r
roger$get_email()
```

    ## [1] "rp456@jhu.edu"

Methods can be used to change the state of an object, for example the
`add_credits()` method does the following:

``` r
brooke$credits
```

    ## [1] 40

``` r
brooke$add_credits(4)
brooke$credits
```

    ## [1] 44

When writing this method, we had to use the `<<-` operator. This is
required if your goal is to modify the fields of an object with a
method.

To inherit from other classes, specify the `contains` arugment when
defining a class.

``` r
Grad_Student <- setRefClass("Grad_Student",
                            contains = "Student",
                            fields = list(thesis_topic = "character"),
                            methods = list(
                              defend = function(){
                                paste0(thesis_topic, ". QED.")
                              }
                            ))

jeff <- Grad_Student$new(name = "Jeff", grad_year = 2021, credits = 8,
                    id = "jl55", courses = list("Fitbit Repair", 
                                                "Advanced Base Graphics"),
                    thesis_topic = "Batch Effects")
jeff$defend()
```

    ## [1] "Batch Effects. QED."
