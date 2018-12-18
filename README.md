README
================
Gabri, Pablo, Joey
December 14, 2018

fecScrape
=========

The fecScrape package provides functions to interface with the [OpenFEC API](https://api.open.fec.gov/developers/). OpenFEC API allows you to access funding data on candidates and committees. This package allows users to scrape individual- and aggregated-level donation data, plot these data to examine the timecourse of donation as well as geographic spread of donations, and does some basic summary statistics.

Thanks
======

During this class project, we came across another package which inspired our own code and thoughts on how to develop this package. Please check out the [tidyusafec](https://github.com/stephenholzman/tidyusafec) package, written by Stephen Holzman.

Installation
============

Installation is done locally for now. Make sure that the project is specified to fecScrape\_project and that both libraries are installed.

``` r
library(devtools)
library(roxygen2)
setwd("./fecScrape") # pathway for where the package folder is located
document() # knits? the package together for use
library(fecScrape)
```

Functions
=========

<table style="width:39%;">
<colgroup>
<col width="19%" />
<col width="19%" />
</colgroup>
<thead>
<tr class="header">
<th>Function Name</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>query_candidate_list</td>
<td>This function returns the list of all candidates that run in the 2018 Senate Election for a given state.</td>
</tr>
<tr class="even">
<td>query_choose_cand</td>
<td>This function allows the user to manually pick 2 opposing candidates (1 Republican and 1 Democrat) from the list retrieved using <em>query_candidate_list</em> for comparison.</td>
</tr>
<tr class="odd">
<td>query_contributions_all</td>
<td>This function retrieves all individual level contributions for every candidate in the list provided.</td>
</tr>
<tr class="even">
<td>query_itemized_contributions</td>
<td>This function opreates within <em>query_contributions_all</em> and it retrieves individual contributions when provided with eahc candidate's principal committees id</td>
</tr>
<tr class="odd">
<td>query_openfec</td>
<td>This function srapes the FEC websites using FEC aPIs. It operates within the <em>query_itemized_contributions</em> and the <em>query_candidate_all</em> higher level functions</td>
</tr>
<tr class="even">
<td>plot_avg_donation</td>
<td>This functions elaborates the individual contributions data from the two main candidates selected and plots the average daily donations.</td>
</tr>
<tr class="odd">
<td>plot_cum_donation</td>
<td>This functions elaborates the individual contributions data from the two main candidates selected and plots the cumulative daily donations.</td>
</tr>
<tr class="even">
<td>plot_top_cities</td>
<td>This function plot a graph bar showing individual donations' origin for the top <em>n</em> cities for each of the opposing candiates.</td>
</tr>
<tr class="odd">
<td>plot_occupations</td>
<td>This function plot a percentage stacked bar plot showing the shares of the top <em>n</em> individual contributors' occupations. All remaning occupations are automatically grouped in the &quot;others&quot; category (up to 8 different top occupations can be selected.).</td>
</tr>
</tbody>
</table>

Example: 2018 Senate race between Whitehouse & Flanders
=======================================================

Step 1: Scrape candidates running in an election of interest.
-------------------------------------------------------------

For our example, we will focus on the recent 2018 Sentate race between Sheldon Whitehouse and Robert Flanders of Rhode Island. We wanted to choose Texas, since Beto and Cruz raised tens of millions of dollars, but the scraping takes a very long time!

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

Step 2: Find individual donations for specified candidates
----------------------------------------------------------

``` r
# Find all individual donations to each candidates' primary committee
ri_indiv_data <- query_contributions_all(
  input_candlist = ri_chosen_data, 
  api_key = my_api
)
```

Step 3: Plot average donations
------------------------------

``` r
ri_avg_donation <- plot_avg_donation(ri_indiv_data)
ri_avg_donation
```

Step 4: Plot cummulative donations
----------------------------------

``` r
ri_cum_donation <- plot_cum_donation(ri_indiv_data)
ri_cum_donation
```

Step 5: Plot cities of donators
-------------------------------

``` r
ri_cities_donation <- plot_top_cities(3, ri_indiv_data)
ri_cities_donation
```

Step 6: Plot occputations of donators
-------------------------------------

``` r
ri_occup_donation <- plot_occupations(4, ri_indiv_data)
ri_occup_donation
```
