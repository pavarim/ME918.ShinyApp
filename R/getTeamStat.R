getTeamStat <- function(team, patch = NULL, intervalDate = NULL) {
  if(!is.null(patch)) db <- db %>% filter(Patch %in% patch)
  if(!is.null(intervalDate)) db <- db %>% filter(Date %within% intervalDate)

  db <- db %>% filter(Team == team)
  
  if(nrow(db) == 0) { # retorna 0 se o filtro removeu todas as linhas
    return(0)
  }
  
  
  result <- list()
  
  result$players <-  db$Player %>% unique()
  
  result$n_matches <- n_matches_team$n_matches[n_matches_team$Team == team]
  result$n_wins <- sum(db$Outcome == 'Win') / 5
  result$winrate <- result$n_wins / result$n_matches
  result$n_losses <- result$n_matches - result$n_wins
  
  result$mean_kills <- mean(db$`Kills Team`)
  result$mean_deaths <- db %>% group_by(Date, `No Game`) %>%
    summarise(deaths = sum(Deaths)) %>%
    ungroup() %>%
    summarise(mean = mean(deaths)) %>%
    as.numeric()
  result$mean_assists <- db %>% group_by(Date, `No Game`) %>%
    summarise(assists = sum(Assists)) %>%
    ungroup() %>%
    summarise(mean = mean(assists)) %>%
    as.numeric()
  
  result$mean_xpd15 <- db %>% group_by(Date, `No Game`) %>%
    summarise(xpd15 = sum(`XPD@15`)) %>%
    ungroup() %>%
    summarise(mean = mean(xpd15)) %>%
    as.numeric()
  result$mean_gd15 <- db %>% group_by(Date, `No Game`) %>%
    summarise(gd15 = sum(`GD@15`)) %>%
    ungroup() %>%
    summarise(mean = mean(gd15)) %>%
    as.numeric()
  result$mean_csd15 <- db %>% group_by(Date, `No Game`) %>%
    summarise(csd15 = sum(`CSD@15`)) %>%
    ungroup() %>%
    summarise(mean = mean(csd15)) %>%
    as.numeric()
  
  result$mean_dragon <- db %>%
    group_by(Date, `No Game`) %>%
    summarise(dragon = mean(`Dragon Team`)) %>%
    ungroup() %>%
    summarise(mean = mean(dragon)) %>%
    as.numeric()
  result$mean_baron <- db %>%
    group_by(Date, `No Game`) %>%
    summarise(baron = mean(`Baron Team`)) %>%
    ungroup() %>%
    summarise(mean = mean(baron)) %>%
    as.numeric()
  
  temp_table_pick <- db %>%
    mutate(n = n(),
           n_win = sum(Outcome == 'Win'),
           .by = Pick) %>%
    select(Pick, n, n_win) %>%
    distinct()
  
  
  temp_table_ban <- db %>%
    group_by(Ban) %>%
    summarise(n_ban = n())
  
  temp_table_opponent_ban <- db %>%
  group_by(`Ban Opponent`) %>%
    summarise(n_opp_ban = n())
  
  all_champs <- c(temp_table_pick$Pick,
                  temp_table_ban$Ban,
                  temp_table_opponent_ban$`Ban Opponent`)
  
  for(champ in all_champs) {
    if(!(champ %in% temp_table_pick$Pick)) {
      temp_table_pick <<- rbind(temp_table_pick, c(champ, 0, 0))
    }
    if(!(champ %in% temp_table_ban$Ban)) {
      temp_table_ban <<- rbind(temp_table_ban, c(champ, 0))
    }
    if(!(champ %in% temp_table_opponent_ban$`Ban Opponent`)) {
      temp_table_opponent_ban <<- rbind(temp_table_opponent_ban, c(champ, 0))
    }
    
  }
  
  result$table_champions <- inner_join(temp_table_pick,
             temp_table_ban,
             by = join_by(Pick == Ban)) %>%
    inner_join(.,
               temp_table_opponent_ban,
               by = join_by(Pick == `Ban Opponent`)) %>%
    arrange(desc(n))
  
  colnames(result$table_champions) <- c('Champion', '# Pick', '# Vitórias', '# Banimentos', '# Banimentos do oponente')
  
  return(result)
}
