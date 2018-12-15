#SHINY APP

#**************************************************************
# APP SETUP
#**************************************************************

# Load packages
library(shiny)
library(ggplot2)
library(dplyr)


#**************************************************************
# UI
#**************************************************************

# Begin fluidPage
ui = fluidPage(

  titlePanel("FEC individual donations"),
  
  
  sidebarLayout(
    
    sidebarPanel("our inputs will go here",
                 
      sliderInput(inputId = "num",
                  label = "Choose a Number",
                  value = 1, min = 1, max = 100
      ),
      
      selectInput(
        inputId = "state",
        label = "Choose a State",
        # c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
        c("AZ","CA","CT")
      )
    ),
    
    
    mainPanel("the results will go here",
      plotOutput("hist"),
      tableOutput("state")
    )
  )
)

#**************************************************************
# SERVER
#**************************************************************

# Begin server
server = function(input, output) {
  
  output$hist = renderPlot({
    hist(rnorm(input$num))
  })
  
  output$state = renderTable({
    load(paste0("./bulkdata/data/contributoins_",input$state))
    filtered = df %>% filter(contribution_receipt_amount >= 25000)
    filtered
  })
}

shinyApp(ui = ui, server = server)
