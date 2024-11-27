
# ShinyLol

Enzo Putton Tortelli, Eric Pavarim Lima, Mariana Peres Nascimento, Rodrigo Caldiron 

## Introdução

A aplicação em shiny ShinyLol tem o objetivo de trazer estatísticas
sumárias relacionadas à etapa de verão da 13ª edição do campeonato da
liga coreana profissional de League of Legends. As visualizações são
separadas em três abas, sendo elas Campeão, Time e Jogador.

## Campeão

Essa aba permite que os dados sejam filtrados por campeão, data da
partida e patch. É importante ressaltar que, quando uma data é
selecionada, apenas os patches existentes no período ficam disponíveis
para seleção no filtro.

Caso o filtro não seja aplicado sobre a data, será considerado todo o
período do campeonato. Do mesmo modo, caso não seja selecionado nenhum
patch, serão considerados todos os disponíveis no período.

A partir dos filtros são retornadas as seguintes informações:

- Número de escolhas do campeão;
- Número de banimentos;
- Taxa de partidas ganhas;
- Taxa de banimentos;
- Valores médios de abates, mortes, assistências, CS por minuto (CSM),
  ouro por minuto (GPM), dano por minuto (DPM), diferença de CS aos 15
  minutos de jogo (CSD@15), diferença de ouro aos 15 minutos de jogo
  (GD@15) e diferença de XP aos 15 minutos de jogo (XPD@15);
- Tabela contendo o nome do jogador, o número de jogos e de vitórias. É
  possível fazer seu download através do botão
  `Baixar Tabela de Campeão`.

## Time

Essa aba permite que os dados sejam filtrados por time, data da partida
e patch. É importante ressaltar que, quando uma data é selecionada,
apenas os patches existentes no período ficam disponíveis para seleção
no filtro.

Caso o filtro não seja aplicado sobre a data, será considerado todo o
período do campeonato. Do mesmo modo, caso não seja selecionado nenhum
patch, serão considerados todos os disponíveis no período.

A partir dos filtros são retornadas as seguintes informações:

- Jogadores que fazem parte do time;
- Número de partidas;
- Número de vitórias;
- Número de derrotas;
- Taxa de partidas ganhas;
- Valores médios de abates, mortes, assistências, diferença de CS aos 15
  minutos de jogo (CSD@15), diferença de ouro aos 15 minutos de jogo
  (GD@15), diferença de XP aos 15 minutos de jogo (XPD@15) e objetivos;
- Tabela contendo o campeão escolhido, o número de jogos e de vitórias,
  o número de banimentos e o número de banimentos do time adversário. É
  possível fazer seu download através do botão
  `Baixar Tabela de Campeões do Time`.

## Jogador

Essa aba permite que os dados sejam filtrados por jogador, data da
partida e patch. É importante ressaltar que, quando uma data é
selecionada, apenas os patches existentes no período ficam disponíveis
para seleção no filtro.

Caso o filtro não seja aplicado sobre a data, será considerado todo o
período do campeonato. Do mesmo modo, caso não seja selecionado nenhum
patch, serão considerados todos os disponíveis no período.

A partir dos filtros são retornadas as seguintes informações:

- Número de partidas;
- Número de vitórias;
- Número de derrotas;
- Taxa de partidas ganhas;
- Valores médios de abates, mortes, assistências, CS por minuto (CSM),
  ouro por minuto (GPM), dano por minuto (DPM), diferença de CS aos 15
  minutos de jogo (CSD@15), diferença de ouro aos 15 minutos de jogo
  (GD@15) e diferença de XP aos 15 minutos de jogo (XPD@15);
- Tabela contendo o nome do campeão, o número de jogos e de vitórias. É
  possível fazer seu download através do botão
  `Baixar Tabela de Jogador`.
