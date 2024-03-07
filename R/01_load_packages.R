# Loading packages --------------------------------------------------------

# https://gist.github.com/stevenworthington/3178163

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

ipak(c("ggplot2",
       "gridExtra",
       "MASS",
       "car",
       "visreg",
       "tidyverse",
       "speciesgeocodeR",
       "terra",
       "readxl", 
       "dplyr", 
       "lme4",
       "Rocc",
       "ggmap"))

# If speciesgeocodeR package is not installed, run the code bellow

remotes::install_github("azizka/speciesgeocodeR")

# If Rocc package is not installed, run the code bellow

remotes::install_github("liibre/Rocc")