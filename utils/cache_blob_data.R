library(stringr)
library(duckdb)
library(AzureStor)
library(data.table)
library(glue)


#previously without pictures urls
# containers_list = c("partitioneddata", "partitioneddatavernacular")
# tmp_directories_names <- c("scientificName_partitioned", "vernacularName_partitioned")
load_data_from_blob_to_tmp <- function(account_url = "https://shinyappdevdata.blob.core.windows.net/"
                                       , account_key = Sys.getenv("SHINYAPPDEVDATA_CONTAINERKEY")
                                       , containers_list = c("scientificp", "vernacularp")
                                       , tmp_directories_names = c("scientificName_part", "vernacularName_part")){
  
  #assuming the same storage account for both
  blob <- storage_endpoint(account_url, account_key)
  
  for (i in seq_along(containers_list)){
    cont <- storage_container(endpoint = blob, name = containers_list[i])
    files <- list_storage_files(container = cont)
    
    storage_multidownload(cont, src=files$name, dest=file.path(paste0("data/tmp/", tmp_directories_names[i]) , files$name))
  }
}


# Define the path for the cached data directory
cache_dir <- "data/tmp/"

# Function to check if the data is cached
is_cached <- function() {
  # Check if the cache directory contains any Parquet files
  any(file.exists(list.files(cache_dir, pattern = "\\.parquet$", recursive = TRUE, full.names = TRUE)))
}

if (!dir.exists(cache_dir)) {
  dir.create(cache_dir)
}

tryCatch({
  load_data_from_blob_to_tmp()
}, error = function(e) {
  message("Looks like there is some issue with writting all partitions data", e$message)
})

tryCatch({
  load_data_from_blob_to_tmp(containers_list = c("countrycodep"), tmp_directories_names = c("countryCode_partitioned"))
}, error = function(e) {
  message("Looks like there is some issue with writting all partitions data", e$message)
})



# account_url = "https://shinyappdevdata.blob.core.windows.net/"
# account_key = Sys.getenv("SHINYAPPDEVDATA_CONTAINERKEY")
# containers_list = c("jpartitioneddata", "jpartitionedvernacular")
# tmp_directories_names = c("j_scientificName_partitioned", "j_vernacularName_partitioned")
# 
# 
# blob <- storage_endpoint(account_url, account_key)
# 
# for (i in seq_along(containers_list)){
#   cont <- storage_container(endpoint = blob, name = containers_list[i])
#   files <- list_storage_files(container = cont)
# 
#   storage_multidownload(cont, src=files$name, dest=file.path(paste0("data/tmp/", tmp_directories_names[i]) , files$name))
# }

