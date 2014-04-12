# Goal: have as little functions as possible a teacher has to use to create and upload a chapter to datacamp 
# Extra functionality will be gradually added. 
# Feel free to contribute or just email suggestions at info@datacamp.com! 

# Author chapter:
author_course = function(chapdir, ...) {
  message(paste0("Creating course directory ",chapdir))
  message("Done.")
  message("Switching to course directory...")
  message(paste0("Opening course.yml and first chapter file..."))
  suppressMessages(author(deckdir = chapdir,  use_git = FALSE, scaffold = system.file('skeleton', package = 'datacamp'), open_rmd = FALSE, ...))
  file.edit("course.yml")
  file.edit("chapter1.Rmd")
}

# Log in to datacamp.com, is also called before all relevant functions if user is not logged in.
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

#' Title
#' 
#' Description
#' 
#' @param u lol
#' 
#' @examples
#' \code{lolzwut}
#' 
#' @export
upload_course = function(open = TRUE) { 
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

# Create/update chapter:
upload_chapter = function( input_file, force = FALSE, open = TRUE, ... ) {
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

# Upload all chapters: TODO
upload_all_chapters = function(open = TRUE) {
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