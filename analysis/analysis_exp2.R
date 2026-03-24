library(lme4)
library(here)
library(MASS)
library(tidyverse)
library(brms)
library(qs2)

# use "here" package to make all paths refer to the project root

# Load data

# Read all PsychoJS trial data
exp2_all_csv_content <- fs::dir_ls(path = here("data"), glob = "*.csv") %>%
  map_dfr(read_csv, .id = "source", col_type = cols(
    .default = col_character(), rt = col_double(), corr = col_integer(), TrialID = col_integer()))

exp2_all_participants <- exp2_all_csv_content |>
  # for each subject, set the first value of counterbalancing condition as the value for all of the data
  # the key assignment is given by the image used in the instruction (3rd row of each data file) 
  group_by(PROLIFIC_PID) |>
  mutate(counterbalancing_condition = counterbalancing_condition[1],
         response_key_condition = if_else(instruct_image[3] == "keyboardresponseNW.png", "NW", "WN")) |>
  ungroup() |>
  # remove rows that are not trials (e.g., instructions) and practice trials
  filter(!is.na(TrialID) & TrialID < 2000) %>%
  # fix some misleading variable names and add response key counterbalancing information (female left vs. male left)
  mutate(Target = Prime, 
         FlankerDuration = PrimeDuration) |>
  select(source, PROLIFIC_PID, date, OS, frameRate, rt, corr, TrialID, StimulusType, Gender, Condition, FlankerDuration, Target, Flanker, response_key_condition, counterbalancing_condition)

participant_list <- exp2_all_participants |> group_by(PROLIFIC_PID, counterbalancing_condition, response_key_condition) |> summarise(
  mean_rt = mean(rt, na.rm = TRUE),
  mean_acc = mean(corr[corr != -1]),
  mean_correct = mean(corr == 1),
  time_out = sum(corr == -1),
  N = n()
  )

low_acc_participants <- participant_list %>% filter(mean_correct < .8)

exp2 <- exp2_all_participants %>% filter(!(PROLIFIC_PID %in% low_acc_participants$PROLIFIC_PID))

# check counterbalancing for counterbalancing_condition and response_key_condition
# how many participants in each condition?

exp2 |> group_by(counterbalancing_condition, response_key_condition) |> summarise(
  N = n(),
  mean_rt = mean(rt, na.rm = TRUE),
  mean_acc = mean(corr[corr != -1]),
  mean_correct = mean(corr == 1),
  time_out = sum(corr == -1)
)


exp2$Condition <- factor(exp2$Condition, levels = c("AGR", "DIS"))

exp2$StimulusType <- factor(exp2$StimulusType, levels = c("WORD", "NOWORD"))

exp2$Gender <- factor(exp2$Gender, levels = c("FEM", "MAS"))


# contrasts: AGR vs DIS

contrasts(exp2$Condition) <- contr.sum

contrasts(exp2$StimulusType) <- contr.sum

contrasts(exp2$Gender) <- contr.sum


exp2$subject <- as.factor(exp2$PROLIFIC_PID) %>% as.numeric() %>% as.factor()


exp2$item <- as.factor(exp2$Target) %>% as.numeric() %>% as.factor()

priors_beta <- c(set_prior("normal(0,1)", class = "b"),
                 set_prior("normal(0,1)", class = "b", dpar = "beta"))


#bm1 <- brm(rt ~ Condition + (Condition|PROLIFIC_PID) + (Condition|Target), data = exp2 %>% filter(rt > .25 & corr == 1 & StimulusType == "WORD") , family = exgaussian(), prior = priors_gaussian, chains = 4, iter = 2000, warmup = 1000, cores = 4)

blmm_exp2_rt_dist <-
  brm(
    data = exp2 %>% filter(rt > .25 & rt < 1.8 & corr == 1 & StimulusType == "WORD"),
    formula = bf(
      rt ~ Condition*Gender  + (Condition*Gender | PROLIFIC_PID) + (Condition  | Target),
      beta ~ Condition*Gender + (Condition*Gender  | PROLIFIC_PID) + (Condition  | Target) ),
    warmup = 1000,
    iter = 5000,
    chains = 4,
    sample_prior = "yes",
    prior = priors_beta,
    family = exgaussian(),
    init = "0",
    control = list(adapt_delta = 0.8),#, max_treedepth = 15),
    cores = 4,
    backend = "cmdstanr",
    threads = threading(2),
    silent = 0
  )

qs_save(blmm_exp2_rt_dist, file = here("analysis", "blmm_exp2_rt_dist.qs"))

blmm_acc_exp2 <-
  brm(
    data = exp2 |> filter(rt > .25 & rt < 1.8 & corr != -1 & StimulusType == "WORD"),
    formula = bf(corr ~ Condition*Gender  + (Condition*Gender | PROLIFIC_PID) + (Condition  | Target)),
    warmup = 1000,
    iter = 5000,
    chains = 4,
    prior = priors_gaussian,
    sample_prior = "yes",
    family = bernoulli(),
    #init = "0",
    control = list(adapt_delta = 0.8),#, max_treedepth = 15),
    cores = 4,
    backend = "cmdstanr",
    threads = threading(2),
    silent = 0
  )

qs_save(blmm_acc_exp2, file = here("analysis", "blmm_acc_exp2.qs"))
