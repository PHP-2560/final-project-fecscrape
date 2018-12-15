README
================
Gabri, Pablo, Joey
December 14, 2018

# fecScrape

The fecScrape package provides functions to interface with the [OpenFEC
API](https://api.open.fec.gov/developers/). OpenFEC API allows you to
access funding data on candidates and committees. This package allows
users to scrape individual- and aggregated-level donation data, plot
these data to examine the timecourse of donation as well as geographic
spread of donations, and does some basic summary statistics.

# Thanks

During this class project, we came across another package which inspired
our own code and thoughts on how to develop this package. Please check
out the [tidyusafec](https://github.com/stephenholzman/tidyusafec)
package, written by Stephen Holzman.

# Installation

Installation is done locally for now. Make sure that the project is
specified to fecScrape\_project and that both libraries are installed.

``` r
library(devtools)
library(roxygen2)
setwd("./fecScrape") # pathway for where the package folder is located
document() # knits? the package together for use
library(fecScrape)
```

# Functions

| Function Name                  | Description                                                                                                                                                                                                                                                |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| query\_candidate\_list         | This function returns the list of all candidates that run in the 2018 Senate Election for a given state.                                                                                                                                                   |
| query\_choose\_cand            | This function allows the user to manually pick 2 opposing candidates (1 Republican and 1 Democrat) from the list retrieved using *query\_candidate\_list* for comparison.                                                                                  |
| query\_contributions\_all      | This function retrieves all individual level contributions for every candidate in the list provided.                                                                                                                                                       |
| query\_itemized\_contributions | This function opreates within *query\_contributions\_all* and it retrieves individual contributions when provided with eahc candidate’s principal committees id                                                                                            |
| query\_openfec                 | This function srapes the FEC websites using FEC aPIs. It operates within the *query\_itemized\_contributions* and the *query\_candidate\_all* higher level functions                                                                                       |
| plot\_avg\_donation            | This functions elaborates the individual contributions data from the two main candidates selected and plots the average daily donations.                                                                                                                   |
| plot\_cum\_donation            | This functions elaborates the individual contributions data from the two main candidates selected and plots the cumulative daily donations.                                                                                                                |
| plot\_top\_cities              | This function plot a graph bar showing individual donations’ origin for the top *n* cities for each of the opposing candiates.                                                                                                                             |
| plot\_occupations              | This function plot a percentage stacked bar plot showing the shares of the top *n* individual contributors’ occupations. All remaning occupations are automatically grouped in the “others” category (up to 8 different top occupations can be selected.). |

# Example: 2018 Senate race between Whitehouse & Flanders

## Step 1: Scrape candidates running in an election of interest.

For our example, we will focus on the recent 2018 Sentate race between
Sheldon Whitehouse and Robert Flanders of Rhode Island. We wanted to
choose Texas, since Beto and Cruz raised tens of millions of dollars,
but the scraping takes a very long time\!

``` r
# Find and select candidates
my_api <- "_______________________" # change to your api_key please!

ri_data <- query_candidate_list(
  api_key = my_api, 
  state = "RI", 
  election_year = 2018, 
  office = "S"
)
ri_data$name

# Select candidates of interest
ri_chosen_data <- choose_cand(ri_data, 3, 5) #numbers are optional, script will prompt for them, 3 specifies Flanders, #5 specifies Whitehouse
head(ri_chosen_data)
```

## Step 2: Find individual donations for specified candidates

``` r
# Find all individual donations to each candidates' primary committee
ri_indiv_data <- query_contributions_all(
  input_candlist = ri_chosen_data, 
  api_key = my_api
)
```

## Step 3: Plot average donations

``` r
ri_avg_donation <- plot_avg_donation(ri_indiv_data)
ri_avg_donation
```

## Step 4: Plot cummulative donations

``` r
ri_cum_donation <- plot_cum_donation(ri_indiv_data)
ri_cum_donation
```

## Step 5: Plot cities of donators

``` r
ri_cities_donation <- plot_top_cities(3, ri_indiv_data)
ri_cities_donation
```

## Step 6: Plot occputations of donators

``` r
ri_occup_donation <- plot_occupations(4, ri_indiv_data)
ri_occup_donation
```
