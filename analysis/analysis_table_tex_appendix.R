start_time <- Sys.time()

causal_output <- read.csv(file=paste0(output_git, "causal_output_D_P.csv"))
instrumental_output <- read.csv(paste0(output_git, "instrumental_output_D_P.csv"))
regression_output <- read.csv(paste0(output_git, "regression_output_D_P.csv"))
prevalence_output <- read.csv(paste0(output_git, "prevalence_output_D_P.csv"))


# Output to LaTeX tables ####
# Forest output
forest_tex <- function(causal_result, instrumental_result) {
  row_tr <- function(row, se=FALSE, abc=FALSE) {
    if (se) {
      if (abc) {
        out <- TexRow(c(NA, NA,
                        causal_result[row, 9:10], NA,
                        instrumental_result[row, 9:10], NA) %>% as.numeric(), se=TRUE, dec=3)
      } else{
        out <- TexRow(c(NA, NA,
                        causal_result[row, 9:11],
                        instrumental_result[row, 9:11]) %>% as.numeric(), se=TRUE, dec=3) 
      }
    } else {
      if (abc) {
        out <- TexRow(c(causal_result[row, c(4:5, 7)]) %>% as.numeric(),
                      pvalues=c(1, causal_result[row, 12:13]) %>% as.numeric(),
                      dec=c(0, rep(3, 2))) /
          TexRow(c("-")) /
          TexRow(c(instrumental_result[row, c(5,7)]) %>% as.numeric(),
                 pvalues=c(instrumental_result[row, 12:13]) %>% as.numeric(),
                 dec=3) /
          TexRow(c("-"))
      } else {
        out <- TexRow(c(causal_result[row, c(4:5, 7:8)],
                        instrumental_result[row, c(5, 7:8)]) %>% as.numeric(),
                      pvalues=c(1,
                                causal_result[row, 12:14],
                                instrumental_result[row, 12:14]) %>% as.numeric(),
                      dec=c(0, rep(3, 6)))
      }
    }
    return(out)
  }
  
  row_tr_nox <- function(col_ols, col_late, se=FALSE) {
    if (se) {
      out <- TexRow(c(NA, NA,
                      regression_output[1, col_ols+1], NA, NA,
                      regression_output[2, col_late+1], NA, NA) %>% as.numeric(), se=TRUE, dec=3)
    } else {
      out <- TexRow(c(regression_output[12, col_ols+4],
                      regression_output[1, col_ols]) %>% as.numeric(),
                    pvalues=c(1, regression_output[1, col_ols+2]) %>% as.numeric(),
                    dec=c(0, 3)) /
        TexRow(rep("-", 2)) /
        TexRow(c(regression_output[2, col_late]) %>% as.numeric(),
               pvalues=c(regression_output[2, col_late+2]) %>% as.numeric(),
               dec=3) /
        TexRow(rep("-", 2))
    }
    return(out)
  }
  
  tab <- TexRow(c("", "ITT", "LATE"), cspan=c(2, 3, 3)) +
    TexMidrule(list(c(3, 5), c(6, 8))) +
    TexRow(c("Sample/Description", "Obs", "OLS", "Causal Forest", "2SLS", "Instrumental Forest"),
           cspan=c(1, 1, 1, 2, 1, 2)) +
    TexRow(c("", "$f_X$", "$f_X^{\\text{ABC}}$",
             "", "$f_X$", "$f_X^{\\text{ABC}}$"),
           cspan=c(3, 1, 1, 1, 1, 1)) + TexMidrule() +
    TexRow(c("", "", "Program: EHS, All"), cspan=c(1, 1, 6)) +
    TexMidrule(list(c(3, 8))) +
    TexRow("Full/No Xs") / row_tr_nox(2, 17) + row_tr_nox(2, 17, se=TRUE) +
    TexRow("Full/All Xs") / row_tr(1) + row_tr(1, se=TRUE) +
    TexRow("Full/Key Xs") / row_tr(2) + row_tr(2, se=TRUE) +
    TexRow("Subsample/No Xs") / row_tr_nox(32, 47) + row_tr_nox(32, 47, se=TRUE) +
    TexRow("Subsample/Key Xs") / row_tr(3) + row_tr(3, se=TRUE) + TexMidrule() +
    TexRow(c("", "", "Program: EHS, Center $+$ Mixed"), cspan=c(1, 1, 6)) +
    TexMidrule(list(c(3, 8))) +
    TexRow("Full/No Xs") / row_tr_nox(62, 77) + row_tr_nox(62, 77, se=TRUE) +
    TexRow("Full/All Xs") / row_tr(4) + row_tr(4, se=TRUE) +
    TexRow("Full/Key Xs") / row_tr(5) + row_tr(5, se=TRUE) +
    TexRow("Subsample/No Xs") / row_tr_nox(92, 107) + row_tr_nox(92, 107, se=TRUE) +
    TexRow("Subsample/Key Xs") / row_tr(6) + row_tr(6, se=TRUE) + TexMidrule() +
    TexRow(c("", "", "Program: EHS, Center Only"), cspan=c(1, 1, 6)) +
    TexMidrule(list(c(3, 8))) +
    TexRow("Full/No Xs") / row_tr_nox(122, 137) + row_tr_nox(122, 137, se=TRUE) +
    TexRow("Full/All Xs") / row_tr(7) + row_tr(7, se=TRUE) +
    TexRow("Full/Key Xs") / row_tr(8) + row_tr(8, se=TRUE) +
    TexRow("Subsample/No Xs") / row_tr_nox(152, 167) + row_tr_nox(152, 167, se=TRUE) +
    TexRow("Subsample/Key Xs") / row_tr(9) + row_tr(9, se=TRUE) + TexMidrule() +
    TexRow(c("", "", "Program: ABC"), cspan=c(1, 1, 6)) +
    TexMidrule(list(c(3, 8))) +
    TexRow("Full/No Xs") / row_tr_nox(182, 197) + row_tr_nox(182, 197, se=TRUE) +
    TexRow("Full/All Xs") / row_tr(10, abc=TRUE) + row_tr(10, se=TRUE, abc=TRUE) +
    TexRow("Full/Key Xs") / row_tr(11, abc=TRUE) + row_tr(11, se=TRUE, abc=TRUE) +
    TexRow("Subsample/No Xs") / row_tr_nox(212, 227) + row_tr_nox(212, 227, se=TRUE) +
    TexRow("Subsample/Key Xs") / row_tr(12, abc=TRUE) + row_tr(12, se=TRUE, abc=TRUE)
  return(tab)
}

tab <- forest_tex(causal_output, instrumental_output)
TexSave(tab, filename="forest_base", positions=c('l', rep('c', 7)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="forest_base", positions=c('l', rep('c', 7)),
        output_path=output_git, stand_alone=FALSE)

# Regression output
regression_tex <- function(regression_result) {
  row_tr <- function(r_name, row, se=FALSE) {
    if (se) {
      out <- TexRow("") /
        TexRow(regression_result[row, seq(3, 61, 5)] %>%
                 as.numeric(), se=TRUE, dec=3)
    } else {
      out <- TexRow(r_name) /
        TexRow(regression_result[row, seq(2, 61, 5)] %>% as.numeric(),
               pvalues=c(replace_na(regression_result[row, seq(4, 61, 5)] %>%
                                      as.numeric(), 1)), dec=3)
    }
    return(out)
  }
  
  tab <- TexRow(c("", "Full", "Subsample"), cspan=c(1, 6, 6)) +
    TexMidrule(list(c(2, 7), c(8, 13))) +
    TexRow(c("", rep(c("OLS", "2SLS"), 2)), cspan=c(1, 3, 3, 3, 3)) +
    TexMidrule(list(c(2, 4), c(5, 7), c(8, 10), c(11, 13))) +
    TexRow("") / TexRow(1:12, surround="(%s)", dec=0) +
    TexRow(c("", rep(c("None", "All", "Short"), 4))) +
    TexMidrule() +
    row_tr("Received Offer", 1) + row_tr("R", 1, se=TRUE) +
    row_tr("Participated", 2) + row_tr("R", 2, se=TRUE) +
    row_tr("Mom IQ", 3) + row_tr("Mom IQ", 3, se=TRUE) +
    row_tr("Black", 4) + row_tr("Black", 4, se=TRUE) +
    row_tr("Sex", 5) + row_tr("Sex", 5, se=TRUE) +
    row_tr("Mom Age", 6) + row_tr("Mom Age", 6, se=TRUE) +
    row_tr("Mom Edu$=$HS", 7) + row_tr("Mom Edu$=$HS", 7, se=TRUE) +
    row_tr("Mom Edu$>$HS", 8) + row_tr("Mom Edu$>$HS", 8, se=TRUE) +
    row_tr("Sibling", 9) + row_tr("Sibling", 9, se=TRUE) +
    row_tr("Gestational Age", 10) + row_tr("Gestational Age", 10, se=TRUE) +
    row_tr("Father Home", 11) + row_tr("Father Home", 11, se=TRUE) +
    row_tr("(Constant)", 12) + row_tr("(Constant)", 12, se=TRUE) +
    TexMidrule() +
    TexRow("F-Stat") /
    TexRow(regression_result[12, seq(5, 61, 5)] %>% as.numeric(), dec=3) +
    TexRow("Observation") /
    TexRow(regression_result[12, seq(6, 61, 5)] %>% as.numeric(), dec=0)
  return(tab)
}

tab <- regression_tex(regression_output[, 1:61])
TexSave(tab, filename="regression_ehs", positions=c('l', rep('c', 12)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="regression_ehs", positions=c('l', rep('c', 12)),
        output_path=output_git, stand_alone=FALSE)
tab <- regression_tex(regression_output[, c(1, 62:121)])
TexSave(tab, filename="regression_ehsmixed_center", positions=c('l', rep('c', 12)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="regression_ehsmixed_center", positions=c('l', rep('c', 12)),
        output_path=output_git, stand_alone=FALSE)
tab <- regression_tex(regression_output[, c(1, 122:181)])
TexSave(tab, filename="regression_ehscenter", positions=c('l', rep('c', 12)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="regression_ehscenter", positions=c('l', rep('c', 12)),
        output_path=output_git, stand_alone=FALSE)
tab <- regression_tex(regression_output[, c(1, 182:241)])
TexSave(tab, filename="regression_abc", positions=c('l', rep('c', 12)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="regression_abc", positions=c('l', rep('c', 12)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
