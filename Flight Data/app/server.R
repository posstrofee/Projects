# server.R
# routine to provide the info that will be displayed
# in each tab defined in ui.R


# include require libraries
library(shiny)
library(shinydashboard)
library(qcc)
library(nortest)
library(e1071)




#########################################
# Main function for shinyServer:        #
# defines all functions to populate     #
# objects set up in ui.R                #
#########################################
shinyServer(function(input, output, session) {
  
  
  
  ##############################################################
  # Returns dataset for specific delays                      #
  ##############################################################

  whichdataset <- reactive({
    data <- flight.data  
    if (length(input$Airline))
    {data$c1 <- grepl(paste(input$Airline, collapse = "|"), data$UniqueCarrier)}
    else 
    {data$c1 <- TRUE}
    if (length(input$Origin))
    {data$c2 <- grepl(paste(input$Origin, collapse = "|"), data$Origin)}
    else 
    {data$c2 <- TRUE}
    if (length(input$Destination))
    {data$c3 <- grepl(paste(input$Destination, collapse = "|"), data$Dest)}
    else 
    {data$c3 <- TRUE}
    data[data$c1 & data$c2 & data$c3 ,c("DepDelay")]
  })
  
  ##############################################################
  # Returns dataset specifically for "Show Data" tab           #
  ##############################################################
  
  datatab <- reactive({
    data <- flight.data  
    if (length(input$Airline))
    {data$c1 <- grepl(paste(input$Airline, collapse = "|"), data$UniqueCarrier)}
    else 
    {data$c1 <- TRUE}
    if (length(input$Origin))
    {data$c2 <- grepl(paste(input$Origin, collapse = "|"), data$Origin)}
    else 
    {data$c2 <- TRUE}
    if (length(input$Destination))
    {data$c3 <- grepl(paste(input$Destination, collapse = "|"), data$Dest)}
    else 
    {data$c3 <- TRUE}
    data[data$c1 & data$c2 & data$c3 ,c("UniqueCarrier", "Origin", "Dest",
                                        "DepDelay")]
  })
  
  # Keeps selectors updated
  updateSelectizeInput(session, 'Airline', choices = sort(unique(flight.data$UniqueCarrier)), server = TRUE)
  updateSelectizeInput(session, 'Origin', choices = sort(unique(flight.data$Origin)), server = TRUE)
  updateSelectizeInput(session, 'Destination', choices = sort(unique(flight.data$Dest)), server = TRUE)
  
  
  
  #######################################################
  # Key Performance Indicators #
  #######################################################
  
  # kpi 1: average delay
  output$averageDelay <- renderValueBox({
    
    dataset = whichdataset()
    average <- round(mean(dataset),3)
    
    valueBox(
      formatC(average, format="d", big.mark=',')
      ,"Average Departure Delay Delay Time"
      ,icon = icon("aplane")
      ,color = ifelse(average >= 10, "red", 
                      ifelse(average <= 10, "green"))
    )
    
  })
  
  # kpi 2: Percentage of flights leaving early/on time
  output$onTime <- renderValueBox({
    
    dataset = whichdataset()
    a <- sum(dataset < 5)
    early <- a/length(dataset)
    valueBox(
      paste0(round(early * 100, 2),"%")
      ,"Percentage of On/Time Early Flights (5 or fewer minutes)"
      ,icon = icon("pie-chart")
      ,color = ifelse(early <= 0.50, "red", 
                      ifelse(early > 0.50, "green"))
    )
  })
  
  #######################################################
  # Generate a descriptive stats summary of the dataset #
  #######################################################
  output$stats <- renderPrint({
    
    dataset=whichdataset()
    
    cat("\n", paste("Count                   = ", round(length(dataset),4)),"\n",
        paste("Mean                    = ", round(mean(dataset),3)),"\n",
        paste("Standard Deviation      = ", round(sd(dataset),3)),"\n",
        paste("Variance                = ", round(var(dataset),3)),"\n",
        paste("Kurtosis                = ", round(kurtosis(dataset),3)),"\n",
        paste("Skewness                = ", round(skewness(dataset),3)),"\n",
        paste("Min                     = ", summary(dataset)[1]),"\n",
        paste("Q1                      = ", summary(dataset)[2]),"\n",
        paste("Median                  = ", median(dataset)) ,"\n",
        paste("Q3                      = ", summary(dataset)[5]),"\n",
        paste("Max                     = ", max(dataset)) ,"\n")
    
  })
  
  
  
  #########################################
  # display plot graphical summary        #
  #########################################
  output$gsHist <- renderPlot({
    
    dataset=whichdataset()
    
    mean=mean(dataset)
    sd  =sd(dataset)
    x      <- seq(-3,3,length=100)*sd + mean
    hx     <- dnorm(x,mean,sd)
    myhist <- hist(dataset)
    yy     <- max(max(hx), max(myhist$density))
    
    
    hist(dataset,col=13, main=paste("Histogram: ",input$vector), prob=TRUE,
         yaxt="n", ylab="", ylim=c(0,yy),xlim=c(mean-(sd*4),mean+(sd*4)))
    lines(x,hx,col="maroon")
    
  }) 
  
  
  
  ################################################
  # Generate a boxplot of the requested variable #
  ################################################
  output$gsPlot <- renderPlot({
    data = whichdataset()
    boxplot(data, horizontal=TRUE)
  })  
  
  # generate the Individuals control chart
  output$ccPlot <- renderPlot({
    qcc(whichdataset(),type="xbar.one",sizes=whichdataset())
  }) 
  
  
  
  #########################################
  # Generate capability analysis plot     #
  #########################################
  output$capPlot <- renderPlot({
    
    
    gsp=whichdataset()
    
    lsl=input$lsl
    usl=input$usl
    
    mean=mean(gsp)
    std=sd(gsp)
    x  <- seq(-3,3,length=100)*std + mean
    hx <- dnorm(x,mean,std)
    
    MR=mean(abs(gsp[1:length(gsp)-1]-gsp[2:length(gsp)]))
    stdw=MR/1.128
    wx  <- seq(-3,3,length=100)*stdw + mean
    whx <- dnorm(x,mean,stdw)
    
    yy<-c(max(hx),max(whx), max(hist(gsp,plot="FALSE")$density))
    y1=max(yy)
    
    x1=min(lsl,mean-(std*6))
    x2=max(usl,mean+(std*6))
    
    hist(gsp,col=13, main="Histogram", prob=TRUE,xlim=c(x1,x2),ylim=c(0,y1),
         yaxt="n", ylab="")
    lines(x, hx,lwd=3)
    lines(wx,whx,col="Red",lwd=3)
    
    #lower spec limit
    cax=c(lsl,lsl)
    cay=c(0,y1)
    lines(cax,cay,col="Red",typ="c",lty=3,lwd=2)
    text(lsl,y1,"LSL",col="Red")
    
    #upper spec limit
    cax=c(usl,usl)
    cay=c(0,y1)
    lines(cax,cay,col="Red",typ="c",lty=3,lwd=2)
    text(usl,y1,"USL",col="Red")
    
  }) 
  
  
  
  ####################################
  # generate text output for CA      #
  ####################################
  output$captext <- renderPrint({
    
    gsp=whichdataset()
    
    #upper and lower spec limits (easier to use variables)
    lsl=input$lsl
    usl=input$usl
    
    #calculate moving range
    MR=mean(abs(gsp[1:length(gsp)-1]-gsp[2:length(gsp)]))  
    
    mean=mean(gsp)
    # standard deviation (overall)
    std=sd(gsp)
    
    # within standard deviation for subgroup size =1
    # is average moving range / constant 1.128
    stdw=MR/1.128
    
    cp=round((usl-lsl)/(6*(MR/1.128)),2)
    
    cpu=round((usl-mean(gsp))/(3*(MR/1.128)),2)
    cpl=round((mean(gsp)-lsl)/(3*(MR/1.128)),2)
    cpk=round(min(cpu,cpl),2)
    
    pp=round((usl-lsl)/(6*(std)),2)
    ppu=round((usl-mean(gsp))/(3*(std)),2)
    ppl=round((mean(gsp)-lsl)/(3*(std)),2)
    ppk=round(min(ppu,ppl),2)
    
    cat(
      "USL    = ",usl, "\n",
      "LSL    = ",lsl, "\n",
      "N      = ",length(gsp),"\n",
      "Mean   = ",mean, "\n",
      "StdDev(within)  = ",round(stdw,4), "\n",
      "StdDev(overall) = ",round(std,4),  "\n", 
      
      "Potention (within) Capability", "\n",
      "CP     = ",cp,  "\n",  
      "CPL    = ",cpl, "\n",  
      "CPU    = ",cpu, "\n",  
      "Cpk    = ",cpk, "\n", 
      
      "Overall Capability", "\n",
      "PP     = ",pp, "\n",
      "PPL    = ",ppl,"\n", 
      "PPU    = ",ppu,"\n", 
      "Ppk    = ",ppk
    ) # end of cat
    
  }) # end of renderPrint
  
  #output data table
  output$table <- renderDataTable(datatab())
  
}) # end of shinyServer