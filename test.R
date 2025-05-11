# app.R
library(shiny)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),  # Enable shinyjs
  tags$head(
    tags$script(HTML("
      Shiny.addCustomMessageHandler('getTimeZone', function(message) {
        var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
        Shiny.setInputValue('user_timezone', tz);
      });
    "))
  ),
  # Hidden input (automatically created by setInputValue)
  h3("Detected Time Zone:"),
  verbatimTextOutput("tz")
)

server <- function(input, output, session) {
  # Trigger time zone detection after session starts
  observe({
    session$sendCustomMessage("getTimeZone", list())
  })
  
  output$tz <- renderPrint({
    input$user_timezone
  })
}

shinyApp(ui, server)
