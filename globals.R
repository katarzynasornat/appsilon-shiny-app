# globals.R

# Load libraries used across the app
library(duckdb)
library(DBI)
library(data.table)
library(dplyr)
library(shiny)
library(leaflet)
library(highcharter)
library(shinyjs)
library(glue)
library(arrow)

# === Configuration ===

# Ports
options(shiny.host = "0.0.0.0")
options(shiny.port = 8180)

# Azure storage account and container
AZURE_STORAGE_ACCOUNT <- "shinyappdevdata"
AZURE_CONTAINER <- "biodata"

#docker run -e RUNNING_IN_DOCKER=true your-image
if (Sys.getenv("RUNNING_IN_DOCKER") != "true") {
  # Access the file only when not running in Docker
  path_to_Renviron_file <- ".Renviron"
  readRenviron(path_to_Renviron_file) 
} else {
  # Skip file access or use alternative logic
  message("Running in Docker; skipping file access.")
}


# SAS Tokens (loaded securely from environment variables — set these in .Renviron or Azure App Settings)
AZURE_SAS_TOKEN_OCCURENCE <- Sys.getenv("SPEX_OCCURENCE_SAS_TOKEN")
AZURE_SAS_TOKEN_MULTIMEDIA <- Sys.getenv("SPEX_MULTIMEDIA_SAS_TOKEN")



# === URLs for Parquet Files ===

URL_OCCURRENCE_PARQUET <- glue::glue("https://{AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/{AZURE_CONTAINER}/occurence.parquet?{AZURE_SAS_TOKEN_OCCURENCE}")
URL_MULTIMEDIA_PARQUET <- glue::glue("https://{AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/{AZURE_CONTAINER}/multimedia.parquet?{AZURE_SAS_TOKEN_MULTIMEDIA}")

load("./data/unique_scientific_names.RData")
load("./data/unique_vernacular_names.RData")


# library(conflicted)
# library(duckplyr)
# conflict_prefer("filter", "dplyr", quiet = TRUE)
# 
# db_exec("INSTALL httpfs")
# db_exec("LOAD httpfs")
# 
# duck_tbl <- read_parquet_duckdb(URL_OCCURRENCE_PARQUET)
# data <- duck_tbl 



# === Precompute unique values per column one time when the app starts ===
unique_values_map <- list(
  scientificName = c("", sort(unique_scientific_names)),
  vernacularName = c("", sort(unique_vernacular_names))
)

TOTAL_OBS = length(unique_values_map$scientificName)
UNIQUE_SCIENTIFICNAME = length(unique_values_map$scientificName)
DAYS_TO_LAST_OBS = length(unique_values_map$scientificName)

choices_columns <- c("", "scientificName", "vernacularName")

# === DuckDB Connection ===

# Use an in-memory DuckDB database
# duckdb_con <- dbConnect(duckdb::duckdb(), dbdir = ":memory:")
# dbExecute(duckdb_con, "INSTALL httpfs; LOAD httpfs;")
# dbExecute(duckdb_con, "INSTALL parquet; LOAD parquet;")
