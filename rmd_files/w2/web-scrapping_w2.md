---
title: "Web Scrapping (ECON/POLISCI 151, Week 2 Section)"
author: "Albert Chiu"
date: ""
output:
    html_document: 
        keep_md: yes
    rmarkdown::github_document: default
---



## A Brief Primer on HTML
HyperText Markup Language (HTML) is a markup language (similar to LaTeX) and is what most websites are written in. An html document is essentially a tree composed of nodes. Nodes can be text, links, tables, etc., and they themselves can have "descendant" nodes (e.g., a table is itself a node, but inside the table there might be something that makes text italics, and then inside that will be the text itself).

For our purposes, there are a few important terms to introduce. First, an _element_ is a type of node that makes up the document, and it can be used for many different purposes. An element is delimited at the front and the end with a _tag_. Below is an example of an element:

    <p> text here </p>

The <tt>`<p>`</tt> at the beginning and the <tt>`</p>`</tt> at the end are tags. 

Elements can also have _attributes_, which are specified inside the opening tag. For example, we might want our element to be a certain color. We can do this using the <tt>style</tt> attribute:

    <p style="color:#8C1515"> text here </p>.

This will appear to the viewer as:

<p style="color:#8C1515"> text here </p>

## General Websites
To do webscrapping in R, we will be using the <tt>rvest</tt> package (a part of <tt>tidyverse</tt>). <tt>rvest</tt> is designed to go with <tt>magrittr</tt> package; you don't need to use the latter, but taking advantage of the pipe <tt>%>%</tt> operator will make your code a lot less verbose. 

We will use a CNN page on the war in Ukraine as an example. First, we need to use the <tt>read_html</tt> function to read the html document (the function returns an xml file, a format which <tt>rvest</tt>'s other functions will need).


```r
cnn_url <- "https://www.cnn.com/europe/live-news/ukraine-russia-putin-news-04-3-22/h_4d0118cfd6f30770be0f8f54e041f9d2"
cnn_page <- cnn_url %>% rvest::read_html() # read_html is actually from xml2, which rvest imports 
```

There are many types of data you might want from a webpage, and each will require a different method of extraction. In this case, we're looking at an article and most likely will want the contents of that article. As a starting point, we might want to look at text that is sandwiched by p tags,

    <p> text here </p>.


```r
cnn_text <- cnn_page %>%
  rvest::html_elements("p") %>%  # elements delimited by the p tag
  rvest::html_text()  # text inside the tag
head(cnn_text)
```

```
## [1] "By Simone McCarthy, Steve George, Sana Noor Haq, Melissa Macaya, Mike Hayes, Maureen Chowdhury and Amir Vera, CNN"                                                                                                                                             
## [2] "From CNN's Jonny Hallam "                                                                                                                                                                                                                                      
## [3] ""                                                                                                                                                                                                                                                              
## [4] "The bodies of at least 20 civilian men have been found lying strewn across the street in the town of Bucha, northwest of Kyiv following the withdrawal of Russian forces from the area in shocking images released by AFP on Saturday. "                       
## [5] "The dead, all in civilian clothing, are found in a variety of awkward poses, some face down against the pavement, others facing upwards with mouths open.  "                                                                                                   
## [6] "\"Three of them are tangled up in bicycles after taking their final ride, while others, with waxy skin, have fallen next to bullet-ridden and crushed cars,\" according to AFP journalists who accessed the town after it had been cut off for nearly a month."
```

This gives us a vector of all the text in each of the paragraph elements on the webpage. 

(Alternatively, you can look try other tags, like "body" -- just note that using a different tag will also mean the output is formated differently (and all the paragraphs will be smooshed together).)

Another example is images: Perhaps we are interested in seeing what types of images news organizations with different political leanings tend to use when covering a given subject (e.g., are more right-leaning news organizations more likely to include pictures of violence/destruction of property when reporting on BLM?). To do this, we will retrieve the <tt>src</tt> attribute of the <tt>img</tt> element.


```r
cnn_img <- cnn_page %>% 
  rvest::html_elements("img") %>%  # img elements
  rvest::html_attr("src")  # the src attribute
```


This gives us links to the images, which we can then feed to whatever learner (or human coder) we want. Maybe we also want to store the captions for these photos:


```r
cnn_cap <- cnn_page %>% rvest::html_elements("figcaption") %>% rvest::html_text()
cnn_img_df <- cbind(link_to_img = cnn_img, caption = cnn_cap)
cnn_img_df[1:2, ]  # first two examples
```

```
##      link_to_img                                                                                     
## [1,] "https://dynaimage.cdn.cnn.com/cnn/digital-images/org/a34e1e33-dff8-478a-ac2e-7d523421b67f.jpeg"
## [2,] "https://dynaimage.cdn.cnn.com/cnn/digital-images/org/c793ffa3-2eba-4dc9-ac37-304305383611.jpeg"
##      caption                                                                                                                                                                                                                         
## [1,] "A man walks with bags of food given to him by the Ukrainian Army in Bucha, Ukraine on April 2. (Ronaldo Schemidt/AFP/Getty Images)"                                                                                            
## [2,] "David Arakhamia, left, Mykhailo Podolyak, center and Crimean Tatar leader Mustafa Dzhemilev speak with the media after their meeting with Russian negotiators in Istanbul, Turkey on March 29.  (Mehmet Emin Caliskan/Reuters)"
```

What you do with this information is a whole 'nother story. We will learn a bit about how to use text as data in a future section, but computer vision is beyond the scope of this class. 

There is, however, one concern that we can address now: What if we can't/don't want to collect the url of potentially thousands of websites? In some circumstances, there will be websites that aggregate other websites, and we can scrape urls from such aggregators. In this case, we can use Google News, which aggregates links to news articles.

## Aggregation Websites: e.g., Google News
This section will walk you through the process of scraping Google News for articles on a specific topic. We will use "ukraine" as the example, but this code can be readily repurposed for search term(s). This is because Google News uses a fixed url format that varies only in the search term, which makes it easy for us to write flexible code. To see what this url is, you can just go to the Google News page and search for something. The url will have a field beggining with <tt>q</tt> (for query), followed by whatever you search for. (This doesn't just have to be a set of words; you can look up Google url search parameters to see how else you can narrow your search. For the purposes of this demonstration, though, let's keep it simple.)

```r
## Get the search result page
term <- "ukraine"
url <- paste0("https://news.google.com/search?q=", term, 
              "&hl=en-US&gl=US&ceid=US%3Aen")
html_doc <- rvest::read_html(url)
```

We want to get the html node that links to the article. Fortunately for us, Google defines specific classes of elements for different functions. To see which one is used for linking to the articles, we open Google News and use Chrome's inspection tool under <tt>View > Developer > Inspect Elements</tt> tool.

![](inspect.png){#id .class width=50% height=50%}

The class of elements we want is called "VDXfz", and we want to extract the hyperlink from it, which is specified using the <tt>href</tt> attribute.

```r
## Get links on the page
links <- html_doc %>% rvest::html_nodes('.VDXfz') %>% rvest::html_attr('href')
```
If we take a look at the html code for the webpage, we can see that the link is a relative path (the file name, e.g., "index.html").
![href](node_href.png)
But we want an absolute path (the link you can enter into a web browser, e.g., "https://nytimes.com"). To get it in this format, we need to replace the root.

```r
# this will give us urls in the following format:
links[1]
```

```
## [1] "./articles/CAIiEPrAVhDmFU2aQkYQgMoCQugqFwgEKg8IACoHCAowjuuKAzCWrzww5oEY?hl=en-US&gl=US&ceid=US%3Aen"
```

```r
# we want them instead to begin with the Google News address
links <- gsub("./articles/", "https://news.google.com/articles/", links)
```

Let's also record the title of each article. To see how to get this info, let's go back to Google News and open Chromes' Devloper Tools UI (or open the raw html file) and look for the corresponding node:
![title](node_title.png)

The class of elements we want seems to be called "DY5T1d". We want to extract the text from this element.

```r
titles <- html_doc %>% rvest::html_nodes('.DY5T1d') %>% rvest::html_text()

# take the first five words
trunc <- sapply(titles, FUN=function(x) 
  paste(c(unlist(strsplit(x, split=" +"))[1:5], "..."), collapse=" "))
df <- cbind(title = titles, truncated_title = unname(trunc), link = links) 
head(df[, c("truncated_title", "link")])
```

```
##      truncated_title                                     
## [1,] "Ukraine-Russia Live News: Civilian Victims ..."    
## [2,] "Ukraine claims 410 bodies found ..."               
## [3,] "Ukraine updates: Ukrainians returning home ..."    
## [4,] "Ukraine latest updates: Ukraine says ..."          
## [5,] "Russia-Ukraine war live updates: International ..."
## [6,] "April 3, 2022 Russia-Ukraine news ..."             
##      link                                                                                                                                                                                                                                                                                                  
## [1,] "https://news.google.com/articles/CAIiEPrAVhDmFU2aQkYQgMoCQugqFwgEKg8IACoHCAowjuuKAzCWrzww5oEY?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                                                           
## [2,] "https://news.google.com/articles/CAIiEMRVBQIidvjPqf8dtOEZEoAqGQgEKhAIACoHCAow2Nb3CjDivdcCMKuvhQY?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                                                        
## [3,] "https://news.google.com/articles/CAIiECIn-DwmTdlz7v-1DvkCLBAqGQgEKhAIACoHCAowjsP7CjCSpPQCMM_b5QU?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                                                        
## [4,] "https://news.google.com/articles/CAIiEBYU5ggCGdzmLwkP9S5mMiQqFQgEKgwIACoFCAowhgIwkDgws_qTBw?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                                                             
## [5,] "https://news.google.com/articles/CAIiEHTSgVW44u_H74H1ErwE_jEqGQgEKhAIACoHCAowvIaCCzDnxf4CMM2F8gU?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                                                        
## [6,] "https://news.google.com/articles/CBMiUWh0dHBzOi8vd3d3LmNubi5jb20vZXVyb3BlL2xpdmUtbmV3cy91a3JhaW5lLXJ1c3NpYS1wdXRpbi1uZXdzLTA0LTMtMjIvaW5kZXguaHRtbNIBVWh0dHBzOi8vYW1wLmNubi5jb20vY25uL2V1cm9wZS9saXZlLW5ld3MvdWtyYWluZS1ydXNzaWEtcHV0aW4tbmV3cy0wNC0zLTIyL2luZGV4Lmh0bWw?hl=en-US&gl=US&ceid=US%3Aen"
```
Now that we have the links to all these web pages, we can just loop through and do what we did in the first section to extract all the text/images (or whatever information you want).


## APIs: e.g., Twitter
What we did in the previous section is a bit cumbersom and the results messy. For example, though our intention was only to gather the body of the article, our data also includes author names.

Sometimes, it's much easier. Some websites have application programming interfaces (APIs), which you can query for specific and well-structured information. Twitter is one such website.

This time let's use a timely but lighter subject as an example: the Oscars.

To access Twitter's API, you need to [register as a devloper](https://developer.twitter.com/). 

We'll use the <tt>rtweet</tt> package. The <tt>search_tweets()</tt> function allows you to search for tweets, and you can specify a number of parameters or filters. We can be quite specific with what types of tweets we want to query.

```r
# tweets that: mention the oscars & are from verified users & are not replies
tw <- rtweet::search_tweets(q="\"oscars\" filter:verified -filter:replies",
                            include_rts = F,  # exclude retweets
                            lang="en",  # only tweets in English 
                            n=10)  # 10 tweets
```

The information is also organized nicely:

```r
# what type of information do we have
head(colnames(tw))  
```

```
## [1] "user_id"     "status_id"   "created_at"  "screen_name" "text"       
## [6] "source"
```

```r
# example of the text in a tweet
tw$text[1]
```

```
## [1] "We Celebrate the artist of New Orleans Center of Creative Arts. Grammys, Oscars, Peabodys, Pulitzers @NOCCA Jon Batiste https://t.co/ajJIhddcWV"
```
This is already looking cleaner than our news article example, but let's still do a bit of pre-processing. We'll go more in depth during our week on text as data, but for now let's just define a basic function for removing some (typically) unmeaningful words, as well as punctuation and whitespace, and apply it to each tweet.

```r
clean_text <- function(x) {
  x %>% tm::removeWords(stopwords::stopwords("en")) %>% 
    tm::stripWhitespace() %>%
    tm::removePunctuation()
}

## Clean tweets
# before
tw[, c("screen_name", "text")]
```

```
## # A tibble: 10 × 2
##    screen_name   text                                                           
##    <chr>         <chr>                                                          
##  1 WendellPierce "We Celebrate the artist of New Orleans Center of Creative Art…
##  2 HowardCohen   "Music industry's MVP, most compassionate soul, has to be @lad…
##  3 fox7austin    "“Took me a while to get my thoughts together,” 'Fresh Prince …
##  4 extratv       "#Grammys host Trevor Noah dropped a subtle joke about the Osc…
##  5 latestly      "#GRAMMYs2022: After #Oscars, #LataMangeshkar Left Out of ‘#In…
##  6 NBCNewYork    "ICYMI: Here's how \"SNL\" handled the Will Smith Oscars slap …
##  7 Independent   "After an action-packed Oscars, the Grammys seems majorly dull…
##  8 cmolanphy     "Genuine kudos to @HarveyMasonjr for a #GRAMMYs show that was …
##  9 THR           "John Oliver Criticizes O.J. Simpson for Weighing In on Will S…
## 10 8NewsNow      "WILL SMITH FILMS ON HOLD: Films starring Will Smith reportedl…
```

```r
# after
tw_wrds <- unname(sapply(tw$text, clean_text))
head(tw_wrds)
```

```
## [1] "We Celebrate artist New Orleans Center Creative Arts Grammys Oscars Peabodys Pulitzers NOCCA Jon Batiste httpstcoajJIhddcWV"                                                                                                        
## [2] "Music industrys MVP compassionate soul ladygaga Last year assisted Tony Bennett concert She helped Liza Minnelli present Oscars I got  After losing popduo Grammys many figured amp Tonys aided winner SZA Sweet httpstcoWh4qGbrigj"
## [3] "“Took get thoughts together” Fresh Prince BelAir star Tatyana Ali wrote social media sharing thoughts happened Oscars httpstcoMbWwZ6XheU"                                                                                           
## [4] "Grammys host Trevor Noah dropped subtle joke Oscars slap monologue 😯 httpstcoq9EokKTfd3"                                                                                                                                           
## [5] "GRAMMYs2022 After Oscars LataMangeshkar Left Out ‘InMemoriam’ Segment 64thAnnualGRAMMYAwards Leaves Indian Fans Annoyed RecordingAcad Grammys Grammys2022 GrammyAwards GrammyAwards2022 httpstcoL7CRbvR2sa"                         
## [6] "ICYMI Heres SNL handled Will Smith Oscars slap httpstcoJKzIGhdGCc"
```

Again, what you do with this data is a different topic. For now, let's do something simple: see which words appear the most often.

```r
# split into words
tw_wrds <- sapply(tw_wrds, FUN=function(x) strsplit(tolower(x), split=" +"))

count <- table(unlist(tw_wrds))
sort(count[count > 1], decreasing = T)
```

```
## 
##      oscars     grammys        slap        will       after       smith 
##          10           6           4           4           3           3 
##         amp       films grammys2022        hold           i         one 
##           2           2           2           2           2           2 
##    thoughts 
##           2
```

The <tt>rtweet</tt> package has lots of other functions that you may find useful. If you want to use Twitter for your project, I encourage you to read the package's documentation. I'll just point out one other function, one which gets tweets from a specific user:

```r
# last 2 tweets from the UN
tl <- rtweet::get_timeline(user="UN", n=2)
tl$text
```

```
## [1] "Despite numerous challenges, our @UNMAS colleagues continue their vital work clearing landmines &amp; explosive remnants of war.\n\nThey are working to create a world where people don't have to be afraid of their next step.\n\nMore on Monday's #MineAwarenessDay: https://t.co/KmYriwGy50 https://t.co/61aEt1VrQJ"
## [2] "Afghanistan: The denial of education violates the human rights of women &amp; girls and can leave them more exposed to violence, poverty and exploitation.\n\nAll students must be allowed to exercise their right to an education. https://t.co/RLTlfBdZAi"
```
