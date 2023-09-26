# plumber.R


source("../controllers/projects_controller.R")
source("../controllers/volunteers_controller.R")

#* Echo the parameter that was sent in
#* @param msg The message to echo back.
#* @get /echo
function(msg=""){
  list(msg = paste0("The message is: '", msg, "'"))
}


# VOLUNTEERS ROUTES

#* Get all volunteers
#* @get /volunteers
function(){
  get_all_volunteers()
}

#* Get volunteer by id
#* @param id the id of the volunteer to search for
#* @get /volunteers/<id>
function(id){
  get_volunteer_by_id(id)
}

#* Add volunteer
#* @param name the name of the volunteer to add
#* @put /volunteers
function(name){
  add_volunteer(name)
}

#* Delete volunteer by id
#* @param id the id of the volunteer to delete
#* @delete /volunteers/<id>
function(id){
  delete_volunteer_by_id(id)
}

#* Modify volunteer details
#* @param id the id of the volunteer to modify
#* @param newName the new value of the name to modify
#* @patch /volunteers/<id>
function(id, newName){
  modify_volunteer_details_by_id(id, newName)
}


#* Get total volunteer hours by id
#* @param id the id of the volunteer to search for
#* @get /volunteers/<id>/hours
function(id){
  get_total_volunteer_hours_by_id(id)
}






# PROJECTS ROUTES
#* Get all projects
#* @get /projects
function(){
  get_all_projects()
}


#* Get project by id
#* @param id the id of the project to search for
#* @get /projects/<id>
function(id){
  get_project_by_id(id)
}

#* Add project
#* @param name the name of the project to add
#* @put /projects
function(name){
  add_project(name)
}

#* Delete project by id
#* @param id the id of the project to delete
#* @delete /projects/<id>
function(id){
  delete_project_by_id(id)
}

#* Modify project details
#* @param id the id of the project to modify
#* @param newName the new value of the name to modify
#* @patch /projects/<id>
function(id, newName){
  modify_project_details_by_id(id, newName)
}

#* Get total project hours by id
#* @param id the id of the project to search for
#* @get /projects/<id>/hours
function(id){
  get_total_project_hours_by_id(id)
}




#* Plot out data from the iris dataset
#* @param spec If provided, filter the data to only this species (e.g. 'setosa')
#* @get /plot
#* @serializer png
function(spec){
  myData <- iris
  title <- "All Species"

  # Filter if the species was specified
  if (!missing(spec)){
    title <- paste0("Only the '", spec, "' Species")
    myData <- subset(iris, Species == spec)
  }

  plot(myData$Sepal.Length, myData$Petal.Length,
       main=title, xlab="Sepal Length", ylab="Petal Length")
}
