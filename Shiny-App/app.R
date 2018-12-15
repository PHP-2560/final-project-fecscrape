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
      uiOutput(outputId = "candlist_rep")
      
      
    ),
  
    
    mainPanel("the results will go here",
      plotOutput("avg_trends")

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
 
  input$cand_dem = renderText({
    output$candlist_dem
  })
  
  input$cand_rep = renderText({
    output$candlist_rep
  })  

  output$avg_trends = renderPlot({
    load(paste0("./bulkdata/data/contributoins_",input$state))
    
    data = df %>% filter(candidate == input$cand_dem | input$cand_rep)
  
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
      title <- paste("From", dates$min, "To", dates$max)
      
      # Extract party from the committee list
      df$party <- as.character(lapply(df$committee, `[[`, "party"))
      
      # Donation data cleanup: clean
      data_clean = df %>% 
        mutate(amount = contribution_receipt_amount, date = as.Date(contribution_receipt_date)) %>%
        select(amount, date, party) %>%
        mutate(date = as.Date(date))
      
      # Donation data cleanup: average daily
      data_average_daily <- data_clean %>% 
        group_by(party, date) %>%
        summarise(Mean = mean(amount), SD = sd(amount), N = n(), SE = SD / sqrt(N), na.rm = TRUE)
      
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
    
    plot_avg_donation(data)
    

  })
  
   
}

shinyApp(ui = ui, server = server)
