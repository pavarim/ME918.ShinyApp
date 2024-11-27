#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(bslib)
library(shinythemes)
library(shinyjs)
library(glue)

source('R/setDb.R')
source('R/setGeneralStat.R')
source('R/getChampionStat.R')
source('R/getTeamStat.R')
source('R/getPlayerStat.R')

# Define UI for application that draws a histogram
ui <- page_sidebar(
  title = 'Estatísticas LCK 2024 Summer',
  sidebar = sidebar(
    selectInput(inputId = 'champion',
                label = 'Campeão',
                choices = unique(db$Champion)[order(unique(db$Champion))]),
    selectInput(inputId = 'team',
                label = 'Time',
                choices = unique(db$Team)[order(unique(db$Team))]),
    selectInput(inputId = 'player',
                label = 'Jogador',
                choices = unique(db$Player)[order(unique(db$Player))]),
    dateRangeInput(inputId = 'match_date',
                   label = 'Data',
                   min = min(db$Date),
                   max = max(db$Date),
                   start = min(db$Date),
                   end = max(db$Date),
                   language = 'pt-BR'),
    selectInput(inputId = 'match_patch',
                label = 'Patch',
                choices = unique(db$Patch),
                multiple = TRUE)
  ),
  tabsetPanel(id = 'tab_panel',
              tabPanel('Campeão',
                       value = 'tab_champion',
                       fluidRow(
                         column(5,
                                card(
                                  card_header('Picks e Bans'),
                                  card_body(textOutput(outputId = 'champion_card_pick_ban')))
                                ),
                         column(5,
                                card(
                                  card_header('Média KDA'),
                                  card_body(
                                    textOutput(outputId = 'champion_card_kda')
                                  ))
                         )
                         
                       ),
                       fluidRow(
                         column(5,
                                card(
                                  card_header('Média estatísticas por minuto'),
                                  card_body(textOutput(outputId = 'champion_card_spm'))) 
                         ),
                         column(5,
                                card(
                                  card_body(
                                    card_header('Média estatísticas @15'),
                                    textOutput(outputId = 'champion_card_s15')
                                  ))
                         )
                         
                       ),
                       dataTableOutput(outputId = 'table_champ_player'),
                       downloadButton('download_champion', 'Baixar Tabela de Campeão')
              ),
              tabPanel('Time',
                       value = 'tab_team',
                       fluidRow(
                         column(5,
                                card(
                                  card_header('Jogadores'),
                                  card_body(textOutput(outputId = 'team_card_players')))
                         ),
                         column(5,
                                card(
                                  card_header('Partidas'),
                                  card_body(
                                    textOutput(outputId = 'team_card_matches')
                                  ))
                         )
                         
                       ),
                       fluidRow(
                         column(4,
                                card(
                                  card_header('Média KDA'),
                                  card_body(textOutput(outputId = 'team_card_kda')))
                         ),
                         column(4,
                                card(
                                  card_header('Média estatísticas @15'),
                                  card_body(
                                    textOutput(outputId = 'team_card_s15')
                                  ))
                         ),
                         column(4,
                                card(
                                  card_header('Média objetivos'),
                                  card_body(
                                    textOutput(outputId = 'team_card_obj')
                                  ))
                         )
                         
                       ),
                       dataTableOutput(outputId = 'table_team_champions'),
                       downloadButton('download_team_champion', 'Baixar Tabela de Campeões do Time')
              ),
              tabPanel('Jogador',
                       value = 'tab_player',
                       fluidRow(
                         column(5,
                                card(
                                  card_header('Partidas'),
                                  card_body(textOutput(outputId = 'player_card_matches')))
                         ),
                         column(5,
                                card(
                                  card_header('Média KDA'),
                                  card_body(
                                    textOutput(outputId = 'player_card_kda')
                                  ))
                         )
                         
                       ),
                       fluidRow(
                         column(5,
                                card(
                                  card_header('Média estatísticas por minuto'),
                                  card_body(textOutput(outputId = 'player_card_spm')))
                         ),
                         column(5,
                                card(
                                  card_header('Média estatísticas @15'),
                                  card_body(
                                    textOutput(outputId = 'player_card_s15')
                                  ))
                         )
                         
                       ),
                       dataTableOutput(outputId = 'table_player_champion'),
                       downloadButton('download_player_champion', 'Baixar Tabela de Jogador')
              )
  ),
  useShinyjs()

)


server <- function(input, output) {
  
  inputDateInterval <- reactive({
    req(input$match_date)
    
    interval(start = input$match_date[1], end = input$match_date[2])
  })
  
  observeEvent(inputDateInterval(), {
    updateSelectInput(inputId='match_patch', choices = db %>%
                        filter(Date %within% inputDateInterval()) %>%
                        select(Patch) %>% unique())
  })
  
  observeEvent(input$tab_panel, {
    if(input$tab_panel == 'tab_champion') {
      shinyjs::hide('player')
      shinyjs::hide('team')
      shinyjs::show('champion')
    } else if(input$tab_panel == 'tab_team') {
      shinyjs::hide('player')
      shinyjs::hide('champion')
      shinyjs::show('team')
    } else if(input$tab_panel == 'tab_player') {
      shinyjs::hide('champion')
      shinyjs::hide('team')
      shinyjs::show('player')
    }
  })
  
  # observeEvent(input$match_patch, {
  #   date_range <- db %>% filter(Patch %in% input$match_patch) %>% select(Date) %>% pull() %>% unique()
  #   updateDateRangeInput(inputId = 'match_date',
  #                        start = min(date_range),
  #                        end = max(date_range))
  # })
  
  #--- Champion tab ---#
  champStat <- reactive({getChampionStat(input$champion, input$match_patch, interval(start = input$match_date[1], end = input$match_date[2]))})
  
  output$table_champ_player <- renderDataTable({
    if(is.list(champStat())) champStat()$table_player
  })
  
  output$champion_card_pick_ban <- renderText({
    if(is.list(champStat())) glue('# picks: {champStat()$n_pick} |
                                  # bans: {champStat()$n_ban} |
                                  Winrate: {round(champStat()$winrate, 2)} |
                                  Banrate: {round(champStat()$banrate, 2)}')
  })
  
  output$champion_card_kda <- renderText({
    if(is.list(champStat())) glue('Abates: {round(champStat()$mean_kills, 2)} |
                                  Mortes: {round(champStat()$mean_deaths, 2)} |
                                  Assistências: {round(champStat()$mean_assists, 2)}')
  })
  
  output$champion_card_spm <- renderText({
    if(is.list(champStat())) glue('CSM: {round(champStat()$mean_csm, 2)} |
                                  GPM: {round(champStat()$mean_deaths, 2)} |
                                  DPM: {round(champStat()$mean_assists, 2)}')
  })
  
  output$champion_card_s15 <- renderText({
    if(is.list(champStat())) glue('CSD@15: {round(champStat()$mean_csd15, 2)} |
                                  GD@15: {round(champStat()$mean_gd15, 2)} |
                                  XPD@15: {round(champStat()$mean_xpd15, 2)}')
  })
  
  output$download_champion <- downloadHandler(
    filename = function() {
      paste("tabela_campeao_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      if(is.list(champStat())) {
        write.csv(champStat()$table_player, file, row.names = FALSE)
      }
    }
  )
  
  
  
  #--- Team tab ---#
  teamStat <- reactive({getTeamStat(input$team, input$match_patch, interval(start = input$match_date[1], end = input$match_date[2]))})
  
  output$team_card_players <- renderText({
    if(is.list(teamStat())) glue('{teamStat()$players}')
  })
  
  output$team_card_matches <- renderText({
    if(is.list(teamStat())) glue('# partidas: {teamStat()$n_matches} |
                                  # vitórias: {teamStat()$n_wins} |
                                  # derrotas: {teamStat()$n_losses} |
                                  Winrate: {round(teamStat()$winrate, 2)}')
  })
  
  output$team_card_kda <- renderText({
    if(is.list(teamStat())) glue('Abates: {round(teamStat()$mean_kills, 2)} |
                                  Mortes: {round(teamStat()$mean_deaths, 2)} |
                                  Assistências: {round(teamStat()$mean_assists, 2)}')
  })
  
  output$team_card_s15 <- renderText({
    if(is.list(teamStat())) glue('CSD@15: {round(teamStat()$mean_csd15, 2)} |
                                  GD@15: {round(teamStat()$mean_gd15, 2)} |
                                  XPD@15: {round(teamStat()$mean_xpd15, 2)}')
  })
  
  output$team_card_obj <- renderText({
    if(is.list(teamStat())) glue('# Dragão: {round(teamStat()$mean_dragon, 2)} |
                                  # Barão: {round(teamStat()$mean_baron, 2)}')
  })

  output$table_team_champions <- renderDataTable({

    if(is.list(teamStat())) teamStat()$table_champions
  })
  
  output$download_team_champion <- downloadHandler(
    filename = function() {
      paste("tabela_team_champion_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      if(is.list(playerStat())) {
        write.csv(playerStat()$table_champion, file, row.names = FALSE)
      }
    }
  )
  
  #--- Player tab ---#
  playerStat <- reactive({getPlayerStat(input$player, input$match_patch, interval(start = input$match_date[1], end = input$match_date[2]))})
  
  output$player_card_matches <- renderText({
    if(is.list(playerStat())) glue('# partidas: {playerStat()$n_matches} | 
                                  # vitórias: {playerStat()$n_wins} |
                                  # derrotas: {playerStat()$n_losses} |
                                  Winrate: {round(playerStat()$winrate, 2)}')
  })
  
  output$player_card_kda <- renderText({
    if(is.list(playerStat())) glue('Abates: {round(playerStat()$mean_kills, 2)} |
                                  Mortes: {round(playerStat()$mean_deaths, 2)} |
                                  Assistências: {round(playerStat()$mean_assists, 2)}')
  })
  
  
  
  output$player_card_spm <- renderText({
    if(is.list(playerStat())) glue('CSM: {round(playerStat()$mean_csm, 2)} |
                                  GPM: {round(playerStat()$mean_deaths, 2)} |
                                  DPM: {round(playerStat()$mean_assists, 2)}')
  })
  
  output$player_card_s15 <- renderText({
    if(is.list(playerStat())) glue('CSD@15: {round(playerStat()$mean_csd15, 2)} |
                                  GD@15: {round(playerStat()$mean_gd15, 2)} |
                                  XPD@15: {round(playerStat()$mean_xpd15, 2)}')
  })
  
  
  output$player_card_ <- renderDataTable({
    if(is.list(playerStat())) playerStat()$table_champion
  })
  
  output$table_player_champion <- renderDataTable({
    if(is.list(playerStat())) playerStat()$table_champion
  })
  
  output$download_player_champion <- downloadHandler(
    filename = function() {
      paste("tabela_player_champion_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      if(is.list(playerStat())) {
        write.csv(playerStat()$table_champion, file, row.names = FALSE)
      }
    }
  )
  
}


shinyApp(ui = ui, server = server)
