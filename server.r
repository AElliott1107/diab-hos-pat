
#declare libraries
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

#Blood Glucose Database Query
gludb <- dbGetQuery(
  conn = diabdb,
  statement = 
    'SELECT * FROM glucose',
)

#Query for hospital plot
hospitaldb <- dbGetQuery(
  conn = diabdb,
  statement = 
    'SELECT * FROM hospital'
)

#Query for encoded hospital data
hos_encoded <- dbGetQuery(
  conn = diabdb,
  statement = 
    'SELECT * FROM hos_encoded'
)

#Split train and test data and build decision tree
set.seed(123)
train <- createDataPartition(hos_encoded$time_in_hospital, p = .8,
                             list = FALSE)
hos_train <- hos_encoded[ train,]
hos_test <- hos_encoded[-train,]

model <- rpart(time_in_hospital ~ num_medications + num_lab_procedures + discharge_disposition_id, data=hos_train, method="anova")

function(input, output, session) {
  #Code list variables for filtering
  code_list <- list(c(48, 57:64), c(58, 59), c(60, 61), c(62, 63), 
                    c(58, 60, 62, 64), c(59, 61, 63), c(48, 57))
  
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
      theme_grey(base_size = 16) +
      theme(axis.text.x = element_text(angle = 60, hjust = 1))
    meas_plot
  })
  
  #Age Distribution plot from hospital data
  output$agePlot <- renderPlot({
    table(hospitaldb$age) %>% barplot(col = "wheat", main = "Hospital Patient Age Distribution", xlab = 'Patient Age')
  })
  
  #Gender Distribution plot from hospital data
  output$genderPlot <- renderPlot({
    table(hospitaldb$gender) %>% barplot(col = "blue", main = "Hospital Patient Gender Distribution", xlab = 'Patient Gender')
  })
  
  #Histogram for time in hospital
  output$timeHist <- renderPlot({
    hist(hospitaldb$time_in_hospital, col = "purple", main = "Time in Hospital Distribution", xlab = 'Patient Time in Hospital (Days)')
  })
  
  #Decision Tree Visualizations
  predictions <- data.frame(cbind(
    hos_test$num_medications,
    predict(object = model, hos_test)
  ))
  
  colnames(predictions) <- c('num_med','time_hos')
  
  sc <- reactive({
    med_input <- input$meds
  })
  
  output$medsPlot <- renderPlot({
    
    meds <- sc()
    
    (
      plot_meds <- ggplot(
        data = predictions,
        aes(x=num_med, y=time_hos)
      ) +
      geom_point(colour="#000099") +
      geom_point(data=predictions[meds, ], aes(x=num_med, y=time_hos), colour="red", size=5) +
      labs(y="Time in Hospital", x="Number of Medications", title = "Time in Hospital based on Number of Medications") +
      theme_grey(base_size = 16) +
      theme(axis.text.x = element_text(angle = 60, hjust = 1))
    )
  })
  
  output$dtreePlot <- renderPlot({
    rpart.plot(model, box.palette="BuPu", shadow.col="gray", nn=TRUE)
  })
}
