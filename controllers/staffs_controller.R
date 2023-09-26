get_all_staffs <- function(){
  df <- readr::read_csv(here::here("db", "staffs.csv"))
  df
}

get_staff_by_id <- function(id){
  df <- readr::read_csv(here::here("db", "staffs.csv"))
  if (id %in% df$id){
    df[df$id == id,]
  } else {
    list(msg = paste0("could not find id ", id))
  }
}

add_staff <- function(name){
  df <- readr::read_csv(here::here("db", "staffs.csv"))
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
  readr::write_csv(dfNew, here::here("db", "staffs.csv"))
  newRow
}

delete_staff_by_id <- function(id){
  df <- readr::read_csv(here::here("db", "staffs.csv"))
  if (id %in% df$id){
    rowToDelete <- df[df$id == id,]
    dfWithRowDeleted <- df[df$id != id,]
    readr::write_csv(dfWithRowDeleted, here::here("db", "staffs.csv"))
    return(
      list(msg = paste0("deleted id ", id, " (name: ", rowToDelete$name, ")"))
    )
  }

  list(msg = paste0("could not find id ", id, " to delete"))
}

modify_staff_details_by_id <- function(id, newName){
  df <- readr::read_csv(here::here("db", "staffs.csv"))
  if (id %in% df$id){
    oldName <- df[df$id == id, "name"]
    df[df$id == id, "name"] <- newName
    readr::write_csv(df, here::here("db", "staffs.csv"))
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

comment_on_volunteer <- function(staffId, volunteerId, comment){
    df <- readr::read_csv(here::here("db", "staffs_volunteers.csv"))
    used_ids <- df$id
    newId <- max(used_ids) + 1
    newRow <-
      tibble::tribble(
        ~"id", ~"staffId", ~"volunteerId", ~"comment",
        newId, staffId, volunteerId, comment
      )
    dfNew <- dplyr::bind_rows(
        df,
        newRow
        )
    readr::write_csv(dfNew, here::here("db", "staffs_volunteers.csv"))
    return(
        list(
            msg = paste0(
                "staff ", staffId,
                " commented on volunteer ", volunteerId, " (comment: ", comment, ")"
                )
            )
    )
}

