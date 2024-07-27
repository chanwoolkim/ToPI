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
  result <- data.frame(sublate_nh=seq(-0.2, late_from/share_nh_from+0.2, 0.001))
  result <- result %>%
    mutate(sublate_ch=(late_from-share_nh_from*sublate_nh)/(1-share_nh_from),
           late_to=share_nh_to*sublate_nh+(1-share_nh_to)*sublate_ch,
           late_from=late_from)
  return(result)
}

# Graph
graph_sublate <- function(result) {
  full_late <- as.numeric((result %>% filter(type=="Full"))$late_from[1])
  subsample_late <- as.numeric((result %>% filter(type=="Subsample"))$late_from[1])
  
  gg <- ggplot(result) +
    geom_line(aes(x=sublate_nh, y=sublate_ch, group=type, colour=type)) +
    fte_theme() +
    labs(colour="Sector") +
    scale_x_continuous(name="nh-subLATE") +
    scale_y_continuous(name="ch-subLATE",
                       limits=c(-0.2,
                                max(full_late, subsample_late)+0.2)) +
    scale_color_manual(values=colours_set) +
    annotate("rect",
             xmin=full_late, xmax=full_late/prevalence_output$nh_share[5],
             ymin=0, ymax=full_late, 
             fill=colours_set[1], alpha=0.2) +
    annotate("rect",
             xmin=subsample_late, xmax=subsample_late/prevalence_output$nh_share[6],
             ymin=0, ymax=subsample_late, 
             fill=colours_set[2], alpha=0.2) +
    theme(legend.position="bottom",
          legend.title=element_blank())
  
  return(gg)
}

graph_late_to <- function(result) {
  full_late <- as.numeric((result %>% filter(type=="Full"))$late_from[1])
  subsample_late <- as.numeric((result %>% filter(type=="Subsample"))$late_from[1])
  
  gg <- ggplot(result) +
    geom_line(aes(x=sublate_nh, y=late_to, group=type, colour=type)) +
    geom_line(aes(x=sublate_nh, y=late_from, group=type, colour=type), linetype="dotdash") +
    fte_theme() +
    labs(colour="Sector") +
    scale_x_continuous(name="nh-subLATE") +
    scale_y_continuous(name="Total LATE",
                       limits=c(-0.2,
                                max(full_late, subsample_late)+0.2)) +
    scale_color_manual(values=colours_set) +
    annotate("rect",
             xmin=full_late, xmax=full_late/prevalence_output$nh_share[5],
             ymin=0, ymax=Inf, 
             fill=colours_set[1], alpha=0.2) +
    annotate("rect",
             xmin=subsample_late, xmax=subsample_late/prevalence_output$nh_share[6],
             ymin=0, ymax=Inf, 
             fill=colours_set[2], alpha=0.2) +
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

# EHS Center Only
sublate_ehscenter <-
  rbind(sublate_estimate(prevalence_output$nh_share[5],
                         prevalence_output$nh_share[7],
                         instrumental_output$coefficient[8]) %>%
          mutate(type="Full"),
        sublate_estimate(prevalence_output$nh_share[6],
                         prevalence_output$nh_share[8],
                         instrumental_output$coefficient[9]) %>%
          mutate(type="Subsample"))

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
