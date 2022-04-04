Web Scrapping (ECON/POLISCI 151, Week 2 Section)
================
Albert Chiu

## A Brief Primer on HTML and <tt>rvest</tt>

HyperText Markup Language (HTML) is a markup language (similar to LaTeX)
and is what most websites are written in. An html document is
essentially a tree composed of nodes. Nodes can be text, links, tables,
etc., and they themselves can have “descendant” nodes (e.g., a table is
itself a node, but inside the table there might be something that makes
text italics, and then inside that will be the text itself).

For our purposes, there are a few important terms to introduce. First,
an *element* is a type of node that makes up the document, and it can be
used for many different purposes. An element is delimited at the front
and the end with a *tag*. Below is an example of an element:

    <p> text here </p>

The <tt>`<p>`</tt> at the beginning and the <tt>`</p>`</tt> at the end
are tags.

Elements can also have *attributes*, which are specified inside the
opening tag. For example, we might want our element to be a certain
color. We can do this using the <tt>style</tt> attribute:

    <p style="color:#8C1515"> text here </p>.

This will appear to the viewer as:

<p style="color:#8C1515">
text here
</p>

To do webscrapping in R, we will be using the <tt>rvest</tt> package (a
part of <tt>tidyverse</tt>). <tt>rvest</tt> is designed to go with
<tt>magrittr</tt> package; you don’t need to use the latter, but taking
advantage of the pipe <tt>%>%</tt> operator will make your code a lot
less verbose.

<tt>rvest</tt> lets you extract nodes corresponding to specific tags:

``` r
eg_html <- rvest::read_html(
"<html>
    <p style=\"color:#8C1515\">
        text here 
        <a href=\"page1.html\"> link1 </p>
    </p>
    <a href=\"page2.html\"> link2 </p>
</html>"
)

eg_html %>% rvest::html_elements("p")
```

    ## {xml_nodeset (1)}
    ## [1] <p style="color:#8C1515">\n        text here \n        <a href="page1.htm ...

We can then extract all the text inside:

``` r
eg_html %>% rvest::html_elements("p") %>%
  rvest::html_text()
```

    ## [1] "\n        text here \n         link1 "

Or maybe we want its descendants with a specific tag:

``` r
eg_html %>% rvest::html_elements("p") %>%
  rvest::html_elements("a")
```

    ## {xml_nodeset (1)}
    ## [1] <a href="page1.html"> link1 </a>

Note that this doesn’t extract the <tt>a</tt> tag outside of the
<tt>p</tt> tag.

Instead of text, we can also extract attributes:

``` r
eg_html %>% rvest::html_elements("p") %>%
  rvest::html_elements("a") %>% 
  rvest::html_attr("href")
```

    ## [1] "page1.html"

## General Websites

We will use a CNN page on the war in Ukraine as an example. First, we
need to use the <tt>read_html</tt> function to read the html document.
In the previous section, we passed it a string with html syntax. We can
also pass it a url.

``` r
# read the documentation to see what we can pass the function
# ?xml2::read_html  # read_html is actually from xml2, which rvest imports 

cnn_url <- "https://www.cnn.com/europe/live-news/ukraine-russia-putin-news-04-3-22/h_4d0118cfd6f30770be0f8f54e041f9d2"
cnn_page <- cnn_url %>% rvest::read_html()
```

There are many types of data you might want from a webpage, and each
will require a different method of extraction. In this case, we’re
looking at an article and most likely will want the contents of that
article. As a starting point, we might want to look at text that is
sandwiched by p tags,

    <p> text here </p>.

``` r
cnn_text <- cnn_page %>%
  rvest::html_elements("p") %>%  # elements delimited by the p tag
  rvest::html_text()  # text inside the tag
head(cnn_text)
```

    ## [1] "By Simone McCarthy, Steve George, Sana Noor Haq, Melissa Macaya, Mike Hayes, Maureen Chowdhury and Amir Vera, CNN"                                                                                                                                             
    ## [2] "From CNN's Jonny Hallam "                                                                                                                                                                                                                                      
    ## [3] ""                                                                                                                                                                                                                                                              
    ## [4] "The bodies of at least 20 civilian men have been found lying strewn across the street in the town of Bucha, northwest of Kyiv following the withdrawal of Russian forces from the area in shocking images released by AFP on Saturday. "                       
    ## [5] "The dead, all in civilian clothing, are found in a variety of awkward poses, some face down against the pavement, others facing upwards with mouths open.  "                                                                                                   
    ## [6] "\"Three of them are tangled up in bicycles after taking their final ride, while others, with waxy skin, have fallen next to bullet-ridden and crushed cars,\" according to AFP journalists who accessed the town after it had been cut off for nearly a month."

This gives us a vector of all the text in each of the paragraph elements
on the webpage.

(Alternatively, you can look try other tags, like “body” – just note
that using a different tag will also mean the output is formated
differently (and all the paragraphs will be smooshed together).)

Another example is images: Perhaps we are interested in seeing what
types of images news organizations with different political leanings
tend to use when covering a given subject (e.g., are more right-leaning
news organizations more likely to include pictures of
violence/destruction of property when reporting on BLM?). To do this, we
will retrieve the <tt>src</tt> attribute of the <tt>img</tt> element.

``` r
cnn_img <- cnn_page %>% 
  rvest::html_elements("img") %>%  # img elements
  rvest::html_attr("src")  # the src attribute
```

This gives us links to the images, which we can then feed to whatever
learner (or human coder) we want. Maybe we also want to store the
captions for these photos:

``` r
cnn_cap <- cnn_page %>% rvest::html_elements("figcaption") %>% rvest::html_text()
cnn_img_df <- cbind(link_to_img = cnn_img, caption = cnn_cap)
cnn_img_df[1:2, ]  # first two examples
```

    ##      link_to_img                                                                                     
    ## [1,] "https://dynaimage.cdn.cnn.com/cnn/digital-images/org/a34e1e33-dff8-478a-ac2e-7d523421b67f.jpeg"
    ## [2,] "https://dynaimage.cdn.cnn.com/cnn/digital-images/org/c793ffa3-2eba-4dc9-ac37-304305383611.jpeg"
    ##      caption                                                                                                                                                                                                                         
    ## [1,] "A man walks with bags of food given to him by the Ukrainian Army in Bucha, Ukraine on April 2. (Ronaldo Schemidt/AFP/Getty Images)"                                                                                            
    ## [2,] "David Arakhamia, left, Mykhailo Podolyak, center and Crimean Tatar leader Mustafa Dzhemilev speak with the media after their meeting with Russian negotiators in Istanbul, Turkey on March 29.  (Mehmet Emin Caliskan/Reuters)"

What you do with this information is a whole ’nother story. We will
learn a bit about how to use text as data in a future section, but
computer vision is beyond the scope of this class.

There is, however, one concern that we can address now: What if we
can’t/don’t want to collect the url of potentially thousands of
websites? In some circumstances, there will be websites that aggregate
other websites, and we can scrape urls from such aggregators. In this
case, we can use Google News, which aggregates links to news articles.

## Aggregation Websites: e.g., Google News

This section will walk you through the process of scraping Google News
for articles on a specific topic. We will use “ukraine” as the example,
but this code can be readily repurposed for search term(s). This is
because Google News uses a fixed url format that varies only in the
search term, which makes it easy for us to write flexible code. To see
what this url is, you can just go to the Google News page and search for
something. The url will have a field beggining with <tt>q</tt> (for
query), followed by whatever you search for. (This doesn’t just have to
be a set of words; you can look up Google url search parameters to see
how else you can narrow your search. For the purposes of this
demonstration, though, let’s keep it simple.)

``` r
## Get the search result page
term <- "ukraine"
url <- paste0("https://news.google.com/search?q=", term, 
              "&hl=en-US&gl=US&ceid=US%3Aen")
html_doc <- rvest::read_html(url)
```

We want to get the html node that links to the article. Fortunately for
us, Google defines specific classes of elements for different functions.
To see which one is used for linking to the articles, we open Google
News and use Chrome’s inspection tool under <tt>View \> Developer \>
Inspect Elements</tt> tool.

<img src="https://github.com/albert-chiu/econ-polisci-151-sec/blob/main/rmd_files/w2/inspect.png?raw=true">

The class of elements we want is called “VDXfz”, and we want to extract
the hyperlink from it, which is specified using the <tt>href</tt>
attribute.

``` r
## Get links on the page
links <- html_doc %>% rvest::html_nodes('.VDXfz') %>% rvest::html_attr('href')
```

If we take a look at the html code for the webpage, we can see that the
link is a relative path (the file name, e.g., “index.html”).

<img src="https://raw.githubusercontent.com/albert-chiu/econ-polisci-151-sec/main/rmd_files/w2/node_href.png">

But we want an absolute path (the link you can enter into a web browser,
e.g., “<https://nytimes.com>”). To get it in this format, we need to
replace the root.

``` r
# this will give us urls in the following format:
links[1]
```

    ## [1] "./articles/CAIiEPrAVhDmFU2aQkYQgMoCQugqFwgEKg8IACoHCAowjuuKAzCWrzww5oEY?hl=en-US&gl=US&ceid=US%3Aen"

``` r
# we want them instead to begin with the Google News address
links <- gsub("./articles/", "https://news.google.com/articles/", links)
```

Let’s also record the title of each article. To see how to get this
info, let’s go back to Google News and open Chromes’ Devloper Tools UI
(or open the raw html file) and look for the corresponding node:
<img  src="https://github.com/albert-chiu/econ-polisci-151-sec/blob/main/rmd_files/w2/node_title.png?raw=true">

The class of elements we want seems to be called “DY5T1d”. We want to
extract the text from this element.

``` r
titles <- html_doc %>% rvest::html_nodes('.DY5T1d') %>% rvest::html_text()

# take the first five words
trunc <- sapply(titles, FUN=function(x) 
  paste(c(unlist(strsplit(x, split=" +"))[1:5], "..."), collapse=" "))
df <- cbind(title = titles, truncated_title = unname(trunc), link = links) 
head(df[, c("truncated_title", "link")])
```

    ##      truncated_title                                     
    ## [1,] "What Happened on Day 39 ..."                       
    ## [2,] "The horrors of Putin's invasion ..."               
    ## [3,] "Ukraine claims 410 bodies found ..."               
    ## [4,] "Russia-Ukraine war live updates: International ..."
    ## [5,] "Ukraine updates: Ukrainians returning home ..."    
    ## [6,] "Russia-Ukraine war: What happened today ..."       
    ##      link                                                                                                                                                                                                                                                          
    ## [1,] "https://news.google.com/articles/CAIiEPrAVhDmFU2aQkYQgMoCQugqFwgEKg8IACoHCAowjuuKAzCWrzww5oEY?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                   
    ## [2,] "https://news.google.com/articles/CAIiEIqJInbL-tJ9NDOrCDptUjIqGQgEKhAIACoHCAowocv1CjCSptoCMPrTpgU?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                
    ## [3,] "https://news.google.com/articles/CAIiEMRVBQIidvjPqf8dtOEZEoAqGQgEKhAIACoHCAow2Nb3CjDivdcCMKuvhQY?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                
    ## [4,] "https://news.google.com/articles/CAIiEHTSgVW44u_H74H1ErwE_jEqGQgEKhAIACoHCAowvIaCCzDnxf4CMM2F8gU?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                
    ## [5,] "https://news.google.com/articles/CAIiECIn-DwmTdlz7v-1DvkCLBAqGQgEKhAIACoHCAowjsP7CjCSpPQCMM_b5QU?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                
    ## [6,] "https://news.google.com/articles/CAIiEPDe97059SHmXfeVPb7W3JkqFwgEKg4IACoGCAow9vBNMK3UCDCFpJYH?uo=CAUiWGh0dHBzOi8vd3d3Lm5wci5vcmcvMjAyMi8wNC8wMy8xMDkwNTIxNzIxL3J1c3NpYS11a3JhaW5lLXdhci13aGF0LWhhcHBlbmVkLXRvZGF5LWFwcmlsLTPSAQA&hl=en-US&gl=US&ceid=US%3Aen"

Now that we have the links to all these web pages, we can just loop
through and do what we did in the first section to extract all the
text/images (or whatever information you want).

## APIs: e.g., Twitter

What we did in the previous section is a bit cumbersom and the results
messy. For example, though our intention was only to gather the body of
the article, our data also includes author names.

Sometimes, it’s much easier. Some websites have application programming
interfaces (APIs), which you can query for specific and well-structured
information. Twitter is one such website.

This time let’s use a timely but lighter subject as an example: the
Oscars.

To access Twitter’s API, you need to [register as a
devloper](https://developer.twitter.com/).

We’ll use the <tt>rtweet</tt> package. The <tt>search_tweets()</tt>
function allows you to search for tweets, and you can specify a number
of parameters or filters. We can be quite specific with what types of
tweets we want to query.

``` r
# tweets that: mention the oscars & are from verified users & are not replies
tw <- rtweet::search_tweets(q="\"oscars\" filter:verified -filter:replies",
                            include_rts = F,  # exclude retweets
                            lang="en",  # only tweets in English 
                            n=10)  # 10 tweets
```

The information is also organized nicely:

``` r
# what type of information do we have
head(colnames(tw))  
```

    ## [1] "user_id"     "status_id"   "created_at"  "screen_name" "text"       
    ## [6] "source"

``` r
# example of the text in a tweet
tw$text[1]
```

    ## [1] "Netflix and Sony have reportedly put movies Will Smith was set to appear in on hold after the actor slapped comedian Chris Rock during the Oscars. \nhttps://t.co/F8OyCqgu0j"

This is already looking cleaner than our news article example, but let’s
still do a bit of pre-processing. We’ll go more in depth during our week
on text as data, but for now let’s just define a basic function for
removing some (typically) unmeaningful words, as well as punctuation and
whitespace, and apply it to each tweet.

``` r
clean_text <- function(x) {
  x %>% tm::removeWords(stopwords::stopwords("en")) %>% 
    tm::stripWhitespace() %>%
    tm::removePunctuation()
}

## Clean tweets
# before
tw[, c("screen_name", "text")]
```

    ## # A tibble: 10 × 2
    ##    screen_name     text                                                         
    ##    <chr>           <chr>                                                        
    ##  1 wbrewyou        "Netflix and Sony have reportedly put movies Will Smith was …
    ##  2 theheraldsun    "\"You gonna hit my mother******** brother ?\" \nChris Rock'…
    ##  3 DailyMailCeleb  "Trevor Noah opens Grammys by joking about Will Smith's Osca…
    ##  4 boomlive_in     "The apologies for the joke do not appear on Chris Rock's so…
    ##  5 boomlive_in     "Edit histories of the posts show they were changed to refer…
    ##  6 PageSix         "Will Smith resigned but is he 'banned' from Oscars like thi…
    ##  7 dailystar       "#Grammys 2022 host Trevor Noah makes subtle dig at Will Smi…
    ##  8 fox32news       "“Took me a while to get my thoughts together,” “Fresh Princ…
    ##  9 mrdiscopop      "The Oscars give Oscars to people who make films about films…
    ## 10 moneycontrolcom "Music legend #LataMangeshkar was missing from the “In Memor…

``` r
# after
tw_wrds <- unname(sapply(tw$text, clean_text))
head(tw_wrds)
```

    ## [1] "Netflix Sony reportedly put movies Will Smith set appear hold actor slapped comedian Chris Rock Oscars httpstcoF8OyCqgu0j"                 
    ## [2] "You gonna hit mother brother  Chris Rocks family unleashed Will Smith infamous Oscars slap httpstcoLpQ8Be3qpk"                             
    ## [3] "Trevor Noah opens Grammys joking Will Smiths Oscars slap Questlove takes dig httpstco2bIUDN2H1l"                                           
    ## [4] "The apologies joke appear Chris Rocks social media accounts publicist said statements fake FakeNews ChrisRock WillSmith httpstcoRIqjDemERX"
    ## [5] "Edit histories posts show changed reference Will Smith slapping Chris Rock took place Oscars ChrisRock WillSmith httpstcoYxrdj2pAfO"       
    ## [6] "Will Smith resigned banned Oscars like exclusive club httpstcoISIvtmV6HE httpstcoyiQBK3JDla"

Again, what you do with this data is a different topic. For now, let’s
do something simple: see which words appear the most often.

``` r
# split into words
tw_wrds <- sapply(tw_wrds, FUN=function(x) strsplit(tolower(x), split=" +"))

count <- table(unlist(tw_wrds))
sort(count[count > 1], decreasing = T)
```

    ## 
    ##    oscars      will   grammys     chris     smith       the     music      slap 
    ##        10         6         5         4         4         4         3         3 
    ##    appear chrisrock       dig     films      give      make     media      noah 
    ##         2         2         2         2         2         2         2         2 
    ##    people      rock     rocks    smiths    social  thoughts    trevor willsmith 
    ##         2         2         2         2         2         2         2         2

The <tt>rtweet</tt> package has lots of other functions that you may
find useful. If you want to use Twitter for your project, I encourage
you to read the package’s documentation. I’ll just point out one other
function, one which gets tweets from a specific user:

``` r
# last 2 tweets from the UN
tl <- rtweet::get_timeline(user="UN", n=2)
tl$text
```

    ## [1] "Despite numerous challenges, our @UNMAS colleagues continue their vital work clearing landmines &amp; explosive remnants of war.\n\nThey are working to create a world where people don't have to be afraid of their next step.\n\nMore on Monday's #MineAwarenessDay: https://t.co/KmYriwGy50 https://t.co/61aEt1VrQJ"
    ## [2] "Afghanistan: The denial of education violates the human rights of women &amp; girls and can leave them more exposed to violence, poverty and exploitation.\n\nAll students must be allowed to exercise their right to an education. https://t.co/RLTlfBdZAi"
