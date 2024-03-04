
# Read data ---------------------------------------------------------------

data_l <- read_xlsx("./data/linnean_data.xlsx", sheet = 1)

# Data organization -------------------------------------------------------

data_l <- data_l %>% 
  group_by(year) %>% 
  summarise(n = length(year)) %>% 
  mutate(n_cum = cumsum(n))

# Figures -----------------------------------------------------------------

description_curve <- ggplot(data = data_l, aes(x = year, y = n_cum)) +
  xlab("Years") +
  ylab("Acumulated number of described species") +
  geom_line() +
  geom_point(colour = "black", size = 2, shape = 21, fill = "grey") +
  theme_bw() +
  annotate("text", x = 1840, y = 2370, label = "A", size = 8) +
  theme(axis.title = element_text(size = 14, colour = "black"),
        axis.text = element_text(size = 12, colour = "black"), 
        panel.grid = element_blank())


effort <- ggplot(data = data_l, aes(x = year, y = n)) +
  xlab("Years") +
  ylab("Number of described species") +
  geom_bar(stat = "identity", fill = "black") +
  geom_hline(yintercept = mean(data_l$n),
             linetype = "dashed", colour = "red") +
  theme_bw() +
  annotate("text", x = 1840, y = 130, label = "B", size = 8) +
  annotate("text", x = 1840, y = 33, label = "\u2248 26", size = 5, colour = "red") +
  theme(axis.title = element_text(size = 14, colour = "black"),
        axis.text = element_text(size = 12, colour = "black"),
        panel.grid = element_blank())

linnean_shortfall <- grid.arrange(description_curve, effort, ncol = 1)

ggsave(filename = "./figures/linnean_shortfall.png", 
       plot = linnean_shortfall, 
       width = 7, 
       height = 11,
       dpi = 300)
