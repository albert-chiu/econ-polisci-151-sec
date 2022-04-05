API (ECON/POLISCI 151, Week 2 Section Supplement)
================
Albert Chiu

Useful source:
<https://github.com/twitterdev/Twitter-API-v2-sample-code>

### Check your authentification credentials work

``` r
url_test <- "https://api.twitter.com/2/tweets/search/recent?query=from:twitterdev"

#bearer_token <- "<your_bearer_token>"
headers <- c(`Authorization` = sprintf('Bearer %s', bearer_token))

# you want to see status: 200
httr::GET(url_test, config=httr::add_headers(.headers=headers))
```

    ## Response [https://api.twitter.com/2/tweets/search/recent?query=from:twitterdev]
    ##   Date: 2022-04-05 03:14
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

    ## $conversation_id
    ## [1] "1511180460621283332"
    ## 
    ## $lang
    ## [1] "es"
    ## 
    ## $id
    ## [1] "1511180460621283332"
    ## 
    ## $text
    ## [1] "RT @CarrillonavasG: #MananasBLU María Cecilia Botero, Mauro Castillo y Carolina Gaitán en #Oscars,  por el #Encanto, un talento sin igual q…"
    ## 
    ## $created_at
    ## [1] "2022-04-05T03:14:32.000Z"

``` r
# extract the text from each tweet
lapply(con$data, function(x) x[["text"]])
```

    ## [[1]]
    ## [1] "RT @CarrillonavasG: #MananasBLU María Cecilia Botero, Mauro Castillo y Carolina Gaitán en #Oscars,  por el #Encanto, un talento sin igual q…"
    ## 
    ## [[2]]
    ## [1] "RT @MChaseRadio: Between Lady Gaga’s compassion for Liza Minelli at the Oscars, her Grammy tribute to Tony Bennett and then helping SZA wit…"
    ## 
    ## [[3]]
    ## [1] "RT @IkematuIkegorou: アカデミー賞の例のスーツ🦎\n大遅刻だけど受賞おめでとう✨✨\nずっと好きやで！！\n#Encanto #camilomadrigal #Oscars #encantofanart https://t.co/l5MXqDzUq5"
    ## 
    ## [[4]]
    ## [1] "Will Smith Is Gone, but the Academy Hasn’t Even Begun to Deal with the Sting of His Slap https://t.co/HlYqeGKoMb via @indiewire"
    ## 
    ## [[5]]
    ## [1] "RT @TheLeoTerrell: I nominate @greggutfeld to host the Oscars next year! I predict a ratings bonanza!"
    ## 
    ## [[6]]
    ## [1] "RT @cchukudebelu: The Oscars are irrelevant to Bollywood.\n\nNigerians should understand that the United States (and even the West) is a smal…"
    ## 
    ## [[7]]
    ## [1] "RT @korimakorima: 英国紙の辛辣で親切なアカデミー賞観覧記。「今回、アカデミー賞は政治コンテンツとしてゼレンスキーのビデオ出演を考案していた。本物の戦争をやっている政治家がオスカーに招待してもらいたがっているという発想はボトックスかナルシズムで爛れた脳からしか出…"
    ## 
    ## [[8]]
    ## [1] "RT @YNB: Did you see @ladygaga help @sza (who’s on crutches) with her train just now? After that and the kindness she showed #LizaMinelli a…"
    ## 
    ## [[9]]
    ## [1] "RT @ArsenioHall: Y’all still talking about the Will Smith slap? How about something positive!? Ariana DeBose made history at the Oscars tha…"
    ## 
    ## [[10]]
    ## [1] "RT @MChaseRadio: Between Lady Gaga’s compassion for Liza Minelli at the Oscars, her Grammy tribute to Tony Bennett and then helping SZA wit…"

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
    ## [[1]]$created_at
    ## [1] "2022-04-05T01:03:00.000Z"
    ## 
    ## [[1]]$text
    ## [1] "Tuesday is the International Day of Conscience. \n\nIn the face of on-going global challenges and conflicts - let's focus on promoting tolerance &amp; solidarity and helping those in need. https://t.co/DBvsTC3RVQ https://t.co/Bj1FuNO5Dn"
    ## 
    ## [[1]]$author_id
    ## [1] "14159148"
    ## 
    ## [[1]]$id
    ## [1] "1511147356770603013"
    ## 
    ## 
    ## [[2]]
    ## [[2]]$created_at
    ## [1] "2022-04-04T23:08:57.000Z"
    ## 
    ## [[2]]$text
    ## [1] "RT @WHOUkraine: The health care system in #Ukraine is burdened from the ongoing war. \n\nAs hostilities continue, people’s access to health s…"
    ## 
    ## [[2]]$author_id
    ## [1] "14159148"
    ## 
    ## [[2]]$id
    ## [1] "1511118656670949382"
