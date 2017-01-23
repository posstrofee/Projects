# Load required libraries
library(reshape2) # For restructuring the data
library(dplyr) # For data preparation
library(e1071) # For Skewness and Kurtosis
library(car) # For Levenes test
library(ggplot2) # For fancy plotting

# load data into R
Pitchers <- read.csv("Pitchers.csv")
FIP <- colnames(Pitchers)[2]
min <- min(FIP)
max <- max(FIP)


Pitchers %>%
  summarise(
    count = NROW(FIP),
    sum = sum(FIP),
    min = min(FIP),
    max = max(FIP),
    mean = round(mean(FIP), digits=2),
    median = round(median(FIP), digits=2),
    range = (max - min),
    q1 = round(quantile(FIP, c(0.25)), digits=2),
    q3 = round(quantile(FIP, c(0.75)), digits=2),
    iqr = IQR(FIP),
    sd = round(sd(FIP), digits=2),
    var = round(var(FIP), digits=2),
    kurt = round(kurtosis(FIP), digits=4),
    skew = round(skewness(FIP), digits=4)
  )

# ANOVA
## Calculate ANOVA results
fit <- lm(data = Pitchers, FIP~Team)
Pitchers.aov <- aov(fit)
Pitchers.aov.summary <- summary(Pitchers.aov)

### Print results
print(Pitchers.aov.summary)

## Perform Tukey-Kramer
Pitchers.tukey <- TukeyHSD(Pitchers.aov)

### Print results
print(Pitchers.tukey)

## Homogenity of variance
Pitchers.levene <- leveneTest(fit)

### Print results
print(Pitchers.levene)

# Create plot and save it into a variable
qqp <- ggplot(Pitchers) +
  stat_qq(aes(sample = value, colour = cyl)) +
  guides(col = guide_legend(title = "Team"))

df <- anova(fit)[, "Df"]
names(df) <- c("between", "within")

# Set alpha error
alpha <- 0.05

## Get the f values
Pitchers.f.crit <- qf(alpha, df["between"], df["within"], lower.tail = FALSE)
Pitchers.f.value <- Pitchers.aov.summary[[1]]$F[1]

## PlotBoxplotofthedataset
bp<-ggplot(Pitchers,aes(x=Team,y=FIP))+
  stat_boxplot(geom = "errorbar") + # Add error bars to the boxplot
  geom_boxplot() + # Add boxplot
  labs(y = "FIP", x = "Team")
bp

## PlotF-distribution
### Displaysettings
ncp <- 0 # Noncentrality parameter
frameEmpty <- "black" # Color for the empty frame
areaEmpty <- "white" # Color for the empty area
frameH0 <- "green4" # Color for the H0 frame
areaH0 <- "green3" # Color for the H0 area
frameH1 <- "red4" # Color for the H1 frame
areaH1 <- "red2" # Color for the H1 area

### Distribution specific settings
df1 <- df[1] # Degree of freedom first parameter
df2 <- df[2] # Degree of freedom second parameter
length <- 500 # number of elements

### Data preperation
x <- seq(from = 0,to = Pitchers.f.value +15, length = length) #Set vector range
dd<- data.frame(x = seq(from = 0, to = Pitchers.f.value+5, length = length),
                y = df(x = x, df1 = df1, df2 = df2, ncp = 5)) # Create data frame

### Create F-distribution plot
pf <- ggplot(data = dd) # Create the plot
pf <- pf + labs(y = "Relative frequency", x = "F-values")#Tidy up the axis title
pf <- pf + geom_area(aes(x = x,y = y), color = frameH0, fill = areaH0) # Add the H0 area 
pf <- pf + geom_area(data = subset(dd , x > Pitchers.f.crit), aes(x = x, y = y), fill = areaH1, color = frameH1) # Add the H1 area 
pf <- pf + geom_vline(xintercept = Pitchers.f.crit, colour = frameH1,linetype = "longdash") # Add the F-critical value line 
pf <- pf + geom_vline(xintercept = Pitchers.f.value, colour = "black", linetype = "dotted") # Add the F-value line 
pf <- pf + scale_x_continuous(breaks = sort(round(c(seq(from = min(dd$x), to = round(max(dd$x),0),by =  2), Pitchers.f.crit,Pitchers.f.value),2))) #Add tick marks for the F values
pf<-pf+annotate("text",y=.2,x=Pitchers.f.value + 1,
                label = paste("Pr(>F) = ",
                              round(Pitchers.aov.summary[[1]]$Pr[1],3))) # Add p-value to plot
pf