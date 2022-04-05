Web Scrapping (ECON/POLISCI 151, Week 2 Section)
================
Albert Chiu

## A Brief Primer on HTML and <tt>rvest</tt>

HyperText Markup Language (HTML) is a markup language (similar to LaTeX)
and is what most websites are written in.

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

We can represent html documents using a document object model (DOM). To
do so, we would use a data structure called a *tree*. Trees are composed
of *nodes* and have a hierarchical structure: there is one “root” node,
and all other nodes branch out from it. In html, nodes can be either
elements or something like text (some consider attributes to be a type
of node, others don’t). Consider the following example:

``` r
# use \ to escape special characters
eg_html <- "<html>
                <p style=\"color:#8C1515\">
                    text here 
                    <a href=\"\\path\\to\\link1\"> link1 </a>
                </p>
                <a href=\"\\path\\to\\link2\"> link2 </a>
            </html>"

# what this string looks like 
cat(eg_html)
```

    ## <html>
    ##                 <p style="color:#8C1515">
    ##                     text here 
    ##                     <a href="\path\to\link1"> link1 </a>
    ##                 </p>
    ##                 <a href="\path\to\link2"> link2 </a>
    ##             </html>

Notice how nodes are nested within each other, ergo the hierarchical
structure. If a node is nested within another, the former is called the
latter’s “child” and the latter is the former’s “parent.” Child nodes
are said to be “descended from” parent nodes. Nodes that are more outer
are higher up in the hierarchy. The DOM for this would look something
like this:
<img src="https://github.com/albert-chiu/econ-polisci-151-sec/blob/main/rmd_files/w2/figures/html_dom.png?raw=true">

There’s a few things to remark on. First, note that there are nodes
called “head” and “body” which are not part of the example code. These
can be omitted (as can the <tt>html</tt> tag) and will be implicitly
created whenever your browser/etc. loads the html file. The head element
will include information like which CSS style sheet to use, and we
largely won’t concern ourselves with it. The body element is where the
contents of the page are. Second, attributes are displayed using dashed
lines/arrows, since not all consider them to be nodes.

To do webscrapping in R, we will be using the <tt>rvest</tt> package (a
part of <tt>tidyverse</tt>). <tt>rvest</tt> is designed to go with
<tt>magrittr</tt> package; you don’t need to use the latter, but taking
advantage of the pipe <tt>%>%</tt> operator will make your code a lot
less verbose.

<tt>rvest</tt> lets you extract nodes corresponding to specific tags:

``` r
eg_doc <- rvest::read_html(eg_html)

# everything inside a p tag, i.e., the p element and all its descendants
eg_doc %>% rvest::html_elements("p")
```

    ## {xml_nodeset (1)}
    ## [1] <p style="color:#8C1515">\n                    text here \n               ...

``` r
# if there are more than one, it returns a "node list"
eg_doc %>% rvest::html_elements("a")
```

    ## {xml_nodeset (2)}
    ## [1] <a href="%5Cpath%5Cto%5Clink1"> link1 </a>
    ## [2] <a href="%5Cpath%5Cto%5Clink2"> link2 </a>

Given a node, we can extract all the text descended from it:

``` r
# notice that this also extracts the text from the "a" element that is descended
# from the p element
eg_doc %>% rvest::html_elements("p") %>%
  rvest::html_text()
```

    ## [1] "\n                    text here \n                     link1 \n                "

Or maybe we want all nodes with a specific tag that descend from that
node:

``` r
# note that this doesn't extract the "a" tag outside of the p tag
eg_doc %>% rvest::html_elements("p") %>%
  rvest::html_elements("a")
```

    ## {xml_nodeset (1)}
    ## [1] <a href="%5Cpath%5Cto%5Clink1"> link1 </a>

Lastly, instead of text, we can also extract attributes:

``` r
eg_doc %>% rvest::html_elements("p") %>%
  rvest::html_elements("a") %>% 
  rvest::html_attr("href")
```

    ## [1] "\\path\\to\\link1"

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
sandwiched by p tags:

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
us, Google defines a specific class for such elements. To see what it’s
called, we can open Google News and use Chrome’s inspection tool under
<tt>View \> Developer \> Inspect Elements</tt> tool and mouse over the
link.

<img src="https://github.com/albert-chiu/econ-polisci-151-sec/blob/main/rmd_files/w2/figures/inspect.png?raw=true">

The class we want is called “VDXfz” (the CSS selector for class is
<tt>.class</tt>), and we want to extract the hyperlink from it, which is
specified using the <tt>href</tt> attribute.

``` r
## Get links on the page
links <- html_doc %>% rvest::html_nodes('.VDXfz') %>%  # specify CSS selector: .class
  rvest::html_attr('href')
```

If we take a look at the html code for the webpage, we can see that the
link is a relative path (the file name, e.g., “index.html”).

<img src="https://github.com/albert-chiu/econ-polisci-151-sec/blob/main/rmd_files/w2/figures/node_href_crop.png?raw=true">

But we want an absolute path (the link you can enter into a web browser,
e.g., “<https://nytimes.com>”). To get it in this format, we need to
replace the root.

``` r
# this will give us links in the following format:
links[1]
```

    ## [1] "./articles/CAIiEHcAW8Ya6GnDh4Q_U-70fnYqFwgEKg8IACoHCAowjuuKAzCWrzww5oEY?hl=en-US&gl=US&ceid=US%3Aen"

``` r
# we want them instead to begin with the Google News address
links <- gsub("./articles/", "https://news.google.com/articles/", links)
```

Let’s also record the title of each article. To see how to get this
info, let’s go back to Google News and open Chromes’ Devloper Tools UI
(or open the raw html file) and look for the corresponding node:
<img  src="https://github.com/albert-chiu/econ-polisci-151-sec/blob/main/rmd_files/w2/figures/node_title.png?raw=true">

Titles seem to be assigned the “DY5T1d” class attribute (it’s actually a
part of two classes; we use take either). We want to extract the text
from this element.

``` r
titles <- html_doc %>% rvest::html_nodes('.DY5T1d') %>%
  rvest::html_text()

# same thing if we use the other class
# html_doc %>%  rvest::html_nodes('.RZIKme') %>% rvest::html_text()

# take the first five words
trunc <- sapply(titles, FUN=function(x) 
  paste(c(unlist(strsplit(x, split=" +"))[1:5], "..."), collapse=" "))
df <- cbind(title = titles, truncated_title = unname(trunc), link = links) 
head(df[, c(2:3)])
```

    ##      truncated_title                              
    ## [1,] "Ukraine-Russia War: Live News and ..."      
    ## [2,] "Russia invades Ukraine: Live updates ..."   
    ## [3,] "Russia-Ukraine war: What happened today ..."
    ## [4,] "Zelenskyy warns deaths in Bucha, ..."       
    ## [5,] "Russia faces global outrage over ..."       
    ## [6,] "Russia-Ukraine war news: Live updates ..."  
    ##      link                                                                                                                                                                                                                                                                                                     
    ## [1,] "https://news.google.com/articles/CAIiEHcAW8Ya6GnDh4Q_U-70fnYqFwgEKg8IACoHCAowjuuKAzCWrzww5oEY?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                                                              
    ## [2,] "https://news.google.com/articles/CBMiUmh0dHBzOi8vd3d3LmNubi5jb20vZXVyb3BlL2xpdmUtbmV3cy91a3JhaW5lLXJ1c3NpYS1wdXRpbi1uZXdzLTA0LTA1LTIyL2luZGV4Lmh0bWzSAVZodHRwczovL2FtcC5jbm4uY29tL2Nubi9ldXJvcGUvbGl2ZS1uZXdzL3VrcmFpbmUtcnVzc2lhLXB1dGluLW5ld3MtMDQtMDUtMjIvaW5kZXguaHRtbA?hl=en-US&gl=US&ceid=US%3Aen"
    ## [3,] "https://news.google.com/articles/CAIiEJ0j7PdPWTmbEC-929SrPEkqFwgEKg4IACoGCAow9vBNMK3UCDDE2Z4H?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                                                              
    ## [4,] "https://news.google.com/articles/CAIiEMnUeMKzq7x9QCeEiHoDLN8qGQgEKhAIACoHCAowvIaCCzDnxf4CMM2F8gU?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                                                           
    ## [5,] "https://news.google.com/articles/CAIiEF_eu4gEPwtoCGYOjXW0E6YqGAgEKg8IACoHCAowhO7OATDh9CgwvaadAg?hl=en-US&gl=US&ceid=US%3Aen"                                                                                                                                                                            
    ## [6,] "https://news.google.com/articles/CAIiEPeddoRSEtSMW_LJqkFVEGEqGAgEKg8IACoHCAowjtSUCjC30XQwzqe5AQ?hl=en-US&gl=US&ceid=US%3Aen"

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

    ## [1] "I wasn’t - someone has superimposed my image from JPL.  I find the shows are dull but this year was very entertaining.  I think encouraging people to fight for Oscars introduces a nice new element of boxing and wrestling that could really bring back the ratings… https://t.co/xcGJ1tNnyZ"

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
    ##  1 EricIdle        "I wasn’t - someone has superimposed my image from JPL.  I f…
    ##  2 TheGameBET      "\"There are ten Rock brothers, you bouta see all of us.\" #…
    ##  3 TheGameBET      "Zendaya attended Vanity Fair's Oscars party in a cinched-wa…
    ##  4 BETNews         "\"There are ten Rock brothers, you bouta see all of us.\" #…
    ##  5 BETNews         "Zendaya attended Vanity Fair's Oscars party in a cinched-wa…
    ##  6 fairvote        "Can't believe the FairVote Awards are already next week! Jo…
    ##  7 lifestyle_ie    "\"I drew my inspiration from the immersive power of movies,…
    ##  8 Daily_Express   "Jada Pinkett Smith ‘wishes Will didn't slap Chris Rock' as …
    ##  9 BETherTV        "Zendaya attended Vanity Fair's Oscars party in a cinched-wa…
    ## 10 4biddnKnowledge "https://t.co/cyKogpKJXm Denzel Washington Speaks Out On Wil…

``` r
# after
tw_wrds <- unname(sapply(tw$text, clean_text))
head(tw_wrds)
```

    ## [1] "I wasn’t  someone superimposed image JPL I find shows dull year entertaining I think encouraging people fight Oscars introduces nice new element boxing wrestling really bring back ratings… httpstcoxcGJ1tNnyZ"
    ## [2] "There ten Rock brothers bouta see us BETBuzz httpstcocb1H15lJ2q"                                                                                                                                                
    ## [3] "Zendaya attended Vanity Fairs Oscars party cinchedwaist power suit long pooling pants via POPSUGAR httpstcoHkgajG801n"                                                                                          
    ## [4] "There ten Rock brothers bouta see us BETBuzz httpstco2OizK3nsKO"                                                                                                                                                
    ## [5] "Zendaya attended Vanity Fairs Oscars party cinchedwaist power suit long pooling pants via POPSUGAR httpstcoFOPVjdQXxr"                                                                                          
    ## [6] "Cant believe FairVote Awards already next week Join us AndrewYang Oscars Democracy NewYorkCity httpstcoLba3r3boXS httpstco3YXXqjBoWi"

Again, what you do with this data is a different topic. For now, let’s
do something simple: see which words appear the most often.

``` r
# split into words
tw_wrds <- sapply(tw_wrds, FUN=function(x) strsplit(tolower(x), split=" +"))

count <- table(unlist(tw_wrds))
sort(count[count > 1], decreasing = T)
```

    ## 
    ##       oscars            i        power           us     attended cinchedwaist 
    ##            6            4            4            4            3            3 
    ##        fairs         long        pants        party      pooling     popsugar 
    ##            3            3            3            3            3            3 
    ##         rock         suit       vanity          via      zendaya      betbuzz 
    ##            3            3            3            3            3            2 
    ##        bouta     brothers          see         slap          ten        there 
    ##            2            2            2            2            2            2 
    ##         will 
    ##            2

The <tt>rtweet</tt> package has lots of other functions that you may
find useful. If you want to use Twitter for your project, I encourage
you to read the package’s documentation. I’ll just point out one other
function, one which gets tweets from a specific user:

``` r
# last 2 tweets from the UN
tl <- rtweet::get_timeline(user="UN", n=2)
tl$text
```

    ## [1] "#ElSalvador must ensure security and justice in compliance with #HumanRights law, while responding to the rise in gang killings, @UNHumanRights says.\n\nhttps://t.co/UKLEg5G8tX"                                                                                                                                      
    ## [2] "Ukraine:\n\n\"The war was started by choice. \n\nThere is no inevitability to it or to the suffering it is causing. \n\nThe UN is ready to do everything within its means to help bring an end to it.\"\n\n-- UN political chief @DicarloRosemary to Security Council. https://t.co/mlNQp6yk6H https://t.co/ndoPGG4JKS"

Lastly, we can do all this without the <tt>rtweet</tt> package, though
it takes considerably more effort. Take a look at the supplement if
interested; the supplement is also a nice jumping off point if you want
to make requests to other APIs, some of which may not have R packages to
do the leg work for you.
