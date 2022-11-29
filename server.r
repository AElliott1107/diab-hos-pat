
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
  output$gluPlot <- renderPlot({
    d <- dbGetQuery(
      conn = diabdb,
      statement = 
        'SELECT * FROM glucose WHERE Date BETWEEN ? AND ?',
      params = list(format(input$date_range[1], format = "%Y-%m-%d"),
                    format(input$date_range[2], format = "%Y-%m-%d"))
    )
    glu_meas <- filter(glucose, Code %in% c(48, 57:64))
    meas_plot <- glu_meas %>%
      mutate(time = as.POSIXct(hms::parse_hm(glu_meas$Time))) %>%
      ggplot(aes(x = time, y = Value)) +
      geom_point(alpha=0.5, size=2, aes(color = Description)) +
      scale_x_datetime(date_labels = "%H:%M") + 
      labs(y="Glucose Measurement", x="Time of Day", subtitle="Patient Glucose Measurements throughout the day") +
      geom_smooth() +
      theme_minimal(base_size = 16) +
      theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
      theme(legend.position = 'none')
    meas_plot
  })

  output$summary <- renderPrint({
    summary(cars)
  })

  output$table <- DT::renderDataTable({
    DT::datatable(cars)
  })
}
