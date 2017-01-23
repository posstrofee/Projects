# ui.R

library(shiny)
library(shinydashboard)
library(qcc)
library(nortest)
library(e1071)



dashboardPage(
  dashboardHeader(title = "Airline Data"),
  
  dashboardSidebar(selectizeInput("Airline", "Airline: ", multiple = TRUE, choices = NULL),
                selectizeInput("Origin", "Origin Airport: ", multiple = TRUE, choices = NULL),
                selectizeInput("Destination", "Destination Airport: ", multiple = TRUE, choices = NULL),
                numericInput("lsl", "Enter Lower Spec Limit: ", 20),
                numericInput("usl", "Enter Upper Spec Limit: ", 30),
                submitButton("Update View"),
                verbatimTextOutput("stats")
                
  ),
  
  
  dashboardBody(
    
    fluidRow(
      valueBoxOutput("averageDelay"),
      valueBoxOutput("onTime")
    ),
    
    tabsetPanel(
      
      tabPanel("Graph Sum", plotOutput("gsHist")),
      tabPanel("Box Plot", plotOutput("gsPlot")),
      tabPanel("Control Chart", plotOutput("ccPlot")),
      tabPanel("Capability", plotOutput("capPlot"),  verbatimTextOutput("captext")),
      tabPanel("Show Data", dataTableOutput('table'))
    )
    
  )
  
)