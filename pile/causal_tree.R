rm(list=ls())
start_time <- Sys.time()

#install.packages("devtools")
#library(devtools)
#devtools::install_github("susanathey/causalTree", INSTALL_opts="--no-multiarch")

library(boot)
library(causalTree)
library(ggplot2)
library(tidyverse)
library(xtable)

data_dir <- "C:/Users/561CO/Downloads/"
output_dir <- "C:/Users/561CO/Downloads/"
seed <- 9657

covariate_names <- c("bw", "twin", "m_age", "m_edu", "sibling", "m_iq", "black", "sex", "gestage", "mf")


# # Manual prediction ####
# # Deprecated since we verified the predict command
# traverse_tree <- function(tree, input, ind) {
#   current_var <- tree %>% filter(index==ind) %>% select(var) %>% as.character()
#   
#   if (current_var=="<leaf>") {
#     val <- tree %>% filter(index==ind) %>% select(yval) %>% as.numeric()
#     return(val)
#   } else {
#     current_val <- input %>% select(current_var) %>% as.numeric()
#     
#     if (is.na(current_val)) {
#       return(NA)
#     } else {
#       formula <- paste0(current_val,
#                         tree %>% filter(index==ind) %>% select(ltemp) %>% as.character())
#       if (eval(parse(text=formula))) {
#         traverse_tree(tree, input, 2*ind)
#       } else {
#         traverse_tree(tree, input, 2*ind+1)
#       }
#     }
#   }
# }


# Function to create data frame for causal tree estimates ####
causal_matrix <- function(program, output_var, program_name) {
  formula_ct <- paste(output_var, "~", paste(covariate_names, collapse=" + "))
  
  # Plot deep tree (with no minsize restriction)
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
  
  # Tree to use in analysis
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
  } else {
    abc_input <- abc %>%
      select(-output_var)
  }
  
  if (output_var=="ppvt3y" | output_var=="sb3y") {
    pdf(paste0(output_dir, program_name, "_", output_var, "_plot.pdf"))
    prp(causal_tree, extra=0)
    dev.off()
  }
  
  # # Pruned tree (deprecated since it gives single node)
  # opcp <- causal_tree$cptable[, 1][which.min(causal_tree$cptable[, 4])]
  # optree <- prune(causal_tree, cp=opcp)
  # 
  # if (output_var=="ppvt3y" | output_var=="sb3y") {
  #   pdf(paste0(output_dir, program_name, "_", output_var, "_pruned_plot.pdf"))
  #   prp(optree, extra=0)
  #   dev.off()
  # }
  
  # Run bootstrap
  tree_boot <- function(data, index) {
    df_select <- data[index,]
    
    # Fit the causal tree on the program of interest
    tree <- causalTree(formula_ct,
                       data=df_select,
                       treatment=df_select$R,
                       split.Rule="CT",
                       split.Honest=FALSE,
                       cv.option="CT",
                       cv.Honest=FALSE,
                       minsize=25)
    
    causal_estimate <- mean(predict(tree, na.action=na.omit))
    causal_estimate_abc <- mean(predict(tree, newdata=abc_input, na.action=na.omit))
    
    output <- c(causal_estimate, causal_estimate_abc)
    return(output)
  }
  
  output_estimates <- boot(data=program,
                           statistic=tree_boot,
                           R=1000)
  
  # tree <- data.frame(index=row.names(causal_tree$frame),
  #                    var=causal_tree$frame$var,
  #                    yval=causal_tree$frame$yval) %>%
  #   cbind(labels(causal_tree, collapse=FALSE))
  # 
  # predicted_abc <- c()
  # 
  # for (i in 1:nrow(abc_input)) {
  #   predicted_abc[i] = traverse_tree(tree, abc_input[i,], 1)
  # }
  # 
  # causal_estimate_abc_manual <- mean(predicted_abc, na.rm=TRUE)
  
  output_row <- data.frame(program=program_name,
                           output_var=output_var,
                           pre_estimate=output_estimates$t0[1],
                           pre_se=sd(output_estimates$t[,1]),
                           abc_estimate=output_estimates$t0[2],
                           abc_se=sd(output_estimates$t[,2]))
  # abc_estimate_manual=causal_estimate_abc_manual)
  output_row
}

# Execute!
programs <- c("ehscenter", "ehsmixed_center", "ehsmixed", "ihdp", "abc")

for (p in programs) {
  assign(p, read.csv(paste0(data_dir, p, "-topi.csv")))
}

abc <- abc %>% mutate(twin=0)

ehscenter_output <- c("ppvt3y") #, "norm_home_learning3y", "norm_home_total3y", "home3y_original")
ehsmixed_center_output <- c("ppvt3y") #, "norm_home_learning3y", "norm_home_total3y", "home3y_original")
ehsmixed_output <- c("ppvt3y") #, "norm_home_learning3y", "norm_home_total3y", "home3y_original")
ihdp_output <- c("ppvt3y", "sb3y") #, "norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "home3y_original")
abc_output <- c("sb3y") #, "norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "home3y_original")

output <- data.frame(program=NULL,
                     output_var=NULL,
                     pre_estimate=NULL,
                     pre_se=NULL,
                     abc_estimate=NULL,
                     abc_se=NULL)
# abc_estimate_manual=NULL)

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    output <- rbind(output, causal_matrix(get(p), v, p))
  }
}

write.csv(output, paste0(output_dir, "causal_tree.csv"), row.names=FALSE)

output <- output %>%
  rename('Program'=program,
         'Outcome'=output_var,
         'Pre-Estimate'=pre_estimate,
         'Pre-SE'=pre_se,
         'ABC-Estimate'=abc_estimate,
         'ABC-SE'=abc_se)
# 'ABC-EStimate-Manual'=abc_estimate_manual)

print(xtable(output, digits=c(0, 0, 0, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"causal_tree_output.tex"))

end_time <- Sys.time()
end_time-start_time
