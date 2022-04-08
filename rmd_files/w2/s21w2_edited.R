rm(list=ls())

# load libraries
library(rvest)
library(magrittr)
library(scales)
library(lubridate)
library(dplyr)
library(purrr)

# We will start webscrapping the rating of a movie on IMDB
# Download the "SelectorGadget" (a chrome extension, www.selectorgadget.com)

# Movie: Isle of Dogs (https://www.imdb.com/title/tt5104604/?ref_=nm_flmg_dr_2)

# define the URL
url <- "https://www.imdb.com/title/tt5104604/?ref_=nm_flmg_dr_2"

# rating
url %>%               # the URL you want to scrape
  read_html() %>%               # reads the extracted html
  html_nodes('.sc-7ab21ed2-1') %>% # extracts pieces out of html (use Selector Gadget)
  html_text() %>%                   # extracts attributes from html
  as.numeric() # make rating numeric

##########################################
# scrape US open champions and runner-ups
##########################################

url_USopen = "https://en.wikipedia.org/wiki/List_of_US_Open_women%27s_singles_champions"

champions <- url_USopen %>% # URL
  read_html() %>%       # reads the tables
  html_table(fill=TRUE) # extracts tables out of html

class(champions) # inspect the class of element

# Visual inspection of the elements in the list
champions[[1]] # first element in the list (categories of wikipedia article)
champions[[3]] # third element of the list (champions of the US national championship)
champions[[4]] # fourth element (champions of US open, modern era)
champions[[5]]
champions[[6]]

# clean data and turn into a neat dataframe
pre <- rbind.data.frame(champions[[3]])  # turn list into dataframe
post <- rbind.data.frame(champions[[4]]) # turn list into dataframe
colnames(pre) <- colnames(post)           # homogeneize column names
champions_table <- rbind.data.frame(pre,post) # append the dataframes

# number of championships per country
freq <- as.data.frame(table(champions_table$Country))
freq <- freq[order(freq$Freq, decreasing = TRUE), ] 

# get list of winners
runnerup <- champions_table$`Runner-up`

#########################################
# find length of biography of runnerups #
#########################################

# the first runner up was Laura Knight (https://en.wikipedia.org/wiki/Laura_Knight)

# the second runner up was Ellen Hansell (https://en.wikipedia.org/wiki/Ellen_Hansell)

# Notice that the URLs have the following structure: https://en.wikipedia.org/wiki/Name_Surname.

# replace white space in names with "_"
champions_table$runnerup <- gsub(" ", "_", champions_table$`Runner-up`)

# use the structure of the url to create a full list of URLs
base_runnersup <- "https://en.wikipedia.org/wiki/"

# make list of wikipedia URLs
urls_runnersup <- paste0(base_runnersup,champions_table$runnerup)

# inspect the list
head(urls_runnersup)

# use a for-loop to search for the runnerups one by one, and record length

champions_table$bio_runnerup <- c() # empty column in the dataframe

# we will do it for the first ten runnerups
for (i in 1:10) {
  webpage <- read_html(urls_runnersup[i])
  biography <- html_nodes(webpage,'#content')
  biography <- html_text(biography)
  champions_table$bio_runnerup[i] <- nchar(biography)
  print(i)
}


# you can also do it for the entire dataframe
# for(i in 1:nrow(champions_table)){
#  webpage <- read_html(urls_runnerups[i])
#  biography <- html_nodes(webpage,'#content')
#  biography <- html_text(biography)
#  champions_table$bio_runnerup[i] <- nchar(biography)
#  print(i)
#}


###########################
# Web-scrape twitter data #
###########################

library(rtweet)

# Get 10 tweets from last 6-9 days that contain "Stanford"
tw <- search_tweets(
  q = "Stanford",         # Query to be searched
  n = 10,                 # Total number of desired tweets
  include_rts = FALSE     # Logical (whether to include retweets)
)

# Get 100 latest tweets from user
tl <- rtweet::get_timeline(
  user = "Stanford", # User to be searched
  n=100
)

# plot time-series of frequency
#ts_plot(tl, by = "1 year")  # plot the number of tweets per year
ts_plot(tl, by = "1 month") # plot the number of tweets per month
ts_plot(tl, by = "1 day")   # plot the number of tweets per day


###########################################
# combine the two tools we learned today
###########################################

# obtain list of most followed twitter accounts

# define the URL with the 50 most followed Twitter accounts
url <- "https://en.wikipedia.org/wiki/List_of_most-followed_Twitter_accounts"

# scrape the data
accounts <- url %>% # URL
  read_html() %>%       # reads the tables
  html_table(fill=TRUE) # extracts tables out of html

# select the table of interest and convert to dataframe
table_accounts <-as.data.frame(accounts[[1]])

# inspect the dataframe
variable.names(table_accounts)

# make a list of account names
tw_accounts <- table_accounts$`Account name`

# remove the @ symbol
tw_accounts <- gsub("[[:punct:]]", "", tw_accounts)  # no libraries needed

# use the twitter accounts to scrape their tweets in the last 10 days

# do it for the first account
tl <- get_timeline(
  user = tw_accounts[1],    # User to be searched
  n = 10                      # Number of tweets
)

# use a for-loop to scrape the tweets of the other 49 Twitter accounts
for(i in 2:length(tw_accounts)){
  
  # scrape tweets
  tl2 <- get_timeline(
    user = tw_accounts[i],
    n = 10
  )
  
  # append the dataframes by rows
  tl <- rbind.data.frame(tl,tl2)
  
  # print progress
  print(i) 
  
}

# inspect the tweets
View(tl)

View(list(1:3))




