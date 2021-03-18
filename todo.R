# todo.R -- convert a spreadsheet into a todo list
#
# Given a comma-separated values (CSV) file with the following columns: 
# Pub_date, Type, Print, Topic, Author, First_draft_date, Draft_done, Art_brief_date, 
# Brief_done, Subedit_date, Subedit_done, Pages_pass_date, Pass_done, Assigned_words and Status, 
# this script creates a to-do list of upcoming 'milestones' -- in this case, the due dates for
# first draft, art brief, subediting, and article pass. 
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

# Use the 'tidyr' package to make our data 'tidy' (https://r4ds.had.co.nz/tidy-data.html). Each row, representing
# one article, is split into four, one each for First_draft_date, Art_brief_date, Subedit_date, and
# Pages_pass_date. Those column headings (ie, 'milestones') are saved in a new column called Milestones, 
# and the associated dates go into a new column called Date.
#
# Remove rows in which no date is supplied, and calculate the number of days remaining for each milestone. 
pub_table <- pub_table %>% 
  pivot_longer(c(First_draft_date, Art_brief_date, Subedit_date, Pages_pass_date), 
               names_to = "Milestone", values_to = "Date") %>% 
  filter(!is.na(Date)) %>% 
  mutate(Remaining = as.Date(Date, format = date_format) - as.Date(today, format = date_format)) 

# for each milestone, if corresponding _done field is TRUE (ie, if the task is done), delete the row
indexes <- rep(TRUE, nrow(pub_table))
for (i in 1:nrow(pub_table)) {
  switch(pub_table$Milestone[i], 
         "First_draft_date" = { if (is.na(pub_table$Draft_done[i]) || pub_table$Draft_done[i] == TRUE) indexes[i] <- FALSE },
         "Art_brief_date" = { if (is.na(pub_table$Brief_done[i]) || pub_table$Brief_done[i] == TRUE) indexes[i] <- FALSE },
         "Subedit_date" = { if (is.na(pub_table$Subedit_done[i]) || pub_table$Subedit_done[i] == TRUE) indexes[i] <- FALSE },
         "Pages_pass_date" = { if (is.na(pub_table$Pass_done[i]) || pub_table$Pass_done[i] == TRUE) indexes[i] <- FALSE }
  )
}
pub_table <- pub_table[which(indexes == TRUE),] %>% 
  select("Date", "Pub_date", "Remaining", "Topic", "Milestone") 

# rename milestone from 'Milestone_due_date' -> 'Milestone' 
pub_table$Milestone <- pub_table$Milestone %>% gsub('_date$', '', .) %>% 
  gsub('_', ' ', .)

# process ancillary to-do list, if it exists, and fold into pub_table
if (!is.null(other_todos)) {
  other_todos <- other_todos[other_todos$Done != TRUE,] %>% 
    mutate(Remaining = as.Date(Due_date, format = date_format) - as.Date(today, format = date_format), 
           Pub_date = NA, 
           Milestone = "To-do") %>%
    rename(Date = Due_date, Topic = Todo) %>%
    select(Date, Pub_date, Remaining, Topic, Milestone)
  pub_table <- rbind(pub_table, other_todos)
}

# sort the table by date
pub_table <- pub_table[order(pub_table$Date, pub_table$Pub_date),]
print (pub_table, n=Inf)