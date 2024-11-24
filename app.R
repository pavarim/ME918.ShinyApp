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

source('R/setDb.R')
source('R/setGeneralStat.R')
source('R/getChampionStat.R')
source('R/getTeamStat.R')
source('R/getPlayerStat.R')

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Estatísticas LCK 2024 Summer"),
  sidebarLayout(
    sidebarPanel(
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
    mainPanel(
      tabsetPanel(
        tabPanel('Campeão',
                 dataTableOutput(outputId = 'table_champ_player')
                 ),
        tabPanel('Time',
                 dataTableOutput(outputId = 'table_team_pick'),
                 dataTableOutput(outputId = 'table_team_ban'),
                 dataTableOutput(outputId = 'table_opponent_ban')
                 ),
        tabPanel('Jogador',
                 dataTableOutput(outputId = 'table_player_champion')
                 )
      )
    )
  )

)


server <- function(input, output) {
  #--- Champion tab ---#
  champStat <- reactive({getChampionStat(input$champion, input$match_patch, interval(start = input$match_date[1], end = input$match_date[2]))})
  
  output$table_champ_player <- renderDataTable({
    if(is.list(champStat())) champStat()$table_player
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
