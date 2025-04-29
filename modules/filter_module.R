# modules/filter_module.R

filter_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
          selectInput(ns("column_choice"), "Column", choices = choices_columns ),
          
          selectizeInput(ns("value_choice"), "Choose value:", 
                         choices = NULL,
                         selected = NULL,
                         options = list(placeholder = 'Please select a value',
                                        allowEmptyOption = TRUE)),
          
          actionButton(ns("apply_filter"), "Generate results", 
                       class = "btn btn-primary", 
                       disabled = TRUE),  # Initially disabled
          
          textOutput(ns("error_message")) # Error message output
  )
}

filter_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    # Dummy data
    filtered_data <- reactive({
      req(input$column_choice, input$value_choice)
      
      if(input$column_choice == "scientificName"){
        
        endpoint <- "shinyappdevdata"
        container <- "scientificp"
        sas_token <- Sys.getenv("JPARTITONED_SCIENTIFIC_SAS")
        azure_url <- "https://shinyappdevdata.blob.core.windows.net/scientificp"
        folder_path <- NULL
      } else{
        endpoint <- "shinyappdevdata"
        container <- "vernacularp"
        sas_token <- Sys.getenv("JPARTITONED_VERNACULAR_SAS")
        azure_url <- "https://shinyappdevdata.blob.core.windows.net/vernacularp"
        folder_path <- NULL
      }
      
      
      result_azure <- get_dataset_for_duckdb(filter_column = input$column_choice,
                                             filter_value = input$value_choice,
                                             group_by_columns = c(input$column_choice, "id","eventDate", "latitudeDecimal", "longitudeDecimal", "family", "kingdom", "photo_urls", "coordinateUncertaintyInMeters")
                                             # azure_container_url = azure_url,
                                             # sas_token = sas_token
      )
      
      result_azure$data
      
    })
    
    # Disable second select initially
    observe({
      shinyjs::disable("value_choice")
    })
    
    # Update second select when first select changes
    observeEvent(input$column_choice, {
      req(input$column_choice != "")
      
      updateSelectizeInput(session, "value_choice", 
                           choices = unique_values_map[[input$column_choice]], 
                           selected = "", 
                           server = TRUE)
      
      shinyjs::enable("value_choice")
    }) 
    
    # Create reactiveVals to store confirmed selections
    selected_column <- reactiveVal(NULL)
    selected_value <- reactiveVal(NULL)
    error_message <- reactiveVal(NULL)
    
    # When button is pressed
    observeEvent(input$apply_filter, {
      if (input$column_choice == "" || is.null(input$value_choice) || input$value_choice == "") {
        error_message("Please select both fields before applying the filter.")
      } else {
        selected_column(input$column_choice)
        selected_value(input$value_choice)
        error_message(NULL) # Clear error if ok
      }
    })
    
    # # Output error message
    # output$error_message <- renderText({
    #   req(error_message())
    #   error_message()
    # })
    
    # Enable the filter button only when both inputs are selected
    observe({
      if (input$column_choice != "" && input$value_choice != "") {
        shinyjs::enable("apply_filter")  # Enable the button
      } else {
        shinyjs::disable("apply_filter")  # Keep it disabled if any input is missing
      }
    })
    
    # Expose captured values
    return(list(
      data = filtered_data,
      selected_column = selected_column,
      selected_value = selected_value
    ))
  })
}
