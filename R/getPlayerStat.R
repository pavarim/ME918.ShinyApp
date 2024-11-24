getPlayerStat <- function(player, patch = NULL, intervalDate = NULL) {
  if(!is.null(patch)) db <- db %>% filter(Patch %in% patch)
  if(!is.null(intervalDate)) db <- db %>% filter(Date %within% intervalDate)
  
  db <- db %>% filter(Player == player)
  
  if(nrow(db) == 0) { # retorna 0 se o filtro removeu todas as linhas
    return(0)
  }
  
  result <- list()
  
  result$table_role <- db %>% group_by(Role) %>% summarise(n = n())
  
  result$mean_kills <- mean(db$Kills)
  result$mean_deaths <- mean(db$Deaths)
  mean_assists <- mean(db$Assists)
  
  result$mean_csm <- mean(as.numeric(db$CSM))
  result$mean_dpm <- mean(db$DPM)
  result$mean_gpm <- mean(db$GPM)
  
  result$mean_gd15 <- mean(db$`GD@15`)
  result$mean_csd15 <- mean(db$`CSD@15`)
  result$mean_xpd15 <- mean(db$`XPD@15`)
  
  result$table_champion <- db %>%
    mutate(n = n(),
           n_win = sum(Outcome == 'Win'),
           .by = Champion) %>%
    select(Champion, n, n_win) %>%
    distinct() %>%
    arrange(desc(n))
  
  return(result)
}