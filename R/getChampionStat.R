getChampionStat <- function(champion, patch = NULL, intervalDate = NULL) {
  if(!is.null(patch)) db <- db %>% filter(Patch %in% patch)
  if(!is.null(intervalDate)) db <- db %>% filter(Date %within% intervalDate)
  
  n_ban <- db %>% filter(Ban == champion) %>% nrow(.)
  porc_ban <- n_ban / n_matches_season
  
  db <- db %>% filter(Champion == champion)
  
  if(nrow(db) == 0) { # retorna 0 se o filtro removeu todas as linhas
    return(0)
  }
  
  n_pick <- nrow(db)
  porc_pick <- n_pick/n_matches_season
  
  
  n_wins <- db %>% filter(Outcome == 'Win') %>% nrow(.)
  n_losses <- db %>% filter(Outcome == 'Loss') %>% nrow(.)
  winrate <- n_wins / n_pick
  
  mean_kills <- mean(db$Kills)
  mean_deaths <- mean(db$Deaths)
  mean_assists <- mean(db$Assists)
  
  mean_csm <- mean(as.numeric(db$CSM))
  mean_dpm <- mean(db$DPM)
  mean_gpm <- mean(db$GPM)
  
  mean_gd15 <- mean(db$`GD@15`)
  mean_csd15 <- mean(db$`CSD@15`)
  mean_xpd15 <- mean(db$`XPD@15`)
  
  table_player <- db %>% group_by(Player, Outcome) %>% summarise(n = n()) %>% ungroup()
  sapply(unique(table_player$Player), FUN = function(player) {
    if(table_player[table_player$Player == player & table_player$Outcome == 'Loss', ] %>% nrow(.) == 0) table_player <<- rbind(table_player, c(player, 'Loss', 0))
    if(table_player[table_player$Player == player & table_player$Outcome == 'Win', ] %>% nrow(.) == 0) table_player <<- rbind(table_player, c(player, 'Win', 0))
  })
  table_player <- table_player %>% pivot_wider(names_from = Outcome, values_from = n) %>%
    mutate(Loss = as.numeric(Loss),
           Win = as.numeric(Win),
           n_games = Loss + Win) %>%
    select(Player, n_games, Win) %>%
    arrange(desc(Win))
  colnames(table_player) <- c('Jogador', '# Jogos', '# Vitórias')
  
  return(list(n_pick = n_pick,
              porc_pick = porc_pick,
              n_wins = n_wins,
              n_losses = n_losses,
              winrate = winrate,
              mean_kills = mean_kills,
              mean_deaths = mean_deaths,
              mean_assists = mean_assists,
              mean_csm = mean_csm,
              mean_dpm = mean_dpm,
              mean_gpm = mean_gpm,
              mean_gd15 = mean_gd15,
              mean_csd15 = mean_csd15,
              mean_xpd15 = mean_xpd15,
              table_player = table_player))
}


