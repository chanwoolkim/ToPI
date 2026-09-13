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
  ehscenter_late <- late("ehscenter")
  abc_late <- late("abc")
  
  program_levels <- c("ABC", "EHS - Center Only")
  result <- result %>%
    mutate(program=factor(program, levels=program_levels))
  
  # Feasible (nh-LATE, ch-LATE) region for each program, drawn as a mapped
  # fill so that the bounds appear in the legend
  bounds <- data.frame(program=factor(program_levels, levels=program_levels),
                       xmin=c(abc_late, ehscenter_late),
                       xmax=c(abc_late/nh_share("abc"),
                              ehscenter_late/nh_share("ehscenter")),
                       ymin=0,
                       ymax=c(abc_late, ehscenter_late))
  
  gg <- ggplot(result) +
    geom_rect(data=bounds,
              aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=program),
              alpha=0.2, inherit.aes=FALSE) +
    geom_line(aes(x=sublate_nh, y=sublate_ch, group=program, colour=program)) +
    fte_theme() +
    labs(colour=NULL, fill=NULL) +
    scale_x_continuous(name="nh-LATE",
                       limits=c(-0.1, 3.1)) +
    scale_y_continuous(name="ch-LATE",
                       limits=c(-0.1, 2)) +
    scale_colour_manual(values=colours_set[1:2],
                        labels=expression("ch-LATE"^"ABC",
                                          "ch-LATE"^"EHS")) +
    scale_fill_manual(values=colours_set[1:2],
                      labels=expression("ch-LATE"^"ABC"~"Bounds",
                                        "ch-LATE"^"EHS"~"Bounds")) +
    guides(colour=guide_legend(order=1),
           fill=guide_legend(order=2)) +
    theme(legend.position="bottom",
          legend.box="vertical",
          legend.spacing.y=unit(0, "pt"))
  
  return(gg)
}

graph_late_to <- function(result) {
  ehscenter_late <- late("ehscenter")
  abc_late <- late("abc")
  
  ehscenter_nhlate_upper_bound <- ehscenter_late/nh_share("ehscenter")
  ehscenter_late_upper_bound <- nh_share("abc")*ehscenter_nhlate_upper_bound
  
  # Three series: LATE^ABC, LATE_ABC^EHS (EHS estimate mapped to the ABC
  # complier mix), and the original LATE^EHS as a dotdash reference line.
  # For ABC late_from equals late_to, so its reference line is dropped.
  series_levels <- c("ABC", "EHS - LATE", "EHS - Center Only")
  lines <- bind_rows(
    result %>%
      transmute(sublate_nh, value=late_to, series=program),
    result %>%
      filter(program=="EHS - Center Only") %>%
      transmute(sublate_nh, value=late_from, series="EHS - LATE")) %>%
    mutate(series=factor(series, levels=series_levels))
  
  # Feasible region for LATE_ABC^EHS, drawn as a mapped fill so that the
  # bounds appear in the legend
  bounds <- data.frame(series=factor("EHS - Center Only", levels=series_levels),
                       xmin=ehscenter_late,
                       xmax=ehscenter_nhlate_upper_bound,
                       ymin=ehscenter_late,
                       ymax=ehscenter_late_upper_bound)
  
  gg <- ggplot(lines) +
    geom_rect(data=bounds,
              aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=series),
              alpha=0.2, inherit.aes=FALSE) +
    geom_line(aes(x=sublate_nh, y=value, group=series, colour=series,
                  linetype=series)) +
    fte_theme() +
    labs(colour=NULL, fill=NULL) +
    scale_x_continuous(name=expression("nh-LATE"^"EHS"),
                       limits=c(-0.1, 3.1)) +
    scale_y_continuous(name="Total LATE",
                       limits=c(-0.1, 2)) +
    scale_colour_manual(values=colours_set[c(1, 2, 2)],
                        labels=expression("LATE"^"ABC",
                                          "LATE"^"EHS",
                                          "LATE"["ABC"]^"EHS")) +
    scale_linetype_manual(values=c("solid", "dotdash", "solid"),
                          guide="none") +
    scale_fill_manual(values=colours_set[2],
                      labels=expression("LATE"["ABC"]^"EHS"~"Bounds")) +
    guides(colour=guide_legend(order=1,
                               override.aes=list(linetype=c("solid", "dotdash",
                                                            "solid"))),
           fill=guide_legend(order=2)) +
    theme(legend.position="bottom",
          legend.box="vertical",
          legend.spacing.y=unit(0, "pt"))
  
  return(gg)
}


# CDF of months in EHS by treatment status, with the 1- and 12-month
# participation thresholds marked
graph_cdf_months <- function(df) {
  gg <- ggplot(df %>%
                 filter(!is.na(mo_ehs)) %>%
                 mutate(group=factor(R, levels=c(1, 0), labels=c("Treated", "Control"))),
               aes(x=mo_ehs, colour=group)) +
    stat_ecdf(geom="step", linewidth=1) +
    geom_vline(xintercept=c(6, 12), linetype="dashed", colour="grey40") +
    scale_colour_manual(values=colours_set[c(2, 1)]) +
    scale_y_continuous(breaks=seq(0, 1, 0.2), limits=c(0, 1)) +
    labs(x="Months in Early Head Start", y="Cumulative Probability", colour=NULL) +
    fte_theme()
  return(gg)
}


# Execute! ####
# Load data
# Subsample estimates with 12-month participation
regression_output <- read.csv(paste0(output_git, "regression_output_12m.csv"))
prevalence_output <- read.csv(paste0(output_git, "prevalence_output_12m.csv"))

# Share of nh-compliers among compliers
nh_share <- function(program) {
  prevalence_output %>%
    filter(program==.env$program, subsample==TRUE) %>%
    pull(nh_share)
}

# LATE without covariates: 2SLS coefficient on D
late <- function(program) {
  regression_output %>%
    filter(program==.env$program, subsample==TRUE, method=="LATE", covariates=="none",
           variable=="D") %>%
    pull(coefficient)
}

# EHS Center Only + ABC
sublate_data <-
  rbind(sublate_estimate(nh_share("ehscenter"),
                         nh_share("abc"),
                         late("ehscenter")) %>%
          mutate(program="EHS - Center Only"),
        sublate_estimate(nh_share("abc"),
                         nh_share("abc"),
                         late("abc")) %>%
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

# CDF of months in EHS (Center Only)
ehscenter <- read.csv(paste0(data_dir, "ehscenter-topi.csv"))

gg_cdf_months <- graph_cdf_months(ehscenter)
gg_cdf_months
ggsave(plot=gg_cdf_months,
       file=paste0(graph_dir, "CDF_months.pdf"),
       width=6, height=4)
ggsave(plot=gg_cdf_months,
       file=paste0(output_git, "CDF_months.pdf"),
       width=6, height=4)

end_time <- Sys.time()
end_time-start_time
