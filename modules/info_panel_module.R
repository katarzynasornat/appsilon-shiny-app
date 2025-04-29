# modules/info_panel_module.R

info_panel_ui <- function(id) {
  ns <- NS(id)
  
  div(
    id = ns("container"),
    style = "margin-top: 60px;",
    tags$div(
      class = "mt-4 p-6 bg-white rounded shadow-lg",
      uiOutput(ns("instruction_or_stats"))
    )
  )
}

info_panel_server <- function(id, filter_applied, filtered_data, selected_column, selected_value, fun_facts_fun) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # fun_facts <- reactiveVal(NULL)
    # 
    # observeEvent(input$`filter1-apply_filter`, {
    #   req(selected_value())
    #   facts <- fun_facts_fun(selected_value())
    #   fun_facts(facts)
    # })
    
      facts <- eventReactive(selected_value(), {
        get_fun_facts(selected_value())
      })
      
      facts_vector <- eventReactive(facts(), {
        unlist(strsplit(facts(), "###"))
      })

      output$fun_facts <- renderPrint({
        facts()
      })
    
    output$instruction_or_stats <- renderUI({
      if (!filter_applied()) {
        # Show Instructions
        tagList(
          tags$h2(class = "text-2xl font-bold text-gray-700 mb-4", "How to Use This App:"),
          tags$ul(
            class = "list-disc pl-5 space-y-2 text-gray-600",
            tags$li("Allow app to know your location and see what species observed are the closest to you. You may need to refresh the page."),
            tags$li("Select a species group from the dropdown."),
            tags$li("Choose a specific species you want to explore."),
            tags$li("Click the 'Apply Filter' button."),
            tags$li("View species observations and fun facts suggested by ChatGPT!"),
            tags$li("Interact with the map and timeline for deeper insights."),
            tags$li("Each point on the map shows one observation + red circle for coordinate uncertainty.")
          )
        )
      } else {
        req(filtered_data(), selected_column(), selected_value())

        #facts <- fun_facts()
        tagList(
          tags$h2(class = "text-2xl font-bold text-gray-700 mb-4", "Filtered Species Stats"),
          tags$div(class = "grid grid-cols-1 md:grid-cols-3 gap-4",
                   tags$div(class = "bg-blue-50 p-4 rounded shadow",
                            tags$h4(class = "font-semibold text-lg", "Kingdom"),
                            tags$p(class = "text-gray-700", filtered_data()[1,"kingdom"])
                   ),
                   tags$div(class = "bg-blue-50 p-4 rounded shadow",
                            tags$h4(class = "font-semibold text-lg", "Family"),
                            tags$p(class = "text-gray-700", gsub("_", " ", filtered_data()[1,"family"]))
                   ),
                   tags$div(class = "bg-blue-50 p-4 rounded shadow",
                            tags$h4(class = "font-semibold text-lg", "Species Name"),
                            tags$p(class = "text-gray-700", selected_value())
                   ),
          ),
          
          tags$div(class = "mt-6",
                   tags$h3(class = "text-xl font-bold text-gray-800 mb-2", "Fun Facts:"),
                   tags$ul(
                     lapply(facts_vector(), function(fact) {
                       tags$li(fact)
                     })
                   )
          )
        )
      }
    })
  })
}