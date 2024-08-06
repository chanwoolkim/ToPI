start_time <- Sys.time()

# Load data
causal_output <- read.csv(file=paste0(output_git, "causal_output_D_12_P_12.csv"))
instrumental_output <- read.csv(paste0(output_git, "instrumental_output_D_12_P_12.csv"))
regression_output <- read.csv(paste0(output_git, "regression_output_D_12_P_12.csv"))
prevalence_output <- read.csv(paste0(output_git, "prevalence_output_D_12_P_12.csv"))

causal_output_all <- read.csv(file=paste0(output_git, "causal_output_E_P.csv"))
instrumental_output_all <- read.csv(paste0(output_git, "instrumental_output_E_P.csv"))
regression_output_all <- read.csv(paste0(output_git, "regression_output_E_P.csv"))
prevalence_output_all <- read.csv(paste0(output_git, "prevalence_output_E_P.csv"))

causal_output_D <- read.csv(file=paste0(output_git, "causal_output_D_1_P_1.csv"))
instrumental_output_D <- read.csv(paste0(output_git, "instrumental_output_D_1_P_1.csv"))
regression_output_D <- read.csv(paste0(output_git, "regression_output_D_1_P_1.csv"))
prevalence_output_D <- read.csv(paste0(output_git, "prevalence_output_D_1_P_1.csv"))

# Output to LaTeX tables ####
# Summary of important coefficients
coefficients_tex <- function(causal_result, instrumental_result, regression_result,
                             causal_result_all, instrumental_result_all, regression_result_all,
                             causal_result_D, instrumental_result_D, regression_result_D) {
  causal_subset <- causal_result %>% filter(subsample)
  instrumental_subset <- instrumental_result %>% filter(subsample)
  causal_subset_all <- causal_result_all %>% filter(subsample)
  instrumental_subset_all <- instrumental_result_all %>% filter(subsample)
  causal_subset_D <- causal_result_D %>% filter(subsample)
  instrumental_subset_D <- instrumental_result_D %>% filter(subsample)
  
  regression_row <- function(colname, row, begin) {
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
    return(out)
  }
  
  tab <- TexRow(c("Program ", "EHS", "ABC"), cspan=c(1, 5, 1)) +
    TexMidrule(list(c(1, 1), c(2, 6), c(7, 7))) +
    TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 1, 1, 3, 1)) +
    TexMidrule(list(c(1, 1), c(2, 2), c(3, 3), c(4, 6))) +
    TexRow(c("Participation", "Any", "Any", "Any", "1m", "12m", "12m")) +
    TexMidrule() +
    TexRow(c("", "ITT"), cspan=c(1, 6)) +
    TexMidrule(list(c(2, 7))) +
    regression_row("Full/No Xs", 1, 2) +
    regression_row("Subsample/No Xs", 1, 32) +
    TexRow("Subsample/Causal Forest") / 
    TexRow(c(causal_subset_all$pre_dr_estimate[1:3],
             causal_subset_D$pre_dr_estimate[3],
             causal_subset$pre_dr_estimate[3:4]) %>% as.numeric(), 
           pvalues=c(causal_subset_all$pre_dr_p_value[1:3],
                     causal_subset_D$pre_dr_p_value[3],
                     causal_subset$pre_dr_p_value[3:4]) %>% as.numeric(), 
           dec=2) +
    TexRow("") / 
    TexRow(c(causal_subset_all$pre_dr_se[1:3],
             causal_subset_D$pre_dr_se[3],
             causal_subset$pre_dr_se[3:4]) %>% as.numeric(), 
           dec=2, se=TRUE) +
    TexRow("Subsample/Causal Forest (ABC)") / 
    TexRow(c(causal_subset_all$to_estimate[1:3],
             causal_subset_D$to_estimate[3],
             causal_subset$to_estimate[3]) %>% as.numeric(), 
           pvalues=c(causal_subset_all$to_p_value[1:3],
                     causal_subset_D$to_p_value[3],
                     causal_subset$to_p_value[3]) %>% as.numeric(), 
           dec=2) / TexRow("-") +
    TexRow("") / 
    TexRow(c(causal_subset_all$to_se[1:3],
             causal_subset_all$to_se[3],
             causal_subset$to_se[3]) %>% as.numeric(), 
           dec=2, se=TRUE) +
    TexMidrule() +
    TexRow(c("", "LATE"), cspan=c(1, 6)) +
    TexMidrule(list(c(2, 7))) +
    regression_row("Full/No Xs", 2, 17) +
    regression_row("Subsample/No Xs", 2, 47) +
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
           dec=2, se=TRUE)
  return(tab)
}

tab <- coefficients_tex(causal_output, instrumental_output, regression_output,
                        causal_output_all, instrumental_output_all, regression_output_all,
                        causal_output_D, instrumental_output_D, regression_output_D)
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
                   regression_result_all, 1, 2) +
    regression_row(c("Center $+$ Mixed", "Full", "Any"),
                   regression_result_all, 1, 62) +
    regression_row(c("Center Only", "Full", "Any"),
                   regression_result_all, 1, 122, arrow=FALSE) +
    regression_row(c("Center Only", "Common Support", "Any"),
                   regression_result_all, 1, 152, arrow=FALSE) +
    TexMidrule() +
    TexRow(c("", "LATE"), cspan=c(3, 4)) +
    TexMidrule(list(c(4, 7))) +
    regression_row(c("Center Only", "Common Support", "Any"),
                   regression_result_all, 2, 167, arrow=FALSE) +
    regression_row(c("Center Only", "Common Support", "1m"),
                   regression_result_D, 2, 167, arrow=FALSE) +
    regression_row(c("Center Only", "Common Support", "12m"),
                   regression_result, 2, 167, arrow=FALSE) +
    TexRow(c("Center Only", "Common Support", "12m")) /
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
