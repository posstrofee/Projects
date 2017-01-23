## Shiny app framework from following link: https://gist.github.com/traidna/9881583
## KPI framework from following link: https://mgiglia.solutions/shiny/msa8215_1/
## 
## This app creates interactive tables to see departure delays for flights between
## certain airports from all of 2015.
##
## NOTE: With correct connection info (mine is default) and working directory set, 
## the app can be run by selecting and executing the entire script.

# Comment DK: this is an unusual setup. Typically global dosn't call the app!
# Also, it would have been perfect, if the destination airports would depend on the origin selection...

library(dplyr) # For Analysis
library(data.table) #For Creating Data Tables
library(DBI) # For Connection
library(RPostgreSQL) # For Reading From PostgreSQL DB
library(shiny) # To Run App
library(shinydashboard) # To Run App With Cool Dashboards

# Establish connection info
host = 'localhost'
port = '5432'
dbname = 'flights'
user = 'flights'
pwd = 'dkalisch@stmarys-ca.edu'

# Create driver for PostgreSQL hookup
drv <- dbDriver("PostgreSQL")

# Open connection to database
flights.db <- dbConnect(drv,
                     host = host,
                     port = port, 
                     dbname = dbname,
                     user = user,
                     password = pwd)

# extract data back out and format
flights.src <- src_postgres(dbname = dbname, host = host, port = port, user = user, password = pwd)
flights.bridge <- tbl(flights.src, "connections")
flight.data <- flights.bridge %>% select (UniqueCarrier, Origin, Dest, DepDelay, ArrDelay)
flight.data <- as.data.frame(flight.data)
flight.data[is.na(flight.data)] <- 0

# Factor columns correctly
flight.data$UniqueCarrier <- as.character(flight.data$UniqueCarrier)
flight.data$Origin <- as.character(flight.data$Origin)
flight.data$Dest <- as.character(flight.data$Dest)
flight.data$DepDelay <- as.numeric(flight.data$DepDelay)
flight.data$ArrDelay <- as.numeric(flight.data$ArrDelay)

# Run App
runApp("app")
