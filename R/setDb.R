db <- read_csv2('data/lck_summer_2024.zip') %>% mutate(Champion = str_replace_all(Champion, '_', ' '),
                                                        Player = glue::glue('({Team}) {Player}'),
                                                        Date = dmy(Date))
