# todo.R -- convert a spreadsheet into a todo list
#
# Given a comma-separated values (CSV) file with columns for project_name, 
# plus arbitrary pairs of MILESTONE_date and MILESTONE_done, 
# this script creates a to-do list of upcoming 'milestones'. 
#
# 

library(tidyverse)

# set this to match the date format you use. Suppose the date is March 1, 2021:
# "2021-03-01" = "%Y-%m-%d"
# "03/01/2021" = "%m/%d/%Y"
# "01/03/2021" = "%d/%m/%Y"
# "01 Mar 2021" = "%d %b %Y"
# for other options see https://www.r-bloggers.com/2013/08/date-formats-in-r/
date_format <- "%Y-%m-%d"
today <- Sys.Date()

# this script uses an artificial table, but you can load one from CSV: 
# mytable <- read_csv("my_spreadsheet.csv")

projects <- paste0("Project_", LETTERS[1:6])
m1_done <- c(T, T, T, F, F, F)
m2_done <- c(T, T, F, F, F, F)
m3_done <- c(T, F, F, F, F, F)
m4_done <- c(F, F, F, F, F, F)

mytable <- data.frame(
  project_name = projects,
  project_start_date = today + 1:6,
  project_start_done = m1_done,
  interim_report_date = today + 7:12,
  interim_report_done = m2_done,
  presentation_date = today + 13:18,
  presentation_done = m3_done,
  final_report_date = today + 19:24,
  final_report_done = m4_done
)

# Use {tidyr} to make our data 'tidy' (https://r4ds.had.co.nz/tidy-data.html). 
# Each row, representing one project, is split into multiple columns, one for each _date column  
# Those column headings are saved in a new column called 'milestone', 
# and the associated dates go into a new column called 'due_date'.
mytable <- mytable %>%
  pivot_longer(cols = ends_with("_date"), names_to = "milestone", values_to = "due_date") %>%
  # Remove rows in which no date is supplied 
  filter(!is.na(due_date)) %>% 
  # calculate the number of days remaining for each milestone.
  mutate(remaining = as.Date(due_date, format = date_format) - as.Date(today, format = date_format),
         # col_to_eval is the column that we're interested in -- that is, MILESTONE_done == FALSE?
         col_to_eval = stringr::str_replace(milestone, '_date$', '_done'),
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
  select(c(due_date, remaining, project_name, milestone)) %>%
  # rename milestone from 'milestone_date' -> 'milestone' 
  mutate(milestone = stringr::str_replace(milestone, '_date', ''),
         milestone = stringr::str_replace_all(milestone, '_', ' ')) 

# sort the table by date
mytable <- mytable %>% arrange(due_date)
print (mytable)