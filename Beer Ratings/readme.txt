Top 100 Beer Data Reviews

This combination of programs will provide a table that will show the Top 100 Most Reviewed Beers of 2016 based on data provided by Beer Advocate and Rate Beer.

1. Python Program

The following files are needed to run the Python script in order to create the .csv file:

-gender_age_raw.txt
-beeradvocate.txt.gz
-ratebeer.txt.gz

The final two files have been sent via email due to their size (more than allowed on GitHub), but I’m guessing you still have them from when you provided them to me last Saturday at the Hack Day. Just wanted to make sure you had them just in case.

Python script scrapes the files and puts it into a .csv file, approximately 2.4 GB in size with over 1.5 million records.

2. Database hosting

Used Postgres local database hosting to access data. Integrated with DataGrip, with upload time approximately an hour to 90 minutes depending on internet connection. Formatted with first row being the header and separated by commas.

NOTE: Myself and Justin Read scraped to the same .csv file since we both worked on the Python code. To save time, you should be able to use the same file for both of us so you don’t have to upload the file twice. Our apps should be different, though.

3. Shiny app creation in R

Used PostgreSQL connection to link to database and create app using Shiny in R. Did it locally so the connection settings should differ on your end depending on how you host it. (“Establish Connection Info” portion of code would have to be altered - If I had more time, I would have kept it hosted on my AWS for you to access remotely more easily.) Used DataTable instead of Table for sorting purposes and better overall presentation.
