# ui.R
library(shiny)

# Define UI for dataset viewer application
shinyUI(fluidPage(
  titlePanel("100 Most Reviewed Beers of 2016"),
      helpText("This shows the 100 most reviewed beers on Beer Advocate and Rate Beer along with 
                their averagescores. Overall score is not directly related to the other three 
                scores, as each score is entered individually. Data is from 2016."),
    mainPanel(
      column(12, dataTableOutput('table')
    )
  )
))
