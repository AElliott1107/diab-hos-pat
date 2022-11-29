library(shiny)
library(markdown)
library(shinythemes)

navbarPage(title = "Diabetes Patient Assistant", theme = shinytheme("cerulean"),     
             
### TABS
# First Panel - About the data - Still need to complete this page!
tabPanel(strong("Home"),
         fluidPage(
           titlePanel("Home Page")),
         br(),
         hr(),
         fluidRow(
           column(6,
                  includeMarkdown("about.md")
           ),
           column(3,
                  img(class="img-polaroid",
                      src=paste0("http://upload.wikimedia.org/",
                                 "wikipedia/commons/9/92/",
                                 "1919_Ford_Model_T_Highboy_Coupe.jpg")),
                  tags$small(
                    "Source: Photographed at the Bay State Antique ",
                    "Automobile Club's July 10, 2005 show at the ",
                    "Endicott Estate in Dedham, MA by ",
                    a(href="http://commons.wikimedia.org/wiki/User:Sfoskett",
                      "User:Sfoskett")
                  )
           )
         )
),
# Second tab panel - Blood Glucose Data
  tabPanel(strong("Blood Glucose Data"),
           fluidPage(
             titlePanel("Daily Blood Sugar Information")),
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
      ),
      mainPanel(
        plotOutput("gluPlot")
      )
    )
  ),

# Third tab panel Hospital Information
  tabPanel(strong("Hospital Information"),
           fluidPage(
             titlePanel("My Summary")),
           br(),
           hr(),
    verbatimTextOutput("summary")
  )

## you can add more tabs, do not forget to add comma to the previous tab if you continue
   
  )

