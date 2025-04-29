# modules/map_module.R

map_ui <- function(id) {
  ns <- NS(id)
  # tagList(
  #   tags$div(class = "w-1/2 p-4",
  #            leafletOutput(ns("map"), height = "500px"))
  #   # tags$div(class="w-1/2",
  #   #          uiOutput("img_popup"))
  # )
  
  fluidRow(
    style = "height: 600px; overflow: hidden;",
    div(
      class = "col-sm-6",
      style = "height: 100%; overflow: hidden;",
      leafletOutput(ns("map"), height = "100%")
    ),
    div(
      class = "col-sm-6",
      style = "height: 100%; overflow: hidden;",
      uiOutput(ns("img_popup"))
    )
  )
}


map_module_server <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    output$map <- renderLeaflet({
      req(filtered_data())
      leaflet(filtered_data()) %>%
        addTiles() %>%
        addMarkers(
          lng = ~longitudeDecimal, lat = ~latitudeDecimal,
          label = ~paste("Observation ID:", id),
          layerId = ~id,
          options = markerOptions(riseOnHover = TRUE)
        ) %>% addCircles(
          lng = ~longitudeDecimal,
          lat = ~latitudeDecimal,
          radius = ~coordinateUncertaintyInMeters/2, # radius in meters
          color = "red",
          weight = 1,
          fillOpacity = 0.1,
          opacity = 0.5,
          group = "Uncertainty",
          options = pathOptions(pane = "shadowPane"))
    })
    
    # Placeholder for image popup
    output$img_popup <- renderUI({
      NULL
    })
    
    # Observe marker clicks
    observeEvent(input$map_marker_click, {
      click <- input$map_marker_click
      if (is.null(click))
        return()
      
      # Find image URL based on clicked marker ID
      img_url <- filtered_data()$photo_urls[filtered_data()$id == click$id][1]
      
      # Update the UI to show the image or the message
      output$img_popup <- renderUI({
        if (is.na(img_url) || img_url == "") {
          # If no image URL is available, show a message
          tags$div(
            class = "p-4 text-center",
            h4("Image is not available for this observation.")
          )
        } else {
          # If an image URL is available, display the image
          tags$div(
            class = "p-4 text-center",
            img(src = img_url, 
                class = "w-full h-full h-auto object-contain rounded-lg shadow-md"
            )
          )
        }
      })
    })
    
    # Default message when no marker is clicked
    output$img_popup <- renderUI({
      tags$div(
        style = "padding: 10px; color: grey; text-align: center;",
        h4("Click a marker to view image if available")
      )
    })
    
  })
}
