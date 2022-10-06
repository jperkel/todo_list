# todo.R -- convert a spreadsheet into a todo list
#
# Given a comma-separated values (CSV) file with columns for: 
# Pub_date, Topic, Status, plus arbitrary pairs of MILESTONE_date and MILESTONE_done, 
# this script creates a to-do list of upcoming 'milestones'. 
#
# 

suppressPackageStartupMessages({library(tidyverse)})
# variable to hold ancillary to-dos, if they exist
other_todos <- NULL

# set this to match the date format you use. Suppose the date is March 1, 2021:
# "2021-03-01" = "%Y-%m-%d"
# "03/01/2021" = "%m/%d/%Y"
# "01/03/2021" = "%d/%m/%Y"
# "01 Mar 2021" = "%d %b %Y"
# for other options see https://www.r-bloggers.com/2013/08/date-formats-in-r/
date_format <- "%Y-%m-%d"

# make sure path points to your planning spreadsheet location
pub_table <- suppressMessages(read_csv("Planning_spreadsheet_demo.csv"))
if (file.exists("Other_todos.csv")) {
  other_todos <- suppressMessages(read_csv("Other_todos.csv"))
}

today <- Sys.Date()

# Use the 'tidyr' package to make our data 'tidy' (https://r4ds.had.co.nz/tidy-data.html). 
# Each row, representing one article, is split into multiple columns, one for each _date column  
# Those column headings are saved in a new column called Milestones, 
# and the associated dates go into a new column called Date.
pub_table <- pub_table %>% 
  pivot_longer(cols = (!starts_with("Pub") & ends_with("_date")), names_to = "Milestone", values_to = "Date") %>%
  # Remove rows in which no date is supplied 
  filter(!is.na(Date)) %>% 
  # remove cols we don't need
  select(-c(Type, Print, Author, Assigned_words)) %>% 
  # calculate the number of days remaining for each milestone.
  mutate(Remaining = as.Date(Date, format = date_format) - as.Date(today, format = date_format),
         # col_to_eval is the column that we're interested in -- that is, MILESTONE_done == FALSE?
         col_to_eval = stringr::str_replace(Milestone, '_date$', '_done'),
         row = row_number()) %>% 
  # pivot table and group by row # so that we can match Milestone_date with Milestone_done field and
  # determine if the milestone should be included in the final todo list
  pivot_longer(ends_with("_done")) %>% 
  group_by(row) %>% 
  # here is where we decide what to include: if the col_to_eval == name and its corresponding value is FALSE
  filter(col_to_eval == name & !value) %>% 
  # pivot back to wide
  pivot_wider(!ends_with("_done")) %>% 
  ungroup() %>%
  select(c(Date, Pub_date, Remaining, Topic, Milestone, Status)) %>%
  # rename milestone from 'Milestone_date' -> 'Milestone' 
  mutate(Milestone = stringr::str_replace(Milestone, '_date', ''),
         Milestone = stringr::str_replace_all(Milestone, '_', ' ')) 

# process ancillary to-do list, if it exists, and fold into pub_table
if (!is.null(other_todos)) {
  other_todos <- other_todos[other_todos$Done != TRUE,] %>% 
    mutate(Remaining = as.Date(Due_date, format = date_format) - as.Date(today, format = date_format), 
           Pub_date = NA, 
           Milestone = "To-do",
           Status = NA
           ) %>%
    rename(Date = Due_date, Topic = Todo) %>%
    select(Date, Pub_date, Remaining, Topic, Milestone, Status)
  pub_table <- rbind(pub_table, other_todos)
}

# sort the table by date
pub_table <- pub_table %>% arrange(Date, Pub_date)
print (pub_table, n=Inf)