mod_footer_ui <- function(id) {
  ns <- NS(id)

    tags$footer(
      class = "custom-footer",
      tags$div(
        class = "footer-container",
        tags$div(
          class = "footer-nav",
          actionLink(inputId=ns("footer_build_reports"), label = "Build Reports", class = "footer-link"),
          actionLink(inputId=ns("footer_learn_more"),label= "Learn More", class = "footer-link"),
          tags$a(target = "_blank", href="https://arcg.is/1zPbbL1", class = "footer-link", "Report Issue")
        ),
        tags$div(
          class = "footer-social",
          tags$a(target = "_blank", href = "https://agr.wa.gov/departments/land-and-water/natural-resources/soil-health/", class = "footer-icon", span(class = "sr-only", "Site"), icon("globe")),
          tags$a(target = "_blank", href = "mailto:washi@agr.wa.gov", class = "footer-icon", span(class = "sr-only", "Email"), icon("envelope")),
          tags$a(target = "_blank", href = "https://github.com/WA-Department-of-Agriculture/", class = "footer-icon", span(class = "sr-only", "GitHub"), icon("github")),
          tags$a(target = "_blank", href = "https://www.linkedin.com/company/wsdagov/", class = "footer-icon", span(class = "sr-only", "LinkedIn"), icon("linkedin")),
          tags$a(target = "_blank", href = "https://www.facebook.com/WAStateDeptAg/", class = "footer-icon", span(class = "sr-only", "Facebook"), icon("facebook")),
          tags$a(target = "_blank", href = "https://www.instagram.com/WSDAgov/", class = "footer-icon", span(class = "sr-only", "Instagram"), icon("instagram")),
          tags$a(target = "_blank", href = "https://www.youtube.com/user/WSDAgov/", class = "footer-icon", span(class = "sr-only", "Youtube"), icon("youtube")),
        ),
        tags$p(class = "footer-copy", "©2025 Washington State Department of Agriculture. All rights reserved.")
      )
    )
}


mod_footer_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # redirect to Build Reports Page - use rootScope to use parent level ids
    observeEvent(input$footer_build_reports, {
      updateNavbarPage(
        session$rootScope(),
        "main_page",
        selected = "page_build_reports"
      )
    })
    
    # redirect to Learn More Page - use rootScope to use parent level ids
    observeEvent(input$footer_learn_more, {
      updateNavbarPage(
        session$rootScope(),
        "main_page",
        selected = "page_learn_more"
      )
    })
  })
}
