library(shiny)
library(shinyWidgets)
library(shinyjs)
library(rmarkdown)
library(zip)
library(readxl)
library(gt)
library(tidyverse)
library(dplyr)
library(readxl)
library(shinybusy)

source("utils/functions.R")
source("utils/data_validation.R")

#mapping file for english by default
measure_mapping<-read.csv("files/measurement_dictionary.csv")


js <- "
$(document).on('shiny:connected', function() {
  $('.custom-button-group').each(function() {
    let inputId = $(this).attr('id');
    let multi = $(this).data('multi') === true;
    let selectedValues = $(this).data('selected');

    if (typeof selectedValues === 'string') {
      selectedValues = JSON.parse(selectedValues);
    }
    if (!Array.isArray(selectedValues)) {
      selectedValues = [selectedValues];
    }
    
    // Apply 'active' class on load
    selectedValues.forEach(function(val) {
      $(this).find(`.custom-button[data-value='${val}']`).addClass('active');
    }.bind(this));

    // Ensure Shiny receives a properly formatted value
    let initialValue = multi ? selectedValues : (selectedValues.length > 0 ? selectedValues[0] : null);
    if (!multi && initialValue !== null) {
      initialValue = initialValue.toString();  // Ensure it's not wrapped as JSON
    }
    
    Shiny.setInputValue(inputId, initialValue, {priority: 'event'});

    // Attach click event
    $(this).on('click', '.custom-button', function() {
      if (!multi) {
        $(this).siblings().removeClass('active');
      }
      $(this).toggleClass('active');

      let selected = $(this).parent().find('.custom-button.active').map(function() {
        return $(this).data('value');
      }).get();

      if (!multi) {
        selected = selected.length > 0 ? selected[0] : null;
      }

      Shiny.setInputValue(inputId, selected, {priority: 'event'});
    });
  });
});
"

#create measure list choices
measurement_list<-measure_mapping%>%
  split(.$type)%>%
  map(~ setNames(.x$file_name, .x$name))  


ui <- navbarPage(
  title = actionLink(inputId="title", 
                     tags$div(style='display:flex;gap:8px;align-items:center', tags$img(src="pictures/wshi.png", style='height:20px'),
                              tags$div(class='title-name', style='font-size:16px', "Soil Health App"))
  ),
  windowTitle = "WSDA Soil Health Reports",
  id = "main_page",
  collapsible = TRUE,
  selected = "page_generate_report",
  header = tags$head(
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "scripts/toc.js"),
    tags$script(src = "scripts/stepper.js"),
    tags$script(HTML(js)), 
    shinyjs::useShinyjs()
  ),
  tabPanel("Home",
           value = "page_home",
           div(class = "banner-bg",
               div(class = "banner-overlay"),
               div(class = "banner-content",
                   h1("Soil Health Report", style='font-size:40px'),
                   p(style="color:#acacac;", 
                   "Brought to you by the Washington State Department of Agriculture and the Washington Soil Health Initiative. Build custom soil health reports for each participant in your soil sampling project.", style='font-size:20px;'),
                   tags$div(style='display:flex;justify-content:center;gap:20px;width:100%;margin-top:20px',
                     actionButton("redirect_generate_report", "Build Reports", class='home-btn'),
                     actionButton("redirect_learn_more", "Learn More", class='home-btn')
                   )
               )                   
           )),  
  tabPanel(
    title = "Build Reports",
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
                div(class = "step-text", "Build Report")
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
            "Choose a report language. Download the Excel template and replace example data with your own."
            ),
            div(style='width:100%;display:flex;justify-content:center',
                customButtonInput("language", 
                              choices = c("English" = "template.qmd", "Spanish" = "template_esp.qmd"),
                              icons = c("English" = "fas fa-flag-usa", "Spanish" = "fas fa-globe"),
                              multi = FALSE, 
                              selected = "template.qmd")
            ),
            div(style='display:flex;justify-content:center',
                disabled(downloadButton("downloadTemplate", "Download Template", style = "margin-top:20px;width:320px;"))
                ),
            div(class = "buttons", style='justify-content:flex-end;',
                actionButton("next1", "Next", class = "next"))
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
            p(class='form-text', "Customize the report with project-specific information."),
             textAreaInput( 
                "project_summary", 
                "Project Summary Description", 
                value = "Insert text here about your project summary"
              ), 
            virtualSelectInput(
              inputId = "measurement_definitions",
              label = "Include Definitions",
              #created from measurement mapping file- defaults to english qmds
              choices = measurement_list,
              showValueAsTags = TRUE,
              search = TRUE,
              multiple = TRUE
            ),
            textAreaInput( 
              "looking_forward", 
              "Looking Forward", 
              value = "Insert text to add to the look forward section"
            ), 
            div(class = "buttons",
                actionButton("prev3", "Previous", class = "prev"),
                actionButton("next3", "Next", class = "next"))
          ),
          
          # Step 4 Content
          div(
            class = "form-content", id = "form-4",
            h4(class="form-step", "Step 4"),
            h2(class="form-title","Build Report"),
            p(class="form-text", "Automatically build custom reports for all participants. Reports will be generated in a zip file within your Downloads folder."),
            tags$div(class="col-2",
                     selectInput(
                       inputId = "year",
                       label = "Year",
                       choices = NULL, 
                       selected = NULL,
                       multiple = TRUE
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
            # Output Selection Buttons
            div(style='width:100%;display:flex;justify-content:center',
                customButtonInput("format", 
                              choices = c("Word" = "docx", "HTML" = "html"),
                              icons = c("Word" = "fas fa-file-word", "HTML" = "fas fa-file-code"),
                              multi = TRUE, 
                              selected = c("html","docx"))
            ),
            # div(
            #   class = "output-selection",
            #   tags$div(
            #     class = "output-button word",
            #     id = "wordOutput",
            #     tags$i(class = "fas fa-file-word", style = "font-size:32px; margin-bottom:10px;"),
            #     tags$span(".docx", style = "display:block; font-size:14px; font-weight:500; color:#333;")
            #   ),
            #   tags$div(
            #     class = "output-button html",
            #     id = "htmlOutput",
            #     tags$i(class = "fas fa-file-code", style = "font-size:32px; margin-bottom:10px;"),
            #     tags$span("HTML", style = "display:block; font-size:14px; font-weight:500; color:#333;")
            #   )
            # ),
            div(class = "buttons",
                actionButton("prev4", "Previous", class = "prev"),
                disabled(downloadButton("report", "Build", icon=NULL, style='display:flex;align-items:center;'))
                
            )
          )
        )
      )
    )
  ),
  tabPanel(
    title = "Learn More",
    value = "page_learn_more",
    create_hero("Learn More", 'pictures/default-hero.png'),
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
  )
