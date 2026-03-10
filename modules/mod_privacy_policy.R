mod_privacy_policy_ui <- function(id) {
  ns <- NS(id)
  tagList(
    create_hero("Privacy Policy", "pictures/default-hero.png"),
    div(
      class = "content-container",
      div(
        class = "content",
        id = "content-area",
        # to modify content for Privacy Policy please edit the markdown file
        includeMarkdown("www/content/privacy_policy.md")
      )
    )
  )
}

mod_privacy_policy_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # No server-side logic needed
  })
}
