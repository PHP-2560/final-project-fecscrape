#This is where we rite the code for our Shiny App

library(shiny)

ui = fluidPage(
  sliderInput(inputId = "num",
              label = "Coose a Number",
              value = 1, min = 1, max = 100),
  plotOutput("hist")
    
  )

server = function(input, output) {
  output$hist = renderPlot({
    hist(rnorm(input$num))
  })
}

shinyApp(ui = ui, server = server)
