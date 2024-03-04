# Loading packages --------------------------------------------------------

# https://gist.github.com/stevenworthington/3178163

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

ipak(c("ggplot2","devtools","gridExtra","MASS","car","visreg","tidyverse",
       "segmented","speciesgeocodeR","raster","readxl", "dplyr", "lme4"))
# readxl, tidyverse
# Pacote para raster de riqueza de especies

devtools::install_github("azizka/speciesgeocodeR")
library(speciesgeocodeR)