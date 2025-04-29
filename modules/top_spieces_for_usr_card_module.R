# modules/species_card_module.R

species_card_ui <- function(id) {
  ns <- NS(id)
  
  # UI Output for the species card
  uiOutput(ns("species_card"))
}

species_card_server <- function(id, species_data) {
  moduleServer(id, function(input, output, session) {
    
    output$species_card <- renderUI({
      req(species_data())
      
      # Take the first species (or you could make this dynamic later)
      first_species <- head(species_data(), 1)
      
      if (nrow(first_species) == 0) {
        return(NULL)
      }
      
      tags$div(
        class = "bg-white shadow-lg hover:shadow-2xl transition-shadow duration-300 rounded-lg overflow-hidden w-full max-w-5xl mx-auto my-6", 
        tags$div(
          class = "md:flex",
          tags$div(
            class = "md:flex-shrink-0",
            tags$img(
              src = "https://cdn.britannica.com/67/115367-050-1CC3D8A6/White-wagtail.jpg",
              class = "h-80 w-full object-cover md:w-1/2"
            )
          ),
          tags$div(
            class = "p-8",
            tags$h2(
              class = "uppercase tracking-wide text-lg text-blue-700 font-semibold",
              first_species$family
            ),
            tags$h1(
              class = "block mt-1 text-4xl leading-tight font-bold text-black",
              first_species$scientificName
            ),
            tags$p(
              class = "mt-4 text-xl text-gray-500",
              first_species$vernacularName
            )
          )
        )
      )
      
    })
    
  })
}
