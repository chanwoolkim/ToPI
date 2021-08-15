#install.packages("devtools")
#library(devtools)
#devtools::install_github("susanathey/causalTree", INSTALL_opts="--no-multiarch")

library(causalTree)
library(ggplot2)
library(tidyverse)
library(xtable)

data_dir <- "C:/Users/561CO/Downloads/"
output_dir <- "C:/Users/561CO/Downloads/"
seed <- 9657

covariate_names <- c("bw", "twin", "m_age", "m_edu", "sibling", "m_iq", "black", "sex", "gestage", "mf")

# Manual prediction
traverse_tree <- function(tree, input, ind) {
  current_var <- tree %>% filter(index==ind) %>% select(var) %>% as.character()
  
  if (current_var=="<leaf>") {
    val <- tree %>% filter(index==ind) %>% select(yval) %>% as.numeric()
    return(val)
  }
  else {
    current_val <- input %>% select(current_var) %>% as.numeric()
    
    if (is.na(current_val)) {
      return(NA)
    }
    else {
      formula <- paste0(current_val,
                        tree %>% filter(index==ind) %>% select(ltemp) %>% as.character())
      if (eval(parse(text=formula))) {
        traverse_tree(tree, input, 2*ind)
      }
      else {
        traverse_tree(tree, input, 2*ind+1)
      }
    }
  }
}

causal_matrix <- function(program, output_var, program_name) {
  formula_ct <- paste(output_var, "~", paste(covariate_names, collapse=" + "))
  causal_tree_deep <- causalTree(formula_ct,
                            data=program,
                            treatment=program$R,
                            split.Rule="CT",
                            split.Honest=FALSE,
                            cv.option="CT",
                            cv.Honest=FALSE)
  
  if (output_var=="ppvt3y" | output_var=="sb3y") {
    pdf(paste0(output_dir, program_name, "_", output_var, "_deep_plot.pdf"))
    prp(causal_tree_deep, extra=0)
    dev.off()
  }
  
  causal_tree <- causalTree(formula_ct,
                            data=program,
                            treatment=program$R,
                            split.Rule="CT",
                            split.Honest=FALSE,
                            cv.option="CT",
                            cv.Honest=FALSE,
                            minsize=25)
  
  if (output_var=="ppvt3y") {
    abc_input <- abc %>%
      select(-"sb3y")
  }
  else {
    abc_input <- abc %>%
      select(-output_var)
  }
  
  if (output_var=="ppvt3y" | output_var=="sb3y") {
    pdf(paste0(output_dir, program_name, "_", output_var, "_plot.pdf"))
    prp(causal_tree, extra=0)
    dev.off()
  }
  
  opcp <- causal_tree$cptable[, 1][which.min(causal_tree$cptable[, 4])]
  optree <- prune(causal_tree, cp=opcp)
  
  if (output_var=="ppvt3y" | output_var=="sb3y") {
    pdf(paste0(output_dir, program_name, "_", output_var, "_pruned_plot.pdf"))
    prp(optree, extra=0)
    dev.off()
  }
  
  causal_estimate <- mean(predict(causal_tree, na.action=na.omit))
  causal_estimate_abc <- mean(predict(causal_tree, newdata=abc_input, na.action=na.omit))
  
  tree <- data.frame(index=row.names(causal_tree$frame),
                     var=causal_tree$frame$var,
                     yval=causal_tree$frame$yval) %>%
    cbind(labels(causal_tree, collapse=FALSE))
  
  predicted_abc <- c()
  
  for (i in 1:nrow(abc_input)) {
    predicted_abc[i] = traverse_tree(tree, abc_input[i,], 1)
  }
  
  causal_estimate_abc_manual <- mean(predicted_abc, na.rm=TRUE)
  
  output_row <- data.frame(program=program_name,
                           output_var=output_var,
                           pre_estimate=causal_estimate,
                           abc_estimate=causal_estimate_abc,
                           abc_estimate_manual=causal_estimate_abc_manual)
  output_row
}

# Execute!
ehscenter <- read.csv(paste0(data_dir,"ehscenter-topi.csv"))
ehsmixed <- read.csv(paste0(data_dir,"ehsmixed-topi.csv"))
ihdp <- read.csv(paste0(data_dir,"ihdp-topi.csv"))
abc <- read.csv(paste0(data_dir,"abc-topi.csv")) %>%
  mutate(twin=0)

output <- data.frame(program=NULL,
                     output_var=NULL,
                     pre_estimate=NULL,
                     abc_estimate=NULL,
                     abc_estimate_manual=NULL)

ehscenter_output <- c("ppvt3y") #, "norm_home_learning3y", "norm_home_total3y", "home3y_original")
ehsmixed_output <- c("ppvt3y") #, "norm_home_learning3y", "norm_home_total3y", "home3y_original")
ihdp_output <- c("ppvt3y", "sb3y") #, "norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "home3y_original")
abc_output <- c("sb3y") #, "norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "home3y_original")

for (v in ehscenter_output) {
  output <- rbind(output, causal_matrix(ehscenter, v, "ehscenter"))
}

for (v in ehsmixed_output) {
  output <- rbind(output, causal_matrix(ehsmixed, v, "ehsmixed"))
}

for (v in ihdp_output) {
  output <- rbind(output, causal_matrix(ihdp, v, "ihdp"))
}

write.csv(output, paste0(output_dir, "causal_tree.csv"), row.names=FALSE)

output <- output %>%
  rename('Program'=program,
         'Outcome'=output_var,
         'Pre-Estimate'=pre_estimate,
         'ABC-Estimate'=abc_estimate,
         'ABC-EStimate-Manual'=abc_estimate_manual)

print(xtable(output,digits=c(0, 0, 0, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"causal_forest_output.tex"))
