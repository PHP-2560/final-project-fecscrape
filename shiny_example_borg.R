# Shiny App - Gabriele Borg example 

# Load packages
library(shiny)


# UI

ui = fluidPage(
   
   sliderInput(inputId = "z",
               label = "Z-value",
               min = -5,
               max = 5,
               value = 0,
               step = 0.1
   ),
   
   tags$div(style="margin-bottom:50px;margin-top:10px",
            tags$b("P-value:"),
            textOutput("pval")
   )
)


# SERVER

server = function(input, output) {
   output$pval = renderPrint({
      calculate_p_value <- function(z) {
         p_value = 2*pnorm(-abs(input$z))
         return(p_value)
      }
      calculate_p_value(input$z)
   })
}

shinyApp(ui = ui, server = server)