mod_home_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$head(
      tags$style(HTML("
        .banner-bg {
          position: relative;
          background: url('pictures/soil_v2.jpeg') center center / cover no-repeat;
          height: 400px;
          display: flex;
          align-items: center;
          justify-content: center;
          text-align: center;
          color: white;
        }

.banner-overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(5, 8, 8, 0.76);
  z-index: 1;
}
        .banner-content {
          position: relative;
          z-index: 2;
          padding: 20px;
          max-width: 800px;
        }

        .banner-content h1 {
          font-size: 40px;
          margin-bottom: 15px;
        }

        .banner-content p {
          font-size: 18px;
          color: #e4e4e4;
        }

        .home-btn, .secondary-btn {
          font-weight: bold;
          padding: 12px 24px;
          border-radius: 30px;
          border: none;
          cursor: pointer;
          transition: background-color 0.3s ease;
        }

        .home-btn {
          background-color: #FCB040;
          color: black;
        }

        .home-btn:hover {
          background-color: #FCB040;
          color: white;
        }

        .secondary-btn {
          background-color: transparent;
          color: white;
          border: 2px solid white;
        }

        .secondary-btn:hover {
          background-color: white;
          color: #1a1a1a;
        }

        .button-wrapper {
          display: flex;
          justify-content: center;
          flex-wrap: wrap;
          gap: 12px;
          margin-top: 20px;
        }

        .button-wrapper .home-btn,
        .button-wrapper .secondary-btn {
          min-width: 180px;
        }

        @media (max-width: 600px) {
          .button-wrapper {
            flex-direction: column;
            align-items: center;
          }

          .button-wrapper .home-btn,
          .button-wrapper .secondary-btn {
            width: 100%;
            max-width: 280px;
          }

          .button-wrapper .home-btn {
            margin-bottom: 10px;
          }

          .button-wrapper .secondary-btn {
            margin-bottom: 0;
          }
        }

        .steps-section {
          background-color: #f4f4f4;
          padding: 40px;
          padding-bottom:80px;
          text-align: center;
        }

        .steps-section h2 {
          font-size: 28px;
          font-weight: bold;
        }

        .steps-grid {
          display: grid;
          gap: 30px;
          max-width: 1000px;
          margin: 0 auto;
        }

        @media (min-width: 800px) {
          .steps-grid {
            grid-template-columns: repeat(4, 1fr);
          }
        }

        @media (min-width: 640px) and (max-width: 799px) {
          .steps-grid {
            grid-template-columns: repeat(2, 1fr);
          }
        }

        @media (max-width: 639px) {
          .steps-grid {
            grid-template-columns: 1fr;
          }
        }

        .step-card {
          background: white;
          padding: 30px;
          border-radius: 10px;
          box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }

        .step-icon {
          font-size: 32px;
          color: #023B2C;
          margin-bottom: 15px;
        }

        .step-card h3 {
          font-size: 18px;
          font-weight: bold;
          margin-bottom: 10px;
        }

        .step-card p {
          font-size: 14px;
          color: #555;
        }
      "))
    ),
    
    # Banner Section
    tags$div(
      class = "banner-bg",
      tags$div(class = "banner-overlay"),
      tags$div(
        class = "banner-content",
        h1("DIRT DATA REPORTS"),
        p(style = 'padding:0px 20px', "Brought to you by the Washington State Department of Agriculture and the Washington Soil Health Initiative. Build custom soil health reports for each participant in your soil sampling project in four steps."),
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
    tags$div(
      class = "steps-section",
      h2("HOW IT WORKS"),
      p(style='margin-bottom:40px', "Generate reports about your soil health in 4 simple steps"),
      tags$div(
        class = "steps-grid",
        tags$div(
          class = "step-card",
          tags$div(class = "step-icon", tags$i(class = "fas fa-download")),
          h3("Step 1"),
          p("Download the Excel template. Replace example data with your own.")
        ),
        tags$div(
          class = "step-card",
          tags$div(class = "step-icon", tags$i(class = "fas fa-table")),
          h3("Step 2"),
          p("Upload and validate your data file.")
        ),
        tags$div(
          class = "step-card",
          tags$div(class = "step-icon", tags$i(class = "fas fa-cog")),
          h3("Step 3"),
          p("Customize with project-specific information.")
        ),
        tags$div(
          class = "step-card",
          tags$div(class = "step-icon", tags$i(class = "fas fa-file-alt")),
          h3("Step 4"),
          p("Generate custom reports for all participants.")
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
