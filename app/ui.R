library(shiny)
library(shinyWidgets)
library(shinyjs)
library(rmarkdown)
library(zip)
library(readxl)
library(gt)
library(dplyr)
library(readxl)
library(shinybusy)

source("utils/functions.R")
source("utils/data_validation.R")


ui <- navbarPage(
  title = actionLink(inputId="title", 
                     tags$div(style='display:flex;gap:8px;align-items:center', shiny::icon("seedling", style='font-size:15px'),
                              tags$div(class='title-name', style='font-size:16px', "WSDA Soil Health Reports"))
  ),
  windowTitle = "WSDA Soil Health Reports",
  id = "main_page",
  collapsible = TRUE,
  selected = "page_home",
  header = tags$head(
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "scripts.js"),
    shinyjs::useShinyjs()
  ),
  tabPanel("Home",
           value = "page_home",
           div(class = "banner-bg",
               div(class = "banner-overlay"),
               div(class = "banner-content",
                   h1("Soil Health Report", style='font-size:40px'),
                   p(style="color:#acacac;", 
                   "Brought to you by the Washington State Department of Agriculture. Generate reports to analyze your soil health.", style='font-size:20px;'),
                   tags$div(style='display:flex;justify-content:center;gap:20px;width:100%;',
                     actionButton("redirect_learn_more", "Learn More", class='home-btn'),
                     actionButton("redirect_generate_report", "Build Report", class='home-btn')
                   )
               )                   
           )),  
  tabPanel(
    title = "Learn More",
    value = "page_learn_more",
    create_hero("Learn More", 'default-hero.png'),
    div(
      class = "content-container",
      div(
        class = "content",
        id = "content-area",
        includeMarkdown("www/content/learn_more.md") 
      ),
      div(
        class = "toc-scroll",
        id = "toc-container",
        h5("FAQs")
      )
    )
  ),
  tabPanel(
    title = "Generate Reports",
    value = "page_generate_report",
    div(
      class = "container-reports",
      div(
        style = "display:flex",
        # Stepper Section
        div(
          class = "stepper",
          div(class = "step active", id = "step-1", onclick = "setStep(1)", 
              div(class = "step-circle", html('<i class="fas fa-circle"  style="font-size:2rem"></i>')), 
              div(
                div(class = "step-num", "Step 1"),
                div(class = "step-text", "Download Template")
              )
          ),
          div(class = "step", id = "step-2", onclick = "setStep(2)", 
              div(class = "step-circle", shiny::icon("table")), 
              div(
                div(class = "step-num", "Step 2"),
                div(class = "step-text", "Upload Data")
              )
          ),
          div(class = "step", id = "step-3", onclick = "setStep(3)", 
              div(class = "step-circle", shiny::icon("gear")), 
              div(
                div(class = "step-num", "Step 3"),
                div(class = "step-text", "Report Parameters")
              )
          ),
          div(class = "step", id = "step-4", onclick = "setStep(4)", 
              div(class = "step-circle", shiny::icon("file-alt")), 
              div(
                div(class = "step-num", "Step 4"),
                div(class = "step-text", "Generate Report")
              )
          )
        ),
        
        # Form Section
        div(
          class = "form-section",
          tags$a(
            style='width:100%;display:flex;margin-bottom:10px;justify-content:end;', 
            href="https://github.com/WA-Department-of-Agriculture/soil-health-report-generator/issues", 
            target="_blank", 
            "Report Issue"),
          #progress bar for smaller screens
          tags$div(
            class = 'progress-bar-container',
            # Title and Step Number
            tags$div(
              class = 'progress-bar-header',
              tags$span(class = 'progress-title', "Step Progress"),
              tags$span(id = 'progress-step-text', class = 'progress-step-text', "1/4") 
            ),
            
            # Progress Bar
            tags$div(
              class = 'progress-bar-wrapper',
              tags$div(id = 'progress-bar', class = 'progress-bar', style = "width: 25%;") 
            )
          ),
          # Step 1 Content
          div(
            class = "form-content active", id = "form-1",
            h4(class="form-step", "Step 1"),
            h2(class="form-title", "Download Template"),
            p(class="form-text",
            "Select your preferred language for your report output, then download the data template."
            ),
            div(
              class = "language-selection",
              tags$div(
                class = "language-button english",
                id = "englishLang",
                tags$div(
                  class = "language-circle",
                  "EN" # Display "EN" inside the circle
                ),
                tags$span("English", style = "display:block; font-size:14px; font-weight:500; color:#333;")
              ),
              tags$div(
                class = "language-button spanish",
                id = "spanishLang",
                tags$div(
                  class = "language-circle",
                  "ES" # Display "ES" inside the circle
                ),
                tags$span("Spanish", style = "display:block; font-size:14px; font-weight:500; color:#333;")
              )
            ),
            div(style='display:flex;justify-content:center',
                disabled(downloadButton("downloadTemplate", "Download Template", style = "margin-top:20px;width:320px;"))
                ),
            div(class = "buttons", style='justify-content:flex-end;',
                actionButton("next1", "Next", class = "next", disabled = TRUE))
          ),
          
          # Step 2 Content
          div(
            class = "form-content", id = "form-2",
            h4(class="form-step", "Step 2"),
            h2(class="form-title", "Upload Data"),
            p(class="form-text",
            "Upload your completed template below and validate the data."),
            fileInput("upload_file", "Upload Data",
                      multiple = FALSE,
                      accept = c("text/xlsx", "text/comma-separated-values,text/plain", ".xlsx")
            ),
            div(id="error_message"),
            div(class = "buttons",
                actionButton("prev2", "Previous", class = "prev"),
                actionButton("next2", "Next", class = "next", disabled = TRUE))
          ),
          
          # Step 3 Content
          div(
            class = "form-content", id = "form-3",
            h4(class="form-step", "Step 3"),
            h2(class="form-title", "Report Parameters"),
            p(class='form-text', "Select parameters to apply to your reports. A maximum of 5 producer IDs can be selected per report batch."),
            tags$div(class="col-2",
                     selectInput(
                       inputId = "year",
                       label = "Year",
                       choices = NULL, 
                       selected = NULL
                     ),
                     shinyWidgets::pickerInput(
                       inputId = "producer_id",
                       label = "Producer IDs",
                       choices = NULL,
                       options = list(
                         "max-options" = 5,
                         "live-search" = TRUE, 
                         'actions-box' = TRUE,
                         "max-options-text" = "Maximum of 5"
                       ),
                       multiple = TRUE
                     )
            ),
            div(class = "buttons",
                actionButton("prev3", "Previous", class = "prev"),
                actionButton("next3", "Next", class = "next", disabled = TRUE))
          ),
          
          # Step 4 Content
          div(
            class = "form-content", id = "form-4",
            h4(class="form-step", "Step 4"),
            h2(class="form-title","Generate Report"),
            p(class="form-text", "Confirm your preferred report file type, then click below to generate your report."),
            # Output Selection Buttons
            div(
              class = "output-selection",
              tags$div(
                class = "output-button word",
                id = "wordOutput",
                tags$i(class = "fas fa-file-word", style = "font-size:32px; margin-bottom:10px;"),
                tags$span(".docx", style = "display:block; font-size:14px; font-weight:500; color:#333;")
              ),
              tags$div(
                class = "output-button html",
                id = "htmlOutput",
                tags$i(class = "fas fa-file-code", style = "font-size:32px; margin-bottom:10px;"),
                tags$span("HTML", style = "display:block; font-size:14px; font-weight:500; color:#333;")
              )
            ),
            div(class = "buttons",
                actionButton("prev4", "Previous", class = "prev"),
                disabled(downloadButton("report", "Generate", icon=NULL, style='display:flex;align-items:center;'))
                
            )
          )
        )
      )
    )
  ))
