
# Obtain species occurrence -----------------------------------------------

# From GBIF

# Creating a dataframe to save species without occurrences

no_coordinates = as.data.frame(matrix(nrow = nrow(data), ncol = 2))
colnames(no_coordinates) = c("ID","species")

# Creating a dataframe to save species occurrences

gbif = as.data.frame(matrix(nrow = 0, ncol = 3))
colnames(gbif) = c("species_search","decimalLongitude","decimalLatitude")

# Creating directory to save results

dir.create("./results")
dir.create("./results/raw")

# Obtaining data

for (i in 1:nrow(data)) {
  occ = rgbif2(species = data[i,1], save = FALSE, limit = 99500)
  if(nrow(occ) == 0){
    no_coordinates[i,1] = i
    no_coordinates[i,2] = data[i,1]
    no_coordinates = na.omit(as.data.frame(no_coordinates))
    write.table(x = no_coordinates, 
                file = "./results/raw/no_coordinates_gbif.txt",
                row.names = FALSE)
  }
  if(nrow(occ) !=  0){
    occ = occ[,c("species_search","decimalLongitude","decimalLatitude")]
    if(i == 1){
      gbif = occ
    } else{
      gbif = rbind(gbif, occ)
    }
  }
  print(i)
}; rm(occ, no_coordinates)



write.table(gbif, 
            file = "./results/raw/gbif.txt",
            sep = "\t" ,
            row.names = FALSE)

# From SpeciesLink

splink <- read_xlsx("./data/splink.xlsx", sheet = 1)
colnames(splink) <- c("species_search", "decimalLongitude", "decimalLatitude")

# Checking names with our species database

checking <- as.numeric()

occ <- gbif

for (i in 1:nrow(splink)) {
  for (j in 1:nrow(data)) {
    checking[j] <- splink[i,1] == data[j,1]
  }
  if(sum(checking) == 1){
    print(splink[i,1]); print(i)
    occ <- rbind(occ, splink[i,c(1:3)])
  }
}; rm(checking)

# Mapping Wallacean Shortfall ---------------------------------------------

# Removing duplicates for richness data

richness <- unique(occ)

# removing duplicates for sampling effort data

effort <- unique(occ[,c(2,3)])

# Organizing sampling effort data to count records

c <- as.character(seq(from = 1, to = nrow(effort), by = 1))
effort <- cbind(c,effort)

# Creating a Spatial Raster

richness <- RichnessGrid(x = richness,
                         reso = 5,
                         type = "spnum")

effort <- RichnessGrid(x = effort,
                       type = "spnum",
                       ras = richness)

# Map ---------------------------------------------------------------------

# Transforming raster in a dataframe

richness <- as.data.frame(richness, xy = TRUE)
effort <- as.data.frame(effort, xy = TRUE)

# Loading world shapefile

world <- map_data("world")

# Richness map ------------------------------------------------------------

richness_plot <- ggplot() +
  geom_tile(data = richness, aes(x = x, y = y, fill = layer)) +
  scale_fill_continuous(low = "lightblue", 
                        high = "#440154FF", ##414487FF
                        na.value = "transparent") +
  geom_map(data = world, map = world, 
           aes(x = long, y = lat, map_id = region), 
           color = "black", fill = NA, size = 0.1) +
  annotate("text", 
           x = -175, 
           y = 80, 
           label = "A", 
           size = 7, 
           color = "black") +
  labs(x = NULL,
       y = NULL,
       fill = "Richness") +
  coord_fixed() +
  theme_classic() +
  theme(panel.grid = element_blank(),
        axis.line = element_line(colour = "white"),
        axis.ticks = element_blank(),
        axis.text = element_blank(), 
        legend.position = c(0.136,0.34),
        legend.title = element_text(face = "bold"))

# Sampling effort map -----------------------------------------------------

effort_plot <- ggplot() +
  geom_tile(data = effort, aes(x = x, y = y, fill = layer)) +
  scale_fill_continuous(low = "lightblue", 
                        high = "#440154FF", ##414487FF
                        na.value = "transparent") +
  geom_map(data = world, map = world, 
           aes(x = long, y = lat, map_id = region), 
           color = "black", fill = NA, size = 0.1) +
  annotate("text", 
           x = -175, 
           y = 80, 
           label = "B", 
           size = 7, 
           color = "black") +
  labs(x = NULL,
       y = NULL,
       fill = "Sampling Effort") +
  coord_fixed() +
  theme_classic() +
  theme(panel.grid = element_blank(),
        axis.line = element_line(colour = "white"),
        axis.ticks = element_blank(),
        axis.text = element_blank(), 
        legend.position = c(0.17,0.34),
        legend.title = element_text(face = "bold"))

# Saving maps

map <- grid.arrange(richness_plot,effort_plot,ncol = 1)

ggsave(filename = "./figures/maps.png",
       plot = map, 
       dpi = 300,
       width = 7.14,
       height = 7.14)

# Bar graph describing the size of the Wallacean shortfall ----------------

# Preparing data

df <- data.frame(categories = c("Without records", "With records"),
                 n = c(1901, 485))

# Structuring the graph

ggplot(data = df, aes(x = categories, y = n, fill = categories)) +
  geom_bar(width = 0.7, stat = "identity") +
  scale_fill_manual(values = c("lightblue","#440154FF")) +
  #scale_fill_viridis_d() +
  theme_bw() +
  labs(x = NULL,
       y = "Number of species",
       fill = "Wallacean Shortfall") +
  theme(axis.text = element_text(size = 12, colour = "black"),
        legend.title = element_text(size = 12, colour = "black", face = "bold"),
        legend.text = element_text(size = 12, colour = "black"),
        axis.title = element_text(size = 12, colour = "black"),
        panel.grid = element_blank())


# Testing the species description time hypothesis -------------------------

# Counting the number of records

clean_data <- unique(occ)

n = clean_data %>% 
  group_by(species_search) %>% 
  summarise(Records = length(species_search))

colnames(n) = c("sp","Records")

n <- left_join(n, data, by = "sp")

ggplot(data = n, aes(x = year, y = Records)) +
  geom_point()

t <- cor.test(x = n$year, y = n$Records, method = "spearman")














