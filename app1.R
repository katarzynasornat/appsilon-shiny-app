library(shiny)
library(shinyjs) 

source("globals.R")
source("modules/map_module.R")
source("modules/filter_module.R")
source("modules/navbar_module.R")
source("modules/footer_module.R")
source("modules/timeline_module1.R")
source("modules/counterUp_module.R")
source("modules/top_spieces_for_usr_card_module.R")
source("modules/info_panel_module.R")

source("modules/geolocation_module.R")
source("utils/distance_helpers.R")
source("utils/estimate_country.R")
source("utils/cache_blob_data.R")
source("utils/get_data.R")
source("utils/chatgpt.R")

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"),
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/countup.js/2.0.8/countUp.umd.js"),
    tags$script(src = "counterUpHandler.js"),
    tags$script(src = "infoButtonHandler.js"),
    tags$script(src = "geoLocationHandler.js")
  ),
  useShinyjs(), 
  
  navbar_ui("navbar_mod"), 
  
  sidebarLayout(
    sidebarPanel(
      style = "background-color: #e6eefc; padding-bottom: 20px; margin-top: 20px;",
      filter_ui("filter1"),
      info_panel_ui("info_panel1")
    ),
    mainPanel(
      style = "margin-top: 20px;",
      uiOutput("conditional_ui")
    )
  ),
  footer_ui("footer_mod")
)

server <- function(input, output, session) {
  
  user_location <- reactive({
    req(input$user_location)
    input$user_location
  })
  
  user_country <- eventReactive(user_location(), {
    loc <- user_location()
    get_country_from_coords(loc$lon, loc$lat)
  })
  
  user_country_data <- eventReactive(user_country(), {
    country <- user_country()
    open_dataset(paste0("data/tmp/countryCode_partitioned/countryCode=", country, "/")) %>% collect()
  })
  
  top_n_closest_obs <- eventReactive(user_country_data(),{
    loc <- user_location()
    get_closest_species(loc$lon, loc$lat, user_country_data(), top_n = 3)
  })
  
  filter_applied <- reactiveVal(FALSE)
  
  observeEvent(input$`filter1-apply_filter`, {
    filter_applied(TRUE)
  })
  
  tabs <- c("tab1", "tab2", "tab3", "tab4")
  tab_labels <- c("Species on the Map", "Tab 2", "Tab 3", "Tab 4")
  current_tab <- reactiveVal("tab1")
  
  observeEvent(input$`navbar_mod-tab1`, current_tab("tab1"))
  observeEvent(input$`navbar_mod-tab2`, current_tab("tab2"))
  observeEvent(input$`navbar_mod-tab3`, current_tab("tab3"))
  observeEvent(input$`navbar_mod-tab4`, current_tab("tab4"))
  
  navbar_server("navbar_mod", tabs, tab_labels, current_tab)
  
  # Call the filter module
  filter_vals <- filter_server("filter1")
  
  #add other values
  counter_server("counter",
                 total = TOTAL_OBS,
                 unique = 7329,
                 last = DAYS_TO_LAST_OBS)
  
  output$user_location <- renderPrint({
    loc <- user_location()
    paste("Latitude:", loc$lat,
          "\nLongitude:", loc$lon,
          "\nCountry:", user_country(),
          "\nClosest:", get_closest_species(loc$lon, loc$lat, user_country_data(), top_n = 3)
    )
  })
  
  output$top_spieces_for_user_location <- renderDataTable(top_n_closest_obs())
  
  #option to extend tabs for different functionalities
  # output$main_ui <- renderUI({
  #   if(current_tab() == "tab1"){
  #     sidebarLayout(
  #       sidebarPanel(
  #         filter_ui("filter1")
  #       ),
  #       mainPanel(
  #         # h3("Confirmed Selections:"),
  #         # verbatimTextOutput("selected_group"),
  #         # verbatimTextOutput("selected_value"),
  #         
  #         # Conditional UI to show based on whether the filter button has been pressed
  #         uiOutput("conditional_ui")
  #       )
  #     )
  #     
  #   } else {
  #     h2(paste("This is", current_tab()))
  #   }
  # })
  
  
  
  # # Use confirmed values in main app
  # output$selected_group <- renderText({
  #   req(filter_vals$selected_column())
  #   paste("Selected Group:", filter_vals$selected_column())
  # })
  # 
  # output$selected_value <- renderText({
  #   req(filter_vals$selected_value())
  #   paste("Selected Value:", filter_vals$selected_value())
  # })
  # 

  
  # Render conditional UI based on whether the filter button has been pressed
  output$conditional_ui <- renderUI({
    #if (is.null(filter_vals$selected_column()) || is.null(filter_vals$selected_value())) {
    if(!filter_applied()){
      # If button not pressed, show UI_1
      tagList(
        tags$div(
          tags$div(class = "max-w-4xl mx-auto mt-10 px-6",
                   tags$h1(class = "text-4xl font-bold text-center mb-6 text-gray-800", "speX Stats"),
                   counter_ui("counter")),
          tags$div(
            class = "bg-white p-4 rounded mt-20",
            species_card_ui("species_card_mod") 
          )
        )
      )
    } else {
      # If button is pressed, show the chosen values
      tagList(
        tags$div(class = "bg-white shadow-md rounded-xl p-4 max-w-full max-h-[400px] overflow-hidden",
            map_ui("map_mod")
        ),
        tags$div(class = "mt-3 h-100 overflow-y-auto", timeline_ui("timeline_mod"))
        
        #map_ui("map_mod")
        #uiOutput("img_popup")
      )
    }
  })
  
  map_module_server("map_mod", reactive({filter_vals$data()}))
  timeline_server("timeline_mod", reactive({filter_vals$data()}))
  species_card_server("species_card_mod",  top_n_closest_obs)
  
  info_panel_server(
    "info_panel1",
    filter_applied = filter_applied,
    filtered_data = reactive({ filter_vals$data() }),
    selected_column = filter_vals$selected_column,
    selected_value = filter_vals$selected_value,
    fun_facts_fun = get_fun_facts
  )
  
}

shinyApp(ui, server)
