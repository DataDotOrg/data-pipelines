library(incidence2)

ebola <- subset(outbreaks::ebola_sim_clean$linelist, !is.na(hospital))
str(ebola)
head(ebola)
daily_incidence <- incidence(ebola, date_index="date_of_onset", interval="isoweek")
plot(daily_incidence)