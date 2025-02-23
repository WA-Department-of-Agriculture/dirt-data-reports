library(shiny)
library(shinyWidgets)
library(tidyverse)
library(glue)

# Sample measurement_mapping data frame
measure_mapping <- data.frame(
  type = c("Category A", "Category A", "Category B", "Category B"),
  name = c("Measure 1", "Measure 2", "Measure 3", "Measure 4"),
  file_name = c("measure1.csv", "measure2.csv", "measure3.csv", "measure4.csv"),
  aliases = c("Alias A1, Alias A2", "Alias A3", "Alias B1, Alias B2", "Alias B3"),
  stringsAsFactors = FALSE
) %>%
  mutate(content = glue("<div>{name}</div><span style='display:none'>{aliases}</span>"))

# Prepare grouped choices
measurement_list <- measure_mapping %>%
  split(.$type) %>%
  map(~ setNames(.x$file_name, .x$name))

# Prepare content list, keeping the same structure
measurement_content <- measure_mapping %>%
  split(.$type) %>%
  map(~ .x$content)

# Shiny App
ui <- fluidPage(
  titlePanel("ShinyWidgets PickerInput Example"),
  
  sidebarLayout(
    sidebarPanel(
      pickerInput(
        inputId = "measurement_definitions",
        label = "Include Definitions",
        choices = measurement_list,
        choicesOpt = list(content = unlist(measurement_content, recursive = FALSE)),
        options = list(
          "live-search" = TRUE, 
          "actions-box" = TRUE
        ),
        multiple = TRUE
      ),
      actionButton("submit", "Submit")
    ),
    
    mainPanel(
      h3("Selected Measurements"),
      verbatimTextOutput("selected_measures")
    )
  )
)

server <- function(input, output, session) {
    output$selected_measures <- renderPrint({
      input$measurement_definitions
    })
}

shinyApp(ui, server)
