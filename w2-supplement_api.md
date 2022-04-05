API (ECON/POLISCI 151, Week 2 Section Supplement)
================
Albert Chiu

Useful source:
<https://github.com/twitterdev/Twitter-API-v2-sample-code>

### Check your authentification credentials work

``` r
url_test <- "https://api.twitter.com/2/tweets/search/recent?query=from:twitterdev"

# keep your bearer_token private
headers <- c(`Authorization` = sprintf('Bearer %s', bearer_token))

# you want to see status: 200
httr::GET(url_test, config=httr::add_headers(.headers=headers))
```

    ## Response [https://api.twitter.com/2/tweets/search/recent?query=from:twitterdev]
    ##   Date: 2022-04-05 03:12
    ##   Status: 200
    ##   Content-Type: application/json; charset=utf-8
    ##   Size: 358 B

### Searching for Tweets

``` r
params_recent = list(
  `query` = 'oscars',
  `max_results` = '10',
  `tweet.fields` = 'created_at,lang,conversation_id'
)

url_recent <- 'https://api.twitter.com/2/tweets/search/recent'

resp <- httr::GET(url_recent, 
                  config=httr::add_headers(.headers=headers),
                  query = params_recent)
con <- httr::content(resp)

# first tweet we pulled
con$data[[1]]
```

    ## $lang
    ## [1] "en"
    ## 
    ## $id
    ## [1] "1511179814614446081"
    ## 
    ## $conversation_id
    ## [1] "1511161956794867725"
    ## 
    ## $created_at
    ## [1] "2022-04-05T03:11:58.000Z"
    ## 
    ## $text
    ## [1] "@IGN Will Smith’s movies are “on hold”. Not cancelled. Nor will Smith be cancelled for what he did. They’re going to wait for it to blow over. then it will be business as usual. But if it had been a white guy that had smacked Chris Rock at the Oscars…"

``` r
# extract the text from each tweet
lapply(con$data, function(x) x[["text"]])
```

    ## [[1]]
    ## [1] "@IGN Will Smith’s movies are “on hold”. Not cancelled. Nor will Smith be cancelled for what he did. They’re going to wait for it to blow over. then it will be business as usual. But if it had been a white guy that had smacked Chris Rock at the Oscars…"
    ## 
    ## [[2]]
    ## [1] "RT @ArsenioHall: Y’all still talking about the Will Smith slap? How about something positive!? Ariana DeBose made history at the Oscars tha…"
    ## 
    ## [[3]]
    ## [1] "@Papa__Drago I’m still pissed that GVK got snubbed at the Oscars for best visual effects"
    ## 
    ## [[4]]
    ## [1] "RT @FilmUpdates: Rachel Zegler addresses the Will Smith and Chris Rock #Oscars incident: “I feel like it’s none of my business.”\n\n(https://…"
    ## 
    ## [[5]]
    ## [1] "RT @Musetta_May: new super sweet pic of timothée chalamet and olivia colman holding hands (\U{01f979}) at the oscars https://t.co/cwors45b27"
    ## 
    ## [[6]]
    ## [1] "RT @RealMFullam: Unlike last week's Oscars, last night's 64th annual Grammy Awards ceremony, was quite possibly the best ever. Seeing 95-ye…"
    ## 
    ## [[7]]
    ## [1] "RT @PopCrave: Amy Schumer reveals #Oscars producers didnt allow her to say “Don’t Look Up is the name of a movie? More like don’t look down…"
    ## 
    ## [[8]]
    ## [1] "people so thirsty for a target to hate, they are raining down on Amy Schumer for a joke she wanted to (but didn't) tell at the Oscars\n#ThoughtCrime"
    ## 
    ## [[9]]
    ## [1] "RT @DC3_SQUAD: Destiny’s Child #Oscars (2022) https://t.co/RHHJgjXtEk"
    ## 
    ## [[10]]
    ## [1] "RT @LookAtDustin: Mary J. Blige has Grammy awards in R&amp;B, rap, pop, and gospel.\n\nThe only artist to ever do this.\n\nAnd she is the first per…"

### Timeline

``` r
user_id <- "14159148"
url_tl <- sprintf("https://api.twitter.com/2/users/%s/tweets", user_id)

params_tl <- list(
  `max_results` = 10,
  `tweet.fields` = "created_at",
  `expansions` = "author_id"
)
resp <- httr::GET(url_tl, 
                  config=httr::add_headers(.headers=headers),
                  query = params_tl)
con <- httr::content(resp)

con$data[c(1,2)]
```

    ## [[1]]
    ## [[1]]$author_id
    ## [1] "14159148"
    ## 
    ## [[1]]$text
    ## [1] "Tuesday is the International Day of Conscience. \n\nIn the face of on-going global challenges and conflicts - let's focus on promoting tolerance &amp; solidarity and helping those in need. https://t.co/DBvsTC3RVQ https://t.co/Bj1FuNO5Dn"
    ## 
    ## [[1]]$id
    ## [1] "1511147356770603013"
    ## 
    ## [[1]]$created_at
    ## [1] "2022-04-05T01:03:00.000Z"
    ## 
    ## 
    ## [[2]]
    ## [[2]]$author_id
    ## [1] "14159148"
    ## 
    ## [[2]]$text
    ## [1] "RT @WHOUkraine: The health care system in #Ukraine is burdened from the ongoing war. \n\nAs hostilities continue, people’s access to health s…"
    ## 
    ## [[2]]$id
    ## [1] "1511118656670949382"
    ## 
    ## [[2]]$created_at
    ## [1] "2022-04-04T23:08:57.000Z"
