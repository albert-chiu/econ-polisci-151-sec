temp <- tempfile()
download.file("http://datasets.americasbarometer.org/database/files/2004-2018%20LAPOP%20AmericasBaometer%20Merge_V1.0_W.zip", temp)
LAPOP <- haven::read_dta(unz(temp, "2004-2018 LAPOP AmericasBarometer Merge (v1.0w).dta"))
unlink(temp)

changes <- read.csv("rmd_files/w7/LARI_data.csv")

## Subset variables we need -------------------------
df <- cbind.data.frame("country"=LAPOP$pais, "prov"=LAPOP$prov,
                       "wave"=LAPOP$wave, "year"=LAPOP$year,  # survey conducted in 2-year "waves"
                       "office"=LAPOP$d5, "marriage"=LAPOP$d6,  # response variables, scale of 1 to 10, 
                                                                # lower is less approve of office holding/same sex marriage
                       "education"=LAPOP$ed, "age"=LAPOP$q2,
                       "rel_importance"=LAPOP$q5b,  # importance of religion, scale of 1 to 4, lower is less important
                       "evangelical"=ifelse(LAPOP$q3c==5, yes=1, no=0), 
                       "ideology"=LAPOP$l1,  # left-right ideology, leftmost=1, rightmost=10
                       "rural"=(LAPOP$ur-1),  # rural = 1, urban = 0
                       "poli_attendance"=LAPOP$cp13,  # political attendance
                       "household_income"=LAPOP$q10, 
                       "news"=LAPOP$gi0,
                       "male"=ifelse(LAPOP$sex==1, yes=1, no=0),
                       "weight1500"=LAPOP$weight1500)

## two codings for income; scale switches from 0-10 to 0-16 in 2012
# separate measures of income
df$household_income_old <- df$household_income
df[df$wave >= 2012, "household_income_old"] <- 0
df$household_income_new <- 0
df[df$wave == 2012, "household_income_new"] <- LAPOP[LAPOP$wave==2012, "q10g_12"]
df[df$wave == 2014, "household_income_new"] <- LAPOP[LAPOP$wave==2014, "q10g_14"]
df[df$wave == 2016, "household_income_new"] <- LAPOP[LAPOP$wave==2016, "q10g_16"]
df[df$wave == 2018, "household_income_new"] <- LAPOP[LAPOP$wave==2018, "q10g_18"]
# single measure -- rescale income after 2012 to original 1-10 scale
df[df$wave==2012, "household_income"] <- LAPOP[LAPOP$wave==2012, "q10g_12"]*(10/16)
df[df$wave==2014, "household_income"] <- LAPOP[LAPOP$wave==2014, "q10g_14"]*(10/16)
df[df$wave==2016, "household_income"] <- LAPOP[LAPOP$wave==2016, "q10g_16"]*(10/16)
df[df$wave==2018, "household_income"] <- LAPOP[LAPOP$wave==2018, "q10g_18"]*(10/16)


## Assign country names -------------------------
df$cname <- NA
df$cname[df$country==17] <- "Argentina"  # Argentina 17
df$cname[df$country==10] <- "Bolivia"  # Bolivia 10
df$cname[df$country==15] <- "Brazil"  # Brazil 15
df$cname[df$country==13] <- "Chile"  # Chile 13
df$cname[df$country==8] <- "Colombia"  # Colombia 8
df$cname[df$country==6] <- "Costa Rica"  # Costa Rica 6
df$cname[df$country==9] <- "Ecuador"  # Ecuador 9
df$cname[df$country==3] <- "El Salvador"  # El Salvador 3
df$cname[df$country==2] <- "Guatemala"  # Guatemala 2
df$cname[df$country==4] <- "Honduras"  # Honduras 4
df$cname[df$country==1] <- "Mexico"  # Mexico 1
df$cname[df$country==5] <- "Nicaragua"  # Nicaragua 5
df$cname[df$country==7] <- "Panama"  # Panama 7
df$cname[df$country==12] <- "Paraguay"  # Paraguay 12
df$cname[df$country==11] <- "Peru"  # Peru 11
df$cname[df$country==14] <- "Uruguay"  # Uruguay 14
df$cname[df$country==16] <- "Venezuela"  # Venezuela 16
# remove observations from other countries
df <- df[!is.na(df$cname), ]



## Coding "treatment," i.e. increase in rights ------------------
df$legal_marry <- 0; df$legal_marry_lag1 <- 0 # Separate measures for same-sex civil unions and marriage
df$legal_union <- 0; df$legal_union_lag1 <- 0
df$LARI <- 0; df$LARI_lead1 <- 0 # LARI: our index for rights
for (lag in 0:5) {
  df[, paste0("LARI_lag", lag)] <- 0  # aditional lags for robustness checks
}
for ( i in 1:nrow(changes) ) {
  country <- changes[i, "Country"]
  year <- changes[i, "Year"]
  
  # LARI
  df[df$cname==country & df$year>=year, "LARI"] <- 
    df[df$cname==country & df$year>=year, "LARI"] + 1
  df[df$cname==country & df$year>=year-1, "LARI_lead1"] <- 
    df[df$cname==country & df$year>=year-1, "LARI_lead1"] + 1
  for (lag in 0:5) {
    df[df$cname==country & df$year>=year+lag, paste0("LARI_lag", lag)] <- 
      df[df$cname==country & df$year>=year+lag, paste0("LARI_lag", lag)] + 1
  }
  
  # marriage and unions
  if (changes[i, "Right"]=="Same-sex marriage") {
    df[df$cname==country & df$year>=year, "legal_marry"] <- 1
    df[df$cname==country & df$year>=year+2, "legal_marry_lag1"] <- 1
  }
  if (changes[i, "Right"]=="Same-sex civil unions") {
    df[df$cname==country & df$year>=year, "legal_union"] <- 1
    df[df$cname==country & df$year>=year+2, "legal_union_lag1"] <- 1
  }
}

  
## Polarization, measured by absolute deviation from mean (ADM) -----------------
df$adm_office <- NA
df$adm_marriage <- NA
for( this_year in unique(df$year) ) {
  for( this_country in unique(df$country) ) {
    avgmarriage <- mean(df$marriage[df$year == this_year & df$country == this_country], na.rm = TRUE)  # Calculate means for country-years
    df$adm_marriage[df$year == this_year & df$country == this_country] <-
      abs(df$marriage[df$year == this_year & df$country == this_country] - avgmarriage)  # subtract cy-mean from each person
    avgoffice <- mean(df$office[df$year == this_year & df$country == this_country], na.rm = TRUE)
    df$adm_office[df$year == this_year & df$country == this_country] <- 
      abs(df$office[df$year == this_year & df$country == this_country] - avgoffice)
  }
}


## aggregated by country-year -----------------
require(tidyverse)
cyr <- df %>% group_by(country, cname, year) %>%
  summarise_all(mean, na.rm=T) %>% ungroup()

## alternative measure of polarization: proportion extreme (1, 2, 9, 10) -----------------
cyr$pe_office <- NA
cyr$pe_marriage <- NA
for( this_year in unique(df$year) ) {
  for( this_country in unique(df$country) ) {
    ind_df <- (df$year == this_year & df$country == this_country)
    tab_marriage <- table(df[ind_df, "marriage"])
    tab_office <- table(df[ind_df, "office"])
    
    ind_cyr <- (cyr$year == this_year & cyr$country == this_country)
    cyr[ind_cyr, "pe_marriage"] <- sum(tab_marriage[c("1", "2", "9", "10")])/sum(tab_marriage)
    cyr[ind_cyr, "pe_office"] <- sum(tab_office[c("1", "2", "9", "10")])/sum(tab_office)
  }
}


## save output
# remove LAPOP -- no longer needed
rm(LAPOP)
# export cleaned data
save(df, cyr, file="rmd_files/w7/cleaned_data.RData")



