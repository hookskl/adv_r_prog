
#########################################
# The variables in the dataset are
#       id: the subject identification number
#       visit: the visit number which can be 0, 1, or 2
#       room: the room in which the monitor was placed
#       value: the level of pollution in micrograms per cubic meter
#       timepoint: the time point of the monitor value for a given visit/room
#
# You will need to design a class called “LongitudinalData” that characterizes 
# the structure of this longitudinal dataset. You will also need to design 
# classes to represent the concept of a “subject”, a “visit”, and a “room”.
#
# In addition you will need to implement the following functions:
#       make_LD: a function that converts a data frame into a “LongitudinalData” object
#       subject: a generic function for extracting subject-specific information
#       visit: a generic function for extracting visit-specific information
#       room: a generic function for extracting room-specific information
# 
# For each generic/class combination you will need to implement a method, 
# although not all combinations are necessary (see below). You will also 
# need to write print and summary methods for some classes (again, see below).
#############################

## load necessary packages
require(dplyr)
require(tidyr)

## Constructor function for LongitudinalData objects
## df is a data frame object

make_LD <- function(df) {
        if(!"data.frame" %in% class(df))
                stop("'df' should be a data.frame")
        
        ## Create the "LongitudinalData" object 
        object <- list(df = df)
        
        ## Set the class name
        class(object) <- "LongitudinalData"
        object
}


## print method for LongitudinalData objects
## ld an object of class LongitudinalData
print.LongitudinalData <- function(ld, ...) {
        cat(paste("Longitudinal dataset with", 
                  length(unique(ld$df$id)), "subjects"))
        invisible(ld)
}

## generic method subject filters LongitudinalData objects
## subj_id is a numeric value for filtering `id`
## returns an object of class subject
subject <- function(ld, subj_id) UseMethod("subject")

subject.LongitudinalData <- function(ld, subj_id) {
        if(!is.numeric(subj_id)) {
                stop("'subj_id' should be a numeric value")
        }
        
        ## create the "subject" object
        df <- ld$df %>% filter(id == subj_id)
        object <- list(id = subj_id, df = df)
        class(object) <- "subject"
        object
}

## print method for subject objects
## subj an object of class subject
print.subject <- function(subj, ...) {
        if(nrow(subj$df) == 0) {
                print(NULL)
        } else {
                cat(paste("Subject ID:", subj$id))     
        }
        invisible(subj)
        
}

## summary method for subject objects
## subj an object of class subject
## creates a table of mean values for 
## each room type, grouped by visit
## returns object of class summarySubject
summary.subject <- function(subj, ...) {
        if(nrow(subj$df) == 0) {
                NULL
        } else {
                # create subjectSummary object
                summary_df <- subj$df %>% 
                        group_by(visit, room) %>% 
                        summarise(mean_value = mean(value, na.rm = TRUE), 
                                  .groups = "drop") %>% 
                        pivot_wider(names_from = room, 
                                    values_from = mean_value)
                object <- list(summary_df = summary_df, 
                               id = subj$id)
                class(object) <- "subjectSummary"
                invisible(object)
                
        }        
}

## print method for subjectSummary objects
## ss an object of class subjectSummary
print.subjectSummary <- function(ss, ...) {
        cat(paste("ID:", ss$id))
        cat(paste(" ", " ",  sep = "\n"))
        print(ss$summary_df)        
}


## generic method visit filters subject objects 
## subj an object of class subject
## visit_id a numeric id specifying the visit
## to filter on
## returns an object of class visit
visit <- function(subj, visit_id) UseMethod("visit")
visit.subject <- function(subj, visit_id) {
        if(!is.numeric(visit_id)) {
                stop("'visit_id' should be a numeric value")
        }
        
        visit_df <- subj$df %>% filter(visit == visit_id)
        object <- list(df = visit_df, id = subj$id, visit_id = visit_id)
        class(object) <- "visit"
        object
}

## print method for visit objects
print.visit <- function(visit, ...) {
        if(nrow(visit$df) == 0){
                print(NULL)
        } else {
                cat(paste("Subject ID:", visit$id))
                cat(paste("\nVisit:", visit$visit_id))
                
        }
        invisible(visit)
}

## summary method for visit objects
## creates a table of mean values for 
## each room type
## returns object of class visitSummary
summary.visit <- function(visit, ...) {
        if(nrow(visit$df) == 0) {
                NULL
        } else {
                # create visitSummary object
                summary_df <- visit$df %>% 
                        group_by(room) %>% 
                        summarise(mean_value = mean(value, na.rm = TRUE), 
                                  .groups = "drop") %>% 
                        pivot_wider(names_from = room, 
                                    values_from = mean_value)
                object <- list(summary_df = summary_df, 
                               id = visit$id,
                               visit_id = visit$visit_id)
                class(object) <- "visitSummary"
                invisible(object)
                
        }                
}

## print method for visitSummary objects
## vs an object of class visitSummary
print.visitSummary <- function(vs, ...) {
        cat(paste("ID:", vs$id))
        cat(paste("\nVisit:", vs$visit_id))
        cat(paste(" ", " ",  sep = "\n"))
        print(vs$summary_df)        
}

## generic method room filters visit objects 
## visit an object of class visit
## room_type a character string specifying
## the room type to filter on
## returns object of class room
room <- function(visit, room_name) UseMethod("room")
room.visit <- function(visit, room_name) {
        if(!is.character(room_name)) {
                stop("'room_name' should be a string")
        }
        
        room_df <- visit$df %>% filter(room == room_name)
        object <- list(df = room_df, id = visit$id, 
                       visit_id = visit$visit_id,
                       room_name = room_name)
        class(object) <- "room"
        object
}

## print method for room objects
## room an object of class room
print.room <- function(room, ...) {
        if(nrow(room$df) == 0){
                NULL
        } else {
                cat(paste("Subject ID:", room$id))
                cat(paste("\nVisit:", room$visit_id))
                cat(paste("\nRoom:", room$room_name))
        } 
        invisible(room)
}

## summary method for room objects
## room an object of class room
## creates a table summarizing values
## from the room object: 
##      min, max, med, mean and 1st/3rd quantiles
## returns object of class roomSummary
summary.room <- function(room) {
        summary_df <- room$df %>% 
                select(value) %>% 
                summarise(`Min.` = min(value), 
                          `1st Qu.` = quantile(value, .25), 
                          Median = median(value), 
                          Mean = mean(value, na.rm = TRUE), 
                          `3rd Qu.` = quantile(value, 0.75), 
                          `Max.` = max(value))   
        
        object <- list(id = room$id, 
                       visit_id = room$visit_id,
                       room_name = room$room_name,
                       summary_df = summary_df)
        class(object) <- "roomSummary" 
        invisible(object)
}

## generic method for printing roomSummary objects
## rs an object of class roomSummary
print.roomSummary <- function(rs, ...) {
        
        cat(paste("ID:", rs$id, "\n"))
        print(rs$summary_df)
}
