##### HELP FUNCTIONS ##### 
datacamp_logged_in = function() {
  if (exists(".DATACAMP_ENV")) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}


#' @import httr
#' @import RJSONIO  
#' @import yaml
#' @import datacampSCT
#' @import slidify
upload_chapter_json = function(theJSON, file_name, open = TRUE) {
  base_url = paste0(.DATACAMP_ENV$base_url, "/chapters/create_from_r.json")
  auth_token = .DATACAMP_ENV$auth_token
  url = paste0(base_url,"?auth_token=", auth_token)
  x = try(POST(url = url, body = theJSON, add_headers(c(`Content-Type` = "application/json", `Expect` = ""))))
  
  if ( class(x) != "response" ) {
    stop("Something went wrong. We didn't get a valid response from the datacamp server. Try again or contact info@datacamp.com in case you keep experiencing this problem.")
  } else { 
    if (is.list(content(x)) ) { 
      if ("course" %in% names(content(x)) ) {  
        course = content(x)$course
        chapter = content(x)$chapter
        new = content(x)$created
        message(paste0("Changes made to course (id:",course$id,"): \"", course$title,"\":"))
        if (new == TRUE) {
          message(paste0("\tCreated new chapter (id:", chapter$id,"): \"", chapter$title,"\".")) 
        } else {
          message(paste0("\tExisting chapter (id:",chapter$id,"): \"", chapter$title,"\" was updated."))
        }
        add_chapter_to_course_yml(file_name, as.integer(chapter$id))
        if (open) {
          browseURL(paste0(.DATACAMP_ENV$redirect_base_url, "/", course$id))
        } 
      } 
      if ("message" %in% names(content(x))) {
        message(content(x)$message)
      }
      if ( "error" %in% names(content(x)) ) {
        message(paste0("Something went wrong:\n", content(x)$error ))
      } 
    } else {
      message(paste0("Something went wrong. Please check whether your course was correctly uploaded to datacamp.com."))
    } 
  } 
}

upload_course_json = function(theJSON, open = TRUE) { 
  base_url = paste0(.DATACAMP_ENV$base_url, "/courses/create_from_r.json")
  auth_token = .DATACAMP_ENV$auth_token
  url = paste0(base_url,"?auth_token=", auth_token)
  x = try(POST(url = url, body = theJSON, add_headers(c(`Content-Type` = "application/json", `Expect` = ""))))
  if ( class(x) != "response" ) {
    stop("Something went wrong. We didn't get a valid response from the datacamp server. Try again or contact info@datacamp.com in case you keep experiencing this problem.")
  } else {
    if (is.list(content(x)) ) {
      if ("course" %in% names(content(x))) {
        course = content(x)$course
        new = content(x)$created
        if (new == TRUE) {
          message(paste0("A new course was created with id ", course$id," and title \"", course$title,"\".")) 
        } else {
          message(paste0("Existing course (id:", course$id,"): \"", course$title,"\" was updated."))
        }
        add_id_to_course_yml(course$id) # write id to course.yml file if it's not already there
        if (open) { 
          browseURL(paste0(.DATACAMP_ENV$redirect_base_url, "/", course$id))
        }
        if ("message" %in% names(content(x))) {
          message(content(x)$message)
        }
      } else if ( "error" %in% names(content(x)) ) {
        message(paste0("Something went wrong:\n", content(x)$error ))
      }
    } else {
      message(paste0("Something went wrong. Please check whether your course was correctly uploaded to DataCamp."))
    }
  }
}

add_id_to_course_yml = function(course_id) {
  yaml_list = yaml.load_file("course.yml")
  if (is.null(yaml_list$id)) {
    # Add id to the front of the list. As.integer because could be num:
    yaml_list = append(yaml_list, list(id = as.integer(course_id)), after = 0)
    
    yaml_output = as.yaml(yaml_list,line.sep="\n")
    write(yaml_output, file="course.yml")
    message("The id was added to your course.yml file.")
  } else if (yaml_list$id != course_id) {
    stop(paste0("Something strange happened. Your course.yml file has course id ", course$id, ", whereas the server just returned ", course_id, " . Please compare your course.yml file with the web interface."))
  }
}

get_chapter_id = function(file_name) {
  course = yaml.load_file("course.yml")
  chapter_index = which(sapply(course$chapters, function(x) {names(x)}) == file_name)
  return(as.integer(chapter_index))
}

add_chapter_to_course_yml = function(chapter_file_name, chapter_id) {
  chapter_index = get_chapter_id(chapter_file_name)
  if (length(chapter_index) == 0) {
    yaml_list = yaml.load_file("course.yml")
    
    n = length(yaml_list$chapters)
    yaml_list$chapters[[n+1]] = structure(list(chapter_id), names=chapter_file_name)

    yaml_output = as.yaml(yaml_list,line.sep="\n")
    write(yaml_output, file="course.yml")
    message("The chapter was added to your course.yml file.")
  }
}

render_chapter_json_for_datacamp = function(file_name, payload, force) {
  # Extract basic course info:
  course = yaml.load_file("course.yml")
  if (is.null(course$id)) {
    stop("Error: course.yml does not contain a course id. Please upload your course before uploading chapters.")
  }
  output_list = list(force = force,
                    course = course$id,
                    email  = .DATACAMP_ENV$email,
                    chapter=list(
                      title_meta=payload$title_meta,
                      title=payload$title,
                      description=payload$description
                    ) 
  )
  
  # Extract chapter id and index from course.yml. If found, add to outputList
  course = yaml.load_file("course.yml")
  chapter_index = get_chapter_id(file_name)
  if (length(chapter_index) != 0) { # existing chapter, add info to output_list
    output_list$chapter$id = as.integer(course$chapters[[chapter_index]])
    output_list$chapter$number = chapter_index
  }
  
  # Extract for each exercise the relevant information:
  slides = payload$slides 
  exerciseList = list() 
  for(i in 1:length(slides)) {
    slide = slides[[i]]
    exerciseList[[i]] = list(  title         = html2txt(slide$title),
                               assignment    = clean_up_html(slide$content), 
                               number        = slide$num,
                               instructions  = clean_up_html(slide$instructions$content), 
                               hint          = clean_up_html(slide$hint$content),
                               sample_code   = extract_code( slide$sample_code$content ),
                               solution      = extract_code( slide$solution$content ),
                               sct           = extract_code( slide$sct$content), 
                               pre_exercise_code = extract_code( slide$pre_exercise_code$content) )
    if (!is.null(slide$type)) {  
      exerciseList[[i]][["type"]] = slide$type
      if (slide$type == "MultipleChoiceExercise") {
        exerciseList[[i]][["instructions"]] = make_multiple_choice_vector(exerciseList[[i]][["instructions"]])
        if (!is.null(slide$contains_graph)) {
          exerciseList[[i]][["contains_graph"]] = slide$contains_graph
        }
      }
    }
  }
  
  # Join everything: 
  output_list$chapter$exercises = exerciseList 
  
  # Make JSON: 
  toJSON(output_list) 
}

extract_code = function(html) {
  if (!is.null(html)) {
    if (nchar(html)!=0) {
      r = regexpr("<code class=\"r\">(.*?)</code>",html)
      code = regmatches(html,r)
      code = gsub("<code class=\"r\">|</code>","",code)
      code = html2txt(code)
      
      # solve bug: when quotes are within quotes, we need different type of quotes! e.g. "c('f','t','w')"
      code = gsub("[\\]\"","'",as.character(code))
      
      return(code)
    }}
} 

# Convenience function to convert html codes:
html2txt <- function(str) {
  require("XML")
  str = paste0("<code>",str,"</code>")
  xpathApply(htmlParse(str, asText=TRUE),"//body//text()", xmlValue)[[1]]
}

# Remove paragraphs:
clean_up_html = function(html) {
  #   html = gsub("<p>|</p>","",html)
  return(html)
}

# Function to create an array with the multiple choice options: 
make_multiple_choice_vector = function(instructions) { 
  pattern = "<li>(.*?)</li>"
  instruction_lines =  strsplit(instructions,"\n")[[1]]
  r = regexec(pattern, instruction_lines)
  matches = regmatches(instruction_lines,r)
  extracted_matches = sapply(matches,function(x) x[2])
  multiple_choice_vector = extracted_matches[!is.na(extracted_matches)]
  
  return(multiple_choice_vector)
}
