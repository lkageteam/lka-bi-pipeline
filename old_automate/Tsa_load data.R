library(DBI)
library(RMariaDB)
library(readxl)
library(rio)

# Defining file path
file_path_tsa_report <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\TSA REPORTS"

# Listing all CSV files
file_list_tsa_reports <- list.files(path = file_path_tsa_report, pattern = "*.csv", full.names = TRUE)

if (length(file_list_tsa_reports) == 0) {
  stop("No CSV files found in the directory.")
}

# Reading the first file to extract column names
first_file <- read.csv(file_list_tsa_reports[1], stringsAsFactors = FALSE)
first_columns <- colnames(first_file)

# Function to read and filter CSV files
read_and_filter <- function(file, columns) {
  df <- tryCatch({
    df <- read.csv(file, stringsAsFactors = FALSE)
    
    # Retain only common columns
    df <- df[, intersect(names(df), columns), drop = FALSE]
    
    # Add missing columns with NA values
    missing_cols <- setdiff(columns, names(df))
    df[missing_cols] <- NA
    
    return(df)
  }, error = function(e) {
    cat("Error reading file:", file, "-", e$message, "\n")
    NULL
  })
  return(df)
}

# Reading and combining all CSV files into one dataframe
data_list_tsa_reports <- lapply(file_list_tsa_reports, read_and_filter, columns = first_columns)

# Remove NULL entries due to failed reads
data_list_tsa_reports <- Filter(Negate(is.null), data_list_tsa_reports)

if (length(data_list_tsa_reports) > 0) {
  Data_tsa_reports <- do.call(rbind, data_list_tsa_reports)
} else {
  stop("No valid data to combine.")
}

# Standardize column names (replace "." with "_")
colnames(Data_tsa_reports) <- gsub("\\.", "_", colnames(Data_tsa_reports))

# Ensure 'createdAt' exists before processing
if ("createdAt" %in% colnames(Data_tsa_reports)) {
  # Convert 'createdAt' to POSIXct
  Data_tsa_reports$createdAt_POSIX <- as.POSIXct(Data_tsa_reports$createdAt, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
  
  # Extract Date and Time
  Data_tsa_reports$Date <- format(Data_tsa_reports$createdAt_POSIX, "%Y-%m-%d")
  Data_tsa_reports$Time <- format(Data_tsa_reports$createdAt_POSIX, "%H:%M:%S")
  
  # Remove temporary column
  Data_tsa_reports$createdAt_POSIX <- NULL
} else {
  warning("'createdAt' column not found in the dataframe.")
}

#loading Deployment data

file_path_tsa_deployments <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\TSA_Deployments"

# List all CSV files in the directory
file_list_tsa_deployments <- list.files(path = file_path_tsa_deployments, pattern = "*.csv", full.names = TRUE)


# Reading the first file to extract column names
first_file <- read.csv(file_list_tsa_deployments[1], stringsAsFactors = FALSE)
first_columns <- colnames(first_file)

#read and filter

read_and_filter <- function(file, columns) {
  df <- tryCatch({
    df <- read.csv(file, stringsAsFactors = FALSE)
    
    # Retain only common columns
    df <- df[, intersect(names(df), columns), drop = FALSE]
    
    # Add missing columns with NA values
    missing_cols <- setdiff(columns, names(df))
    df[missing_cols] <- NA
    
    return(df)
  }, error = function(e) {
    cat("Error reading file:", file, "-", e$message, "\n")
    NULL
  })
  return(df)
}

# Read and combine all CSV files into one dataframe
data_list_tsa_deployments <- lapply(file_list_tsa_deployments, read_and_filter, columns = first_columns)

# Load all CSVs into a list of dataframes
data_list_tsa_deployments <- Filter(Negate(is.null), data_list_tsa_deployments)

if (length(data_list_tsa_deployments) > 0) {
  Data_tsa_deployments <- do.call(rbind, data_list_tsa_deployments)
} else {
  stop("No valid data to combine.")
}

# Standardize column names (replace "." with "_")

colnames(Data_tsa_deployments) <- gsub("\\.", "_", colnames(Data_tsa_deployments))

if ("createdAt" %in% colnames(Data_tsa_deployments)) {
  
  # Convert 'createdAT' to a POSIXct format for easy splitting
  Data_tsa_deployments$createdAt_POSIX <- as.POSIXct(Data_tsa_deployments$createdAt, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
  
  # Extract Date and Time as new columns
  Data_tsa_deployments$Date <- format(Data_tsa_deployments$createdAt_POSIX, "%Y-%m-%d")
  Data_tsa_deployments$Time <- format(Data_tsa_deployments$createdAt_POSIX, "%H:%M:%S")
  
  # Optional: Remove the intermediate 'createdAT_POSIX' column
  Data_tsa_deployments$createdAt_POSIX <- NULL
} else {
  warning("'createdAt' column not found in the dataframe.")
}


# Connect to MySQL database
conn <- dbConnect(
  MariaDB(),
  user = "root",
  password = "My670552646@", 
  dbname = "TSA_ACTIVITIES", 
  host = "localhost"
)

#loading reports

tryCatch({
  dbWriteTable(conn, name = "TSA_Reports", value = Data_tsa_reports, overwrite = TRUE, row.names = FALSE)
  cat("tsa_report uploaded successfully to MySQL table 'tsa_reports'.\n")
}, error = function(e) {
  cat("Error uploading tsa_reports:", e$message, "\n")
})

#loading deployment data
tryCatch({
  dbWriteTable(conn, name = "TSA_Deployments", value = Data_tsa_deployments, overwrite = TRUE, row.names = FALSE)
  cat("tsa_Deployments uploaded successfully to MySQL table 'tsa_Deployments'.\n")
}, error = function(e) {
  cat("Error uploading tsa_Deployments:", e$message, "\n")
})


#loading numenclature data

#Loading numenclature data to data base

file_path_tsa_numenclature <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\TSA_list\\tsa_list.xlsx"

tsa_numenclature <- import(file_path_tsa_numenclature)

names(tsa_numenclature) <- gsub(" ", "_", names(tsa_numenclature))

tryCatch({
  dbWriteTable(conn, name = "tsa_numenclature", value = tsa_numenclature, overwrite = TRUE, row.names = FALSE)
  cat("tsa_Numenclature uploaded successfully to MySQL table 'tsa_Numenclature'.\n")
}, error = function(e) {
  cat("Error uploading Numenclature:", e$message, "\n")
})

#loading period data to db

file_path_tsa_date <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\TSA_list\\Date.xlsx"

tsa_date <- import(file_path_tsa_date)

tryCatch({
  dbWriteTable(conn, name = "tsa_date", value = tsa_date, overwrite = TRUE, row.names = FALSE)
  cat("tsa_Numenclature uploaded successfully to MySQL table 'tsa_date'.\n")
}, error = function(e) {
  cat("Error uploading Numenclature:", e$message, "\n")
})

#loading Value share data

file_path_value_share <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\TSA data\\Value_Share.xlsx"

value_share_pos <- import(file_path_value_share)

tryCatch({
  dbWriteTable(conn, name = "Value_share_pos", value = value_share, overwrite = TRUE, row.names = FALSE)
  cat("Value_share uploaded successfully to MySQL table 'Value_share'.\n")
}, error = function(e) {
  cat("Error uploading Numenclature:", e$message, "\n")
})


#Data base disconnect

dbDisconnect(conn)
