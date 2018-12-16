#SHINY APP

#**************************************************************
# APP SETUP
#**************************************************************

# Load packages
library(shiny)
library(ggplot2)
library(dplyr)

# load(paste0("./bulkdata/data/contributoins_","CA"))
#**************************************************************
# UI
#**************************************************************

# Begin fluidPage
ui = fluidPage(

  titlePanel("FEC individual donations"),
  
  
  sidebarLayout(
    
    sidebarPanel("our inputs will go here",
                 
      selectInput(
        inputId = "state",
        label = "Choose a State",
        c("AZ","CA","CT")
      ),
      
      uiOutput(outputId = "candlist_dem"),
      uiOutput(outputId = "candlist_rep"),
      
      dateRangeInput(
        inputId = "daterange",
        label = "Date range input: yyyy-mm-dd",
        start = "2017-01-01",
        end = "2018-11-06"
      )
    ),
  
    
    mainPanel(
      plotOutput("avg_trends"),
      plotOutput("cum_trends")

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
    candidates = df %>% filter(party =="DEM")
    candidates = unique(candidates$candidate)
    radioButtons("candidates_dem", "Pick one Democratic candidate", candidates)
  })
  
  output$candlist_rep = renderUI({
    load(paste0("./bulkdata/data/contributoins_",input$state))
    candidates = df %>% filter(party =="REP")
    candidates = unique(candidates$candidate)
    radioButtons("candidates_rep", "Pick one Republican candidate", candidates)
  })
  
  data_trend = reactive({
    load(paste0("./bulkdata/data/contributoins_",input$state))
    df[df$candidate %in% c(input$candidates_dem, input$candidates_rep), ]
  })

  output$avg_trends = renderPlot({
    plot_avg_donation <- function(df) {

      # Initialize graph attributes
      graph_theme = theme_bw(base_size = 12) +
        theme(panel.grid.major = element_line(size = .1, color = "grey"), # Increase size of gridlines
              axis.line = element_line(size = .7, color = "black"), # Increase size of axis lines
              axis.text.x = element_text(angle = 90, hjust = 1), #Rotate text
              text = element_text(size = 12)) # Increase the font size
      group_colors = c("#377EB8", "#E41A1C") # blue, red

      # Get dates
      dates <- df %>% select(contribution_receipt_date) %>%  mutate(date = as.Date(contribution_receipt_date)) %>%
        summarise(min = min(date), max = max(date))
      title <- paste("From", input$daterange[1], "To", input$daterange[2])

      # Donation data cleanup: clean
      data_clean = df %>%
        mutate(amount = contribution_receipt_amount, date = as.Date(contribution_receipt_date)) %>%
        select(amount, date, party) %>%
        mutate(date = as.Date(date))

      # Donation data cleanup: average daily
      data_average_daily <- data_clean %>%
        group_by(party, date) %>%
        summarise(Mean = mean(amount), SD = sd(amount), N = n(), SE = SD / sqrt(N), na.rm = TRUE) %>%
        filter(date >= input$daterange[1] & date <= input$daterange[2] )

      plot_average_daily <- ggplot(data_average_daily,
                                   aes(x = date, y = Mean, group = party, color = party)) +
        geom_point() +
        geom_smooth(method = "loess") + # loess
        xlab(label = "Date") +
        scale_y_continuous(name = "Average Donation per Contributor") +
        ggtitle(paste("Senate Donations", title, "\nDaily")) +
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
              axis.text.x = element_text(angle = 90, hjust = 1), #Rotate text
              text = element_text(size = 12)) # Increase the font size
      group_colors = c("#377EB8", "#E41A1C") # blue, red
      
      # Get dates
      dates <- df %>% select(contribution_receipt_date) %>%  mutate(date = as.Date(contribution_receipt_date)) %>%
        summarise(min = min(date), max = max(date))
      title <- paste("From", input$daterange[1], "To", input$daterange[2])
      
      # Donation data cleanup: clean
      data_clean = df %>% 
        mutate(amount = contribution_receipt_amount, date = as.Date(contribution_receipt_date)) %>%
        select(amount, date, party) %>%
        mutate(date = as.Date(date))
      
      # Donation data cleanup: cumulative
      data_cumulative = data_clean %>%
        group_by(party) %>%
        filter(date >= input$daterange[1] & date <= input$daterange[2]) %>%
        arrange(date) %>%
        mutate(cum_donation = cumsum(amount))
      
      plot_cum <- ggplot(data_cumulative,
                         aes(x = date, y = cum_donation, group = party, color = party)) + 
        geom_line() + 
        #geom_smooth(method = "lm", size = 2) + # loess
        xlab(label = "Date") +
        scale_y_continuous(name = "Cummulative Donation per Party Candidate") +    
        ggtitle(paste("Senate Donations", title, "\nDaily")) + 
        scale_color_manual(values = group_colors) +
        graph_theme 
      
      return(plot_cum)
    }
    
    plot_cum_donation(data_trend())
  })
  
  
  
  
     
}

shinyApp(ui = ui, server = server)
