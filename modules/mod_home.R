mod_home_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "banner-bg",
      tags$div(class = "banner-overlay"),
      tags$div(
        class = "banner-content",
        h1("Soil Health Report", style = "font-size:40px"),
        p(
          style = "color:#c4c2c2;",
          "Brought to you by the Washington State Department of Agriculture and the Washington Soil Health Initiative. Build custom soil health reports for each participant in your soil sampling project in four steps.",
          style = "font-size:20px;"
        ),
        img(
          width = "100%",
          src = "content/steps.png",
          alt = "Step 1: Download the Excel template & replace example data with your own. Step 2: Upload and validate your data file. Step 3: Customize with project-specific information. Step 4: Generate custom reports for all participants."
        ),
        tags$div(
          style = "display:flex;justify-content:center;gap:20px;width:100%;margin-top:20px",
          actionButton(
            ns("redirect_build_reports"),
            "Build Reports",
            class = "home-btn"
          ),
          actionButton(
            ns("redirect_learn_more"),
            "Learn More",
            class = "home-btn"
          ),
        )
      )
    )
  )
}

mod_home_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # redirect to Build Reports Page - use rootScope to use parent level ids
    observeEvent(input$redirect_build_reports, {
      updateNavbarPage(
        session$rootScope(),
        "main_page",
        selected = "page_build_reports"
      )
    })

    # redirect to Learn More Page - use rootScope to use parent level ids
    observeEvent(input$redirect_learn_more, {
      updateNavbarPage(
        session$rootScope(),
        "main_page",
        selected = "page_learn_more"
      )
    })
  })
}
