library(shiny)
library(markdown)
library(shinythemes)

navbarPage(title = "Diabetes Patient Assistant", theme = shinytheme("cerulean"),     
             
### TABS
# First Panel - About the data - Still need to complete this page!
tabPanel(strong("Home"),
         fluidPage(
           titlePanel("Welcome to the Diabetes Patient Assisstant")),
         br(),
         hr(),
         fluidRow(
           column(6,
                  wellPanel(includeMarkdown("about.md"))
           ),
           column(3,
                  img(class="img-polaroid",
                      src=paste0("https://upload.wikimedia.org/wikipedia/commons/5/52/Prevalence_of_Diabetes_by_Percent_of_Country_Population_%282014%29_Gradient_Map.png")),
                  tags$small(
                    "Walter Scott WilkensUniversity of Illinois - Urbana Champaign Department of Geography and GIScience, CC BY-SA 4.0 ",a(href="https://creativecommons.org/licenses/by-sa/4.0"," via Wikimedia Commons")
                  )
           )
         )
),
# Second tab panel - Blood Glucose Data
  tabPanel(strong("Blood Glucose Data"),
           fluidPage(
             titlePanel("Daily Blood Sugar Information"),
             br(),
             hr(),
             sidebarLayout(
               sidebarPanel(
                 dateRangeInput(
                   inputId = "date_range",
                   label = "Date Range:",
                   start = "1988-01-01",
                   end = "1992-01-01"
                 ),
                 selectInput(
                   inputId = 'code_type',
                   label = 'Measurement Category:',
                   choices = c('All' = 1, 'Breakfast' = 2, 'Lunch' = 3, 'Dinner' = 4, 
                               'Pre Meal' = 5, 'Post Meal' = 6, 'Miscellaneous' = 7),
                   selected = 'All'
                 ),
               ),
               mainPanel(
                 plotOutput("gluPlot")
               )
             )
             )
  ),

# Third tab panel Hospital Information
  tabPanel(strong("Hospital Information"),
           fluidPage(
             titlePanel("Hospital Patient Summary"),
             br(),
             hr(),
             fluidRow(
               align = 'center',
               column(
                width = 3,
                plotOutput('agePlot')
               ),
               column(
                 width = 3,
                 plotOutput('genderPlot')
               ),
               column(
                 width = 6,
                 plotOutput('timeHist')
               )
             ),
             fluidRow(
               align = 'center',
               column(
                 width = 2,
                 wellPanel(numericInput("meds", "Number of Medications:", 1, min = 0, max = 80))
               ),
               column(
                 width = 5,
                 plotOutput('medsPlot')
               ),
               column(
                 width = 5,
                 plotOutput('dtreePlot')
               )
             )
          )
    )
)

