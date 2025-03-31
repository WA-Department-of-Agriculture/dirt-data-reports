mod_home_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Banner Section
    tags$div(
      class = "banner-bg",
      tags$div(class = "banner-overlay"),
      tags$div(
        class = "banner-content",
        h1("DIRT DATA REPORTS"),
        p(style = 'padding:0px 20px', "Generate customized soil health reports for your sampling project. Brought to you by the Washington State Department of Agriculture and the Washington Soil Health Initiative."),
        tags$div(
          class = "button-wrapper",
          actionButton(
            ns("redirect_build_reports"),
            label = tagList(tags$i(class = "fas fa-seedling"), " Build Reports"),
            class = "home-btn"
          ),
          actionButton(
            ns("redirect_learn_more"),
            label = "Learn More",
            class = "secondary-btn"
          )
        )
      )
    ),
    
    # Steps Section
    tags$section(
      class = "section-block section-light",
      tags$div(class="section-header", 
        h2("HOW IT WORKS"),
        p("Build custom soil health reports for each participant in your soil sampling project in four steps")
      ),
      tags$div(
        class = "steps-grid",
        tags$div(
          class = "step-card",
          tags$div(class = "step-icon", tags$i(class = "fas fa-download")),
          h3("Step 1"),
          HTML("<p><b>Download</b> the Excel template. Replace example data with your own.</p>")
        ),
        tags$div(
          class = "step-card",
          tags$div(class = "step-icon", tags$i(class = "fas fa-table")),
          h3("Step 2"),
          HTML("<p><b>Upload</b> and validate your data file.</p>")
        ),
        tags$div(
          class = "step-card",
          tags$div(class = "step-icon", tags$i(class = "fas fa-cog")),
          h3("Step 3"),
          HTML("<p><b>Customize</b> with project-specific information.</p>")
        ),
        tags$div(
          class = "step-card",
          tags$div(class = "step-icon", tags$i(class = "fas fa-file-alt")),
          h3("Step 4"),
          HTML("<p><b>Build</b> custom reports for all participants.</p>")
        )
      )
    ),
    tags$section(
      class="section-block",
      tags$div(class='section-header', 
               h2("ABOUT THE REPORTS")
      ),
      tags$div(class='col-2', style='gap:40px!important',
          tags$div(
            HTML("<p style='text-align:left!important;font-size:18px!important;'>Soil Health Reports summarize key indicators from your soil samples to help you better understand <b>biological</b>, <b>chemical</b>, and <b>physical</b> soil properties. Each report compares participant results to other samples in your project and interprets results using benchmarks grounded in soil health research. These reports are designed to be clear, customizable, and informative—whether you're a grower, researcher, or educator.</p>")
            ),
          tags$div(
                   tags$img(style='width:100%;min-width:300px;', src="pictures/report-example.png")
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
