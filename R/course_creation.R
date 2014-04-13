# Goal: have as little functions as possible a teacher has to use to create and upload a chapter to datacamp 
# Extra functionality will be gradually added. 
# Feel free to contribute or just email suggestions at info@datacamp.com! 

#' Generate course and chapter scaffold
#'
#' The \code{author_course} function will:
#' \enumerate{
#'  \item create a folder in you current working directory with the name "course_name".
#'  \item create and open a `course.yml` file, a scaffold to provide the necessary course information.
#'  \item create and open a `chapter1.Rmd` file, a scaffold for creating your first chapter.
#' }
#' 
#' In the `course.yml` file a course title, course author and course description should be provided. Next, it also contains the unique 
#' course ID, and a list of the chapters within the course. The `chapter1.Rmd` file provides the structure and building blocks of the 
#' first chapter.    
#' 
#' @usage author_course(course_name, ...)
#' @param course_name String indicating the course name (and thus the name of the folder that will be created in your current working directory).
#' @param ... Extra arguments you'd like to pass to the function. Under the hood, the \code{author} function from the \code{slidify} package is called.
#' @return No return values.
#' @examples
#' \dontrun{
#' # This will create the new directory ../myNewTutorialName in your current working directory 
#' author_course("myNewTutorialName")
#' }
#' @export
author_course = function(course_name, ...) {
  require("slidify")
  message(paste0("Creating course directory ",course_name))
  message("Done.")
  message("Switching to course directory...")
  suppressMessages(author(deckdir = course_name,  use_git = FALSE, scaffold = system.file('skeleton', package = 'datacamp'), open_rmd = FALSE, ...))  
  message(paste0("Creating course.yml and opening first chapter file..."))
  file.edit("course.yml")
  file.edit("chapter1.Rmd")
}

#' Log in to DataCamp.com via R
#' 
#' To be able to upload your course to the DataCamp platform, you need to log in to set-up the connection. The function will prompt for your
#' DataCamp username and password, and will then log you into the DataCamp server. Optionally, a subdomain can be specified (the default is 
#' www.DataCamp.com). Note, in addition to the log in via R, it is also necessary to log into DataCamp.com via your browser.
#' 
#' 
#' @usage datacamp_login()
#' @return No return values.
#' @export
datacamp_login = function() {
  email = readline("Email: ")
  pw = readline("Password: ")
  subdomain = readline("Subdomain (leave empty for default): ")
  
  if (subdomain == "" || subdomain == " ") {
    base_url = paste0("https://api.datacamp.com")
    redirect_base_url = paste0("https://teach.datacamp.com/courses")
  } else if (subdomain == "localhost") {
    base_url = "http://localhost:3000"
    redirect_base_url = "http://localhost:9000/courses"
  } else {
    base_url = paste0("https://api-", subdomain, ".datacamp.com")
    redirect_base_url = paste0("https://teach-", subdomain, ".datacamp.com/courses")
  }
  
  url = paste0(base_url, "/users/details.json?email=", email, "&password=", pw) 
  message("Logging in...")
  if (url.exists(url)) {
    getURL(url)
    content = getURLContent(url)
    auth_token = fromJSON(content)$authentication_token
    .DATACAMP_ENV <<- new.env()
    .DATACAMP_ENV$auth_token = auth_token
    .DATACAMP_ENV$email = email
    .DATACAMP_ENV$base_url = base_url
    .DATACAMP_ENV$redirect_base_url = redirect_base_url
    message(paste0("Logged in successfully to datacamp.com with R! Make sure to log in with your browser to datacamp.com as well using the same account."))
  } else {
    stop("Wrong user name  or password for datacamp.com.")
  } 
}

#' Create or update a course
#' 
#' Uploads the \code{course.yml} file to datacamp.com. Use this function to change the course title, description, etc. and to update the chapters' ordering.
#' 
#' If you're not yet logged in when calling this function, you'll be prompted to log in.
#' 
#' @usage upload_course(open = TRUE)
#' @param open boolean, TRUE by default, determines whether a browser window should open, showing the course creation web interface
#' @examples 
#' \dontrun{
#' upload_course() 
#' }
#' @export
upload_course = function(open = TRUE) { 
  require("slidify")
  if (!datacamp_logged_in()) { datacamp_login() }
  if (!file.exists("course.yml")) { return(message("Error: Seems like there is no course.yml file in the current directory.")) }
  course = yaml.load_file("course.yml")
  if (is.null(course$id)) {
    sure = readline("No id found in course.yml. This will create a new course, are you sure you want to continue? (Y/N) ")
    if (!(sure == "y" || sure == "Y" || sure == "yes" || sure == "Yes")) { return(message("Aborted.")) }
  }
  course$chapters = lapply(course$chapters, function(x) { as.integer(x) }) # put ids in array
  the_course_json = toJSON(course)
  upload_course_json(the_course_json)
}

#' Create or update a chapter
#' 
#' @usage upload_chapter(input_file, force = FALSE, open = TRUE, ...)
#' @param input_file Path to the ".Rmd" file to be uploaded
#' @param force boolean, FALSE by default, specifies whether exercises should be removed. If set, will prompt for confirmation.
#' @param open boolean, TRUE by default, determines whether a browser window should open, showing the course creation web interface
#' @param ... Extra arguments to be passed to the \code{slidify} function under the hood
#' @return No return values.
#' @examples
#' \dontrun{
#' # Upload without possibly deleting existing exercises
#' upload_chapter("chapter1.Rmd")
#' 
#' # Completely sync markdown chapter with online version
#' upload_chapter("chapter1.Rmd", force = TRUE)
#' }
#' @export
upload_chapter = function(input_file, force = FALSE, open = TRUE, ... ) {
  require("slidify")
  if (!datacamp_logged_in()) { datacamp_login() }
  if (!file.exists("course.yml")) { return(message("Error: Seems like there is no course.yml file in the current directory.")) }
  if (force == TRUE) {
    sure = readline("Using 'force' deletes exercises. Are you sure you want to continue? (Y/N) ")
    if (!(sure == "y" || sure == "Y" || sure == "yes" || sure == "Yes")) { return(message("Aborted.")) }
  }
  if (length(get_chapter_id(input_file)) == 0) {
    sure = readline("Chapter not found in course.yml. This will create a new chapter, are you sure you want to continue? (Y/N) ")
    if (!(sure == "y" || sure == "Y" || sure == "yes" || sure == "Yes")) { return(message("Aborted.")) }
  }
  payload = suppressWarnings(slidify(input_file, return_page = TRUE,...)) # Get the payload  
  theJSON = render_chapter_json_for_datacamp(input_file, payload, force) # Get the JSON
  upload_chapter_json(theJSON, input_file, open = open) # Upload everything
}

#' Upload all chapters
#' 
#' Loop over all \code{.Rmd} files in the course directory and upload them using the \code{upload_chapter()} function.
#' 
#' @usage upload_all_chapters()
#' @return No return values.
#' @examples 
#' \dontrun{
#' upload_all_chapters()
#' }
#' @export
upload_all_chapters = function() {
  require("slidify")
  if (!datacamp_logged_in()) { datacamp_login() }
  if (!file.exists("course.yml")) { return(message("Error: Seems like there is no course.yml file in the current directory.")) }
  
  chapters = list.files(pattern="*.Rmd") # list all chapters in the directory  
  if (length(chapters)==0) { stop("There seem to be no chapters (in '.Rmd' format) in the current directory") }
  
  if (length(chapters) > 0) { 
    for (i in 1:length(chapters)) {
      message(paste0("Start uploading chapter: ", chapters[i]) ," ...")
      message("...uploading...")
      invisible( capture.output( suppressMessages(upload_chapter(chapters[i], open = FALSE)) ) )
      message(paste0("Successfully uploaded ", chapters[i],"!"))
      message("###")
    }
    message("### Succesfully uploaded all chapters ###")
  } 
}