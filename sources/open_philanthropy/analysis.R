## Description:

## Libraries

### Install
# install.packages("ggplot2")
# install.packages("readr")
# install.packages("ggthemes")
# install.packages("ggsci")
# install.packages("dplyr")

### Load
library("ggplot2")
library("readr")
library("ggthemes")
library("magrittr")
library("RColorBrewer")
library("ggsci")

## Data import
# setwd("/home/loki/Blog/nunosempere.com/blog/2024/11/20/brief-update-ea-funding/.source")
data <- read.csv("grants.csv", header=TRUE, stringsAsFactors = FALSE)

## Data cleaning
colnames(data)
getYear <- function(dateRow){
  year = strsplit(dateRow, " ")[[1]][2]
  return(year)
}
getYear(data$Date[1])
as.vector(sapply(data$Date, getYear))
df <- list()
df$year <- as.vector(sapply(data$Date, getYear))
df$amount <- as.vector(sapply(data$Amount, parse_number))
df$amount <- ifelse(is.na(df$amount), 0, df$amount)
df$area <- as.vector(data$Focus.Area)
df <- as.data.frame(df)
df$area <- as.vector(data$Focus.Area) # not sure why this line is needed, but things break otherwise
# View(df)

## Classify according to areas
areas <- unique(df$area)
ea_growth <-  c("Effective Altruism Community Growth", "Effective Altruism Community Growth (Global Health and Wellbeing)")
global_health <- c("South Asian Air Quality", "Human Health and Wellbeing", "GiveWell-Recommended Charities", "Global Aid Policy", "Global Health & Wellbeing", "Global Health & Development","Science for Global Health")
longtermism <- c("Biosecurity & Pandemic Preparedness", "Potential Risks from Advanced AI", "Science Supporting Biosecurity and Pandemic Preparedness", "Longtermism")
animal_welfare <- c("Farm Animal Welfare", "Broiler Chicken Welfare", "Cage-Free Reforms", "Alternatives to Animal Products")
scientific_research <- c("Transformative Basic Science", "Scientific Research", "Other Scientific Research Areas", "Scientific Innovation: Tools and Techniques")
politicy_advocacy <- c("Land Use Reform","Macroeconomic Stabilization Policy", "Criminal Justice Reform", "Immigration Policy")
not_other <- c(ea_growth, global_health, longtermism, animal_welfare, scientific_research, politicy_advocacy)
other <- areas[!(areas %in% not_other)]

df$area <- ifelse(df$area %in% ea_growth, "EA Community Building", df$area)
df$area <- ifelse(df$area %in% global_health, "Global Health and Wellbeing", df$area)
df$area <- ifelse(df$area %in% longtermism, "Longtermism & GCRs", df$area)
df$area <- ifelse(df$area %in% animal_welfare, "Animal Welfare", df$area)
df$area <- ifelse(df$area %in% scientific_research, "Scientific Research", df$area)
df$area <- ifelse(df$area %in% politicy_advocacy, "Policy Advocacy", df$area)
df$area <- ifelse(df$area %in% other, "Other", df$area)
df$area

## Aggregate by year and area
years <- c(2014: 2024)# as.vector(unique(df$year))
num_years <- length(years)
area_names <- as.vector(unique(df$area))
num_areas <- length(area_names)

df2 <- list()
df2$area <- sort(rep(area_names, num_years))
df2$year <- rep(years, num_areas)
df2 <- as.data.frame(df2)

getAmountForYearAreaPair <- function(a_df, target_year, target_area){
  filter = dplyr::filter
  # target_year = 2024
  # target_area = "Longtermism"
  rows = a_df %>% filter(year == target_year) %>% filter(area == target_area)
  return(sum(rows$amount))
}
getAmountForYearAreaPair(df, 2024, "Longtermism & GCRs")

getAmountForArea <- function(a_df, target_area){
  filter = dplyr::filter
  rows = a_df %>% filter(area == target_area)
  return(sum(rows$amount))
}
getAmountForArea(df, "Longtermism & GCRs")

amounts <- c()
for(i in c(1:dim(df2)[1])){
  amount <- getAmountForYearAreaPair(df, df2$year[i], df2$area[i])
  amounts <- c(amounts, amount)
}
df2$amount <- amounts

## Order by cummulative amount
df2$cummulative_amount_for_its_area = sapply(df2$area, function(area) {
  return(getAmountForArea(df, area)) 
})
View(df2)

## Plotting
title_text="Open Philanthropy allocation by year and cause area"
subtitle_text="with my own aggregation of categories"
palette = "Classic Red-Blue"
direction = -1
open_philanthropy_plot <- ggplot(data=df2, aes(x=year, y=amount, fill=area, group = cummulative_amount_for_its_area))+
  geom_bar(stat="identity")+
  labs(
    title=title_text,
    subtitle=subtitle_text,
    x=element_blank(),
    y=element_blank()
  ) +
  # scale_fill_wsj() +
  # scale_fill_tableau(dir =1) +
  # scale_fill_tableau(palette, dir=direction) +
  # scale_fill_viridis(discrete = TRUE) +
  # scale_fill_brewer(palette = "Set2") +
  
  scale_fill_d3( "category20", alpha=0.8) +
  # scale_fill_uchicago("dark") +
  # scale_fill_startrek() +
  scale_y_continuous(labels = scales::dollar_format(scale = 0.000001, suffix = "M"), breaks = c(0:6)*10^8)+
  scale_x_continuous(breaks = years)+
  theme_tufte() +
  theme(
    legend.title = element_blank(),
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    legend.position="bottom",
    legend.box="vertical",
    axis.text.x=element_text(angle=60, hjust=1),
    legend.text=element_text(size=7, hjust = 0.5)
  ) + 
  geom_text(aes(label=ifelse(amount > 25e6, paste0(round(amount / 1e6, 0), "M"), "")), size = 1.7, colour="#f9f9f9", position = position_stack(vjust = 0.5)) +
  geom_text(
    aes(label = paste0(round(after_stat(y) / 1e6, 0), "M"), group = year), 
    stat = 'summary', fun = sum, size=2.2, vjust = -0.5
  ) +
  guides(fill=guide_legend(nrow=3,byrow=TRUE))

open_philanthropy_plot
getwd() ## Working directory on which the file will be saved. Can be changed with setwd("/your/directory")
height = 5
width = 5
ggsave(plot=open_philanthropy_plot, "open_philanthropy_grants_stacked_with_amounts.png", width=width, height=height, bg = "white")

## Look at the different longtermist areas independently.
longtermism <- c("Biosecurity & Pandemic Preparedness", "Potential Risks from Advanced AI", "Science Supporting Biosecurity and Pandemic Preparedness", "Longtermism")

df3 <- list()
df3$year <- as.vector(sapply(data$Date, getYear))
df3$amount <- as.vector(sapply(data$Amount, parse_number))
df3$amount <- ifelse(is.na(df$amount), 0, df$amount)
df3$area <- as.vector(data$Focus.Area)
df3 <- as.data.frame(df3)
df3$area <- as.vector(data$Focus.Area)
df3 <- df3 %>% dplyr::filter(area %in% longtermism)
# View(df3)

## Group area

pure_longtermism = c("Longtermism")
biorisk = c("Biosecurity & Pandemic Preparedness", "Science Supporting Biosecurity and Pandemic Preparedness")
ai_risk = c( "Potential Risks from Advanced AI")
longtermism_labels = c(pure_longtermism, "Biosecurity & Pandemic Preparedness", ai_risk)  

df3$area <- ifelse(df3$area %in% pure_longtermism, "Longtermism", df3$area)
df3$area <- ifelse(df3$area %in% biorisk, "Biosecurity & Pandemic Preparedness", df3$area)
df3$area <- ifelse(df3$area %in% ai_risk, "Potential Risks from Advanced AI", df3$area)

years <- c(2014: 2024) # as.vector(unique(df$year))
num_years <- length(years)
area_names <- longtermism_labels
num_areas <- length(area_names)

df4 <- list()
df4$area <- sort(rep(area_names, num_years))
df4$year <- rep(years, num_areas)
df4 <- as.data.frame(df4)
# View(df4)
getAmountForYearAreaPair(df3, 2024, "Longtermism")

amounts <- c()
for(i in c(1:dim(df4)[1])){
  amount <- getAmountForYearAreaPair(df3, df4$year[i], df4$area[i])
  amounts <- c(amounts, amount)
}
df4$amount <- amounts
df4$cummulative_amount_for_its_area = sapply(df4$area, function(area) {
  return(getAmountForArea(df3, area)) 
})
View(df4)

## Plotting longtermist funding
title_text="Open Philanthropy allocation by year and cause area"
subtitle_text="restricted to longtermism & GCRs"
palette = "Classic Red-Blue"
direction = -1
open_philanthropy_plot_lt <- ggplot(data=df4, aes(x=year, y=amount, fill=area, group=cummulative_amount_for_its_area))+
  geom_bar(stat="identity")+
  labs(
    title=title_text,
    subtitle=subtitle_text,
    x=element_blank(),
    y=element_blank()
  ) +
  # scale_fill_wsj() +
  # scale_fill_tableau(dir =1) +
  # scale_fill_tableau(palette, dir=direction) +
  # scale_fill_viridis(discrete = TRUE) +
  # scale_fill_brewer(palette = "Set2") +
  
  scale_fill_d3( "category20", alpha=0.8) +
  # scale_fill_uchicago("dark") +
  # scale_fill_startrek() +
  scale_y_continuous(labels = scales::dollar_format(scale = 0.000001, suffix = "M"))+
  scale_x_continuous(breaks = years)+
  theme_tufte() +
  theme(
    legend.title = element_blank(),
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    legend.position="bottom",
    legend.box="vertical",
    axis.text.x=element_text(angle=60, hjust=1),
    legend.text=element_text(size=7)
  ) + 
  geom_text(aes(label=ifelse(amount > 5e6, paste0(round(amount / 1e6, 0), "M"), "")),  size = 2, colour="#f9f9f9", position = position_stack(vjust = 0.5)) +
  geom_text(
    aes(label = paste0(round(after_stat(y) / 1e6, 0), "M"), group = year), 
    stat = 'summary', fun = sum, size=2.3, vjust = -0.5
  ) +
  guides(fill=guide_legend(nrow=3,byrow=TRUE))
open_philanthropy_plot_lt
getwd() ## Working directory on which the file will be saved. Can be changed with setwd("/your/directory")
height = 5
width = 7
## open_philanthropy_plot_lt
ggsave(plot=open_philanthropy_plot_lt, "open_philanthropy_grants_lt_labeled.png", width=width, height=height, bg = "white")

## Including Dustin Moskovitz's wealth 
coeff <- 10^7*3.5
wealth <- c(6, 8, 12, 15, 18, 12, 14, 19, 14, 18, 25)
df2$wealth <- rep(wealth * coeff, num_areas)

subtitle_text=""
make_fortune_plot <- function(show_fortune_legend = FALSE) {
  open_philanthropy_plot_with_fortune <- ggplot(data=df2, aes(x=year, y=amount, fill=area, group = cummulative_amount_for_its_area))+
    geom_bar(stat="identity")+
    geom_point(
      aes(x=year, y=wealth), size=2, color="darkblue", shape=4,
      show.legend=show_fortune_legend
    )+
    labs(
      title=title_text,
      subtitle=subtitle_text,
      x=element_blank(),
      y=element_blank()
    ) +
    # scale_fill_wsj() +
    # scale_fill_tableau(dir =1) +
    # scale_fill_tableau(palette, dir=direction) +
    # scale_fill_viridis(discrete = TRUE) +
    # scale_fill_brewer(palette = "Set2") +

    scale_fill_d3( "category20", alpha=0.8) +
    # scale_fill_uchicago("dark") +
    # scale_fill_startrek() +
    scale_y_continuous(
      labels = scales::dollar_format(scale = 0.000001, suffix = "M"),
      name="OpenPhil donations",
      breaks = c(0:6)*10^8,
      sec.axis = sec_axis(
        ~.*1,
        name="Dustin Moskovitz's fortune\n(est. Bloomberg)",
        breaks = seq(0,25,by=5)*coeff,
        labels = c("$0B", "$5B","$10B","$15B", "$20B", "$25B")
        ),
      limits=c(0,26 * coeff)
      )+
    scale_x_continuous(breaks = years)+
    theme_tufte() +
    theme(
      legend.title = element_blank(),
      plot.title = element_text(hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5),
      legend.position="bottom",
      legend.box="vertical",
      axis.text.x=element_text(angle=60, hjust=1),
      axis.title.y = element_text(vjust=3, hjust=0.25, size=10),
      axis.title.y.right = element_text(vjust=3, hjust=0.5, size=10),
      legend.text=element_text(size=8)
    ) +
    guides(fill=guide_legend(nrow=4,byrow=TRUE))
  # open_philanthropy_plot_with_fortune

  height = 6
  width = 5

  filename = ifelse(
    show_fortune_legend,
    "open_philanthropy_plot_with_fortune.png",
    "open_philanthropy_plot_with_fortune_clean_labels.png"
  )
  ggsave(plot=open_philanthropy_plot_with_fortune, filename, width=width, height=height, bg = "white")
}

make_fortune_plot(TRUE)
make_fortune_plot(FALSE)
