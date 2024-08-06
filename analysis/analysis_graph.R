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
  result <- data.frame(sublate_nh=seq(-0.2, 3, 0.001))
  result <- result %>%
    mutate(sublate_ch=(late_from-share_nh_from*sublate_nh)/(1-share_nh_from),
           late_to=share_nh_to*sublate_nh+(1-share_nh_to)*sublate_ch,
           late_from=late_from)
  return(result)
}

# Graph
graph_sublate <- function(result) {
  ehscenter_late <- instrumental_output$coefficient[9]
  abc_late <- instrumental_output$coefficient[12]
  
  gg <- ggplot(result) +
    geom_line(aes(x=sublate_nh, y=sublate_ch, group=program, colour=program)) +
    fte_theme() +
    labs(colour="Program") +
    scale_x_continuous(name="nh-LATE",
                       limits=c(-0.1, 3.1)) +
    scale_y_continuous(name="ch-LATE",
                       limits=c(-0.1, 2)) +
    scale_color_manual(values=colours_set) +
    annotate("rect",
             xmin=abc_late, xmax=abc_late/prevalence_output$nh_share[8],
             ymin=0, ymax=abc_late, 
             fill=colours_set[1], alpha=0.2) +
    annotate("rect",
             xmin=ehscenter_late, xmax=ehscenter_late/prevalence_output$nh_share[6],
             ymin=0, ymax=ehscenter_late, 
             fill=colours_set[2], alpha=0.2) +
    theme(legend.position="bottom")
  
  return(gg)
}

graph_late_to <- function(result) {
  ehscenter_late <- instrumental_output$coefficient[9]
  abc_late <- instrumental_output$coefficient[12]
  
  ehscenter_nhlate_upper_bound <- ehscenter_late/prevalence_output$nh_share[6]
  ehscenter_late_upper_bound <- prevalence_output$nh_share[8]*ehscenter_nhlate_upper_bound
  
  gg <- ggplot(result) +
    geom_line(aes(x=sublate_nh, y=late_to, group=program, colour=program)) +
    geom_line(aes(x=sublate_nh, y=late_from, group=program, colour=program), linetype="dotdash") +
    fte_theme() +
    labs(colour="Program") +
    scale_x_continuous(name="nh-LATE",
                       limits=c(-0.1, 3.1)) +
    scale_y_continuous(name="Total LATE",
                       limits=c(-0.1, 2)) +
    scale_color_manual(values=colours_set) +
    annotate("rect",
             xmin=ehscenter_late, xmax=ehscenter_late/prevalence_output$nh_share[6],
             ymin=ehscenter_late, ymax=ehscenter_late_upper_bound, 
             fill=colours_set[2], alpha=0.2) +
    theme(legend.position="bottom")
  
  return(gg)
}


# Execute! ####
# Load data
causal_output <- read.csv(paste0(output_git, "causal_output_D_12_P_12.csv"))
instrumental_output <- read.csv(paste0(output_git, "instrumental_output_D_12_P_12.csv"))
regression_output <- read.csv(paste0(output_git, "regression_output_D_12_P_12.csv"))
prevalence_output <- read.csv(paste0(output_git, "prevalence_output_D_12_P_12.csv"))

# EHS Center Only + ABC
sublate_data <-
  rbind(sublate_estimate(prevalence_output$nh_share[6],
                         prevalence_output$nh_share[8],
                         instrumental_output$coefficient[9]) %>%
          mutate(program="EHS - Center Only"),
        sublate_estimate(prevalence_output$nh_share[8],
                         prevalence_output$nh_share[8],
                         instrumental_output$coefficient[12]) %>%
          mutate(program="ABC"))

gg_sublate_ehscenter <- graph_sublate(sublate_data)
gg_sublate_ehscenter
ggsave(plot=gg_sublate_ehscenter,
       file=paste0(output_dir, "sublate_ch_ehscenter.png"),
       width=6, height=4)
ggsave(plot=gg_sublate_ehscenter,
       file=paste0(output_git, "sublate_ch_ehscenter.png"),
       width=6, height=4)

gg_late_to_ehscenter <- graph_late_to(sublate_data)
gg_late_to_ehscenter
ggsave(plot=gg_late_to_ehscenter,
       file=paste0(output_dir, "late_ehscenter.png"),
       width=6, height=4)
ggsave(plot=gg_late_to_ehscenter,
       file=paste0(output_git, "late_ehscenter.png"),
       width=6, height=4)

end_time <- Sys.time()
end_time-start_time
