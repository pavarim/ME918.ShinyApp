n_matches_team <- db %>% group_by(Team, Date, `No Game`) %>% summarise(gato = n()) %>% ungroup()
n_matches_team <- n_matches_team %>% group_by(Team) %>% summarise(n_matches = n())
n_matches_season <- sum(n_matches_team$n_matches) / 2