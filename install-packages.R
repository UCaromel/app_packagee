# install-packages.R
install.packages("devtools")
devtools::install_version("lubridate", version = "1.9.2")
devtools::install_version("purrr", version = "1.0.1")
devtools::install_version("jsonlite", version = "1.8.7")
devtools::install_version("readr", version = "2.1.4")
devtools::install_version("httr", version = "1.4.2")
remotes::install_github("UCaromel/movaround_pkg")

