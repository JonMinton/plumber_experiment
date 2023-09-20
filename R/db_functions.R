get_all_volunteers <- function(){
  out <- readr::read_csv(here::here("db", "volunteers.csv"))
  out
}


get_volunteer_by_id <- function(id){
  df <- readr::read_csv(here::here("db", "volunteers.csv"))
  if (id %in% df$id){
    return(df[df$id == id,])
  }
  NULL
}

add_volunteer <- function(name){
  df <- readr::read_csv(here::here("db", "volunteers.csv"))
  used_ids <- df$id
  newId <- max(used_ids) + 1
  newRow <-
    tibble::tribble(
      ~"id", ~"name",
      newId, name
    )
  dfNew <- dplyr::bind_rows(
    df,
    newRow
  )
  readr::write_csv(dfNew, here::here("db", "volunteers.csv"))
  newRow
}

delete_volunteer_by_id <- function(id){
  df <- readr::read_csv(here::here("db", "volunteers.csv"))
  if (id %in% df$id){
    rowToDelete <- df[df$id == id,]
    dfWithRowDeleted <- df[df$id != id,]
    readr::write_csv(dfWithRowDeleted, here::here("db", "volunteers.csv"))
    return(
      list(msg = paste0("deleted id ", id, " (name: ", rowToDelete$name, ")"))
    )
  }

    list(msg = paste0("could not find id ", id, " to delete"))
}
