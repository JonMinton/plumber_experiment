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

modify_volunteer_details_by_id <- function(id, newName){
  df <- readr::read_csv(here::here("db", "volunteers.csv"))
  if (id %in% df$id){
    oldName <- df[df$id == id, "name"]
    df[df$id == id, "name"] <- newName
    readr::write_csv(df, here::here("db", "volunteers.csv"))
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


get_total_volunteer_hours_by_id <- function(id) {
  df_vp <- readr::read_csv(here::here("db", "volunteers_projects.csv"))
  df_v  <- readr::read_csv(here::here("db", "volunteers.csv"))

  if (!(id %in% df_v$id)){
    return(
      list(
        msg =
          paste0(
            "Volunteer id ", id, " not recognised"
          )
      )
    )
  }

  if (id %in% df_vp$volunteer_id){
    totalHours <- sum(df_vp[df_vp$volunteer_id == id,"hours"])
    return(totalHours)
  }

  return(
    list(msg = paste0(
      "No hours registered for volunteer ", id, " (name ",
      df_v[df_v$id == id, "name"], ")"
    ))
  )
}


get_comments_on_volunteer <- function(volunteerId) {
  df_sv <- readr::read_csv(here::here("db", "staffs_volunteers.csv"))

  if (!(volunteerId %in% df_sv$volunteer_id)){
    return(
      list(
        msg =
          paste0(
            "Volunteer id ", volunteerId, " not recognised"
          )
      )
    )
  }

  if (volunteerId %in% df_sv$volunteer_id){
    comments <- df_sv[df_sv$volunteer_id == volunteerId,"comment"]
    return(comments)
  }

  return(
    list(msg = paste0(
      "No comments registered for volunteer ", volunteerId, " (name ",
      df_s[df_s$id == volunteerId, "name"], ")"
    ))
  )
}

