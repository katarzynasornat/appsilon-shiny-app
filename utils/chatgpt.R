library(shiny)
library(httr)
library(jsonlite)

# Function to call ChatGPT API
get_fun_facts <- function(animal = "horse") {
  openai_api_key <- Sys.getenv("OPENAI_API_KEY")  # Make sure it's set
  
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", openai_api_key)),
    content_type_json(),
    body = toJSON(list(
      model = "gpt-3.5-turbo",
      messages = list(
        list(role = "system", content = "You are a zoologist who loves sharing quirky animal facts."),
        list(role = "user", content = paste0("Give me three fun facts about a ", animal, ". Make them short and playful."))
      ),
      temperature = 0.7
    ), auto_unbox = TRUE)
  )
  
  content <- fromJSON(content(response, "text", encoding = "UTF-8"))
  content$choices$message$content
}
# 
# # Shiny UI
# ui <- fluidPage(
#   titlePanel("Fun Animal Facts with ChatGPT"),
#   sidebarLayout(
#     sidebarPanel(
#       selectInput("animal", "Choose an animal", choices = c("horse", "cat", "dog", "elephant")),
#       actionButton("get_facts", "Get Fun Facts")
#     ),
#     mainPanel(
#       h3("Fun Facts"),
#       verbatimTextOutput("fun_facts")
#     )
#   )
# )
# 
# # Shiny Server
# server <- function(input, output, session) {
#   facts <- eventReactive(input$get_facts, {
#     get_fun_facts(input$animal)
#   })
#   
#   output$fun_facts <- renderText({
#     facts()
#   })
# }
# 
# # Run the app
# shinyApp(ui, server)
