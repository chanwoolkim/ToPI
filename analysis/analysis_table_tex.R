start_time <- Sys.time()

causal_output <- read.csv(file=paste0(output_git, "causal_output.csv"))
instrumental_output <- read.csv(paste0(output_git, "instrumental_output.csv"))
regression_output <- read.csv(paste0(output_git, "regression_output.csv"))
prevalence_output <- read.csv(paste0(output_git, "prevalence_output.csv"))


# Output to LaTeX tables ####
# Summary of important coefficients
coefficients_tex <- function(causal_result, instrumental_result, regression_result) {
  causal_subset <- causal_result %>% filter(subsample)
  instrumental_subset <- instrumental_result %>% filter(subsample)
  
  tab <- TexRow(c("", "EHS", "ABC"), cspan=c(1, 3, 1)) +
    TexMidrule(list(c(2, 4))) +
    TexRow(c("", "All", "Center $+$ Mixed", "Center Only", "")) +
    TexMidrule() +
    TexRow(c("", "ITT"), cspan=c(1, 4)) +
    TexMidrule(list(c(2, 5))) +
    TexRow("Full/No Xs") / 
    TexRow(regression_output[1, seq(2, 241, 60)] %>% as.numeric(), 
           pvalues=regression_output[1, seq(4, 241, 60)] %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(regression_output[1, seq(3, 241, 60)] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("Subsample/No Xs") / 
    TexRow(regression_output[1, seq(32, 241, 60)] %>% as.numeric(), 
           pvalues=regression_output[1, seq(34, 241, 60)] %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(regression_output[1, seq(33, 241, 60)] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("Subsample/Causal Forest") / 
    TexRow(causal_subset$pre_dr_estimate %>% as.numeric(), 
           pvalues=causal_subset$pre_dr_p_value %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(causal_subset$pre_dr_se %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("Subsample/Causal Forest (ABC)") / 
    TexRow(causal_subset$to_estimate[1:3] %>% as.numeric(), 
           pvalues=causal_subset$to_p_value[1:3] %>% as.numeric(), 
           dec=3) / TexRow("-") +
    TexRow("") / 
    TexRow(causal_subset$to_se[1:3] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexMidrule() +
    TexRow(c("", "LATE"), cspan=c(1, 4)) +
    TexMidrule(list(c(2, 5))) +
    TexRow("Full/No Xs") / 
    TexRow(regression_output[2, seq(17, 241, 60)] %>% as.numeric(), 
           pvalues=regression_output[2, seq(19, 241, 60)] %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(regression_output[2, seq(18, 241, 60)] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("Subsample/No Xs") / 
    TexRow(regression_output[2, seq(47, 241, 60)] %>% as.numeric(), 
           pvalues=regression_output[2, seq(49, 241, 60)] %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(regression_output[2, seq(48, 241, 60)] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("Subsample/Causal Forest") / 
    TexRow(instrumental_subset$pre_dr_estimate %>% as.numeric(), 
           pvalues=instrumental_subset$pre_dr_p_value %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(instrumental_subset$pre_dr_se %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("Subsample/Causal Forest (ABC)") / 
    TexRow(instrumental_subset$to_estimate[1:3] %>% as.numeric(), 
           pvalues=instrumental_subset$to_p_value[1:3] %>% as.numeric(), 
           dec=3) / TexRow("-") +
    TexRow("") / 
    TexRow(instrumental_subset$to_se[1:3] %>% as.numeric(), 
           dec=3, se=TRUE)
  return(tab)
}

tab <- coefficients_tex(causal_output, instrumental_output, regression_output)
TexSave(tab, filename="coefficients_base", positions=c('l', rep('c', 5)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="coefficients_base", positions=c('l', rep('c', 5)),
        output_path=output_git, stand_alone=FALSE)

# Progress table
progress_tex <- function(causal_result, instrumental_result, regression_result) {
  causal_subset <- causal_result %>% filter(subsample)
  instrumental_subset <- instrumental_result %>% filter(subsample)
  
  tab <- TexRow(c("", "EHS", "ABC")) +
    TexMidrule() +
    TexRow("ITT") /
    TexRow(regression_output[1, 2] %>% as.numeric(), 
           pvalues=regression_output[1, 4] %>% as.numeric(), 
           dec=3) / TexRow("-") +
    TexRow("") / 
    TexRow(regression_output[1, 3] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("ITT - Center $+$ Mixed") /
    TexRow(regression_output[1, 62] %>% as.numeric(), 
           pvalues=regression_output[1, 64] %>% as.numeric(), 
           dec=3) / TexRow("-") +
    TexRow("") / 
    TexRow(regression_output[1, 63] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("ITT - Center Only") /
    TexRow(regression_output[1, c(122, 182)] %>% as.numeric(), 
           pvalues=regression_output[1, c(124, 184)] %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(regression_output[1, c(123, 183)] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("LATE - Center Only") /
    TexRow(regression_output[2, c(137, 197)] %>% as.numeric(), 
           pvalues=regression_output[2, c(139, 199)] %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(regression_output[2, c(138, 198)] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("LATE - Center Only (Subsample)") /
    TexRow(regression_output[2, c(167, 227)] %>% as.numeric(), 
           pvalues=regression_output[2, c(169, 229)] %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(regression_output[2, c(168, 228)] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("LATE - Instrumental Forest") /
    TexRow(instrumental_subset$pre_dr_estimate[3:4] %>% as.numeric(), 
           pvalues=instrumental_subset$pre_dr_p_value[3:4] %>% as.numeric(), 
           dec=3) +
    TexRow("") / 
    TexRow(instrumental_subset$pre_dr_se[3:4] %>% as.numeric(), 
           dec=3, se=TRUE) +
    TexRow("LATE - Instrumental Forest (ABC)") /
    TexRow(instrumental_subset$to_estimate[3] %>% as.numeric(), 
           pvalues=instrumental_subset$to_p_value[3] %>% as.numeric(), 
           dec=3) / TexRow("-") +
    TexRow("") / 
    TexRow(instrumental_subset$to_se[3] %>% as.numeric(), 
           dec=3, se=TRUE)
    return(tab)
}

tab <- progress_tex(causal_output, instrumental_output, regression_output)
TexSave(tab, filename="progress_base", positions=c('l', rep('c', 2)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="progress_base", positions=c('l', rep('c', 2)),
        output_path=output_git, stand_alone=FALSE)

# Type prevalence output
prevalence_tex <- function(prevalence_result) {
  row_tr <- function(row) {
    out <- TexRow(prevalence_result[row, 2:8] %>% as.numeric(),
                  dec=c(0, rep(3, 6)))
    return(out)
  }
  
  tab <- TexRow(c("", "Compliers", "", "Always-Takers"), cspan=c(2, 2, 1, 3)) +
    TexMidrule(list(c(3, 4), c(6, 8))) +
    TexRow(c("Sample", "Obs",
             "$p_{nh}$", "$p_{ch}$", "$nh$-share", "$p_{hh}$", "$p_{cc}$", "$p_{nn}$")) +
    TexMidrule() +
    TexRow(c("", "", "Program: EHS, Center Only"), cspan=c(1, 1, 6)) +
    TexMidrule(list(c(3, 8))) +
    TexRow("Full") / row_tr(5) + TexRow("Subsample") / row_tr(6) +
    TexMidrule() +
    TexRow(c("", "", "Program: ABC"), cspan=c(1, 1, 6)) +
    TexMidrule(list(c(3, 8))) +
    TexRow("Full") / row_tr(7) + TexRow("Subsample") / row_tr(8)
  return(tab)
}

tab <- prevalence_tex(prevalence_output)
TexSave(tab, filename="type_prevalence", positions=c('l', rep('c', 7)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="type_prevalence", positions=c('l', rep('c', 7)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
