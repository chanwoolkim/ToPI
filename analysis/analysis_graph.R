start_time <- Sys.time()

colours_set <- brewer.pal("Set2", n=8)

fte_theme <- function() {
  # Generate the colours for the chart procedurally with RColorBrewer
  palette <- brewer.pal("Greys", n=9)
  color.background="white"
  color.grid.major=palette[3]
  color.axis.text=palette[7]
  color.axis.title=palette[7]
  color.title=palette[9]
  
  # Begin construction of chart
  theme_bw(base_size=12, base_family="serif") +
    
    # Set the entire chart region to a light gray color
    theme(panel.background=element_rect(fill=color.background, color=color.background)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color=color.background)) +
    
    # Format the grid
    theme(panel.grid.major=element_line(color=color.grid.major,size=.25)) +
    theme(panel.grid.minor=element_blank()) +
    theme(axis.ticks=element_blank()) +
    
    # Format the legend
    theme(legend.position="bottom") +
    theme(legend.background=element_rect(fill=color.background)) +
    theme(legend.title=element_blank()) +
    theme(legend.text=element_text(size=14, color=color.axis.title, family="serif")) +
    theme(legend.box.background=element_rect(colour=color.grid.major)) +
    theme(legend.title.align=0.5) +
    
    # Set title and axis labels, and format these and tick marks
    theme(axis.text=element_text(size=rel(1), color=color.axis.text)) +
    theme(axis.title.x=element_text(color=color.axis.title, vjust=0)) +
    theme(axis.title.y=element_text(color=color.axis.title, vjust=1.25)) +
    
    # Plot margins
    theme(plot.margin=unit(c(0.35, 0.2, 0.3, 0.35), "cm"))
}


# Function to create data frame for graph inputs ####
# Create subLATE and combined LATE for the data
sublate_estimate <- function(share_nh_from, share_nh_to, late_from) {
  result <- data.frame(sublate_nh=seq(-1, 1, 0.001))
  result <- result %>%
    mutate(sublate_ch=(late_from-share_nh_from*sublate_nh)/(1-share_nh_from),
           late_to=share_nh_to*sublate_nh+(1-share_nh_to)*sublate_ch,
           late_from=late_from)
  return(result)
}

# Graph
graph_sublate <- function(result) {
  gg <- ggplot(result,
               aes(x=sublate_nh, y=sublate_ch, group=type, colour=type)) +
    geom_line() +
    fte_theme() +
    labs(colour="Sector") +
    scale_x_continuous(name="nh-subLATE") +
    scale_y_continuous(name="ch-subLATE") +
    scale_color_manual(values=colours_set) +
    theme(legend.position="bottom",
          legend.title=element_blank())
  return(gg)
}

graph_late_to <- function(result) {
  gg <- ggplot(result,
               aes(x=sublate_nh, y=late_to, group=type, colour=type)) +
    geom_line() +
    geom_line(aes(x=sublate_nh, y=late_from, group=type, colour=type)) +
    fte_theme() +
    labs(colour="Sector") +
    scale_x_continuous(name="nh-subLATE") +
    scale_y_continuous(name="Total LATE") +
    scale_color_manual(values=colours_set) +
    theme(legend.position="bottom",
          legend.title=element_blank())
  return(gg)
}


# Execute! ####
# Load data
causal_output <- read.csv(paste0(output_git, "causal_output.csv"))
instrumental_output <- read.csv(paste0(output_git, "instrumental_output.csv"))
regression_output <- read.csv(paste0(output_git, "regression_output.csv"))
prevalence_output <- read.csv(paste0(output_git, "prevalence_output.csv"))

# ITT basic
itt_results <- regression_output[1, c(2, 3, 6, 7, 10, 11)]
itt_results <- data.frame(program=c("EHS, Center + Mixed",
                                    "EHS, Center Only",
                                    "ABC"),
                          coef=itt_results[1, c(1, 3, 5)] %>% as.numeric(),
                          se=itt_results[1, c(2, 4, 6)] %>% as.numeric()) %>%
  mutate(ci_lower=coef-1.96*se,
         ci_upper=coef+1.96*se)

gg_itt_results <- ggplot(itt_results,
                         aes(x=coef, y=program, group=1)) +
  geom_errorbar(width=.1,
                aes(xmin=ci_lower, xmax=ci_upper),
                colour="red") +
  geom_point(shape=21, size=5, fill="white", stroke=1) +
  fte_theme() +
  scale_x_continuous(name="Coefficients") +
  scale_y_discrete(name="")
gg_itt_results
ggsave(plot=gg_itt_results,
       file=paste0(output_dir, "itt_results.png"),
       width=6, height=4)
ggsave(plot=gg_itt_results,
       file=paste0(output_git, "itt_results.png"),
       width=6, height=4)

# EHS Center-Mixed
sublate_ehscenter_mixed <-
  rbind(sublate_estimate(prevalence_output$nh_share[1],
                         prevalence_output$nh_share[5],
                         instrumental_output$coefficient[1]) %>%
          mutate(type="Full/All Xs"),
        sublate_estimate(prevalence_output$nh_share[1],
                         prevalence_output$nh_share[5],
                         instrumental_output$coefficient[2]) %>%
          mutate(type="Full/Key Xs"),
        sublate_estimate(prevalence_output$nh_share[2],
                         prevalence_output$nh_share[6],
                         instrumental_output$coefficient[3]) %>%
          mutate(type="Subsample/Key Xs"))

gg_sublate_ehscenter_mixed <- graph_sublate(sublate_ehscenter_mixed)
gg_sublate_ehscenter_mixed
ggsave(plot=gg_sublate_ehscenter_mixed,
       file=paste0(output_dir, "sublate_ch_ehscenter_mixed.png"),
       width=6, height=4)
ggsave(plot=gg_sublate_ehscenter_mixed,
       file=paste0(output_git, "sublate_ch_ehscenter_mixed.png"),
       width=6, height=4)

gg_late_to_ehscenter_mixed <- graph_late_to(sublate_ehscenter_mixed)
gg_late_to_ehscenter_mixed
ggsave(plot=gg_late_to_ehscenter_mixed,
       file=paste0(output_dir, "late_ehscenter_mixed.png"),
       width=6, height=4)
ggsave(plot=gg_late_to_ehscenter_mixed,
       file=paste0(output_git, "late_ehscenter_mixed.png"),
       width=6, height=4)

# EHS Center Only
sublate_ehscenter <-
  rbind(sublate_estimate(prevalence_output$nh_share[3],
                         prevalence_output$nh_share[5],
                         instrumental_output$coefficient[4]) %>%
          mutate(type="Full/All Xs"),
        sublate_estimate(prevalence_output$nh_share[3],
                         prevalence_output$nh_share[5],
                         instrumental_output$coefficient[5]) %>%
          mutate(type="Full/Key Xs"),
        sublate_estimate(prevalence_output$nh_share[4],
                         prevalence_output$nh_share[6],
                         instrumental_output$coefficient[6]) %>%
          mutate(type="Subsample/Key Xs"))

gg_sublate_ehscenter <- graph_sublate(sublate_ehscenter)
gg_sublate_ehscenter
ggsave(plot=gg_sublate_ehscenter,
       file=paste0(output_dir, "sublate_ch_ehscenter.png"),
       width=6, height=4)
ggsave(plot=gg_sublate_ehscenter,
       file=paste0(output_git, "sublate_ch_ehscenter.png"),
       width=6, height=4)

gg_late_to_ehscenter <- graph_late_to(sublate_ehscenter)
gg_late_to_ehscenter
ggsave(plot=gg_late_to_ehscenter,
       file=paste0(output_dir, "late_ehscenter.png"),
       width=6, height=4)
ggsave(plot=gg_late_to_ehscenter,
       file=paste0(output_git, "late_ehscenter.png"),
       width=6, height=4)

end_time <- Sys.time()
end_time-start_time
