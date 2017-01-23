# Load required libraries
library(reshape2) # For restructuring the data
library(dplyr) # For data preparation
library(e1071) # For Skewness and Kurtosis
library(car) # For Levenes test
library(ggplot2) # For fancy plotting

# load data into R
Hitters <- read.csv("Hitters.csv")
wRC <- colnames(Hitters)[2]
min <- min(wRC)
max <- max(wRC)

Hitters %>%
  summarise(
    count = NROW(wRC),
    sum = sum(wRC),
    min = min(wRC),
    max = max(wRC),
    mean = round(mean(wRC)),
    median = round(median(wRC)),
    range = (max - min),
    q1 = round(quantile(wRC, c(0.25)), digits=-1),
    q3 = round(quantile(wRC, c(0.75)), digits=-1),
    iqr = IQR(wRC),
    sd = round(sd(wRC)),
    var = round(var(wRC)),
    kurt = round(kurtosis(wRC), digits=4),
    skew = round(skewness(wRC), digits=4)
  )

# ANOVA
## Calculate ANOVA results
fit <- lm(data = Hitters, wRC~Team)
Hitters.aov <- aov(fit)
Hitters.aov.summary <- summary(Hitters.aov)

### Print results
print(Hitters.aov.summary)


## Perform Tukey-Kramer
Hitters.tukey <- TukeyHSD(Hitters.aov)

### Print results
print(Hitters.tukey)

## Homogenity of variance
Hitters.levene <- leveneTest(fit)

### Print results
print(Hitters.levene)

# Create plot and save it into a variable
qqp <- ggplot(Hitters) +
  stat_qq(aes(sample = value, colour = cyl)) +
  guides(col = guide_legend(title = "Team"))

df <- anova(fit)[, "Df"]
names(df) <- c("between", "within")

# Set alpha error
alpha <- 0.05

## Get the f values
Hitters.f.crit <- qf(alpha, df["between"], df["within"], lower.tail = FALSE)
Hitters.f.value <- Hitters.aov.summary[[1]]$F[1]

# PlotANOVAresults
## PlotBoxplotofthedataset
bp<-ggplot(Hitters,aes(x=Team,y=wRC))+
  stat_boxplot(geom = "errorbar") + # Add error bars to the boxplot
  geom_boxplot() + # Add boxplot
  labs(y = "wRC+", x = "Team")
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
x <- seq(from = 0,to = Hitters.f.value + 10, length = length) #Set vector range
dd<- data.frame(x = seq(from = 0, to = Hitters.f.value+2, length = length),
                y = df(x = x, df1 = df1, df2 = df2, ncp = 5)) # Create data frame

### Create F-distribution plot
pf <- ggplot(data = dd) # Create the plot
pf <- pf + labs(y = "Relative frequency", x = "F-values")#Tidy up the axis title
pf <- pf + geom_area(aes(x = x,y = y), color = frameH0, fill = areaH0) # Add the H0 area 
pf <- pf + geom_area(data = subset(dd , x > Hitters.f.crit), aes(x = x, y = y), fill = areaH1, color = frameH1) # Add the H1 area 
pf <- pf + geom_vline(xintercept = Hitters.f.crit, colour = frameH1,linetype = "longdash") # Add the F-critical value line 
pf <- pf + geom_vline(xintercept = Hitters.f.value, colour = "black", linetype = "dotted") # Add the F-value line 
pf <- pf + scale_x_continuous(breaks = sort(round(c(seq(from = min(dd$x), to = round(max(dd$x),0),by =  2), Hitters.f.crit,Hitters.f.value),2))) #Add tick marks for the F values
pf<-pf+annotate("text",y=.2,x=Hitters.f.value,
                label = paste("Pr(>F) = ",
                              round(Hitters.aov.summary[[1]]$Pr[1],3))) # Add p-value to plot
pf