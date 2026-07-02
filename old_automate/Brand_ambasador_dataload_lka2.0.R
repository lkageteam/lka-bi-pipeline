install.packages("DBI")
install.packages("RMariaDB")
install.packages("readxl")
install.packages("rio")
install.packages("openxlsx")

library(DBI)
library(RMariaDB)
library(rio)
library(openxlsx)
library(readxl)

# Defining File path

file_path_Vente_sim <- "E:\\2025\\Data\\Brand Ambassadors\\VENTE_SIM_PRO2"

# List all CSV files in the directory
file_list_vente_sim <- list.files(path = file_path_Vente_sim, pattern = "*.csv", full.names = TRUE)

if(length(file_list_vente_sim)==0) {
  stop("No CSV files found in the directory")
}

read_and_align <- function(file){
  tryCatch({
    df <-read.csv(file, stringsAsFactors = FALSE)
    
    #Normalize column names
    colnames(df) <- gsub("\\.","_", colnames(df))
    
    #merge badge number typos into userinfo_numerobadge
    badge_cols <- grep("numeroB[ae]?g[de]?", colnames(df), ignore.case = TRUE, value = TRUE)
    if (length(badge_cols) > 0) {
      df$userInfo_numeroBadge <- apply(df[, badge_cols, drop = FALSE], 1, function(x) {
        x <- x[!is.na(x) & x != ""]
        if (length(x) > 0) x[1] else NA
      })
      df <- df[, !(colnames(df) %in% badge_cols)]
    }
    return(df)
  }, error = function(e) {
    cat("Error reading file:", file, "-", e$message, "\n")
    return(NULL)
  })
}


# Read and combine all CSV files into one dataframe
data_list_vente_sim <- lapply(file_list_vente_sim, read_and_align)
data_list_vente_sim <- Filter(Negate(is.null), data_list_vente_sim)

if(length(data_list_vente_sim)==0){
  stop("No valid data to combine")
}
# set template for column names using the columns in the first file
first_columns <- colnames(data_list_vente_sim[[1]])

# Align all dataframes to the template
data_list_vente_sim <- lapply(data_list_vente_sim, function(df){
  missing_cols <- setdiff(first_columns, colnames(df))
  if (length(missing_cols)>0) df[missing_cols] <- NA
  df <- df[, first_columns, drop = FALSE]
  return(df)
})

#combine data

Data_vente_sim <- do.call(rbind, data_list_vente_sim) 

# converting UTC dates to standard dates

if ("createdAt" %in% colnames(Data_vente_sim)) {
  
  # Convert 'createdAT' to a POSIXct format for easy splitting
  Data_vente_sim$createdAt_POSIX <- as.POSIXct(Data_vente_sim$createdAt, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
  
  
  # Extract Date and Time as new columns
  Data_vente_sim$Date <- format(Data_vente_sim$createdAt_POSIX, "%Y-%m-%d")
  Data_vente_sim$Time <- format(Data_vente_sim$createdAt_POSIX, "%H:%M:%S")
  
  # Optional: Remove the intermediate 'createdAT_POSIX' column
  Data_vente_sim$createdAt_POSIX <- NULL
} else {
  warning("'createdAt' column not found in the dataframe.")
}
  
# Ensure 'Data' is not NULL or empty before filtering
if (!is.null(Data_vente_sim) && nrow(Data_vente_sim) > 0) {
  # Filter rows where 'numero.vendu' is at least 8 characters long
  # and remove duplicates
  if ("numSim" %in% colnames(Data_vente_sim)) {
    Data_vente_sim <- Data_vente_sim[nchar(as.character(Data_vente_sim$numSim)) >= 8, ]  # Filter rows
    Data_vente_sim <- Data_vente_sim[!duplicated(Data_vente_sim$numSim), ]              # Remove duplicates
  } else {
    stop("Column 'numSim' not found in the Data_vente_sim.")
  }
} else {
  stop("No valid data after combining.")
}



#loading DTC_Exisiting data


# setting file directory

file_path_DTC_Existing <- "E:\\2025\\Data\\Brand Ambassadors\\DTC_PRO"

# List all CSV files in the directory
file_list_DTC_Existing <- list.files(path = file_path_DTC_Existing, pattern = "*.csv", full.names = TRUE)

if(length(file_list_DTC_Existing)==0){
  stop("No CSV files found in the directory.")
}
#function to handle badge typos and aligment

# Function to handle badge typos and alignment
read_and_align <- function(file) {
  tryCatch({
    df <- read.csv(file, stringsAsFactors = FALSE)
    
    # Normalize column names
    colnames(df) <- gsub("\\.", "_", colnames(df))
    
    # Merge badge number typos into userInfo_numeroBadge
    badge_cols <- grep("numeroB[ae]?g[de]?", colnames(df), ignore.case = TRUE, value = TRUE)
    if (length(badge_cols) > 0) {
      df$userInfo_numeroBadge <- apply(df[, badge_cols, drop = FALSE], 1, function(x) {
        x <- x[!is.na(x) & x != ""]
        if (length(x) > 0) x[1] else NA
      })
      df <- df[, !(colnames(df) %in% badge_cols)]
    }
    
    return(df)
  }, error = function(e) {
    cat("Error reading file:", file, "-", e$message, "\n")
    return(NULL)
  })
}

data_list_DTC_Existing <- lapply(file_list_DTC_Existing, read_and_align)
data_list_DTC_Existing <- Filter(Negate(is.null), data_list_DTC_Existing)

if(length(data_list_DTC_Existing)==0){
  stop("No valid data to combine.")
}

#set column name template from first file in directory

first_columns <- colnames(data_list_DTC_Existing[[1]])

# Align all dataframes to the template
data_list_DTC_Existing <- lapply(data_list_DTC_Existing, function(df) {
  missing_cols <- setdiff(first_columns, colnames(df))
  if (length(missing_cols) > 0) df[missing_cols] <- NA
  df <- df[, first_columns, drop = FALSE]
  return(df)
})


# combine all CSV files into one dataframe

  Data_DTC_Existing <- do.call(rbind, data_list_DTC_Existing) 

# converting UTC dates to standard dates

if ("createdAt" %in% colnames(Data_DTC_Existing)) {
  
  # Convert 'createdAT' to a POSIXct format for easy splitting
  Data_DTC_Existing$createdAt_POSIX <- as.POSIXct(Data_DTC_Existing$createdAt, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
  
  
  # Extract Date and Time as new columns
  Data_DTC_Existing$Date <- format(Data_DTC_Existing$createdAt_POSIX, "%Y-%m-%d")
  Data_DTC_Existing$Time <- format(Data_DTC_Existing$createdAt_POSIX, "%H:%M:%S")
  
  # Optional: Remove the intermediate 'createdAT_POSIX' column
  Data_Ayoba$createdAt_POSIX <- NULL
} else {
  warning("'createdAt' column not found in the dataframe.")
}

# Ensure 'Data' is not NULL or empty before filtering
if (!is.null(Data_DTC_Existing) && nrow(Data_DTC_Existing) > 0) {
  # Filter rows where 'numero.vendu' is at least 8 characters long
  # and remove duplicates
  if ("numClient" %in% colnames(Data_DTC_Existing)) {
    Data_DTC_Existing <- Data_DTC_Existing[nchar(as.character(Data_DTC_Existing$numClient)) >= 8, ]  # Filter rows
    Data_DTC_Existing <- Data_DTC_Existing[!duplicated(Data_DTC_Existing$numClient), ]              # Remove duplicates
  } else {
    stop("Column 'numClient' not found in the Data_DTC_Existing.")
  }
} else {
  stop("No valid data after combining.")
}


#Loading AYOBA data to data frame



file_path_Ayoba <- "E:\\2025\\Data\\Brand Ambassadors\\AYOBA_PRO"

# List all CSV files in the directory
file_list_Ayoba <- list.files(path = file_path_Ayoba, pattern = "*.csv", full.names = TRUE)

# Read and combine all CSV files into one dataframe
data_list_Ayoba <- lapply(file_list_Ayoba, function(file) {
  tryCatch({
    
    dfrename <- read.csv(file)
    
    return(dfrename)
    
  }, error = function(e) {
    cat("Error reading file:", file, "-", e$message, "\n")
    NULL
    
  })
})
# Load all CSVs into a list of dataframes
if (length(data_list_Ayoba) > 0) {
  Data_Ayoba <- do.call(rbind, data_list_Ayoba) 
} else {
  stop("No Valid data to combine.") 
} # Combine all dataframes into one dataframe
#Ensuring 'Data' is not NULL or empty before filtering

colnames(Data_Ayoba) <- gsub("\\.", "_", colnames(Data_Ayoba))

#Date converstion

if ("createdAt" %in% colnames(Data_Ayoba)) {
  
  # Convert 'createdAT' to a POSIXct format for easy splitting
  Data_Ayoba$createdAt_POSIX <- as.POSIXct(Data_Ayoba$createdAt, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
  
  
  # Extract Date and Time as new columns
  Data_Ayoba$Date <- format(Data_Ayoba$createdAt_POSIX, "%Y-%m-%d")
  Data_Ayoba$Time <- format(Data_Ayoba$createdAt_POSIX, "%H:%M:%S")
  
  # Optional: Remove the intermediate 'createdAT_POSIX' column
  Data_Ayoba$createdAt_POSIX <- NULL
} else {
  warning("'createdAt' column not found in the dataframe.")
}

# Ensure 'Data' is not NULL or empty before filtering
if (!is.null(Data_Ayoba) && nrow(Data_Ayoba) > 0) {
  # Filter rows where 'numero.vendu' is at least 8 characters long
  # and remove duplicates
  if ("numClient" %in% colnames(Data_Ayoba)) {
    Data_Ayoba <- Data_Ayoba[nchar(as.character(Data_Ayoba$numClient)) >= 8, ]  # Filter rows
    Data_Ayoba <- Data_Ayoba[!duplicated(Data_Ayoba$numClient), ]              # Remove duplicates
  } else {
    stop("Column 'Contact_abonné' not found in the Data_Ayoba.")
  }
} else {
  stop("No valid data after combining.")
}


#Loading MAJ data to data frame


file_path_MAJ <- "E:\\2025\\Data\\Brand Ambassadors\\MAJ"

# List all CSV files in the directory
file_list_MAJ <- list.files(path = file_path_MAJ, pattern = "*.csv", full.names = TRUE)

# Read and combine all CSV files into one dataframe
data_list_MAJ <- lapply(file_list_MAJ, function(file) {
  tryCatch({
    
    dfrename <- read.csv(file)
    
    return(dfrename)
    
  }, error = function(e) {
    cat("Error reading file:", file, "-", e$message, "\n")
    NULL
    
  })
})
# Load all CSVs into a list of dataframes
if (length(data_list_MAJ) > 0) {
  Data_MAJ <- do.call(rbind, data_list_MAJ) 
} else {
  stop("No Valid data to combine.") 
} # Combine all dataframes into one dataframe
#Ensuring 'Data' is not NULL or empty before filtering

colnames(Data_MAJ) <- gsub("\\.", "_", colnames(Data_MAJ))

# Ensure 'Data' is not NULL or empty before filtering
if (!is.null(Data_MAJ) && nrow(Data_MAJ) > 0) {
  # Filter rows where 'numero.vendu' is at least 8 characters long
  # and remove duplicates
  if ("Contact_abonné" %in% colnames(Data_MAJ)) {
    Data_MAJ <- Data_MAJ[nchar(as.character(Data_MAJ$Contact_abonné)) >= 8, ]  # Filter rows
    Data_MAJ <- Data_MAJ[!duplicated(Data_MAJ$Contact_abonné), ]              # Remove duplicates
  } else {
    stop("Column 'Contact_abonné' not found in the Data_MAJ.")
  }
} else {
  stop("No valid data after combining.")
}



#loading MTN_Hype data to dataframe

file_path_MTN_Hype <- "E:\\2025\\Data\\Brand Ambassadors\\MTN_HYPE_PRO2"
file_list_MTN_Hype <- list.files(path = file_path_MTN_Hype, pattern = "*.csv", full.names = TRUE)

if (length(file_list_MTN_Hype) == 0) {
  stop("No CSV files found in the directory.")
}

# Function to handle badge typos and alignment
read_and_align <- function(file) {
  tryCatch({
    df <- read.csv(file, stringsAsFactors = FALSE)
    
    # Normalize column names
    colnames(df) <- gsub("\\.", "_", colnames(df))
    
    # Merge badge number typos into userInfo_numeroBadge
    badge_cols <- grep("numeroB[ae]?g[de]?", colnames(df), ignore.case = TRUE, value = TRUE)
    if (length(badge_cols) > 0) {
      df$userInfo_numeroBadge <- apply(df[, badge_cols, drop = FALSE], 1, function(x) {
        x <- x[!is.na(x) & x != ""]
        if (length(x) > 0) x[1] else NA
      })
      df <- df[, !(colnames(df) %in% badge_cols)]
    }
    
    return(df)
  }, error = function(e) {
    cat("Error reading file:", file, "-", e$message, "\n")
    return(NULL)
  })
}

# Read all files
data_list_MTN_Hype <- lapply(file_list_MTN_Hype, read_and_align)
data_list_MTN_Hype <- Filter(Negate(is.null), data_list_MTN_Hype)

if (length(data_list_MTN_Hype) == 0) {
  stop("No valid data to combine.")
}

# Set template from first valid file
first_columns <- colnames(data_list_MTN_Hype[[1]])

# Align all dataframes to the template
data_list_MTN_Hype <- lapply(data_list_MTN_Hype, function(df) {
  missing_cols <- setdiff(first_columns, colnames(df))
  if (length(missing_cols) > 0) df[missing_cols] <- NA
  df <- df[, first_columns, drop = FALSE]
  return(df)
})

# Combine data
Data_MTN_Hype <- do.call(rbind, data_list_MTN_Hype)

# Process createdAt and filtering (same as before)
if ("createdAt" %in% colnames(Data_MTN_Hype)) {
  Data_MTN_Hype$createdAt_POSIX <- as.POSIXct(Data_MTN_Hype$createdAt, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
  Data_MTN_Hype$Date <- format(Data_MTN_Hype$createdAt_POSIX, "%Y-%m-%d")
  Data_MTN_Hype$Time <- format(Data_MTN_Hype$createdAt_POSIX, "%H:%M:%S")
  Data_MTN_Hype$createdAt_POSIX <- NULL
} else {
  warning("'createdAt' column not found.")
}

if ("numClient" %in% colnames(Data_MTN_Hype) && nrow(Data_MTN_Hype) > 0) {
  valid_nums <- nchar(as.character(Data_MTN_Hype$numClient)) >= 8
  Data_MTN_Hype <- Data_MTN_Hype[valid_nums, ]
  Data_MTN_Hype <- Data_MTN_Hype[!duplicated(Data_MTN_Hype$numClient), ]
} else {
  stop("Column 'numClient' not found or data is empty.")
} 


#Loading Numeclature and Date_period parameter data




# Connect to MySQL database
conn <- dbConnect(
  MariaDB(),
  user = "root",
  password = "My670552646@", 
  dbname = "BRAND_SOLDIER_ACTIVITIES", 
  host = "localhost"
)

# Upload the all combined dataframes to MySQL

tryCatch({
  dbWriteTable(conn, name = "VENTE_SIM", value = Data_vente_sim, overwrite = TRUE, row.names = FALSE)
  cat("Data_vente_sim uploaded successfully to MySQL table 'VENTE_SIM'.\n")
}, error = function(e) {
  cat("Error uploading Data_vente_sim:", e$message, "\n")
})

tryCatch({
  dbWriteTable(conn, name = "DTC_EXISITING", value = Data_DTC_Existing, overwrite = TRUE, row.names = FALSE)
  cat("Data_vente_sim uploaded successfully to MySQL table 'DTC_EXISTING'.\n")
}, error = function(e) {
  cat("Error uploading DTC_Exisiting:", e$message, "\n")
})

tryCatch({
  dbWriteTable(conn, name = "AYOBA", value = Data_Ayoba, overwrite = TRUE, row.names = FALSE)
  cat("Data_vente_sim uploaded successfully to MySQL table 'AYOBA'.\n")
}, error = function(e) {
  cat("Error uploading Ayoba:", e$message, "\n")
})

tryCatch({
  dbWriteTable(conn, name = "MAJ", value = Data_MAJ, overwrite = TRUE, row.names = FALSE)
  cat("Data_MAJ uploaded successfully to MySQL table 'MAJ'.\n")
}, error = function(e) {
  cat("Error uploading Mise a jour:", e$message, "\n")
})

tryCatch({
  dbWriteTable(conn, name = "MTN_HYPE", value = Data_MTN_Hype, overwrite = TRUE, row.names = FALSE)
  cat("Data_MTN_HYPE uploaded successfully to MySQL table 'MTN HYPE'.\n")
}, error = function(e) {
  cat("Error uploading MTN Hype:", e$message, "\n")
})

# Correct file path (this should point to a directory, not a file)
file_path_NewAdd <- "E:\\2025\\Data\\Brand Ambassadors\\Valide By user"

# Get list of .xlsx files in the directory
file_list_NewAdd <- list.files(path = file_path_NewAdd, pattern = "\\.xlsx$", full.names = TRUE)

# Read each file safely into a list
data_list_NewAdd <- lapply(file_list_NewAdd, function(file) {
  tryCatch({
    dfrename <- read.xlsx(file)
    return(dfrename)
  }, error = function(e) {
    cat("Error reading file:", file, "-", e$message, "\n")
    NULL
  })
})

# Combine data if any valid data frames are read
if (length(data_list_NewAdd) > 0 && any(sapply(data_list_NewAdd, is.data.frame))) {
  NewAdd <- do.call(rbind, data_list_NewAdd)
} else {
  stop("No valid data to combine.")
}

tryCatch({
  dbWriteTable(conn, name = "NewAdd", value = NewAdd, overwrite = TRUE, row.names = FALSE)
  cat("Newadd uploaded successfully to MySQL table 'Newadd'.\n")
}, error = function(e) {
  cat("Error uploading NewAdd:", e$message, "\n")
})

#Loading numenclature data to data base

cat("Importing Excel file...\n")

file_path_Numenclature <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\BS Data file\\BASE BA LKA.xlsx"

Numenclature <- import(file_path_Numenclature)

cat("Writing to database...\n")
  
  tryCatch({
    dbWriteTable(conn, name = "Numenclature", value = Numenclature, overwrite = TRUE, row.names = FALSE)
    cat("Numenclature uploaded successfully to MySQL table 'Numenclature'.\n")
}, error = function(e) {
    cat("Error uploading Numenclature:", e$message, "\n")
})

cat("Importing Excel file...\n")

file_path_Supervisor_list <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\BS Data file\\SUPERVISEUR BA LKA.xlsx"

Supervisor_list <- import(file_path_Supervisor_list)

cat("Writing to database...\n")

tryCatch({
  dbWriteTable(conn, name = "Supervisor_list", value = Supervisor_list, overwrite = TRUE, row.names = FALSE)
  cat("Numenclature uploaded successfully to MySQL table 'Supervisor_list'.\n")
}, error = function(e) {
  cat("Error uploading Supervisor_list:", e$message, "\n")
})  
  
#Loading Period data to data base

file_path_Period <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\BS Data file\\Date.xlsx"

Period_data <- import(file_path_Period)


tryCatch({
  dbWriteTable(conn, name = "Period_data", value = Period_data, overwrite = TRUE, row.names = FALSE)
  cat("Period_data uploaded successfully to MySQL table 'Period_data'.\n")
}, error = function(e) {
  cat("Error uploading Period_data:", e$message, "\n")
})  


#Loading KPI targets data to data base

file_path_Targets <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\BS Data file\\KPIs.xlsx"

Target_data <- import(file_path_Targets)

File_path_KPI_Targets <- "E:\\2024\\Weekly Report\\PERFORAMANCE TEMPLATES\\BS Data file\\KPI_Targets.xlsx"

KPI_Targets_Data <- import(File_path_KPI_Targets)


tryCatch({
  dbWriteTable(conn, name = "KPI Targets", value = KPI_Targets_Data, overwrite = TRUE, row.names = FALSE)
  cat("Targets uploaded successfully to MySQL table 'KPI Target'.\n")
}, error = function(e) {
  cat("Error uploading KPI Target data:", e$message, "\n")
}) 

#seperate gross Add target upload to database for test

tryCatch({
  dbWriteTable(conn, name = "KPI_Targets", value = GrossAddTargetData, overwrite = TRUE, row.names = FALSE)
  cat("KPI_Targets uploaded successfully to MySQL table 'KPI_Targets'.\n")
}, error = function(e) {
  cat("Error uploading KPI_Targets:", e$message, "\n")
})



#Data base disconnect

dbDisconnect(conn)

