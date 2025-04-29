footer_ui <- function(id) {
  ns <- NS(id)
  # Footer
  tags$div(class = "footer border-t border-gray-300 mb-2 pt-4 px-6 flex justify-between text-gray-500 text-m",
           tags$span(HTML("Created by <strong>SorKa</strong> with ❤️")),
           tags$span("2025")
  )
}

footer_server <- function(id) {
  moduleServer(id, function(input, output, session) {})
}