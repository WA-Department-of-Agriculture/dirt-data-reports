# Load packages and modules
source("global.R")

ui <- navbarPage(
  title = actionLink(
    inputId = "title",
    tags$div(
      style = "display:flex;gap:8px;align-items:center",
      tags$img(
        src = "pictures/wshi.png",
        style = "height:20px"
      ),
      tags$div(
        class = "title-name",
        style = "font-size:16px",
        "Dirt Data Reports"
      )
    )
  ),
  windowTitle = "Soil Health Reports",
  id = "main_page",
  collapsible = TRUE,
  selected = "page_home",
  header = tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css"
    ),
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "styles.css"
    ),
    tags$link(
      rel = "shortcut icon",
      href = "pictures/wshi.png"
    ),
    tags$script(src = "scripts/toc.js"),
    tags$script(src = "scripts/stepper.js"),
    shinyjs::useShinyjs(),
    sever::useSever()
  ),
  tabPanel(
    title = "Home",
    value = "page_home",
    mod_home_ui("home")
  ),
  tabPanel(
    title = "Build Reports",
    value = "page_build_reports",
    mod_build_reports_ui("build")
  ),
  tabPanel(
    title = "Learn More",
    value = "page_learn_more",
    mod_learn_more_ui("learn")
  ),
  mod_footer_ui("footer") # Add the footer here
)

server <- function(input, output, session) {
  
  #when app disconnects, sever message
  sever::sever(
    html = sever_default(
      title = "Pause", 
      subtitle = "You've been inactive for too long. Click reload to refresh page.", 
      button = "Reload", 
      button_class = "default"), 
    bg_color = "#023B2C"
  )
  
  mod_home_server("home")
  mod_build_reports_server("build")
  mod_learn_more_server("learn")
  

  # Redirect when logo/title is clicked
  observeEvent(input$title, {
    updateNavbarPage(session, "main_page", selected = "page_home")
  })
}

shinyApp(ui, server)
