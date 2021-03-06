# packages ----------------------------------------------------------------
library(tidyverse)
library(reshape2)

# data import -------------------------------------------------------------
dataset_tidy <- read_rds("data/dataset_tidy.RData")

glimpse(dataset_tidy)
dataset_tidy %>% 
  drop_na() %>% 
  select(session_id,
         starts_with("cond"),
         starts_with("iat")) %>% 
  unnest()
  glimpse()
# D2 pre-processing -------------------------------------------------------

data_alaysis <-
    dataset_tidy %>% 
    drop_na() %>% 
    select(session_id,
           starts_with("cond"),
           starts_with("iat")) %>% 
    unnest() %>% 
    mutate(
    iat_block_type = 
      case_when(
        iat_label_left == "SELF-LUUPITE" | iat_label_right == "SELF-LUUPITE" ~ "self_luupite",
        iat_label_left == "SELF-NIFFITE" | iat_label_right == "SELF-NIFFITE" ~ "self_niffite"
        )
    ) %>% 
filter(rt > 400,
       rt < 10000,
       iat_type == "test") %>% 
  group_by(session_id) %>% 
  mutate(SD = sd(rt)) %>% 
  ungroup() %>% 
  dcast(session_id + cond_approach_training + SD ~ iat_block_type,
        value.var = "rt",
        fun.aggregate = mean) %>% 
  mutate_at(vars("self_luupite", "self_niffite"),
            funs(./SD)) %>% 
  mutate(D2 = self_luupite - self_niffite)

write_rds(data_alaysis, "data/data_analysis.Rdata")
