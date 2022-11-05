library(shiny)

library(markdown)

navbarPage("Diabetes Patient Assistant",     
             
### TABS
# First Panel - About the data
tabPanel(strong("About"),
         fluidPage(
           titlePanel("About")),
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
# Second tab panel - you can demo some visualization
  tabPanel(strong("Daily Blood Sugar Information"),
           fluidPage(
             titlePanel("My Plot")),
           br(),
           hr(),
    sidebarLayout(
      sidebarPanel(
        radioButtons("plotType", "Plot type",
          c("Scatter"="p", "Line"="l")
        )
      ),
      mainPanel(
        
        plotOutput("plot")
      )
    )
  ),

# Third tab panel you can present EDA
  tabPanel(strong("Hospital Information"),
           fluidPage(
             titlePanel("My Summary")),
           br(),
           hr(),
    verbatimTextOutput("summary")
  )

## you can add more tabs, do not forget to add comma to the previous tab if you continue
   
  )

