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
                                  card_body(textOutput(outputId = 'n_champion_pick'))) 
                                ),
                         column(5,
                                card(
                                  card_body(markdown('### Pick: 5')))
                         )
                         
                       ),
                       dataTableOutput(outputId = 'table_champ_player')
              ),
              tabPanel('Time',
                       value = 'tab_team',
                       dataTableOutput(outputId = 'table_team_pick'),
                       dataTableOutput(outputId = 'table_team_ban'),
                       dataTableOutput(outputId = 'table_opponent_ban')
              ),
              tabPanel('Jogador',
                       value = 'tab_player',
                       dataTableOutput(outputId = 'table_player_champion')
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
  
  output$n_champion_pick <- renderText({
    if(is.list(champStat())) glue('Número de jogos: {champStat()$n_pick}')
  })
  
  #--- Team tab ---#
  teamStat <- reactive({getTeamStat(input$team, input$match_patch, interval(start = input$match_date[1], end = input$match_date[2]))})

  output$table_team_pick <- renderDataTable({
    if(is.list(teamStat())) teamStat()$table_pick
  })
  
  output$table_team_ban <- renderDataTable({
    if(is.list(teamStat())) teamStat()$table_ban
  })
  
  output$table_opponent_ban <- renderDataTable({
    if(is.list(teamStat())) teamStat()$table_opponent_ban
  })
  
  #--- Player tab ---#
  playerStat <- reactive({getPlayerStat(input$player, input$match_patch, interval(start = input$match_date[1], end = input$match_date[2]))})
  
  output$table_player_champion <- renderDataTable({
    if(is.list(playerStat())) playerStat()$table_champion
  })
  
}


shinyApp(ui = ui, server = server)
