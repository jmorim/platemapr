#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readxl)
library(rhandsontable)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("platemapr"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            fileInput('file',
                      "Input plate map",
                      multiple = FALSE,
                      accept = c('text/csv',
                                 'text/comma-separated-values,text/plain',
                                 '.csv',
                                 'xlsx',
                                 'xls')),
            tags$hr(),
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
            rHandsontableOutput('contents')
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$contents = renderRHandsontable({
        req(input$file)
        df = read_excel(input$file$datapath)
        rhandsontable(df,
                      readOnly = FALSE,
                      selectCallback = TRUE)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
