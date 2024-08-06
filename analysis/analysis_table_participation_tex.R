start_time <- Sys.time()

# Load data ####
instrumental_output_1 <- read.csv(paste0(output_git, "instrumental_output_D_1_P_1.csv"))
regression_output_1 <- read.csv(paste0(output_git, "regression_output_D_1_P_1.csv"))

instrumental_output_6 <- read.csv(paste0(output_git, "instrumental_output_D_6_P_6.csv"))
regression_output_6 <- read.csv(paste0(output_git, "regression_output_D_6_P_6.csv"))

instrumental_output_12 <- read.csv(paste0(output_git, "instrumental_output_D_12_P_12.csv"))
regression_output_12 <- read.csv(paste0(output_git, "regression_output_D_12_P_12.csv"))

instrumental_output_18 <- read.csv(paste0(output_git, "instrumental_output_D_18_P_18.csv"))
regression_output_18 <- read.csv(paste0(output_git, "regression_output_D_18_P_18.csv"))


# TeX table ####
# Progress table
instrumental_subset_1 <- instrumental_output_1 %>% filter(subsample)
instrumental_subset_6 <- instrumental_output_6 %>% filter(subsample)
instrumental_subset_12 <- instrumental_output_12 %>% filter(subsample)
instrumental_subset_18 <- instrumental_output_18 %>% filter(subsample)

tab <- TexRow(c("Participation", "1m", "6m", "12m", "18m")) +
  TexMidrule() +
  TexRow("LATE - Center Only (Subsample)") /
  TexRow(c(regression_output_1[2, 167],
           regression_output_6[2, 167],
           regression_output_12[2, 167],
           regression_output_18[2, 167]) %>% as.numeric(),
         pvalues=c(regression_output_1[2, 169],
                   regression_output_6[2, 169],
                   regression_output_12[2, 169],
                   regression_output_18[2, 169]) %>% as.numeric(),
         dec=2) +
  TexRow("") / 
  TexRow(c(regression_output_1[2, 168],
           regression_output_6[2, 168],
           regression_output_12[2, 168],
           regression_output_18[2, 168]) %>% as.numeric(),
         dec=2, se=TRUE) +
  TexRow("LATE - Instrumental Forest (ABC)") /
  TexRow(c(instrumental_subset_1$to_estimate[3],
           instrumental_subset_6$to_estimate[3],
           instrumental_subset_12$to_estimate[3],
           instrumental_subset_18$to_estimate[3]) %>% as.numeric(), 
         pvalues=c(instrumental_subset_1$to_p_value[3],
                   instrumental_subset_6$to_p_value[3],
                   instrumental_subset_12$to_p_value[3],
                   instrumental_subset_18$to_p_value[3]) %>% as.numeric(), 
         dec=2) +
  TexRow("") / 
  TexRow(c(instrumental_subset_1$to_se[3],
           instrumental_subset_6$to_se[3],
           instrumental_subset_12$to_se[3],
           instrumental_subset_18$to_se[3]) %>% as.numeric(), 
         dec=2, se=TRUE)

TexSave(tab, filename="progress_participation", positions=c('l', rep('c', 4)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="progress_participation", positions=c('l', rep('c', 4)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
