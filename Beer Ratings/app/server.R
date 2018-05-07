library(shiny)

# Define server logic required to summarize and view the selected
# dataset

# Comment DK: This is not complete...
function(input, output) {
  output$table <- renderDataTable(mostreviews)
}