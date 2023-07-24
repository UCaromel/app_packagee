library(lubridate)
library(purrr)
library(jsonlite)
library(readr)
library(httr)
library(dplyr)

library(telraamStats)

########
# Utilisation of the lubridate package
########

options(lubridate.week.start = 1)  # To start the week on day 1 (package parameter)
today <- today()

########
# Sensor list
########

# /!\ The order of the following lists is important, as it links sensor ids to their names /!\

sensor_ids <- c(9000002156, 9000001906, 9000001618,9000003090,9000002453,9000001844,
                9000001877,9000002666,9000002181,9000002707,9000003703,
                9000003746,9000003775,9000003736,9000004971,9000004130,
                9000004042,9000004697)

sensor_names <- c("Burel-01","Leclerc-02","ParisMarche-03","rueVignes-04","ParisArcEnCiel-05","RteVitre-06",
                  "RueGdDomaine-07","StDidierNord-08","rueVallee-09","StDidierSud-10","RuePrieure-11",
                  "RueCottage-12","RueVeronniere-13","RueDesEcoles-14","RueManoirs-15","RueToursCarree-16",
                  "PlaceHotelDeVille-17","BoulevardLiberté-18")


########
# API key (see the Telraam site to generate one)
########

key <- Sys.getenv("MY_KEY")
key1 <- c(
  'X-Api-Key' = key
)

## Initialization of the update

date_filepath <- "data/date.txt"

# Function to check if an update is possible
checkUpdatePossible <- function(date) {
  return(as.Date(date) < as.Date(Sys.Date()))
}

# Function to update the database
updateDatabase <- function(update) {
  date <- as.Date(update$date)
  
  # Check if an update is possible, otherwise nothing happens
  if (checkUpdatePossible(date)) {
    # Check the existence of the API's key
    if (is.null(key)) {
      update$state <- "The API key is missing."
    } else if (!api_state(key)) {
      update$state <- "There seems to be a problem with the API. Please wait until tomorrow or contact support."
    } else {
      # Update the database
      for (id_sensor in sensor_ids) { # Iteration on all sensors
        yesterday <- Sys.Date() - 1 # Today is excluded
        write_update_data(id_sensor, date1 = date, date2 = yesterday)
      }
      
      # Update the date of the next update
      writeLines(as.character(Sys.Date()), con = date_filepath)
      update$date <- Sys.Date()
      
      # Update the state of the database
      update$state <- paste0("The data ranges from 2021-01-01 to ", Sys.Date() - 1, ". The database has been updated. Please restart the application.")
    }
  }
}

# Initialize the update object
if (file.exists(date_filepath)) { # When the database already exists
  date <- readLines(date_filepath)
  
  # Check if an update is possible
  if (checkUpdatePossible(date)) {
    action <- ", an update with the Telraam API is possible."
  } else {
    action <- ", the database is up to date with the Telraam API."
  }
  
  update <- list(
    state = paste0("The data stored in the application ranges from 2021-01-01 to ", date, action),
    date = date,
    key = NULL
  )
  
} else { # When the database is empty
  update <- list(
    state = "The database is empty, please update the data.",
    date = "2021-01-01", # The database begins on 2021-01-01
    key = NULL
  )
}

# Update the database
updateDatabase(update)