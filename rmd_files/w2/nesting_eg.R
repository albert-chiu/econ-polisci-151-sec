require(dplyr)

# div tag nested within div tag
eg_html <- "<div> outer text \n \t <div> inner text </div> \n </div>"
cat(eg_html)

# will extract both the inner and the outer element
divs <- eg_html %>% rvest::read_html() %>%
  rvest::html_elements("div") 
divs

divs %>% rvest::html_text()

# if we want just the inner tag:
divs[1] %>%
  rvest::html_elements("div")