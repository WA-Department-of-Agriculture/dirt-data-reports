library(shiny)
library(shinyWidgets)
library(shinybusy)
library(shinyjs)
library(colourpicker)
library(readxl)
library(glue)
library(rmarkdown)

# Define UI for application that draws a histogram
ui <-navbarPage(tags$div(style='display:flex;gap:8px;align-items:center', shiny::icon("seedling", style='font-size:15px'),
tags$div(style='font-size:16px', "Soil Health Reports")),
          header = tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
            tags$script(src="script.js"),
            shinyjs::useShinyjs()
          ),
          tabPanel("Generate Report",
                   tags$div(style='padding:20px 40px;margin-bottom:20px',
                     tags$h1("Report Generator"),
                     tags$p("Follow the steps below to generate your report")
                   ),
                   tags$div(class='slider',
                            tags$div(class='steplist',
                                     tags$div(
                                       class='step-part',
                                       tags$button(id='step1', class='step-button active', 
                                                   tags$span(shiny::icon("file-arrow-down")), 
                                                   onclick = "activateSteps(1)"),
                                       tags$div(class='step-divider')
                                     ),
                                     tags$div(
                                       class='step-part',
                                       tags$button(id='step2', class='step-button', 
                                                   tags$span(shiny::icon("file-arrow-up")), 
                                                   onclick = "activateSteps(2)"),
                                       tags$div(class='step-divider')
                                     ),
                                     tags$div(
                                       class='step-part',
                                       tags$button(id='step3', class='step-button', 
                                                   tags$span(shiny::icon("paint-roller")), 
                                                   onclick = "activateSteps(3)"),
                                       tags$div(class='step-divider')
                                     ),
                                     tags$div(
                                       class='step-part-l',
                                       tags$button(id='step4', class='step-button', 
                                                   tags$span(shiny::icon("file-export")), 
                                                   onclick = "activateSteps(4)")
                                     )
                            ),
                            # Glider/Slides for each step
                            tags$div(class='slides',
                                     tags$div(id='slide1', class='slide active-slide', 
                                              tags$div(class='slide-container',
                                                tags$h3(class='slide-title', "Step 1"),
                                                tags$div(class='slide-content',
                                                         tags$p("Specify report type and language setting. Download and fill out template.", style='margin-bottom:20px'),
                                                         tags$div(style='display:flex;justify-content:space-between',
                                                                  pickerInput(
                                                                    inputId = "selectReportType",
                                                                    label = "Report Type", 
                                                                    choices = c("Soil Health Report"),
                                                                  ),
                                                                  radioGroupButtons(
                                                                     inputId = "selectLanguage",
                                                                     label = "Language",
                                                                     choices = c("English", "Spanish"),
                                                                     individual = TRUE,
                                                                     checkIcon = list(
                                                                       checkIcon = list(
                                                                         yes = icon("ok", 
                                                                                    lib = "glyphicon"))
                                                                     )
                                                                   ),
                                                                   radioGroupButtons(
                                                                     inputId = "selectOutputType",
                                                                     label = "Report Type",
                                                                     choices = c("Word", "HTML"),
                                                                     selected = 'HTML',
                                                                     individual = TRUE,
                                                                     checkIcon = list(
                                                                       checkIcon = list(
                                                                         yes = icon("ok", 
                                                                                    lib = "glyphicon"))
                                                                     )
                                                                   )
                                                         ),
                                                         downloadButton('downloadData', 'Download Template')
                                                )
                                              ),
                                              tags$div(class='slider-button', style="display:flex;justify-content:end;margin-top: 20px",
                                                tags$button(id='next1', class='next-button', "Next", onclick="nextSlide(2)")
                                              )
                                     ),
                                     tags$div(id='slide2', class='slide', 
                                              tags$div(class='slide-container',
                                                       tags$h3(class='slide-title', "Step 2"),
                                                       tags$div(class='slide-content',
                                                                tags$p("Upload and validate data file.", style='margin-bottom:20px'),
                                                                fileInput("uploadFile", "Upload Data",
                                                                          multiple = FALSE,
                                                                          accept = c("text/xlsx",
                                                                                     "text/comma-separated-values,text/plain",
                                                                                     ".xlsx"))
                                                                
                                                                )
                                              ),
                                              tags$div(class='slider-buttons',
                                              tags$button(id='prev3', class='prev-button', "Previous", onclick="activateSteps(1)"),
                                              tags$button(id='next3', class='next-button', "Next", onclick="nextSlide(3)")
                                              )
                                     ),
                                     tags$div(id='slide3', class='slide', 
                                              tags$div(class='slide-container',
                                                       tags$h3(class='slide-title', "Step 3"),
                                                       tags$div(class='slide-content',
                                                                tags$p("Customize your report with descriptive text and/or include branded colors.", style='margin-bottom:20px'),
                                                                pickerInput(
                                                                  inputId = "fontOption",
                                                                  label = "Font", 
                                                                  choices = c("Poppins", "Roboto", "Arimo", "Josefin Sans", "Barlow Condensed"),
                                                                  choicesOpt = list(
                                                                    style = c("font-family: Poppins;", 
                                                                              "font-family: Roboto;", 
                                                                              "font-family: Arimo;", 
                                                                              "font-family: 'Josefin Sans';",
                                                                              "font-family: 'Barlow Condensed';"))
                                                                ),
                                                                tags$div(style='display:flex;gap:2px;justify-content:space-between;',
                                                                    colourpicker::colourInput(
                                                                    "primaryColor",
                                                                    "Primary Color",
                                                                    value = "#3DA35D",
                                                                    showColour = c("both", "text", "background"),
                                                                    palette = c("square", "limited")
                                                                  ),
                                                                  colourpicker::colourInput(
                                                                    "secondaryColor",
                                                                    "Secondary Color",
                                                                    value = "#C5DD6E",
                                                                    showColour = c("both", "text", "background"),
                                                                    palette = c("square", "limited")
                                                                  )
                                                                )
                                                                )
                                              ),
                                              tags$div(class='slider-buttons',
                                              tags$button(id='prev4', class='prev-button', "Previous", onclick="activateSteps(2)"),
                                              tags$button(id='next4', class='next-button', "Next", onclick="nextSlide(4)")
                                              )
                                     ),
                                     tags$div(id='slide4', class='slide', 
                                              tags$div(class='slide-container',
                                                       tags$h3(class='slide-title', "Step 4"),
                                                       tags$div(class='slide-content',
                                                                tags$p("Some text explaining this step in more detail.", style='margin-bottom:20px'),
                                                                downloadButton("downloadReport", label="Generate Report")
                                                                
                                                       )
                                              ),
                                              tags$div(class='slider-buttons',
                                              tags$button(id='prev5', class='prev-button', "Previous", onclick="activateSteps(3)")
                                              )
                                     )
                            ),
          )
          ),
        tabPanel("Guide"),
        tabPanel("About")
          
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  #template file download
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("template-", Sys.Date(), ".xlsx", sep = "")
    },
    content = function(file) {
      file.copy("files/template.xlsx", file)
    }
  )
  
  rmd <- reactive({
    if(input$selectOutputType == 'Word'){'report.Rmd'}
    else if(input$selectOutputType == 'HTML'){'report_html.Rmd'}
  })
  
  filename_label <- reactive({
    if(input$selectOutputType == 'Word'){'report_doc.docx'}
    else if(input$selectOutputType == 'HTML'){'report_html.html'}
  })
  
  output$downloadReport <- downloadHandler(
    filename = filename_label(),
    
    content = function(file) {
      
      shinybusy::show_modal_spinner(
        spin='dots',
        color = '#047857',
        text='Generating Report...'
      )
      
      tempReport <- file.path(tempdir(), rmd())
      
      file.copy(rmd(), tempReport, overwrite = TRUE)
      
      rmarkdown::render(tempReport, output_file = file,
                        envir = new.env(parent = globalenv())
      )
      
      shinybusy::remove_modal_spinner()
      
      
    }
  )
  
  output$uploadMessage <- renderUI({
    req(input$uploadFile) # Make sure the file is uploaded
    
    # Read the sheet names from the uploaded Excel file
    sheet_names <- excel_sheets(input$uploadFile$datapath)
    
    # Check if "Data" and "Data Dictionary" are present
    required_sheets <- c("Data", "Data Dictionary")
    missing_sheets <- setdiff(required_sheets, sheet_names)
    
    if (length(missing_sheets) == 0) {
      message1<-"Data and Data Dictionary in Workbook"
    } else {
      message1<-paste("Missing sheets:", paste(missing_sheets, collapse = ", "))
    }
    
    return(message1)
  })

  #modal popup for file upload
  observeEvent(input$uploadFile, {
    showModal(modalDialog(
      title = "Uploading File",
      uiOutput("uploadMessage"),
      easyClose = TRUE,
      footer = NULL
    ))
  })
  
  
  # observe({
  #   if (!is.null(input$uploadFile)) {
  #     shinyjs::enable("downloadReport")
  #   } else {
  #     shinyjs::disable("downloadReport")
  #   }
  # })


}

# Run the application 
shinyApp(ui = ui, server = server)
