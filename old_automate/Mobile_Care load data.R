library(DBI)
library(RMariaDB)
library(readxl)
library(rio)

file_path_mcare_report <- "E:\\2025\\Data\\Mobile Care"

# List all CSV files in the directory
file_list_mcare_reports <- list.files(path = file_path_mcare_report, pattern = "*.csv", full.names = TRUE)

# Read and combine all CSV files into one dataframe
data_list_mcare_reports <- lapply(file_list_mcare_reports, function(file) {
  tryCatch({
    
    dfrename <- read.csv(file)
    
    return(dfrename)
    
  }, error = function(e) {
    cat("Error reading file:", file, "-", e$message, "\n")
    NULL
    
  })
})

# Load all CSVs into a list of dataframes
if (length(data_list_mcare_reports) > 0) {
  Data_mcare_reports <- do.call(rbind, data_list_mcare_reports) 
} else {
  stop("No Valid data to combine.") 
} # Combine all dataframes into one dataframe

#Ensuring 'Data' is not NULL or empty before filtering

colnames(Data_mcare_reports) <- gsub("\\.", "_", colnames(Data_mcare_reports))

if ("createdAt" %in% colnames(Data_mcare_reports)) {
  
  # Convert 'createdAT' to a POSIXct format for easy splitting
  Data_mcare_reports$createdAt_POSIX <- as.POSIXct(Data_mcare_reports$createdAt, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
  
  # Extract Date and Time as new columns
  Data_mcare_reports$Date <- format(Data_mcare_reports$createdAt_POSIX, "%Y-%m-%d")
  Data_mcare_reports$Time <- format(Data_mcare_reports$createdAt_POSIX, "%H:%M:%S")
  
  # Optional: Remove the intermediate 'createdAT_POSIX' column
  Data_mcare_reports$createdAt_POSIX <- NULL
} else {
  warning("'createdAt' column not found in the dataframe.")
}

# Connect to MySQL database
conn <- dbConnect(
  MariaDB(),
  user = "root",
  password = "My670552646@", 
  dbname = "MOBILE_CARE", 
  host = "localhost"
)

#loading reports

tryCatch({
  dbWriteTable(conn, name = "MCare_Reports", value = Data_mcare_reports, overwrite = TRUE, row.names = FALSE)
  cat("MCare_report uploaded successfully to MySQL table 'MCare_reports'.\n")
}, error = function(e) {
  cat("Error uploading tsa_reports:", e$message, "\n")
})

#loading Value share data

file_path_Mobile_care_agents <- "E:\\2025\\Data\\Mobile Care\\Agent List\\Mobile-care Agents.xlsx"

Mobile_care_agents <- import(file_path_Mobile_care_agents)

file_path_Mobile_care_agents_Old <- "E:\\2025\\Data\\Mobile Care\\Agent List\\Mobile-care Agents-Old.xlsx"

Mobile_care_agents_Old <- import(file_path_Mobile_care_agents_Old)

tryCatch({
  dbWriteTable(conn, name = "Mobile_care_agents_Old", value = Mobile_care_agents_Old, overwrite = TRUE, row.names = FALSE)
  cat("Mobile_care_agents uploaded successfully to MySQL table 'Mobile_care_agents'.\n")
}, error = function(e) {
  cat("Error uploading Numenclature:", e$message, "\n")
})

tryCatch({
  dbWriteTable(conn, name = "Mobile_care_agents", value = Mobile_care_agents, overwrite = TRUE, row.names = FALSE)
  cat("Mobile_care_agents uploaded successfully to MySQL table 'Mobile_care_agents'.\n")
}, error = function(e) {
  cat("Error uploading Numenclature:", e$message, "\n")
})

#loading Value share data

file_path_Mobile_care_Date <- "E:\\2025\\Data\\Mobile Care\\Agent List\\Date.xlsx"

Mobile_care_Date <- import(file_path_Mobile_care_Date)

tryCatch({
  dbWriteTable(conn, name = "Mobile_care_Date", value = Mobile_care_Date, overwrite = TRUE, row.names = FALSE)
  cat("Mobile_care_Date uploaded successfully to MySQL table 'Mobile_care_Date'.\n")
}, error = function(e) {
  cat("Error uploading Numenclature:", e$message, "\n")
})


dbDisconnect(conn)