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

To Do: Create a naming schematic for the functions such that all
functions which interface with the OpenFEC API use the “query\_” prefix
and all functions which plot data use the “plot\_”
prefix.

| Table Header     | Second Header                                                                                            |
| ---------------- | -------------------------------------------------------------------------------------------------------- |
| query\_candidate | This function returns the list of all candidates that run in the 2018 Senate Election for a given state. |
| Cell 3           | Cell 4                                                                                                   |

\[x\] choose\_cand: Selects candidates from a list \[x\]
query\_contributions\_all: Find all individual donations to candidate  
\[x\] query\_itemized\_contributions: Finds individual contributions
associated with a list of candidates \[x\] plot\_avg\_donation: Plot the
average donation for candidates over the time window \[x\]
plot\_cum\_donation: Plot the cummulative donation for candidates over
the time window \[x\] query\_candidate\_list: Search for political
candidates in FEC  
\[x\] query\_openfec: Make a request to the OpenFEC API \[x\]
plot\_top\_cities: Plot zipcode level data for cities with the most
donations \[x\] plot\_occupations: Plot occputation level data for
donations

# Example: 2018 Senate race between Whitehouse & Flanders

## Step 1: Scrape candidates running in an election of interest.

For our example, we will focus on the recent 2018 Sentate race in West
Virginia between Sheldon Whitehouse and Robert Flanders of Rhode Island.
We wanted to choose Texas, since Beto and Cruz raised tens of millions
of dollars, but the scraping takes a very long time\!

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
