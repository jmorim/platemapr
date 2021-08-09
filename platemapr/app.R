# TODO
# [ ] Add column for sample location
# [ ] Add 'select all and copy' button
# [X] Add reset button
# [ ] Add equilibration sequence option (inj/loc = 3)
# [?] Copy and paste to blank plate map by default
# [ ] Make readxl column data types strings
# [ ] Scale platemap with window


library(shiny)
library(readxl)
library(rhandsontable)

ui <- fluidPage(

    # Application title
    titlePanel("platemapr"),

    sidebarLayout(
        # Sidebar --------------------------------------------------------------
        sidebarPanel(
            # File button ------------------------------------------------------
            fileInput('file',
                      "Input plate map",
                      multiple = FALSE,
                      accept = c('.csv',
                                 '.xlsx',
                                 '.xls')),
            # hline ------------------------------------------------------------
            tags$hr(),
            # reset button -----------------------------------------------------
            actionButton('reset',
                         'reset',),
            # full seq table ---------------------------------------------------
            rHandsontableOutput('seq.full')
        ),

        # main panel -----------------------------------------------------------
        mainPanel(
            # add button -------------------------------------------------------
            column(width = 3,
                   actionButton('add', label = 'add to sequence')),
            # platemap ---------------------------------------------------------
            rHandsontableOutput('contents'),
            # partial sequence from selection ----------------------------------
            rHandsontableOutput('seq.part')
        )
    )
)

server <- function(input, output) {
    # reactive var platemap from file input ------------------------------------
    platemap = reactive({
        req(input$file)
        read_excel(input$file$datapath, col_names = FALSE)
    })
    
    # default sequence with prime entry ----------------------------------------
    full.seq = reactiveValues(seq = c('prime'))
    
    # output table from reactive var -------------------------------------------
    output$contents = renderRHandsontable({
        req(platemap())
        rhandsontable(platemap(),
                      readOnly = FALSE,
                      selectCallback = TRUE)
    })
    
    # generate reactive value partial seq from selection -----------------------
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
    })
    
    # make table from partial seq ----------------------------------------------
    output$seq.part = renderRHandsontable({
        req(seq.part())
        rhandsontable(as.data.frame(unlist(seq.part())),
                      colHeaders = 'sequence part',
                      readOnly = TRUE)
    })
    
    # when add button used, add partial seq to full seq ------------------------
    observeEvent(input$add, {
        full.seq$seq = c(full.seq$seq, unlist(seq.part()))
    })
    
    # when reset button used, set full seq back to default ---------------------
    observeEvent(input$reset, {
        full.seq$seq = c('prime')
    })
    
    # generate table for full seq object ---------------------------------------
    output$seq.full = renderRHandsontable({
        rhandsontable(as.data.frame(full.seq$seq),
                      colHeaders = 'full sequence',
                      readOnly = TRUE)
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
