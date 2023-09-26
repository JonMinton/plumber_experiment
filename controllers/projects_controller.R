get_all_projects <- function(){
  out <- readr::read_csv(here::here("db", "projects.csv"))
  out
}


get_project_by_id <- function(id){
  df <- readr::read_csv(here::here("db", "projects.csv"))
  if (id %in% df$id){
    return(df[df$id == id,])
  }
  NULL
}

add_project <- function(name){
  df <- readr::read_csv(here::here("db", "projects.csv"))
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
  readr::write_csv(dfNew, here::here("db", "projects.csv"))
  newRow
}

delete_project_by_id <- function(id){
  df <- readr::read_csv(here::here("db", "projects.csv"))
  if (id %in% df$id){
    rowToDelete <- df[df$id == id,]
    dfWithRowDeleted <- df[df$id != id,]
    readr::write_csv(dfWithRowDeleted, here::here("db", "projects.csv"))
    return(
      list(msg = paste0("deleted id ", id, " (name: ", rowToDelete$name, ")"))
    )
  }

  list(msg = paste0("could not find id ", id, " to delete"))
}

modify_project_details_by_id <- function(id, newName){
  df <- readr::read_csv(here::here("db", "projects.csv"))
  if (id %in% df$id){
    oldName <- df[df$id == id, "name"]
    df[df$id == id, "name"] <- newName
    readr::write_csv(df, here::here("db", "projects.csv"))
    return(
      list(msg = paste0(
        "modified id ", id,
        " (changed name from ", oldName, " to ", newName, ")"
      )
      )
    )
  }

  list(msg = paste0("could not find id ", id, " to modify"))
}


get_total_project_hours_by_id <- function(id) {
  df_vp <- readr::read_csv(here::here("db", "volunteers_projects.csv"))
  df_p  <- readr::read_csv(here::here("db", "projects.csv"))

  if (!(id %in% df_p$id)){
    return(
      list(
        msg =
          paste0(
            "Project id ", id, " not recognised"
          )
      )
    )
  }

  if (id %in% df_vp$project_id){
    totalHours <- sum(df_vp[df_vp$project_id == id,"hours"])
    return(totalHours)
  }

  return(
    list(msg = paste0(
      "No hours registered for project ", id, " (name ",
      df_p[df_p$id == id, "name"], ")"
    ))
  )
}
