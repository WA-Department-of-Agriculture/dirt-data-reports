mod_footer_ui <- function(id) {
  ns <- NS(id)

    tags$footer(
      class = "custom-footer",
      tags$div(
        class = "footer-container",
        tags$div(
          class = "footer-nav",
          actionLink(inputId=ns("footer_learn_more"),label= "Learn More", class = "footer-link"),
          actionLink(inputId=ns("footer_build_reports"), label = "Build Reports", class = "footer-link"),
          a(class = "footer-link", "Report Issue")
        ),
        tags$div(
          class = "footer-social",
          tags$a(href = "mailto:example@domain.com", class = "footer-icon", span(class = "sr-only", "Email"), icon("envelope")),
          tags$a(href = "https://github.com", class = "footer-icon", span(class = "sr-only", "GitHub"), icon("github")),
          tags$a(href = "https://facebook.com", class = "footer-icon", span(class = "sr-only", "Facebook"), icon("facebook")),
          tags$a(href = "https://linkedin.com", class = "footer-icon", span(class = "sr-only", "LinkedIn"), icon("linkedin"))
        ),
        tags$p(class = "footer-copy", "\u00A9 2024 Created by Washington Department of Agriculture")
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
