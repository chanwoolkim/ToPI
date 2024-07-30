# Load data ####
causal_output_1 <- read.csv(paste0(output_git, "causal_output_D_1_P_1.csv"))
instrumental_output_1 <- read.csv(paste0(output_git, "instrumental_output_D_1_P_1.csv"))
regression_output_1 <- read.csv(paste0(output_git, "regression_output_D_1_P_1.csv"))
prevalence_output_1 <- read.csv(paste0(output_git, "prevalence_output_D_1_P_1.csv"))

causal_output_12 <- read.csv(paste0(output_git, "causal_output_D_12_P_12.csv"))
instrumental_output_12 <- read.csv(paste0(output_git, "instrumental_output_D_12_P_12.csv"))
regression_output_12 <- read.csv(paste0(output_git, "regression_output_D_12_P_12.csv"))
prevalence_output_12 <- read.csv(paste0(output_git, "prevalence_output_D_12_P_12.csv"))

causal_output_new <- read.csv(paste0(output_git, "causal_output_new_D_P.csv"))
instrumental_output_new <- read.csv(paste0(output_git, "instrumental_output_new_D_P.csv"))
regression_output_new <- read.csv(paste0(output_git, "regression_output_new_D_P.csv"))
prevalence_output_new <- read.csv(paste0(output_git, "prevalence_output_new_D_P.csv"))

causal_output_new_1 <- read.csv(paste0(output_git, "causal_output_new_D_1_P_1.csv"))
instrumental_output_new_1 <- read.csv(paste0(output_git, "instrumental_output_new_D_1_P_1.csv"))
regression_output_new_1 <- read.csv(paste0(output_git, "regression_output_new_D_1_P_1.csv"))
prevalence_output_new_1 <- read.csv(paste0(output_git, "prevalence_output_new_D_1_P_1.csv"))

causal_output_new_6 <- read.csv(paste0(output_git, "causal_output_new_D_6_P_6.csv"))
instrumental_output_new_6 <- read.csv(paste0(output_git, "instrumental_output_new_D_6_P_6.csv"))
regression_output_new_6 <- read.csv(paste0(output_git, "regression_output_new_D_6_P_6.csv"))
prevalence_output_new_6 <- read.csv(paste0(output_git, "prevalence_output_new_D_6_P_6.csv"))

causal_output_new_12 <- read.csv(paste0(output_git, "causal_output_new_D_12_P_12.csv"))
instrumental_output_new_12 <- read.csv(paste0(output_git, "instrumental_output_new_D_12_P_12.csv"))
regression_output_new_12 <- read.csv(paste0(output_git, "regression_output_new_D_12_P_12.csv"))
prevalence_output_new_12 <- read.csv(paste0(output_git, "prevalence_output_new_D_12_P_12.csv"))

causal_output_new_18 <- read.csv(paste0(output_git, "causal_output_new_D_18_P_18.csv"))
instrumental_output_new_18 <- read.csv(paste0(output_git, "instrumental_output_new_D_18_P_18.csv"))
regression_output_new_18 <- read.csv(paste0(output_git, "regression_output_new_D_18_P_18.csv"))
prevalence_output_new_18 <- read.csv(paste0(output_git, "prevalence_output_new_D_18_P_18.csv"))


# TeX table ####
# Progress table
causal_subset_1 <- causal_output_1 %>% filter(subsample)
instrumental_subset_1 <- instrumental_output_1 %>% filter(subsample)

causal_subset_12 <- causal_output_12 %>% filter(subsample)
instrumental_subset_12 <- instrumental_output_12 %>% filter(subsample)

causal_subset_new <- causal_output_new %>% filter(subsample)
instrumental_subset_new <- instrumental_output_new %>% filter(subsample)

causal_subset_new_1 <- causal_output_new_1 %>% filter(subsample)
instrumental_subset_new_1 <- instrumental_output_new_1 %>% filter(subsample)

causal_subset_new_6 <- causal_output_new_6 %>% filter(subsample)
instrumental_subset_new_6 <- instrumental_output_new_6 %>% filter(subsample)

causal_subset_new_12 <- causal_output_new_12 %>% filter(subsample)
instrumental_subset_new_12 <- instrumental_output_new_12 %>% filter(subsample)

causal_subset_new_18 <- causal_output_new_18 %>% filter(subsample)
instrumental_subset_new_18 <- instrumental_output_new_18 %>% filter(subsample)

regression_row <- function(colname, row, col, arrow=TRUE) {
  if (arrow) {
    out <- TexRow(colname) / 
      TexRow(c(regression_output_12[row, col],
               regression_output_1[row, col],
               regression_output_new[row, col],
               regression_output_new_1[row, col],
               regression_output_new_6[row, col],
               regression_output_new_12[row, col],
               regression_output_new_18[row, col])  %>% as.numeric(), 
             pvalues=c(regression_output_12[row, col+2],
                       regression_output_1[row, col+2],
                       regression_output_new[row, col+2],
                       regression_output_new_1[row, col+2],
                       regression_output_new_6[row, col+2],
                       regression_output_new_12[row, col+2],
                       regression_output_new_18[row, col+2]) %>% as.numeric(), 
             dec=2) / TexRow("-") +
      TexRow("") / 
      TexRow(c(regression_output_12[row, col+1],
               regression_output_1[row, col+1],
               regression_output_new[row, col+1],
               regression_output_new_1[row, col+1],
               regression_output_new_6[row, col+1],
               regression_output_new_12[row, col+1],
               regression_output_new_18[row, col+1]) %>% as.numeric(), 
             dec=2, se=TRUE)
  } else {
    out <- TexRow(colname) /
      TexRow(c(regression_output_12[row, col],
               regression_output_1[row, col],
               regression_output_new[row, col],
               regression_output_new_1[row, col],
               regression_output_new_6[row, col],
               regression_output_new_12[row, col],
               regression_output_new_18[row, col],
               regression_output_12[row, col+60]) %>% as.numeric(),
             pvalues=c(regression_output_12[row, col+2],
                       regression_output_1[row, col+2],
                       regression_output_new[row, col+2],
                       regression_output_new_1[row, col+2],
                       regression_output_new_6[row, col+2],
                       regression_output_new_12[row, col+2],
                       regression_output_new_18[row, col+2],
                       regression_output_12[row, col+62]) %>% as.numeric(),
             dec=2) +
      TexRow("") / 
      TexRow(c(regression_output_12[row, col+1],
               regression_output_1[row, col+1],
               regression_output_new[row, col+1],
               regression_output_new_1[row, col+1],
               regression_output_new_6[row, col+1],
               regression_output_new_12[row, col+1],
               regression_output_new_18[row, col+1],
               regression_output_12[row, col+61]) %>% as.numeric(),
             dec=2, se=TRUE)
  }
  return(out)
}

tab <- TexRow(c("", "EHS", "ABC"), cspan=c(1, 7, 1)) +
  TexMidrule(list(c(2, 8), c(9, 9))) +
  TexRow(c("Data", "Old", "New", "Old"), cspan=c(1, 2, 5, 1)) +
  TexMidrule(list(c(1, 1), c(2, 3), c(4, 8), c(9, 9))) +
  TexRow(c("Month", "12", "1", "-", "1", "6", "12", "18", "12")) +
  TexMidrule() +
  regression_row("ITT", 1, 2) +
  regression_row("ITT - Center $+$ Mixed", 1, 62) +
  regression_row("ITT - Center Only", 1, 122, arrow=FALSE) +
  regression_row("ITT - Center Only (Subsample)", 1, 152, arrow=FALSE) +
  regression_row("LATE - Center Only (Subsample)", 2, 167, arrow=FALSE) +
  TexRow("LATE - Instrumental Forest (ABC)") /
  TexRow(c(instrumental_subset_12$to_estimate[3],
           instrumental_subset_1$to_estimate[3],
           instrumental_subset_new$to_estimate[3],
           instrumental_subset_new_1$to_estimate[3],
           instrumental_subset_new_6$to_estimate[3],
           instrumental_subset_new_12$to_estimate[3],
           instrumental_subset_new_18$to_estimate[3]) %>% as.numeric(), 
         pvalues=c(instrumental_subset_12$to_p_value[3],
                   instrumental_subset_1$to_p_value[3],
                   instrumental_subset_new$to_p_value[3],
                   instrumental_subset_new_1$to_p_value[3],
                   instrumental_subset_new_6$to_p_value[3],
                   instrumental_subset_new_12$to_p_value[3],
                   instrumental_subset_new_18$to_p_value[3]) %>% as.numeric(), 
         dec=2) / TexRow("-") +
  TexRow("") / 
  TexRow(c(instrumental_subset_12$to_se[3],
           instrumental_subset_1$to_se[3],
           instrumental_subset_new$to_se[3],
           instrumental_subset_new_1$to_se[3],
           instrumental_subset_new_6$to_se[3],
           instrumental_subset_new_12$to_se[3],
           instrumental_subset_new_18$to_se[3]) %>% as.numeric(), 
         dec=2, se=TRUE)

TexSave(tab, filename="progress_participation", positions=c('l', rep('c', 8)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="progress_participation", positions=c('l', rep('c', 8)),
        output_path=output_git, stand_alone=FALSE)

# Type prevalence output
row_tr <- function(prevalence_result, row) {
  out <- TexRow(prevalence_result[row, 2:8] %>% as.numeric(),
                dec=c(0, rep(2, 6)))
  return(out)
}

tab <- TexRow(c("", "Compliers", "", "Always-Takers"), cspan=c(2, 2, 1, 3)) +
  TexMidrule(list(c(3, 4), c(6, 8))) +
  TexRow(c("Program/Participation", "Obs",
           "$p_{nh}$", "$p_{ch}$", "$\\omega_{nh}$", "$p_{hh}$", "$p_{cc}$", "$p_{nn}$")) +
  TexMidrule() +
  TexRow("\\textbf{EHS - Center Only}") +
  TexRow("\\quad Old/12") / row_tr(prevalence_output_12, 6) +
  TexRow("\\quad Old/1") / row_tr(prevalence_output_1, 6) +
  TexRow("\\quad New/-") / row_tr(prevalence_output_new, 6) +
  TexRow("\\quad New/1") / row_tr(prevalence_output_new_1, 6) +
  TexRow("\\quad New/6") / row_tr(prevalence_output_new_6, 6) +
  TexRow("\\quad New/12") / row_tr(prevalence_output_new_12, 6) +
  TexRow("\\quad New/18") / row_tr(prevalence_output_new_18, 6) +
  TexRow("\\textbf{ABC}") +
  TexRow("\\quad Old/12") / row_tr(prevalence_output_12, 8)

TexSave(tab, filename="type_prevalence_participation", positions=c('l', rep('c', 7)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="type_prevalence_participation", positions=c('l', rep('c', 7)),
        output_path=output_git, stand_alone=FALSE)
