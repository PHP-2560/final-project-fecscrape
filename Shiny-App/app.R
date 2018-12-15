#SHINY APP

#**************************************************************
# APP SETUP
#**************************************************************

# Load packages
library(shiny)

# load basefile
# basefile <- readRDS("data/basefile.Rds")

#load codebooks
# codebook <- read_excel("data/codebook.xlsx")
# quickcode <- read_excel("data/modal_codebook.xlsx")



#**************************************************************
# UI
#**************************************************************


# Begin fluidPage
ui = fluidPage(
  sliderInput(inputId = "num",
              label = "Choose a Number",
              value = 1, min = 1, max = 100),
  plotOutput("hist")
    
  )

server = function(input, output) {
  output$hist = renderPlot({
    hist(rnorm(input$num))
  })
}

shinyApp(ui = ui, server = server)
