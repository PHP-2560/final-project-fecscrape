# fecScrape Shiny App

#**************************************************************
# APP SETUP
#**************************************************************

# Load packages
library(shiny)
library(ggplot2)
library(dplyr)
library(scales)
library(shinythemes)
library(DT) # for datatables 

#**************************************************************
# UI
#**************************************************************

# Begin fluidPage
ui = fluidPage(
  theme = shinytheme("cerulean"),
  titlePanel("FEC individual donations"),
  
  sidebarLayout(
    sidebarPanel("our inputs will go here",
                 selectInput(
                   inputId = "state",
                   label = "Choose a State",
                   c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
                 ),
                 
                 uiOutput(outputId = "candlist_dem"),
                 uiOutput(outputId = "candlist_rep"),
                 
                 # Add x-axis range slider
                 sliderInput("X_axis_range", 
                             "Choose date range:", 
                             min = as.Date("2017-01-01", "%Y-%m-%d"), 
                             max = as.Date("2018-12-01", "%Y-%m-%d"), 
                             value = c(as.Date("2018-01-01", "%Y-%m-%d"), 
                                       as.Date("2018-12-01", "%Y-%m-%d")), 
                             dragRange = TRUE)
                 
                 #dateRangeInput(
                 #   inputId = "daterange",
                #   label = "Date range input: yyyy-mm-dd",
                #   start = "2017-01-01",
                #   end = "2018-11-06"
                # )
    ),
    
    
    mainPanel(
      # Add descriptive table for number donations and total per party
      dataTableOutput('donations_table'),
      
      plotOutput("avg_trends"),
      # Add y-axis range slider
      sliderInput("Y_axis_range", 
                  "Choose Average Donation (y-axis) range:", 
                  min = 0, max = 10000, 
                  value = c(0, 5000), step = 500,
                  pre = "$", sep = ",",
                  dragRange = TRUE),
      
      
      plotOutput("cum_trends"), 
      # Add y-axis range slider
      sliderInput("Y_axis_range_cum", 
                  "Choose Cumulative Donation (y-axis) range:", 
                  min = 0, max = 10000000, 
                  value = c(0, 5000000), step = 1000,
                  pre = "$", sep = ",",
                  dragRange = TRUE),
      
      plotOutput("top_cities"),
      sliderInput(inputId = "num_cities", 
                  label = "Select the number of top cities to display",
                  min = 1, 
                  max = 10, 
                  value = 2), 
      
      plotOutput("top_occ"),
      sliderInput(inputId = "num_occ", 
                  label = "Select the number of top occupations to display",
                  min = 1, 
                  max = 8, 
                  value = 2)
      
    )
  )
)

#**************************************************************
# SERVER
#**************************************************************

# Begin server
server = function(input, output) {
  
  output$candlist_dem = renderUI({
    load(paste0("./bulkdata/data/contributoins_",input$state))
    candidates = df %>% filter(party =="DEM") %>% group_by(candidate) %>% 
      summarise(Total = sum(contribution_receipt_amount)) %>%
      arrange(desc(Total)) # put the most $$$ candidates first
    candidates = unique(candidates$candidate)
    #radioButtons("candidates_dem", "Pick one Democratic candidate", candidates)
    # Added functionality: multiple candidates can be specified
    checkboxGroupInput("candidates_dem", label = "Select Democratic candidates", 
                       choices = candidates, 
                       selected = candidates[1])
  })
  
  output$candlist_rep = renderUI({
    load(paste0("./bulkdata/data/contributoins_",input$state))
    candidates = df %>% filter(party =="REP") %>% group_by(candidate) %>% 
      summarise(Total = sum(contribution_receipt_amount)) %>%
      arrange(desc(Total))
    candidates = unique(candidates$candidate)
    #radioButtons("candidates_rep", "Pick one Republican candidate", candidates)
    checkboxGroupInput("candidates_rep", label = "Select Republican candidates", 
                       choices = candidates, 
                       selected = candidates[1])
  })
  
  data_trend = reactive({
    load(paste0("./bulkdata/data/contributoins_",input$state))
    df[df$candidate %in% c(input$candidates_dem, input$candidates_rep), ]
  })
  
  output$donations_table <- renderDataTable({
    donations_data_table <- function(df) {
      
      # Donation data cleanup: clean
      donation_table <- df %>%
        group_by(candidate, party) %>%
        summarise(num_donations = n(), 
                  total_donations_amount = sum(contribution_receipt_amount), 
                  avg_donation = round((total_donations_amount / num_donations), 2)) %>%
        arrange(num_donations = desc(num_donations)) %>%
        mutate_at(vars(total_donations_amount:avg_donation), dollar) 
      return(donation_table)
    }
    table_print <- donations_data_table(data_trend())
    datatable(table_print, options = list(dom = 't'),
              caption = 'Donation Descriptives for Specified Date Range')
  })
  
  output$avg_trends = renderPlot({
    plot_avg_donation <- function(df) {
      
      # Initialize graph attributes
      graph_theme = theme_bw(base_size = 12) +
        theme(panel.grid.major = element_line(size = .1, color = "grey"), # Increase size of gridlines
              axis.line = element_line(size = .7, color = "black"), # Increase size of axis lines
              text = element_text(size = 12)) # Increase the font size
      
      # Get dates
      dates <- df %>% select(contribution_receipt_date) %>%  mutate(date = as.Date(contribution_receipt_date)) %>%
        summarise(min = min(date), max = max(date))
      title <- paste("From", input$X_axis_range[1], "To", input$X_axis_range[2])
      
      # Donation data cleanup: clean
      data_clean = df %>%
        mutate(amount = contribution_receipt_amount, date = as.Date(contribution_receipt_date)) %>%
        select(amount, date, candidate, party) %>%
        mutate(date = as.Date(date))

      # Donation data cleanup: average daily
      data_average_daily <- data_clean %>%
        group_by(candidate, date, party) %>%
        summarise(Mean = mean(amount), SD = sd(amount), N = n(), SE = SD / sqrt(N), na.rm = TRUE) %>%
        filter(date >= input$X_axis_range[1] & date <= input$X_axis_range[2] ) # changed input
      
      # Specify colors depending on number of candidates allowed
      group_colors <- data_clean %>% 
        group_by(candidate, party) %>%
        distinct(candidate) %>% # just need one row per candidate
        mutate(color = ifelse(party == "DEM", "#377EB8", "#E41A1C")) %>% # blue for all DEM, red for REP
        .$color # return vector of just color

      # Y-axis range
      Y_axis_range <- c(input$Y_axis_range[1], input$Y_axis_range[2])
      
      plot_average_daily <- ggplot(data_average_daily,
                                   aes(x = date, y = Mean, linetype = candidate, color = candidate)) +
        # geom_point() +
        geom_smooth(method = "loess") + # loess
        xlab(label = "Date") + 
        scale_x_date(labels = date_format("%b-%Y")) + # month-year
        ylab(label = "Average Donation per Contributor") + 
        coord_cartesian(ylim = Y_axis_range) + # prevents errors if geom_smooth lower than 0
        scale_y_continuous(labels = dollar) +
        ggtitle(paste("Senate Donations", title, "\nDaily Donations Data")) +
        scale_color_manual(values = group_colors) +
        graph_theme
      
      return(plot_average_daily)
    }
    
    plot_avg_donation(data_trend())
  })
  
  
  output$cum_trends = renderPlot({
    plot_cum_donation <- function(df) {
      
      # Initialize graph attributes 
      graph_theme = theme_bw(base_size = 12) +
        theme(panel.grid.major = element_line(size = .1, color = "grey"), # Increase size of gridlines 
              axis.line = element_line(size = .7, color = "black"), # Increase size of axis lines 
              text = element_text(size = 12)) # Increase the font size
      
      # Get dates
      dates <- df %>% select(contribution_receipt_date) %>%  mutate(date = as.Date(contribution_receipt_date)) %>%
        summarise(min = min(date), max = max(date))
      title <- paste("From", input$X_axis_range[1], "To", input$X_axis_range[2])
      
      # Donation data cleanup: clean
      data_clean = df %>% 
        mutate(amount = contribution_receipt_amount, date = as.Date(contribution_receipt_date)) %>%
        select(amount, date, party, candidate) %>%
        mutate(date = as.Date(date))
      
      # Donation data cleanup: cumulative
      data_cumulative = data_clean %>%
        group_by(party, candidate) %>%
        filter(date >= input$X_axis_range[1] & date <= input$X_axis_range[2]) %>% # changed
        arrange(date) %>%
        mutate(cum_donation = cumsum(amount))
      
      # Specify colors depending on number of candidates allowed
      group_colors <- data_clean %>% 
        group_by(candidate, party) %>%
        distinct(candidate) %>% # just need one row per candidate
        mutate(color = ifelse(party == "DEM", "#377EB8", "#E41A1C")) %>% # blue for all DEM, red for REP
        .$color # return vector of just color
      
      # Y-axis range
      Y_axis_range_cum <- c(input$Y_axis_range_cum[1], input$Y_axis_range_cum[2])
      
      plot_cum <- ggplot(data_cumulative,
                         aes(x = date, y = cum_donation, linetype = candidate, color = candidate)) + 
        geom_line(size = 1) + 
        #geom_smooth(method = "lm", size = 1.5, linetype = "dashed") +
        xlab(label = "Date") +
        scale_x_date(labels = date_format("%b-%Y")) + # month-year
        ylab(label = "Cumulative Donation per Party Candidate") + 
        coord_cartesian(ylim = Y_axis_range_cum) +
        scale_y_continuous(labels = dollar) +
        ggtitle(paste("Senate Donations", title, "\nDaily Donations Data")) + 
        scale_color_manual(values = group_colors) +
        graph_theme 
      
      return(plot_cum)
    }
    
    plot_cum_donation(data_trend())
  })
  
  output$top_cities <- renderPlot({
    plot_top_cities <- function(n, df) {
      #aggregate by city
      citydf <- df %>%
        mutate(city_state = paste0(contributor_city, ", ", contributor_state)) %>%
        group_by(candidate, city_state) %>%
        summarize(party = first(party) , count = n(), total = sum(contribution_receipt_amount, na.rm = T), average = mean(contribution_receipt_amount, na.rm = T), sd = sd(contribution_receipt_amount, na.rm = T), min = min(contribution_receipt_amount, na.rm = T), max = max(contribution_receipt_amount, na.rm = T)) %>%
        arrange(desc(total)) %>%
        top_n(n, total)
      
      citydf
      
      ## GRAPH
      # set theme
      graph_theme = theme_bw(base_size = 12) +
        theme(panel.grid.major = element_line(size = .1, color = "grey"), # Increase size of gridlines
              axis.line = element_line(size = .7, color = "black"), # Increase size of axis lines
              text = element_text(size = 14)) # Increase the font size
      
      if (citydf$party[1]=="DEM") { #this if statement assign the right color to each candidate: red for Republicans and Blue for Democrats
        group_colors <- c("#377EB8", "#E41A1C") # set colors
      } else {
        group_colors <- c("#E41A1C", "#377EB8") # set colors
      }
      
      #prepare labels
      brk<-citydf$total %>%
        range() %>%
        max()
      brk<-c(brk/2,brk)
      brk<-  round(brk/10000,0)*10000
      brk<-c(-brk,0,brk)
      brk<-sort(brk)
      brk
      lab<-abs(brk)
      
      #plot
      plot<- citydf %>%
        mutate(total = ifelse(party=="REP", -total, total )) %>%
        arrange(desc(total), party) %>%
        ggplot(aes(x = reorder(city_state, -total), y = total, fill = candidate, group = candidate)) +
        geom_bar(stat = "identity") +
        coord_flip() +
        xlab("Top Donations Cities") +
        scale_y_continuous(breaks = brk, labels=lab, name = "Total Donations")  +
        scale_fill_manual(values = group_colors) +
        graph_theme
      
      
      output<-list(citydf, plot)
      
      return(output)
    }
    
    plot_top_cities(input$num_cities,data_trend())
  })
  
  output$top_occ <- renderPlot({
    plot_occupations <- function(n, df) {
      
      if (n >= 8 ) n = 8
      
      #compute total donations by party
      totdon<-df %>%
        group_by(candidate) %>%
        summarize(count1 = n(), tot = sum(contribution_receipt_amount))
      #totdon
      
      #compute total donation for top 5 occupations for each party
      tottop<-df %>%
        mutate(city_state = paste0(contributor_city, ", ", contributor_state)) %>%
        group_by(candidate, contributor_occupation) %>%
        summarize(count = n(), total_donations = sum(contribution_receipt_amount)) %>%
        arrange(desc(total_donations)) %>%
        top_n(n, total_donations) %>%
        group_by(candidate) %>%
        summarize(count2 = sum(count), tottop = sum(total_donations))
      #tottop
      
      # generate residual donations category (not top 5 occupation) to create percentage stacked bar
      others<-totdon %>%
        left_join(tottop) %>%
        mutate(count = count1 - count2, total = tot - tottop) %>%
        mutate(contributor_occupation = "OTHERS") %>%
        select("candidate", "contributor_occupation", "count", "total")
      #others
      
      #prepare summary stats
      topocc_data<-df %>%
        group_by(candidate, contributor_occupation) %>%
        summarize(party = first(party) , count = n(), total = sum(contribution_receipt_amount, na.rm = T), average = mean(contribution_receipt_amount, na.rm = T), sd = sd(contribution_receipt_amount, na.rm = T), min = min(contribution_receipt_amount, na.rm = T), max = max(contribution_receipt_amount, na.rm = T)) %>%
        arrange(desc(total)) %>%
        top_n(n, total) %>%
        arrange(candidate, desc(total))
      topocc_data$contributor_occupation[is.na(topocc_data$contributor_occupation)]<-"NOT AVAILABLE"
      
      topocc_data
      
      ## GRAPH
      #graph theme settings
      graph_theme = theme_bw(base_size = 12) +
        theme(panel.grid.major = element_line(size = .1, color = "grey"), # Increase size of gridlines
              axis.line = element_line(size = .7, color = "black"), # Increase size of axis lines
              text = element_text(size = 12), legend.text=element_text(size=rel(0.7))) # Increase the font size
      
      
      blues<-RColorBrewer::brewer.pal(n+1, "Blues")
      reds<-RColorBrewer::brewer.pal(n+1, "Reds")
      
      if (topocc_data$party[1]=="DEM") {
        cols<-c(blues, reds)
      } else {
        cols<-c(reds, blues)
      }
      
      #add others category to data
      topocc_data<-topocc_data %>%
        bind_rows(others)
      
      topocc_data$contributor_occupation<-factor(topocc_data$contributor_occupation, levels = unique(topocc_data$contributor_occupation)[order(topocc_data$total, decreasing = F)])
      
      #prepare data for barplot
      plot_final <- topocc_data %>%
        arrange(candidate, desc(total)) %>%
        ggplot(aes(x = candidate, y = total, fill = interaction(contributor_occupation, candidate))) +
        geom_bar(stat= "identity", position = "fill") +
        scale_y_continuous(labels = percent_format()) +
        # scale_fill_hue(h = c(45, 365)) +
        scale_fill_manual(values = cols, name = "Top Occupations")+
        ylab("Donation Shares") +
        labs(caption = "The OTHERS category groups all the residual occupations not in the top-n positions") +
        graph_theme
      
      return(plot_final)
    }
    plot_occupations(input$num_occ,data_trend())
  })
  
  
}

shinyApp(ui = ui, server = server)
