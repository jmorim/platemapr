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
            rHandsontableOutput('contents'),
            rHandsontableOutput('seq')
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    platemap = reactive({
        req(input$file)
        read_excel(input$file$datapath, col_names = FALSE)
    })
    
    output$contents = renderRHandsontable({
#        req(input$file)
#        df = read_excel(input$file$datapath)
        req(platemap())
        rhandsontable(platemap(),
                      readOnly = FALSE,
                      selectCallback = TRUE)
    })
    
    output$seq = renderRHandsontable({
        req(input$contents_select$select)
        row.selection = input$contents_select$select$rAll
        col.selection = input$contents_select$select$cAll
#        rhandsontable(platemap()[row.selection, col.selection],
#                      readOnly = FALSE,
#                      selectCallback = TRUE)
        rhandsontable(unlist(platemap()[row.selection, col.selection]),
                      readOnly = FALSE,
                      selectCallback = TRUE)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
