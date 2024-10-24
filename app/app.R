library(shiny)
library(shinyWidgets)
library(shinybusy)
library(shinyjs)
library(colourpicker)
library(readxl)
library(glue)
library(rmarkdown)


source("utils/functions.R")

# Define UI for application that draws a histogram
ui <-navbarPage(
  title = actionLink(inputId="title", 
                    tags$div(style='display:flex;gap:8px;align-items:center', shiny::icon("seedling", style='font-size:15px'),
                             tags$div(style='font-size:16px', "Soil Health Reports"))
                    ),
          header = tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
            tags$script(src="script.js"),
            shinyjs::useShinyjs()
          ),
  id = "main_page",
          tabPanel("Home",
                   value = "home",
                   div(class = "bg",
                       div(class = "overlay"),
                       div(class = "content",
                           h1("Soil Health Report", style='font-size:40px'),
                           p("Brought to you by the Washington State Department of Agriculture. Generate reports to analyze your soil health.", style='font-size:20px;'),
                           actionButton("learn_more", "Learn More", class='home-btn'),
                           actionButton("generate_report", "Build Report", class='home-btn')
                       )                   
                   )),
          tabPanel("Learn More", 
                   value = "learn_more",
                   create_hero("Learn More", 'default-hero.png'),
                   tags$div(class='content-p', 
                            tags$p("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus lacinia odio vitae vestibulum vestibulum.")
                   )
                   ),
          tabPanel("Generate Report",
                   value = "generate_report",
                   create_hero("Generate Report", 'default-hero.png'),
                   tags$div(class='slider',
                            create_stepper(
                              list(
                                list(icon = "file-arrow-down"),
                                list(icon = "file-arrow-up"),
                                list(icon = "paint-roller"),
                                list(icon = "file-export")
                              )
                            ),
                            # Glider/Slides for each step
                            create_slides(
                              slides_content <- list(
                                list(
                                  title = "Step 1",
                                  content = tags$div(
                                    tags$p("Specify report type and language setting. Download and fill out template.", style='margin-bottom:20px'),
                                    tags$div(
                                      style = 'display:flex;justify-content:space-between;',
                                      pickerInput(
                                        inputId = "selectReportType",
                                        label = "Report Type", 
                                        choices = c("Soil Health Report")
                                      ),
                                      radioGroupButtons(
                                        inputId = "selectLanguage",
                                        label = "Language",
                                        choices = c("English", "Spanish"),
                                        individual = TRUE,
                                        checkIcon = list(
                                          checkIcon = list(
                                            yes = icon("ok", lib = "glyphicon")
                                          )
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
                                            yes = icon("ok", lib = "glyphicon")
                                          )
                                        )
                                      )
                                    ),
                                    downloadButton('downloadData', 'Download Template')
                                  )
                                ),
                                list(
                                  title = "Step 2",
                                  content = tags$div(
                                    tags$p("Upload and validate data file.", style='margin-bottom:20px'),
                                    fileInput("uploadFile", "Upload Data",
                                              multiple = FALSE,
                                              accept = c("text/xlsx", "text/comma-separated-values,text/plain", ".xlsx")
                                    )
                                  )
                                ),
                                list(
                                  title = "Step 3",
                                  content = tags$div(
                                    tags$p("Customize your report with descriptive text and/or include branded colors.", style='margin-bottom:20px'),
                                    pickerInput(
                                      inputId = "fontOption",
                                      label = "Font", 
                                      choices = c("Poppins", "Roboto", "Arimo", "Josefin Sans", "Barlow Condensed"),
                                      choicesOpt = list(
                                        style = c(
                                          "font-family: Poppins;", 
                                          "font-family: Roboto;", 
                                          "font-family: Arimo;", 
                                          "font-family: 'Josefin Sans';",
                                          "font-family: 'Barlow Condensed';"
                                        )
                                      )
                                    ),
                                    tags$div(
                                      style = 'display:flex;gap:2px;justify-content:space-between;',
                                      colourInput(
                                        inputId = "primaryColor",
                                        label = "Primary Color",
                                        value = "#3DA35D",
                                        showColour = c("both", "text", "background"),
                                        palette = c("square", "limited")
                                      ),
                                      colourInput(
                                        inputId = "secondaryColor",
                                        label = "Secondary Color",
                                        value = "#C5DD6E",
                                        showColour = c("both", "text", "background"),
                                        palette = c("square", "limited")
                                      )
                                    )
                                  )
                                ),
                                list(
                                  title = "Step 4",
                                  content = tags$div(
                                    tags$p("Some text explaining this step in more detail.", style='margin-bottom:20px'),
                                    downloadButton("downloadReport", label = "Generate Report")
                                  )
                                )
                              )
                            )
          )
          )
          
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  observeEvent(input$title, {
    updateNavbarPage(session, "main_page", "home")
  })
  
  observeEvent(input$learn_more, {
    updateNavbarPage(session, "main_page", "learn_more")
  })
  
  observeEvent(input$generate_report, {
    updateNavbarPage(session, "main_page", "generate_report")
  })
  
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
