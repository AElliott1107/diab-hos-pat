# This file contains cleaning functions for reference prior to storage in MySQL workbench
# Application will connect to cleaned data using RSQLite

# Loading packages
library(tools)
library(readr)
library(dplyr)
library(tidyr)
library(tidyverse)
library(chron)


# Reading separated patient files
glu1 <- read.csv("data/PatientGlucose1_10.csv", header = TRUE)
glu2 <- read.csv("data/PatientGlucose11_20.csv", header = TRUE)
glu3 <- read.csv("data/PatientGlucose21_30.csv", header = TRUE)
glu4 <- read.csv("data/PatientGlucose31_40.csv", header = TRUE)
glu5 <- read.csv("data/PatientGlucose41_50.csv", header = TRUE)
glu6 <- read.csv("data/PatientGlucose51_60.csv", header = TRUE)
glu7 <- read.csv("data/PatientGlucose61_70.csv", header = TRUE)
glu_map <- read.csv("data/Code_map.csv", header = TRUE)

# Reviewing import
head(glu1)
head(glu2)
head(glu3)
head(glu4)
head(glu5)
head(glu6)
head(glu7)
head(glu_map)

# Cleaning non-numerical Value data
glu1 <- transform(glu1, Value = as.integer(Value))
glu4 <- transform(glu4, Value = as.integer(Value))
head(glu1)
head(glu4)

# Binding together
glucose <- rbind(glu1, glu2, glu3, glu4, glu5, glu6, glu7)
glucose <- left_join(glucose, glu_map, by = c("Code" = "Code"))

# Transforming Time column into timestamp data and convert to military time
glucose <- transform(glucose, Date = as.Date(Date, "%m/%d/%Y"))
str(glucose)

# Transforming Time column into timestamp data and convert to military time
glucose$Time <- format(as.POSIXct(glucose$Time,format='%I:%M:%S %p'),format="%H:%M:%S")
#glucose$Time <- chron(times=glucose$Time)

# Checking complete cases
summary(glucose)
table(complete.cases(glucose))

# Removing NAs
glucose <- na.omit(glucose)
summary(glucose)

# Write to cleaned glucose csv
write.csv(glucose,file = 'data/patient_glucose_clean.csv', row.names = FALSE)

# Loading glucose data into SQLite
library(RSQLite)
library(DBI)

diabdb <- dbConnect(RSQLite::SQLite(), "diabetes-db.sqlite", extended_types = TRUE)
dbWriteTable(diabdb, "glucose", glucose, overwrite = TRUE)

#Test database load with query
dbGetQuery(diabdb, 'SELECT * FROM glucose LIMIT 5')
head(glucose)
dbGetQuery(diabdb, 'PRAGMA table_info(glucose)')
summary(glucose)
str(glucose)
