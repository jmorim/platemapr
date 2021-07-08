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
                      accept = c(#'text/csv',
                                 #'text/comma-separated-values,text/plain',
                                 '.csv',
                                 '.xlsx',
                                 '.xls')),
            tags$hr(),
            rHandsontableOutput('seq.full')
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
            rHandsontableOutput('contents'),
            column(width = 3,
                   actionButton('add', label = 'add to sequence')),
            rHandsontableOutput('seq.part')
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    platemap = reactive({
        req(input$file)
        read_excel(input$file$datapath, col_names = FALSE)
    })
    
    full.seq = reactiveValues(seq = c('prime'))
    
    output$contents = renderRHandsontable({
#        req(input$file)
#        df = read_excel(input$file$datapath)
        req(platemap())
        rhandsontable(platemap(),
                      readOnly = FALSE,
                      selectCallback = TRUE)
    })
    
#    output$seq.part = renderRHandsontable({
    seq.part = reactive({
        req(input$contents_select$select)
        row.selection = input$contents_select$select$rAll
        col.selection = input$contents_select$select$cAll
        # Iterate through plate and make a list
        listed.plate = c()
        k = 1
        plate.selection = platemap()[row.selection, col.selection]
        for(i in 1:nrow(plate.selection)){
            for(j in 1:ncol(plate.selection)){
                listed.plate[k] = plate.selection[i, j]
                k = k + 1
            }
        }
        return(listed.plate)
        
        # Output handsontable for the list
#        rhandsontable(as.data.frame(unlist(listed.plate)),
#                      colHeaders = 'sequence part',
#                      readOnly = TRUE)
#        
    })
    
    output$seq.part = renderRHandsontable({
        req(seq.part())
        rhandsontable(as.data.frame(unlist(seq.part())),
                      colHeaders = 'sequence part',
                      readOnly = TRUE)
    })
    
    observeEvent(input$add, {
        full.seq$seq = c(full.seq$seq, unlist(seq.part()))
    })
    
    output$seq.full = renderRHandsontable({
#        if (is.null(full.seq$seq)) return(c())
        rhandsontable(as.data.frame(full.seq$seq),
                      colHeaders = 'full sequence',
                      readOnly = TRUE)
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
