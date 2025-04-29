library(stringr)
library(duckdb)
library(AzureStor)
library(data.table)
library(glue)


# endpoint <- "shinyappdevdata"
# container <- "partitioneddata"
# sas_token <- Sys.getenv("PARTITIONED_DATA_SAS_TOKEN")
# azure_url <- "https://shinyappdevdata.blob.core.windows.net/partitioneddata"


get_dataset_for_duckdb <- function(folder_path = "data/tmp/",
                                   group_by_columns = c("eventDate", "country"),
                                   filter_column = "scientificName", 
                                   filter_value = "PARUS MAJOR",
                                   azure_container_url = NULL, 
                                   sas_token = NULL) {
  time_start <- Sys.time()
  
  conn <- dbConnect(duckdb())
  dbExecute(conn, "INSTALL httpfs;")
  dbExecute(conn, "LOAD httpfs;")
  
  # If using Azure Blob Storage
  if (!is.null(azure_container_url) && !is.null(sas_token)) {
    # Construct the full Azure Blob Storage URL to the Parquet file
    partition_indicator <- substr(toupper(filter_value), 1, 1)
    parquet_path <- paste0(azure_container_url, "/first_letter_", filter_column, "=", partition_indicator, "/part-0.parquet", sas_token)
  } else {
    # Default local path
    partition_indicator <- substr(toupper(filter_value), 1, 1)
    parquet_path <- paste0(folder_path, filter_column, "_part/first_letter_",filter_column,"=", partition_indicator, "/part-0.parquet")
    #parquet_path <- paste0(folder_path, filter_column, "_partitioned/first_letter_",filter_column,"=", partition_indicator, "/part-0.parquet")
  }
  
  group_by_clause <- paste(group_by_columns, collapse = ", ")
  
  # Construct the DuckDB query
  duck_query <- str_interp("
  SELECT ${group_by_clause}, SUM(individualCount) AS individualCount
  FROM parquet_scan('${parquet_path}')
  WHERE ${filter_column} = '${filter_value}'
  GROUP BY ${group_by_clause}")
  
  # Connect to DuckDB and execute the query
  res <- dbGetQuery(conn, duck_query)
  dbDisconnect(conn)
  time_end <- Sys.time()
  
  return(list(
    data = res,
    runtime = as.numeric(time_end - time_start)
  ))
}




# endpoint <- "shinyappdevdata"
# container <- "partitioneddata"
# sas_token <- Sys.getenv("PARTITIONED_DATA_SAS_TOKEN")
# azure_url <- "https://shinyappdevdata.blob.core.windows.net/partitioneddata"
# 
# 
# result_azure <- get_dataset_for_duckdb(filter_column = "scientificName",
#                                        filter_value = "PARUS MAJOR",
#                                        group_by_columns = c("scientificName", "eventDate", "latitudeDecimal", "longitudeDecimal"),
#                                        azure_container_url = azure_url,
#                                        sas_token = sas_token
# )
# 
# result_azure <- get_dataset_for_duckdb(
#   filter_value = "PARUS MAJOR",
#   group_by_columns = c("eventDate", "latitudeDecimal", "longitudeDecimal")
# )

# result_azure <- get_dataset_for_duckdb(
#   scientificName_value = "PARUS MAJOR",
#   group_by_columns = c("eventDate", "latitudeDecimal", "longitudeDecimal"),
#   azure_container_url = azure_url,
#   sas_token = sas_token
# )