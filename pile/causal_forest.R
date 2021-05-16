library(tidyverse)
library(grf)
library(DiagrammeR)

data_dir <- "C:/Users/Unit 9657/Dropbox/Research/TOPI/working/"
set.seed(9657)


# Function that traverses the tree and fill in
traverse_tree <- function(tree) {
  arr <- c(1)
  while (length(arr)!=0) {
    node_num <- arr[1]
    arr <- arr[-1]
    
    if (!(tree$nodes[[node_num]]$is_leaf)) {
      arr <- c(arr, tree$nodes[[node_num]]$left_child)
      arr <- c(arr, tree$nodes[[node_num]]$right_child)
    }
    else {
      tree$nodes[[node_num]]$count <- 0
    }
  }
  return(tree)
}

fill_tree <- function(df, tree) {
  df <- df %>%
    select(X.1=bw,
           X.2=twin,
           X.3=m_age,
           X.4=m_edu,
           X.5=sibling,
           X.6=m_iq,
           X.7=black,
           X.8=sex,
           X.9=gestage,
           X.10=mf)
  
  n <- nrow(df)
  
  for (i in 1:n) {
    node_num <- 1
    while (!(tree$nodes[[node_num]]$is_leaf)) {
      split_var <- df[i, tree$nodes[[node_num]]$split_variable]
      split_val <- tree$nodes[[node_num]]$split_value
      if(split_var <= split_val) {
        node_num <- tree$nodes[[node_num]]$left_child
      }
      else {
        node_num <- tree$nodes[[node_num]]$right_child
      }
    }
    tree$nodes[[node_num]]$count = tree$nodes[[node_num]]$count + 1/n
  }
  return(tree)
}


# Function to create data frame for causal forest estimates
causal_matrix <- function(df, output_var, program) {
  df <- df %>%
    filter(!is.na(!!(sym(output_var))))
  
  n <- nrow(df)
  p <- 10
  X <- matrix(c(df$bw,
                df$twin,
                df$m_age,
                df$m_edu,
                df$sibling,
                df$m_iq,
                df$black,
                df$sex,
                df$gestage,
                df$mf), n, p)
  W <- df$R
  Y <- df %>% pull(output_var)
  
  c.forest <- causal_forest(X, Y, W, honesty=FALSE)
  c.tree <- get_tree(c.forest, 1)
  c.ate <- average_treatment_effect(c.forest)
  c.vi <- variable_importance(c.forest)
  
  output <- data.frame(program=program,
                       output_var=output_var,
                       ate=c.ate[[1]],
                       ate_error=c.ate[[2]],
                       vi_bw=c.vi[[1]],
                       vi_twin=c.vi[[2]],
                       vi_m_age=c.vi[[3]],
                       vi_m_edu=c.vi[[4]],
                       vi_sibling=c.vi[[5]],
                       vi_m_iq=c.vi[[6]],
                       vi_black=c.vi[[7]],
                       vi_sex=c.vi[[8]],
                       vi_gestage=c.vi[[9]],
                       vi_mf=c.vi[[10]])
  
  return(output)
}

# Execute!
ehscenter <- read.csv(paste0(data_dir,"ehscenter-topi.csv"))
ihdp <- read.csv(paste0(data_dir,"ihdp-topi.csv"))
abc <- read.csv(paste0(data_dir,"abc-topi.csv"))

output <- data.frame(program=NULL,
                     ate=NULL,
                     ate_error=NULL,
                     vi_bw=NULL,
                     vi_twin=NULL,
                     vi_m_age=NULL,
                     vi_m_edu=NULL,
                     vi_sibling=NULL,
                     vi_m_iq=NULL,
                     vi_black=NULL,
                     vi_sex=NULL,
                     vi_gestage=NULL,
                     vi_mf=NULL)

ehscenter_output <- c("norm_home_learning3y", "norm_home_total3y", "home3y_original")
ihdp_output <- c("norm_home_learning3y", "norm_home_total3y", "home3y_original", "home_jbg_learning")
abc_output <- c("norm_home_learning3y", "norm_home_total3y", "home3y6m_original", "home_jbg_learning")

for (v in ehscenter_output) {
  output <- rbind(output,
                  causal_matrix(ehscenter, v, "ehscenter"))
}

for (v in ihdp_output) {
  output <- rbind(output,
                  causal_matrix(ihdp, v, "ihdp"))
}

for (v in abc_output) {
  output <- rbind(output,
                  causal_matrix(abc, v, "abc"))
}

output <- output %>%
  mutate(lower_ci=ate-qnorm(0.975)*ate_error,
         upper_ci=ate+qnorm(0.975)*ate_error)

write.csv(output, paste0(data_dir, "causal_forest.csv"), row.names=FALSE)

output_edit <- output %>%
  mutate(numCF=1:11) %>%
  select(numCF,
         coeffCF=ate,
         lowerCF=lower_ci,
         upperCF=upper_ci)

write.csv(output_edit, paste0(data_dir, "causal_forest_edit.csv"), row.names=FALSE)

