# functions.R

# Function to read, clean, and transform CSV files
read_and_clean_csv <- function(filepath, delim=";") {
  # Read the dataset
  data <- read_delim(filepath, delim, col_types = cols('Znesek/Amount' = col_character()))
  
  # Clean column names to keep only the Slovene portion
  cleaned_names <- gsub("\\s*/\\s*.*", "", colnames(data))
  colnames(data) <- cleaned_names
  
  
  # Clean amount data: replace "," with ".", remove extra "." and convert to numeric
  data$Znesek <- as.numeric(gsub(",", ".", gsub("\\.", "", data$Znesek)))
  
  # Adjust sign based on +/- column
  data$Znesek <- ifelse(data$`+` == "-", -data$Znesek, data$Znesek)
  
  # Select relevant columns and convert date format
  data <- data %>%
    select(Opis, Kategorija, Znesek, Valuta, `Datum plačila`, Namen) %>%
    mutate(`Datum plačila` = as.Date(`Datum plačila`, format = "%d-%m-%Y"))
  
  return(data)
}

data24 <- read_and_clean_csv("stroski24_1.csv", delim=';')

# Function to save transactions to an .rds file
save_transactions <- function(data, filepath = "transactions.rds") {
  saveRDS(data, filepath)
}

# Function to load transactions from an .rds file
load_transactions <- function(filepath = "transactions.rds") {
  if (file.exists(filepath)) {
    return(readRDS(filepath))
  } else {
    return(data.frame(Opis = character(), Kategorija = character(), Znesek = numeric(), 
                      Valuta = character(), `Datum plačila` = as.Date(character()), 
                      Namen = character(), stringsAsFactors = FALSE))
  }
}

# Function to update categories
update_categories <- function(data, new_category) {
  if (!new_category %in% data$Kategorija) {
    data$Kategorija <- c(data$Kategorija, new_category)
  }
  return(data)
}
