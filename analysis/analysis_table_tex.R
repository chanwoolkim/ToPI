start_time <- Sys.time()

# Load data
causal_output <- read.csv(file=paste0(output_git, "causal_output_D_12_P_12.csv"))
instrumental_output <- read.csv(paste0(output_git, "instrumental_output_D_12_P_12.csv"))
regression_output <- read.csv(paste0(output_git, "regression_output_D_12_P_12.csv"))
fra_output <- read.csv(paste0(output_git, "fra_output_D_12_P_12.csv"))
prevalence_output <- read.csv(paste0(output_git, "prevalence_output_D_12_P_12.csv"))

causal_output_all <- read.csv(file=paste0(output_git, "causal_output_E_P.csv"))
instrumental_output_all <- read.csv(paste0(output_git, "instrumental_output_E_P.csv"))
regression_output_all <- read.csv(paste0(output_git, "regression_output_E_P.csv"))
fra_output_all <- read.csv(paste0(output_git, "fra_output_E_P.csv"))
prevalence_output_all <- read.csv(paste0(output_git, "prevalence_output_E_P.csv"))

causal_output_D <- read.csv(file=paste0(output_git, "causal_output_D_1_P_1.csv"))
instrumental_output_D <- read.csv(paste0(output_git, "instrumental_output_D_1_P_1.csv"))
regression_output_D <- read.csv(paste0(output_git, "regression_output_D_1_P_1.csv"))
fra_output_D <- read.csv(paste0(output_git, "fra_output_D_1_P_1.csv"))
prevalence_output_D <- read.csv(paste0(output_git, "prevalence_output_D_1_P_1.csv"))

# Output to LaTeX tables ####
# Summary of important coefficients
coefficients_tex <- function(causal_result, instrumental_result, regression_result, fra_result,
                             causal_result_all, instrumental_result_all, regression_result_all, fra_result_all,
                             causal_result_D, instrumental_result_D, regression_result_D, fra_result_D) {
  causal_subset <- causal_result %>% filter(subsample)
  instrumental_subset <- instrumental_result %>% filter(subsample)
  causal_subset_all <- causal_result_all %>% filter(subsample)
  instrumental_subset_all <- instrumental_result_all %>% filter(subsample)
  causal_subset_D <- causal_result_D %>% filter(subsample)
  instrumental_subset_D <- instrumental_result_D %>% filter(subsample)
  
  regression_row <- function(colname, row, begin, method="ITT") {
    if (method=="ITT") {
      out <- TexRow(colname) / 
        TexRow(c(regression_result_all[row, seq(begin, 181, 60)],
                 regression_result[row, seq(begin+180, 241, 60)]) %>% as.numeric(),
               pvalues=c(regression_result_all[row, seq(begin+2, 181, 60)],
                         regression_result[row, seq(begin+182, 241, 60)]) %>% as.numeric(),
               cspan=c(1, 1, 3, 1), dec=2) +
        TexRow("") /
        TexRow(c(regression_result_all[row, seq(begin+1, 181, 60)],
                 regression_result[row, seq(begin+181, 241, 60)]) %>% as.numeric(),
               cspan=c(1, 1, 3, 1), dec=2, se=TRUE)
    } else if (method=="LATE") {
      out <- TexRow(colname) / 
        TexRow(c(regression_result_all[row, seq(begin, 181, 60)],
                 regression_result_D[row, begin+120],
                 regression_result[row, seq(begin+120, 241, 60)]) %>% as.numeric(),
               pvalues=c(regression_result_all[row, seq(begin+2, 181, 60)],
                         regression_result_D[row, begin+122],
                         regression_result[row, seq(begin+122, 241, 60)]) %>% as.numeric(),
               dec=2) +
        TexRow("") /
        TexRow(c(regression_result_all[row, seq(begin+1, 181, 60)],
                 regression_result_D[row, begin+121],
                 regression_result[row, seq(begin+121, 241, 60)]) %>% as.numeric(),
               dec=2, se=TRUE)
    }
    return(out)
  }
  
  fra_row <- function(method="ITT", subsample=FALSE) {
    if (method=="ITT") {
      if (!subsample) {
        out <- TexRow("Full/FRA") / 
          TexRow(c(fra_output_all[seq(1, 24, 8), 1],
                   fra_output[seq(25, 32, 8), 1]) %>% as.numeric(),
                 pvalues=c(fra_output_all[seq(1, 24, 8), 3],
                           fra_output_D[17, 3],
                           fra_output[seq(17, 32, 8), 3]) %>% as.numeric(),
                 cspan=c(1, 1, 3, 1), dec=2) +
          TexRow("") /
          TexRow(c(fra_output_all[seq(1, 24, 8), 2],
                   fra_output[seq(25, 32, 8), 2]) %>% as.numeric(),
                 cspan=c(1, 1, 3, 1), dec=2, se=TRUE)
      } else if (subsample) {
        out <- TexRow("Subsample/FRA") / 
          TexRow(c(fra_output_all[seq(5, 24, 8), 1],
                   fra_output[seq(29, 32, 8), 1]) %>% as.numeric(),
                 pvalues=c(fra_output_all[seq(5, 24, 8), 3],
                           fra_output[seq(29, 32, 8), 3]) %>% as.numeric(),
                 cspan=c(1, 1, 3, 1), dec=2) +
          TexRow("") /
          TexRow(c(fra_output_all[seq(5, 24, 8), 2],
                   fra_output[seq(29, 32, 8), 2]) %>% as.numeric(),
                 cspan=c(1, 1, 3, 1), dec=2, se=TRUE)
      }
    } else if (method=="LATE") {
      if (!subsample) {
        out <- TexRow("Full/FRA") / 
          TexRow(c(fra_output_all[seq(3, 24, 8), 1],
                   fra_output_D[19, 1],
                   fra_output[seq(19, 32, 8), 1]) %>% as.numeric(),
                 pvalues=c(fra_output_all[seq(3, 24, 8), 3],
                           fra_output_D[19, 3],
                           fra_output[seq(19, 32, 8), 3]) %>% as.numeric(),
                 dec=2) +
          TexRow("") /
          TexRow(c(fra_output_all[seq(3, 24, 8), 2],
                   fra_output_D[19, 2],
                   fra_output[seq(19, 32, 8), 2]) %>% as.numeric(),
                 dec=2, se=TRUE)
      } else if (subsample) {
        out <- TexRow("Subsample/FRA") /
          TexRow(c(fra_output_all[seq(7, 24, 8), 1],
                   fra_output_D[23, 1],
                   fra_output[seq(23, 32, 8), 1]) %>% as.numeric(),
                 pvalues=c(fra_output_all[seq(7, 24, 8), 3],
                           fra_output_D[23, 3],
                           fra_output[seq(23, 32, 8), 3]) %>% as.numeric(),
                 dec=2) +
          TexRow("") /
          TexRow(c(fra_output_all[seq(7, 24, 8), 2],
                   fra_output_D[23, 2],
                   fra_output[seq(23, 32, 8), 2]) %>% as.numeric(),
                 dec=2, se=TRUE)
      }
    }
    return(out)
  }
  
  tab <- TexRow(c("", "ITT"), cspan=c(1, 6)) +
    TexMidrule(list(c(2, 7))) +
    TexRow(c("Program ", "EHS", "ABC"), cspan=c(1, 5, 1)) +
    TexMidrule(list(c(2, 6), c(7, 7))) +
    TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 1, 1, 3, 1)) +
    TexMidrule() +
    regression_row("Full", 1, 2+5) +
    fra_row("ITT", subsample=FALSE) +
    regression_row("Subsample", 1, 32+5) +
    fra_row("ITT", subsample=TRUE) +
    TexRow("Subsample/Causal Forest") / 
    TexRow(c(causal_subset_all$pre_dr_estimate[1:3],
             causal_subset$pre_dr_estimate[4]) %>% as.numeric(), 
           pvalues=c(causal_subset_all$pre_dr_p_value[1:3],
                     causal_subset$pre_dr_p_value[4]) %>% as.numeric(), 
           cspan=c(1, 1, 3, 1), dec=2) +
    TexRow("") / 
    TexRow(c(causal_subset_all$pre_dr_se[1:3],
             causal_subset$pre_dr_se[4]) %>% as.numeric(), 
           cspan=c(1, 1, 3, 1), dec=2, se=TRUE) +
    TexRow("Subsample/Causal Forest (ABC)") / 
    TexRow(c(causal_subset_all$to_estimate[1:3]) %>% as.numeric(), 
           pvalues=c(causal_subset_all$to_p_value[1:3]) %>% as.numeric(), 
           cspan=c(1, 1, 3), dec=2) / TexRow("-") +
    TexRow("") / 
    TexRow(c(causal_subset_all$to_se[1:3]) %>% as.numeric(), 
           cspan=c(1, 1, 3), dec=2, se=TRUE) +
    TexMidrule() +
    TexMidrule() +
    TexRow(c("", "LATE"), cspan=c(1, 6)) +
    TexMidrule(list(c(2, 7))) +
    TexRow(c("Program ", "EHS", "ABC"), cspan=c(1, 5, 1)) +
    TexMidrule(list(c(2, 6), c(7, 7))) +
    TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 1, 1, 3, 1)) +
    TexMidrule(list(c(2, 2), c(3, 3), c(4, 6), c(7, 7))) +
    TexRow(c("Participation", "Any", "Any", "Any", "1m", "12m", "12m")) +
    TexMidrule() +
    regression_row("Full", 2, 17+5, "LATE") +
    fra_row("LATE", subsample=FALSE) +
    regression_row("Subsample", 2, 47+5, "LATE") +
    fra_row("LATE", subsample=TRUE) +
    TexRow("Subsample/Instrumental Forest") / 
    TexRow(c(instrumental_subset_all$pre_dr_estimate[1:3],
             instrumental_subset_D$pre_dr_estimate[3],
             instrumental_subset$pre_dr_estimate[3:4]) %>% as.numeric(), 
           pvalues=c(instrumental_subset_all$pre_dr_p_value[1:3],
                     instrumental_subset_D$pre_dr_p_value[3],
                     instrumental_subset$pre_dr_p_value[3:4]) %>% as.numeric(), 
           dec=2) +
    TexRow("") / 
    TexRow(c(instrumental_subset_all$pre_dr_se[1:3],
             instrumental_subset_D$pre_dr_se[3],
             instrumental_subset$pre_dr_se[3:4]) %>% as.numeric(), 
           dec=2, se=TRUE) +
    TexRow("Subsample/Instrumental Forest (ABC)") / 
    TexRow(c(instrumental_subset_all$to_estimate[1:3],
             instrumental_subset_D$to_estimate[3],
             instrumental_subset$to_estimate[3]) %>% as.numeric(), 
           pvalues=c(instrumental_subset_all$to_p_value[1:3],
                     instrumental_subset_D$to_p_value[3],
                     instrumental_subset$to_p_value[3]) %>% as.numeric(), 
           dec=2) / TexRow("-") +
    TexRow("") / 
    TexRow(c(instrumental_subset_all$to_se[1:3],
             instrumental_subset_D$to_se[3],
             instrumental_subset$to_se[3]) %>% as.numeric(), 
           dec=2, se=TRUE) +
    TexMidrule() +
    TexMidrule() +
    TexRow("Sample Size: Full") /
    TexRow(causal_result$N[c(1, 4, 7, 10)] %>% as.numeric(), 
           cspan=c(1, 1, 3, 1), dec=0) +
    TexRow("Sample Size: Subsample") /
    TexRow(causal_result$N[c(3, 6, 9, 12)] %>% as.numeric(), 
           cspan=c(1, 1, 3, 1), dec=0)
  return(tab)
}

tab <- coefficients_tex(causal_output, instrumental_output, regression_output, fra_output,
                        causal_output_all, instrumental_output_all, regression_output_all, fra_output_all,
                        causal_output_D, instrumental_output_D, regression_output_D, fra_output_D)
TexSave(tab, filename="coefficients_base", positions=c('l', rep('c', 6)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="coefficients_base", positions=c('l', rep('c', 6)),
        output_path=output_git, stand_alone=FALSE)

# Progress table
progress_tex <- function(instrumental_result,
                         regression_result, regression_result_all, regression_result_D) {
  instrumental_subset <- instrumental_result %>% filter(subsample)
  
  regression_row <- function(pre, result, row, col, arrow=TRUE) {
    if (arrow) {
      out <- TexRow(pre) /
        TexRow(c(result[row, col],
                 result[12, col+4]) %>% as.numeric(), 
               pvalues=c(result[row, col+2], 1) %>% as.numeric(), 
               dec=c(2, 0)) / TexRow("-") +
        TexRow(rep("", 3)) / 
        TexRow(c(result[row, col+1], NA) %>% as.numeric(), 
               dec=2, se=TRUE)
    } else {
      out <- TexRow(pre) /
        TexRow(c(result[row, col],
                 result[row, col+4],
                 result[row, col+60],
                 result[row, col+64]) %>% as.numeric(), 
               pvalues=c(result[row, col+2],
                         1,
                         result[row, col+62],
                         1) %>% as.numeric(), 
               dec=rep(c(2, 0), 2)) +
        TexRow(rep("", 3)) / 
        TexRow(c(result[row, col+1],
                 NA,
                 result[row, col+61],
                 NA) %>% as.numeric(), 
               dec=rep(c(2, 0), 2), se=TRUE)
    }
    return(out)
  }
  
  tab <- TexRow(c("Program", "EHS", "ABC"),
                cspan=c(3, 2, 2), position=c("l", "c", "c")) +
    TexMidrule(list(c(1, 3), c(4, 5), c(6, 7))) +
    TexRow(c("Type", "Sample", "Participation", rep(c("Coefficient", "Obs"), 2))) +
    TexMidrule() +
    TexRow(c("", "ITT"), cspan=c(3, 4)) +
    TexMidrule(list(c(4, 7))) +
    regression_row(c("All", "Full", "Any"),
                   regression_result_all, 1, 2+5) +
    regression_row(c("Center $+$ Mixed", "Full", "Any"),
                   regression_result_all, 1, 62+5) +
    regression_row(c("Center Only", "Full", "Any"),
                   regression_result_all, 1, 122+5, arrow=FALSE) +
    regression_row(c("Center Only", "Subsample", "Any"),
                   regression_result_all, 1, 152+5, arrow=FALSE) +
    TexMidrule() +
    TexRow(c("", "LATE"), cspan=c(3, 4)) +
    TexMidrule(list(c(4, 7))) +
    regression_row(c("Center Only", "Subsample", "Any"),
                   regression_result_all, 2, 167+5, arrow=FALSE) +
    regression_row(c("Center Only", "Subsample", "1m"),
                   regression_result_D, 2, 167+5, arrow=FALSE) +
    regression_row(c("Center Only", "Subsample", "12m"),
                   regression_result, 2, 167+5, arrow=FALSE) +
    TexRow(c("Center Only", "Subsample", "12m")) /
    TexRow(c(instrumental_subset$to_estimate[3],
             instrumental_subset$N[3]) %>% as.numeric(), 
           pvalues=c(instrumental_subset$to_p_value[3], 1) %>% as.numeric(), 
           dec=c(2, 0)) / TexRow("-") +
    TexRow(c("", "(Instrumental Forest (ABC))", "")) / 
    TexRow(c(instrumental_subset$to_se[3], NA) %>% as.numeric(), 
           dec=c(2, 0), se=TRUE)
  return(tab)
}

tab <- progress_tex(instrumental_output,
                    regression_output, regression_output_all, regression_output_D)
TexSave(tab, filename="progress_base", positions=c(rep('l', 3), rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="progress_base", positions=c(rep('l', 3), rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)

# Prevalence and subLATE bounds
prevalence_sublate_tex <- function(instrumental_result, prevalence_result) {
  ehscenter_late <- instrumental_result$coefficient[9]
  abc_late <- instrumental_result$coefficient[12]
  
  row_tr <- function(col) {
    out <- TexRow(prevalence_result[c(6, 8), col] %>% as.numeric(),
                  cspan=c(2, 2), dec=2)
    return(out)
  }
  
  tab <- TexRow(c("Program", "EHS Center Only", "ABC"), cspan=c(1, 2, 2)) +
    TexMidrule() +
    TexRow(c("", "Prevalence of Compliance Types"), cspan=c(1, 4)) +
    TexMidrule(list(c(2, 5))) +
    TexRow(c("\\textbf{Observations}")) / 
    TexRow(prevalence_result[c(6, 8), 2] %>% as.numeric(),
           cspan=c(2, 2), dec=0) +
    TexRow("\\textbf{Compliers}") +
    TexRow("\\quad $p_{nh}$") / row_tr(3) +
    TexRow("\\quad $p_{ch}$") / row_tr(4) +
    TexRow("\\textbf{Share}") +
    TexRow("\\quad $\\omega_{nh}$") / row_tr(5) +
    TexRow("\\textbf{Always-Takers}") +
    TexRow("\\quad $p_{hh}$") / row_tr(6) +
    TexRow("\\quad $p_{cc}$") / row_tr(7) +
    TexRow("\\quad $p_{nn}$") / row_tr(8) +
    TexMidrule() +
    TexRow(c("", "sub-LATE Bounds"), cspan=c(1, 4)) +
    TexMidrule(list(c(2, 5))) +
    TexRow(c("", rep(c("ch-LATE", "nh-LATE"), 2))) +
    TexMidrule(list(c(2, 3), c(4, 5))) +
    TexRow("\\textbf{Bounds}") +
    TexRow("\\quad Lower Bound") /
    TexRow(c(0, 
             ehscenter_late,
             0,
             abc_late), 
           dec=2) +
    TexRow("\\quad Upper Bound") /
    TexRow(c(ehscenter_late, 
             ehscenter_late/prevalence_result$nh_share[6],
             abc_late,
             abc_late/prevalence_result$nh_share[8]),
           dec=2)
  return(tab)
}

tab <- prevalence_sublate_tex(instrumental_output, prevalence_output)
TexSave(tab, filename="prevalence_bounds", positions=c('l', rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="prevalence_bounds", positions=c('l', rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
