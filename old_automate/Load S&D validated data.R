library(DBI)
library(RMariaDB)
library(rio)
library(openxlsx)
library(readxl)


conn <- dbConnect(
  MariaDB(),
  user = "root",
  password = "My670552646@", 
  dbname = "BRAND_SOLDIER_ACTIVITIES", 
  host = "localhost"
)

file_path_SnD_Valid <- "E:\\2025\\Data\\Brand Ambassadors\\S&D_VALID"
file_list_SnD_Valid <- list.files(path = file_path_SnD_Valid, pattern = "^[^~].*\\.xlsx$", full.names = TRUE)

if (length(file_list_SnD_Valid) == 0) {
  cat("No valid Excel files found in the directory. Process aborted.\n")
} else {
  # Read Excel files
  data_list_SnD_Valid <- lapply(file_list_SnD_Valid, function(file) {
    tryCatch({
      dfrename <- read.xlsx(file)
      
      if ("DAYNUMBER" %in% colnames(dfrename)) {
        dfrename$DAYNUMBER <- as.Date(dfrename$DAYNUMBER, origin = "1899-12-30")
    }  
      return(dfrename)
    }, error = function(e) {
      cat("Error reading file:", file, "-", e$message, "\n")
      NULL
    })
  })
  
  # Remove NULL values
  data_list_SnD_Valid <- Filter(Negate(is.null), data_list_SnD_Valid)
  
  if (length(data_list_SnD_Valid) > 0) {
    SnD_Valid <- do.call(rbind, data_list_SnD_Valid)
    
    # Clean column names
    colnames(SnD_Valid) <- gsub("[ .]", "_", colnames(SnD_Valid))
    
    colnames(SnD_Valid) <- make.unique(colnames(SnD_Valid), sep = "_")
    
    if ("DAYNUMBER" %in% colnames(SnD_Valid)) {
      SnD_Valid$DAYNUMBER <- format(SnD_Valid$DAYNUMBER, "%Y-%m-%d")  # Ensure MySQL date format
    }
    
    # Check database connection
    if (!dbIsValid(conn)) {
      cat("Database connection is not valid.\n")
      return()
    }
    
    # Upload to MySQL
    tryCatch({
      dbWriteTable(conn, name = "SnD_Valid", value = SnD_Valid, overwrite = TRUE, row.names = FALSE)
      cat("SnD_Valid uploaded successfully to MySQL table 'S&D_Valid'.\n")
    }, error = function(e) {
      cat("Error uploading SnD_Valid:", e$message, "\n")
    })
  } else {
    cat("No valid data frames to combine.\n")
  }
}

dbDisconnect(conn)
