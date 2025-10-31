start_time <- Sys.time()

# Load output data
lee_bounds_results <- read_csv(paste0(data_dir, "/lee_bounds_results.csv"))

# Now to a TeX file
lee_bounds_results <- lee_bounds_results %>%
  mutate(bounds=paste0("(", sprintf("%.2f", round(lower, 2)), ", ", sprintf("%.2f", round(upper, 2)), ")"),
         subsample=subsample==1) %>%
  distinct()

tab <- TexRow(c("", "ITT"), cspan=c(1, 6)) +
  TexMidrule(list(c(2, 7))) +
  TexRow(c("Program ", "EHS", "ABC"), cspan=c(1, 5, 1)) +
  TexMidrule(list(c(2, 6), c(7, 7))) +
  TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 1, 1, 3, 1)) +
  TexMidrule() +
  TexRow(c("Full", 
           lee_bounds_results %>% 
             filter(program=="ehs-full", type=="r", subsample==FALSE) %>% 
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="ehsmixed_center", type=="r", subsample==FALSE) %>% 
             pull(bounds),
           lee_bounds_results %>%
             filter(program=="ehscenter", type=="r", subsample==FALSE) %>%
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="abc", type=="r", subsample==FALSE) %>% 
             pull(bounds)), cspan=c(1, 1, 1, 3, 1)) +
  TexRow(c("Subsample",
           lee_bounds_results %>% 
             filter(program=="ehs-full", type=="r", subsample==TRUE) %>% 
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="ehsmixed_center", type=="r", subsample==TRUE) %>% 
             pull(bounds),
           lee_bounds_results %>%
             filter(program=="ehscenter", type=="r", subsample==TRUE) %>%
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="abc", type=="r", subsample==TRUE) %>% 
             pull(bounds)), cspan=c(1, 1, 1, 3, 1)) +
  TexMidrule() +
  TexMidrule() +
  TexRow(c("", "LATE"), cspan=c(1, 6)) +
  TexMidrule(list(c(2, 7))) +
  TexRow(c("Program ", "EHS", "ABC"), cspan=c(1, 5, 1)) +
  TexMidrule(list(c(2, 6), c(7, 7))) +
  TexRow(c("Type", "All", "Center $+$ Mixed", "Center Only", ""), cspan=c(1, 1, 1, 3, 1)) +
  TexMidrule(list(c(2, 2), c(3, 3), c(4, 6), c(7, 7))) +
  TexRow(c("Participation", "Any", "Any", "Any", "1m", "12m", "12m")) +
  TexMidrule() +
  TexRow(c("Full", 
           lee_bounds_results %>% 
             filter(program=="ehs-full", type=="d", subsample==FALSE) %>% 
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="ehsmixed_center", type=="d", subsample==FALSE) %>% 
             pull(bounds),
           lee_bounds_results %>%
             filter(program=="ehscenter", type=="d", subsample==FALSE) %>%
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="ehscenter", type=="d_1", subsample==FALSE) %>% 
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="ehscenter", type=="d_12", subsample==FALSE) %>% 
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="abc", type=="d_12", subsample==FALSE) %>% 
             pull(bounds))) +
  TexRow(c("Subsample",
           lee_bounds_results %>% 
             filter(program=="ehs-full", type=="d", subsample==TRUE) %>% 
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="ehsmixed_center", type=="d", subsample==TRUE) %>% 
             pull(bounds),
           lee_bounds_results %>%
             filter(program=="ehscenter", type=="d", subsample==TRUE) %>%
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="ehscenter", type=="d_1", subsample==TRUE) %>% 
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="ehscenter", type=="d_12", subsample==TRUE) %>% 
             pull(bounds),
           lee_bounds_results %>% 
             filter(program=="abc", type=="d_12", subsample==TRUE) %>% 
             pull(bounds)))

TexSave(tab, filename="lee_bounds", positions=c('l', rep('c', 6)),
        output_path=output_dir, stand_alone=FALSE)
TexSave(tab, filename="lee_bounds", positions=c('l', rep('c', 6)),
        output_path=output_git, stand_alone=FALSE)

end_time <- Sys.time()
end_time-start_time
