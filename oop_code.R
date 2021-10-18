
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

## create LongitudinalData class (S3)

LongitudinalData <- function(df) {
        structure(list(df = df,
                       subjects = unique(df$id),
                       rooms = unique(df$room)),
                  class = "LongitudinalData")
}

## function make_LD is used to convert a data frame
## to class LongitudinalData
make_LD <- function(df) UseMethod("make_LD")

make_LD <- function(df) {
        LongitudinalData(df)
}

## create generic method for printing objects of class 
## LongitudinalData
print.LongitudinalData <- function(ld) {
        cat(paste("Longitudinal dataset with", length(ld$subjects), "subjects"))
}

## subject function takes a LogitudinalData object
## and integer value representing a subject's id
## and returns a subject object containing a dataframe
## filtered by the id. 
subject <- function(ld, subject_id) {
        subject_df <- ld$df %>% filter(id == subject_id) 
        structure(list(subject_id = subject_id, df = subject_df),
                  class = "subject")
}

## generic method for printing objects of class subject
print.subject <- function(subject) {
        if(nrow(subject$df) == 0){
                NULL
        } else {
                cat(paste("Subject ID:", subject$subject))
                
        }
        
}

## generic method for summarizing objects of class subject
## returns class subjectSummary
summary.subject <- function(subject) {
        summary_df <- subject$df %>% 
                group_by(visit, room) %>% 
                summarise(mean_value = mean(value, na.rm = TRUE), .groups = "drop") %>% 
                pivot_wider(names_from = room, values_from = mean_value) 
        structure(list(subject_id = subject$subject_id, summary_df = summary_df),
                  class = "subjectSummary")
}

## generic method for printing objects of class
## subjectSummary
print.subjectSummary <- function(subjectSummary) {
        cat(paste("ID:", subjectSummary$subject_id))
        cat(paste(" ", " ",  sep = "\n"))
        print(subjectSummary$summary_df)
}

## visit function takes a subject object and integer value
## representing a visit id and returns a visit object
## containing a dataframe filtered by visit id
visit <- function(subject, v_id) {
        visit_df <- subject$df %>% filter(visit == v_id) 
        structure(list(subject_id = subject$subject_id, visit_id = v_id, df = visit_df),
                  class = "visit")
}

## generic method for printing visit objects
print.visit <- function(visit) {
        if(nrow(visit$df) == 0){
                NULL
        } else {
                cat(paste("Subject ID:", visit$subject_id))
                cat(paste("\nVisit:", visit$visit_id))
                
        }
        
}
## generic method for summarizing visit objects
## returns a visitSummary object
summary.visit <- function(visit) {
        summary_df <- visit$df %>% 
                select(room, value) %>% 
                group_by(room) %>% 
                summarise(mean_values = mean(value, na.rm = TRUE)) %>% 
                pivot_wider(names_from = room, values_from = mean_values) 
        structure(list(subject_id = visit$subject_id, 
                       visit_id = visit$visit_id, 
                       summary_df = summary_df),
                  class = "visitSummary")
}

## generic method for printing visitSummary objects
print.visitSummary <- function(visitSummary) {
        cat(paste("ID:", visitSummary$subject_id))
        cat(paste("\nVisit:", visitSummary$visit_id, "\n"))
        print(visitSummary$summary_df)
        
}
## room function takes a visit object and character string 
## and returns a room object containing a dataframe 
## filtered by room_name
room <- function(visit, room_name) {
        room_df <- visit$df %>% filter(room == room_name) 
        structure(list(subject_id = visit$subject_id, 
                       visit_id = visit$visit_id, 
                       room_name = room_name,
                       df = room_df),
                  class = "room")
}

## generic method for printing room objects
print.room <- function(room) {
        if(nrow(room$df) == 0){
                NULL
        } else {
                cat(paste("Subject ID:", room$subject_id))
                cat(paste("\nVisit:", room$visit_id))
                cat(paste("\nRoom:", room$room_name))
                
        }
        
}
## generic method for summarizing room objects
## returns a roomSummary object
summary.room <- function(room) {
        summary_df <- room$df %>% 
                select(value) %>% 
                summarise(`Min.` = min(value), 
                          `1st Qu.` = quantile(value, .25), 
                          Median = median(value), 
                          Mean = mean(value, na.rm = TRUE), 
                          `3rd Qu.` = quantile(value, 0.75), 
                          `Max.` = max(value))
        
        structure(list(subject_id = room$subject_id, 
                       visit_id = room$visit_id,
                       room_name = room$room_name,
                       summary_df = summary_df),
                  class = "roomSummary")        
}
## generic method for printing roomSummary objects
print.roomSummary <- function(roomSummary) {
        cat(paste("ID:", roomSummary$subject_id, "\n"))
        print(roomSummary$summary_df)
}



