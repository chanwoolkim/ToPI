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


# Output to LaTeX tables ####
# Summary of important coefficients
coefficients_tex <- function(causal_result, instrumental_result, regression_result,
                             causal_result_all, instrumental_result_all, regression_result_all) {
  causal_subset <- causal_result %>% filter(subsample)
  instrumental_subset <- instrumental_result %>% filter(subsample)
  causal_subset_all <- causal_result_all %>% filter(subsample)
  instrumental_subset_all <- instrumental_result_all %>% filter(subsample)
  
  regression_row <- function(colname, row, begin) {
    out <- TexRow(colname) / 
      TexRow(c(regression_result_all[row, seq(begin, 121, 60)],
               regression_result[row, seq(begin+60, 241, 60)]) %>% as.numeric(),
             pvalues=c(regression_result_all[row, seq(begin+2, 121, 60)],
                       regression_result[row, seq(begin+62, 241, 60)]) %>% as.numeric(),
             dec=2) +
      TexRow("") /
      TexRow(c(regression_result_all[row, seq(begin+1, 121, 60)],
               regression_result[row, seq(begin+61, 241, 60)]) %>% as.numeric(),
             dec=2, se=TRUE)
    return(out)
  }
  
  tab <- TexRow(c("", "EHS", "ABC"), cspan=c(1, 4, 1)) +
    TexMidrule(list(c(2, 5), c(6, 6))) +
    TexRow(c("", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 1, 2, 1, 1)) +
    TexMidrule(list(c(2, 2), c(3, 4), c(5, 5))) +
    TexRow(c("", "All", "All", "Center", "Center", "Center")) +
    TexMidrule() +
    TexRow(c("", "ITT"), cspan=c(1, 5)) +
    TexMidrule(list(c(2, 6))) +
    regression_row("Full/No Xs", 1, 2) +
    regression_row("Subsample/No Xs", 1, 32) +
    TexRow("Subsample/Causal Forest") / 
    TexRow(c(causal_subset_all$pre_dr_estimate[1:2],
             causal_subset$pre_dr_estimate[2:4]) %>% as.numeric(), 
           pvalues=c(causal_subset_all$pre_dr_p_value[1:2],
                     causal_subset$pre_dr_p_value[2:4]) %>% as.numeric(), 
           dec=2) +
    TexRow("") / 
    TexRow(c(causal_subset_all$pre_dr_se[1:2],
             causal_subset$pre_dr_se[2:4]) %>% as.numeric(), 
           dec=2, se=TRUE) +
    TexRow("Subsample/Causal Forest (ABC)") / 
    TexRow(c(causal_subset_all$to_estimate[1:2],
             causal_subset$to_estimate[2:3]) %>% as.numeric(), 
           pvalues=c(causal_subset_all$to_p_value[1:2],
                     causal_subset$to_p_value[2:3]) %>% as.numeric(), 
           dec=2) / TexRow("-") +
    TexRow("") / 
    TexRow(c(causal_subset_all$to_se[1:2],
             causal_subset$to_se[2:3]) %>% as.numeric(), 
           dec=2, se=TRUE) +
    TexMidrule() +
    TexRow(c("", "LATE"), cspan=c(1, 5)) +
    TexMidrule(list(c(2, 6))) +
    regression_row("Full/No Xs", 2, 17) +
    regression_row("Subsample/No Xs", 2, 47) +
    TexRow("Subsample/Causal Forest") / 
    TexRow(c(instrumental_subset_all$pre_dr_estimate[1:2],
             instrumental_subset$pre_dr_estimate[2:4]) %>% as.numeric(), 
           pvalues=c(instrumental_subset_all$pre_dr_p_value[1:2],
                     instrumental_subset$pre_dr_p_value[2:4]) %>% as.numeric(), 
           dec=2) +
    TexRow("") / 
    TexRow(c(instrumental_subset_all$pre_dr_se[1:2],
             instrumental_subset$pre_dr_se[2:4]) %>% as.numeric(), 
           dec=2, se=TRUE) +
    TexRow("Subsample/Causal Forest (ABC)") / 
    TexRow(c(instrumental_subset_all$to_estimate[1:2],
             instrumental_subset$to_estimate[2:3]) %>% as.numeric(), 
           pvalues=c(instrumental_subset_all$to_p_value[1:2],
                     instrumental_subset$to_p_value[2:3]) %>% as.numeric(), 
           dec=2) / TexRow("-") +
    TexRow("") / 
    TexRow(c(instrumental_subset_all$to_se[1:2],
             instrumental_subset$to_se[2:3]) %>% as.numeric(), 
           dec=2, se=TRUE)
  return(tab)
}

tab <- coefficients_tex(causal_output, instrumental_output, regression_output,
                        causal_output_all, instrumental_output_all, regression_output_all)
TexSave(tab, filename="coefficients_base", positions=c('l', rep('c', 5)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="coefficients_base", positions=c('l', rep('c', 5)),
        output_path=output_git, stand_alone=FALSE)

# Progress table
progress_tex <- function(causal_result, instrumental_result, regression_result,
                         causal_result_all, instrumental_result_all, regression_result_all) {
  causal_subset <- causal_result %>% filter(subsample)
  instrumental_subset <- instrumental_result %>% filter(subsample)
  causal_subset_all <- causal_result_all %>% filter(subsample)
  instrumental_subset_all <- instrumental_result_all %>% filter(subsample)
  
  regression_row <- function(colname, nextcolname, result, row, col, arrow=TRUE) {
    if (arrow) {
      out <- TexRow(colname) / 
        TexRow(c(result[row, col],
                 result[12, col+4]) %>% as.numeric(), 
               pvalues=c(result[row, col+2], 1) %>% as.numeric(), 
               dec=c(2, 0)) / TexRow("-") +
        TexRow(nextcolname) / 
        TexRow(c(result[row, col+1], NA) %>% as.numeric(), 
               dec=2, se=TRUE)
    } else {
      out <- TexRow(colname) /
        TexRow(c(result[row, col],
                 result[row, col+4],
                 result[row, col+60],
                 result[row, col+64]) %>% as.numeric(), 
               pvalues=c(result[row, col+2],
                         1,
                         result[row, col+62],
                         1) %>% as.numeric(), 
               dec=rep(c(2, 0), 2)) +
        TexRow(nextcolname) / 
        TexRow(c(result[row, col+1],
                 NA,
                 result[row, col+61],
                 NA) %>% as.numeric(), 
               dec=rep(c(2, 0), 2), se=TRUE)
    }
    return(out)
  }
  
  tab <- TexRow(c("", "EHS", "ABC"), cspan=c(1, 2, 2)) +
    TexMidrule(list(c(2, 3), c(4, 5))) +
    TexRow(c("", "Coefficient", "Obs", "Coefficient", "Obs")) +
    TexMidrule() +
    regression_row("ITT", "", 
                   regression_result_all, 1, 2) +
    regression_row("ITT - Center $+$ Mixed", "", 
                   regression_result_all, 1, 62) +
    regression_row("ITT - Center Only", "",
                   regression_result, 1, 122, arrow=FALSE) +
    regression_row("ITT - Center Only",  "(Subsample)",
                   regression_result, 1, 152, arrow=FALSE) +
    regression_row("LATE - Center Only", "(Subsample)",
                   regression_result, 2, 167, arrow=FALSE) +
    TexRow("LATE - Center Only") /
    TexRow(c(instrumental_subset$to_estimate[3],
             instrumental_subset$N[3]) %>% as.numeric(), 
           pvalues=c(instrumental_subset$to_p_value[3], 1) %>% as.numeric(), 
           dec=c(2, 0)) / TexRow("-") +
    TexRow("(Instrumental Forest (ABC))") / 
    TexRow(c(instrumental_subset$to_se[3], NA) %>% as.numeric(), 
           dec=c(2, 0), se=TRUE)
  return(tab)
}

tab <- progress_tex(causal_output, instrumental_output, regression_output,
                    causal_output_all, instrumental_output_all, regression_output_all)
TexSave(tab, filename="progress_base", positions=c('l', rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="progress_base", positions=c('l', rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)

# Type prevalence output
prevalence_tex <- function(prevalence_result) {
  row_tr <- function(row) {
    out <- TexRow(prevalence_result[row, 2:8] %>% as.numeric(),
                  dec=c(0, rep(2, 6)))
    return(out)
  }
  
  tab <- TexRow(c("", "Compliers", "", "Always-Takers"), cspan=c(2, 2, 1, 3)) +
    TexMidrule(list(c(3, 4), c(6, 8))) +
    TexRow(c("Program", "Obs",
             "$p_{nh}$", "$p_{ch}$", "$\\omega_{nh}$", "$p_{hh}$", "$p_{cc}$", "$p_{nn}$")) +
    TexMidrule() +
    TexRow("EHS - Center Only") / row_tr(6) +
    TexRow("ABC") / row_tr(8)
  return(tab)
}

tab <- prevalence_tex(prevalence_output)
TexSave(tab, filename="type_prevalence", positions=c('l', rep('c', 7)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="type_prevalence", positions=c('l', rep('c', 7)),
        output_path=output_git, stand_alone=FALSE)

# subLATE bounds
bounds_tex <- function(instrumental_result, prevalence_result) {
  ehscenter_late <- instrumental_result$coefficient[9]
  abc_late <- instrumental_result$coefficient[12]
  
  tab <- TexRow(c("", "EHS", ""), cspan=c(1, 2, 2)) +
    TexRow(c("", "Center Only", "ABC"), cspan=c(1, 2, 2)) +
    TexMidrule(list(c(2, 3), c(4, 5))) +
    TexRow(c("", rep(c("ch-LATE", "nh-LATE"), 2))) +
    TexMidrule() +
    TexRow("lower bound") /
    TexRow(c(0, 
             ehscenter_late,
             0,
             abc_late), 
           dec=2) +
    TexRow("upper bound") /
    TexRow(c(ehscenter_late, 
             ehscenter_late/prevalence_result$nh_share[6],
             abc_late,
             abc_late/prevalence_result$nh_share[8]),
           dec=2)
  return(tab)
}

tab <- bounds_tex(instrumental_output, prevalence_output)
TexSave(tab, filename="sublate_bounds", positions=rep('c', 5),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="sublate_bounds", positions=rep('c', 5),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
