
#declare libraries
library(datasets)
library(tools)
library(ggplot2)
library(readr)
library(dplyr)
library(caret)
library(visdat)
library(corrplot)
library(chron)
library(tidyr)
library(tidyverse)
library(rpart)
library(rpart.plot)
library(parsnip)
library(mlbench)
library(RSQLite)
library(DBI)

diabdb <- dbConnect(RSQLite::SQLite(), "diabetes-db.sqlite", extended_types = TRUE)

function(input, output, session) {
  #Blood Glucose Database Query
  gludb <- dbGetQuery(
    conn = diabdb,
    statement = 
      'SELECT * FROM glucose',
  )
  
  #Code list variables for filtering
  code_list <- list(c(48, 57:64), c(48))
  
  #Blood Glucose Plot for 2nd tab
  output$gluPlot <- renderPlot({
    #params = list(format(input$date_range[1], format = "%Y-%m-%d"),format(input$date_range[2], format = "%Y-%m-%d"))
    glu_meas <- filter(gludb, gludb$Code %in% c(code_list[[strtoi(input$code_type)]]))
    meas_plot <- glu_meas %>%
      mutate(time = as.POSIXct(hms::parse_hm(glu_meas$Time))) %>%
      ggplot(aes(x = time, y = Value)) +
      geom_point(alpha=0.5, size=2, aes(color = Description)) +
      scale_x_datetime(date_labels = "%H:%M") + 
      labs(y="Glucose Measurement", x="Time of Day", subtitle="Patient Glucose Measurements throughout the day") +
      geom_smooth() +
      theme_minimal(base_size = 16) +
      theme(axis.text.x = element_text(angle = 60, hjust = 1))
    meas_plot
  })
  
  #Query for hospital plot
  hospitaldb <- dbGetQuery(
    conn = diabdb,
    statement = 
      'SELECT * FROM hospital'
  )
  #Age Distribution plot from hospital data
  output$agePlot <- renderPlot({
    table(hospitaldb$age) %>% barplot(col = "wheat", main = "Hospital Patient Age Distribution")
  })
  
  #Gender Distribution plot from hospital data
  output$genderPlot <- renderPlot({
    table(hospitaldb$gender) %>% barplot(col = "blue", main = "Hospital Patient Gender Distribution")
  })
  
  #Histogram for time in hospital
  output$timeHist <- renderPlot({
    hist(hospitaldb$time_in_hospital, col = "purple", main = "Time in Hospital Distribution")
  })
}
