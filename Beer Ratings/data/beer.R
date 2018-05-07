library(dplyr) # For Analysis
library(DBI) # For Connection
library(RPostgreSQL) # For Reading From PostgreSQL DB

# Establish connection info
host = 'localhost'
port = '5432'
dbname = 'beerdata'
user = 'tim'
pwd = 'tim'

# Create driver for PostgreSQL hookup
drv <- dbDriver("PostgreSQL")

# Open connection to database
beer.db <- dbConnect(drv,
                    host = host,
                    port = port, 
                    dbname = dbname,
                    user = user,
                    password = pwd)

# Read table from database
reviews.db <- dbReadTable(beer.db, 'reviews')

# Rename columns
colnames(reviews.db) <- c('Appearance', 'Style', 'PalateScore', 'TasteScore', 'Name',
                          'Time', 'ABV', 'BeerID', 'BrewerID', 'OverallScore', 'Review', 'User',
                          'AromaScore')

# Set variables to correct types
reviews.db$Apperance <- as.character(reviews.db$Appearance)
reviews.db$Style <- as.character(reviews.db$Style)
reviews.db$PalateScore <- as.double(reviews.db$PalateScore)
reviews.db$TasteScore <- as.double(reviews.db$TasteScore)
reviews.db$Name <- as.character(reviews.db$Name)
reviews.db$Time <- as.numeric(reviews.db$Time)
reviews.db$ABV <- as.double(reviews.db$ABV)
reviews.db$BeerID <- as.numeric(reviews.db$BeerID)
reviews.db$BrewerID <- as.numeric(reviews.db$BrewerID)
reviews.db$OverallScore <- as.double(reviews.db$OverallScore)
reviews.db$Review <- as.character(reviews.db$Review)
reviews.db$User <- as.character(reviews.db$User)
reviews.db$AromaScore <- as.double(reviews.db$AromaScore)

# Group beers by name
name <- group_by(reviews.db, Name)

# Create data frame for average scores of beers
summary <- data.frame(summarise(name,
          Count = n(),
          Overall = round(mean(OverallScore), 1), 
          Palate = round(mean(PalateScore), 1),
          Taste = round(mean(TasteScore), 1),
          Aroma = round(mean(AromaScore), 1)))

# Create data frame for 100 most reviewed beers
mostreviews <- summary[summary$Count >= 1412,]