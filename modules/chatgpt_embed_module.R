funFactsUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(class = "mt-6",
             tags$h3(class = "text-xl font-bold text-gray-800 mb-2", "Fun Facts:"),
             uiOutput(ns("fact_list"))
    )
  )
}

funFactsServer <- function(id, facts) {
  moduleServer(id, function(input, output, session) {
    output$fact_list <- renderUI({
      tags$ul(
        class = "list-decimal pl-6 text-gray-700 space-y-2",
        lapply(facts, tags$li)
      )
    })
  })
}
