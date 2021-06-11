library(tidyverse)
library(grf)
library(DiagrammeR)

data_dir <- "C:/Users/CKIRUser/Downloads/"
seed <- 9657


# Function to create data frame for causal forest estimates
causal_matrix <- function(df, output_var, program) {
  # Input for the program of interest
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
  
  # Fit the causal forest on the program of interest
  c_forest <- causal_forest(X, Y, W, honesty=FALSE, seed=seed)
  
  # Now create input for ABC
  # Pull out SB even when the program of interest has PPVT
  if (output_var %in% c("sb3y", "ppvt3y")) {
    df_abc <- abc %>%
      filter(!is.na(sb3y))
  } else {
    df_abc <- abc %>%
      filter(!is.na(!!(sym(output_var))))
  }
  
  n <- nrow(df_abc)
  p <- 10
  X_abc <- matrix(c(df_abc$bw,
                    df_abc$twin,
                    df_abc$m_age,
                    df_abc$m_edu,
                    df_abc$sibling,
                    df_abc$m_iq,
                    df_abc$black,
                    df_abc$sex,
                    df_abc$gestage,
                    df_abc$mf), n, p)
  
  # Use ABC original Y and W
  W_abc <- df_abc$R
  
  if (output_var %in% c("sb3y", "ppvt3y")) {
    Y_abc <- df_abc %>% pull(sb3y)
  } else {
    Y_abc <- df_abc %>% pull(output_var)
  }
  
  args_orthog <- list(X=X_abc,
                      num.trees=max(50, 2000/4),
                      sample.weights=NULL,
                      clusters=NULL,
                      equalize.cluster.weights=FALSE,
                      sample.fraction=0.5,
                      mtry=min(ceiling(sqrt(ncol(X_abc))+20), ncol(X_abc)),
                      min.node.size=5,
                      honesty=TRUE,
                      honesty.fraction=0.5,
                      honesty.prune.leaves=TRUE,
                      alpha=0.05,
                      imbalance.penalty=0,
                      ci.group.size=1,
                      tune.parameters="none",
                      num.threads=NULL,
                      seed=seed)
  
  # Find predicted values for Y and W for ABC
  forest_Y <- do.call(regression_forest, c(Y=list(Y_abc), args_orthog))
  Y_hat <- predict(forest_Y)$predictions
  
  forest_W <- do.call(regression_forest, c(Y=list(W_abc), args_orthog))
  W_hat <- predict(forest_W)$predictions
  
  # Find estimates and standard errors for ATE using ABC weights
  debiasing_weights <- (W_abc-W_hat)/(W_hat*(1-W_hat))
  tau_hat_pointwise <- predict(c_forest, X_abc)$predictions
  Y_residual <- Y_abc-(Y_hat+tau_hat_pointwise*(W_abc-W_hat))
  scores <- tau_hat_pointwise+debiasing_weights*Y_residual
  
  clusters <- 1:NROW(Y_abc)
  raw_weights <- rep(1, NROW(Y_abc))
  observation_weight <- raw_weights/sum(raw_weights)
  
  .sigma2.hat <- function(DR_scores, tau_hat) {
    correction_clust <- Matrix::sparse.model.matrix(~factor(clusters)+0, transpose=TRUE) %*%
      (sweep(as.matrix(DR_scores), 2, tau_hat, "-")*observation_weight)
    
    Matrix::colSums(correction_clust^2)/sum(observation_weight)^2*
      nrow(correction_clust)/(nrow(correction_clust)-1)
  }
  
  tau_hat <- weighted.mean(scores, observation_weight)
  sigma2_hat <- .sigma2.hat(scores, tau_hat)

  output <- data.frame(program=program,
                       output_var=output_var,
                       estimate=tau_hat,
                       std_error=sqrt(sigma2_hat))
  
  return(output)
}

# Execute!
ehscenter <- read.csv(paste0(data_dir,"ehscenter-topi.csv"))
ihdp <- read.csv(paste0(data_dir,"ihdp-topi.csv"))
abc <- read.csv(paste0(data_dir,"abc-topi.csv"))

output <- data.frame(program=NULL,
                     output_var=NULL,
                     estimate=NULL,
                     std_error=NULL)

ehscenter_output <- c("norm_home_learning3y", "norm_home_total3y", "ppvt3y") #, "home3y_original")
ihdp_output <- c("norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "ppvt3y", "sb3y") #, "home3y_original")
abc_output <- c("norm_home_learning3y", "norm_home_total3y", "home_jbg_learning", "sb3y") #, "home3y_original")

for (v in ehscenter_output) {
  output <- rbind(output, causal_matrix(ehscenter, v, "ehscenter"))
}

for (v in ihdp_output) {
  output <- rbind(output, causal_matrix(ihdp, v, "ihdp"))
}

write.csv(output, paste0(data_dir, "causal_forest.csv"), row.names=FALSE)
