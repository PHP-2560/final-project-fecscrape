#SHINY APP

#**************************************************************
# APP SETUP
#**************************************************************

# Load packages
library(shiny)

# load basefile
# file = load("./bulkdata/data/contributions_AZ")

#load codebooks
# codebook <- read_excel("data/codebook.xlsx")
# quickcode <- read_excel("data/modal_codebook.xlsx")



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
      radioButtons(inputId = "state",
                   label = "Choose a State",
                   c("Rhode Island" = "RI",
                     "Wyoming" = "WY")
      )
    ),
    mainPanel("the results will go here",
      plotOutput("hist")
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
}

shinyApp(ui = ui, server = server)
