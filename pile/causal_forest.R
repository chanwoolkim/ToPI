rm(list=ls())
start_time <- Sys.time()

library(boot)
library(DiagrammeR)
library(grf)
library(tidyverse)
library(xtable)

data_dir <- "C:/Users/561CO/Downloads/"
output_dir <- "C:/Users/561CO/Downloads/"
seed <- 9657

source(paste0(data_dir, "best_tree.R"))

covariate_names <- c("bw", "twin", "m_age", "m_edu_2", "m_edu_3", "sibling", "m_iq", "black", "sex", "gestage", "mf")


# Helper functions ####
# Helper to fill out yval in a best single tree
yval_fill_forest <- function(forest) {
  best_tree_info <- find_best_tree(forest)
  best_tree_index <- best_tree_info$best_tree
  tree <- get_tree(forest, best_tree_index)
  
  arr <- c(1)
  
  while (length(arr)!=0) {
    node_num <- arr[1]
    arr <- arr[-1]
    
    if (!(tree$nodes[[node_num]]$is_leaf)) {
      arr <- c(arr, tree$nodes[[node_num]]$left_child)
      arr <- c(arr, tree$nodes[[node_num]]$right_child)
    } else {
      sample_list <- tree$nodes[[node_num]]$samples
      y_select <- forest$Y.orig[sample_list]
      w_select <- forest$W.orig[sample_list]
      
      y1 <- mean(y_select[which(w_select==1)])
      y0 <- mean(y_select[which(w_select==0)])
      
      tree$nodes[[node_num]]$yval <- y1-y0
    }
  }
  return(tree)
}

# Helper to get predicted estimates for ABC in a single tree
abc_best_tree_predict <- function(tree, input) {
  df_select <- input %>%
    select(X.1=bw,
           X.2=twin,
           X.3=m_age,
           X.4=m_edu_2,
           X.5=m_edu_3,
           X.6=sibling,
           X.7=m_iq,
           X.8=black,
           X.9=sex,
           X.10=gestage,
           X.11=mf)
  
  prediction <- c()
  n <- nrow(df_select)
  
  for (i in 1:n) {
    node_num <- 1
    while (!(tree$nodes[[node_num]]$is_leaf)) {
      split_var <- df_select[i, tree$nodes[[node_num]]$split_variable]
      split_val <- tree$nodes[[node_num]]$split_value
      if (is.na(split_var <= split_val)) {
        break
      } else if (split_var <= split_val) {
        node_num <- tree$nodes[[node_num]]$left_child
      } else {
        node_num <- tree$nodes[[node_num]]$right_child
      }
    }
    if (is.na(split_var <= split_val)) {
      prediction[i] <- NA
    } else {
      prediction[i] <- tree$nodes[[node_num]]$yval
    }
  }
  
  df_estimate <- mean(prediction, na.rm=TRUE)
  return(df_estimate)
}


# Function to create data frame for causal forest estimates ####
causal_matrix <- function(df, output_var, program, method="ATE") {
  # Input for the program of interest
  if (method=="ATE") {
    df <- df %>%
      filter(!is.na(!!(sym(output_var))))
  } else if (method=="LATE") {
    df <- df %>%
      filter(!is.na(!!(sym(output_var))),
             !is.na(D))
  } else {
    stop("Enter valid method")
  }
  
  # Now create input for ABC
  # Pull out SB even when the program of interest has PPVT
  if (output_var %in% c("sb3y", "ppvt3y")) {
    df_abc <- abc %>%
      filter(!is.na(sb3y))
  } else {
    df_abc <- abc %>%
      filter(!is.na(!!(sym(output_var))))
  }
  
  if (method=="LATE") {
    df_abc <- df_abc %>% filter(!is.na(D))
  }
  
  X_abc <- df_abc %>% select(covariate_names) %>% as.matrix()
  
  # Variable importance can be run outside bootstrap
  X <- df %>% select(covariate_names) %>% as.matrix()
  W <- df$R
  Y <- df %>% pull(output_var)
  Z <- df$D
  
  # Fit the causal/instrumental forest on the program of interest
  if (method=="ATE") {
    forest <- causal_forest(X, Y, W, honesty=FALSE, seed=seed)
  } else if (method=="LATE") {
    forest <- instrumental_forest(X, Y, W, Z, honesty=FALSE, seed=seed)
  }
  
  var_importance <- variable_importance(forest)
  
  # Run bootstrap
  forest_boot <- function(data, index) {
    df_select <- data[index,]
    X <- df_select %>% select(covariate_names) %>% as.matrix()
    W <- df_select$R
    Y <- df_select %>% pull(output_var)
    Z <- df_select$D
    
    # Fit the causal/instrumental forest on the program of interest
    if (method=="ATE") {
      forest <- causal_forest(X, Y, W, honesty=FALSE, seed=seed)
    } else if (method=="LATE") {
      forest <- instrumental_forest(X, Y, W, Z, honesty=FALSE, seed=seed)
    }
    
    pre_estimate <- mean(forest$predictions)
    pre_dr_estimate <- average_treatment_effect(forest)[[1]]
    pre_dr_se <- average_treatment_effect(forest)[[2]]
    abc_estimate <- mean(predict(forest, X_abc)$predictions)
    
    if (method=="ATE") {
      yval_tree <- yval_fill_forest(forest)
      abc_best_estimate <- abc_best_tree_predict(yval_tree, df_abc)
      output <- c(pre_estimate,
                  pre_dr_estimate, pre_dr_se,
                  abc_estimate,
                  abc_best_estimate)
    } else if (method=="LATE") {
      output <- c(pre_estimate,
                  pre_dr_estimate, pre_dr_se,
                  abc_estimate)
    }
    
    return(output)
  }
  
  output_estimates <- boot(data=df,
                           statistic=forest_boot,
                           R=1000)
  
  if (method=="ATE") {
    output <- data.frame(program=program,
                         output_var=output_var,
                         pre_estimate=output_estimates$t0[1],
                         pre_dr_estimate=output_estimates$t0[2],
                         pre_dr_se=output_estimates$t0[3],
                         abc_estimate=output_estimates$t0[4],
                         abc_se=sd(output_estimates$t[,4]),
                         abc_best_estimate=output_estimates$t0[5],
                         abc_best_se=sd(output_estimates$t[,5]),
                         bw_importance=var_importance[1],
                         twin_importance=var_importance[2],
                         m_age_importance=var_importance[3],
                         m_edu_2_importance=var_importance[4],
                         m_edu_3_importance=var_importance[5],
                         sibling_importance=var_importance[6],
                         m_iq_importance=var_importance[7],
                         black_importance=var_importance[8],
                         sex_importance=var_importance[9],
                         gestage_importance=var_importance[10],
                         mf_importance=var_importance[11])
  } else if (method=="LATE") {
    output <- data.frame(program=program,
                         output_var=output_var,
                         pre_estimate=output_estimates$t0[1],
                         pre_dr_estimate=output_estimates$t0[2],
                         pre_dr_se=output_estimates$t0[3],
                         abc_estimate=output_estimates$t0[4],
                         abc_se=sd(output_estimates$t[,4]),
                         bw_importance=var_importance[1],
                         twin_importance=var_importance[2],
                         m_age_importance=var_importance[3],
                         m_edu_2_importance=var_importance[4],
                         m_edu_3_importance=var_importance[5],
                         sibling_importance=var_importance[6],
                         m_iq_importance=var_importance[7],
                         black_importance=var_importance[8],
                         sex_importance=var_importance[9],
                         gestage_importance=var_importance[10],
                         mf_importance=var_importance[11])
  }
  return(output)
}


# Execute! ####
programs <- c("ehscenter", "ehsmixed_center", "ehsmixed", "ihdp")

for (p in programs) {
  assign(p, read.csv(paste0(data_dir, p, "-topi.csv")) %>%
           mutate(m_edu_2=m_edu==2,
                  m_edu_3=m_edu==3))
}

abc <- read.csv(paste0(data_dir, "abc-topi.csv")) %>%
  mutate(twin=0,
         m_edu_2=m_edu==2,
         m_edu_3=m_edu==3)

ehscenter_output <- c("ppvt3y") #, "norm_home_learning3y", "norm_home_total3y", "home3y_original")
ehsmixed_center_output <- c("ppvt3y") #, "norm_home_learning3y", "norm_home_total3y", "home3y_original")
ehsmixed_output <- c("ppvt3y") #, "norm_home_learning3y", "norm_home_total3y", "home3y_original")
ihdp_output <- c("ppvt3y", "sb3y") #, "norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "home3y_original")
abc_output <- c("sb3y") #, "norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "home3y_original")

causal_output <- data.frame(program=NULL,
                            output_var=NULL,
                            pre_estimate=NULL,
                            pre_dr_estimate=NULL,
                            pre_dr_se=NULL,
                            abc_estimate=NULL,
                            abc_se=NULL,
                            abc_best_estimate=NULL,
                            abc_best_se=NULL,
                            bw_importance=NULL,
                            twin_importance=NULL,
                            m_age_importance=NULL,
                            m_edu_importance=NULL,
                            sibling_importance=NULL,
                            m_iq_importance=NULL,
                            black_importance=NULL,
                            sex_importance=NULL,
                            gestage_importance=NULL,
                            mf_importance=NULL)

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    causal_output <- rbind(causal_output,
                           causal_matrix(get(p), v, p))
  }
}

write.csv(causal_output, paste0(output_dir, "causal_forest.csv"), row.names=FALSE)

causal_output_main <- causal_output %>%
  select('Program'=program,
         'Outcome'=output_var,
         'Pre-Estimate'=pre_estimate,
         'Pre-DR-Estimate'=pre_dr_estimate,
         'Pre-DR-SE'=pre_dr_se,
         'ABC-Estimate'=abc_estimate,
         'ABC-SE'=abc_se,
         'ABC-Best-Tree-Estimate'=abc_best_estimate,
         'ABC-Best-Tree-SE'=abc_best_se)

print(xtable(causal_output_main,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"causal_forest_output.tex"))

causal_output_importance <- causal_output %>%
  select('Program'=program,
         'Outcome'=output_var,
         'Birth Weight'=bw_importance,
         'Twin'=twin_importance,
         'Mother Age'=m_age_importance,
         'Mother Edu'=m_edu_importance,
         'Sibling'=sibling_importance,
         'Mother IQ'=m_iq_importance,
         'Black'=black_importance,
         'Sex'=sex_importance,
         'Gestational Age'=gestage_importance,
         'Father Home'=mf_importance)

print(xtable(causal_output_importance,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"causal_forest_importance_output.tex"))

instrumental_output <- data.frame(program=NULL,
                                  output_var=NULL,
                                  pre_estimate=NULL,
                                  pre_dr_estimate=NULL,
                                  pre_dr_se=NULL,
                                  abc_estimate=NULL,
                                  abc_se=NULL,
                                  bw_importance=NULL,
                                  twin_importance=NULL,
                                  m_age_importance=NULL,
                                  m_edu_importance=NULL,
                                  sibling_importance=NULL,
                                  m_iq_importance=NULL,
                                  black_importance=NULL,
                                  sex_importance=NULL,
                                  gestage_importance=NULL,
                                  mf_importance=NULL)

for (p in programs) {
  for (v in get(paste0(p, "_output"))) {
    instrumental_output <- rbind(instrumental_output,
                           causal_matrix(get(p), v, p, "LATE"))
  }
}

write.csv(instrumental_output, paste0(output_dir, "instrumental_forest.csv"), row.names=FALSE)

instrumental_output_main <- instrumental_output %>%
  select('Program'=program,
         'Outcome'=output_var,
         'Pre-Estimate'=pre_estimate,
         'Pre-DR-Estimate'=pre_dr_estimate,
         'Pre-DR-SE'=pre_dr_se,
         'ABC-Estimate'=abc_estimate,
         'ABC-SE'=abc_se)

print(xtable(instrumental_output_main,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"instrumental_forest_output.tex"))

instrumental_output_importance <- instrumental_output %>%
  select('Program'=program,
         'Outcome'=output_var,
         'Birth Weight'=bw_importance,
         'Twin'=twin_importance,
         'Mother Age'=m_age_importance,
         'Mother Edu'=m_edu_importance,
         'Sibling'=sibling_importance,
         'Mother IQ'=m_iq_importance,
         'Black'=black_importance,
         'Sex'=sex_importance,
         'Gestational Age'=gestage_importance,
         'Father Home'=mf_importance)

print(xtable(instrumental_output_importance,
             digits=c(0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3)),
      include.rownames=FALSE,
      comment=FALSE,
      file=paste0(output_dir,"instrumental_forest_importance_output.tex"))

end_time <- Sys.time()
end_time-start_time
