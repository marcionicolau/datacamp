[![Build Status](https://api.travis-ci.org/Data-Camp/datacamp.svg?branch=master)](https://travis-ci.org/Data-Camp/datacamp)
<p align="center">
<img src="https://s3.amazonaws.com/assets.datacamp.com/maintenance/logo.png" width="250">
</p>

# Build your own interactive course(s)!
## Introduction
Creating interactive courses for data analysis with R can and should be easy. This tutorial explains **how you can create interactive courses** on the DataCamp platform. Furthermore, the tutorial explains the **Submission Correctness Test** - the key concept to add interactivity to your course or tutorial.

## Create and managing interactive courses
Courses are created locally using R Markdown files and managed with a complementary web interface on datacamp.com.

- **The R interface - Use R Markdown and the datacamp R package to create interactive courses:**<br>
The datacamp R package enables you to write interactive R courses in R Markdown (e.g. using RStudio locally) and then upload them to the datacamp.com platform. The DataCamp package is essentially a wrapper around the [slidify](http://slidify.org/) package. This way, you can also use existing R Markdown files as the basis of your interactive courses, and collaborate easily with others on courses (e.g. by sharing the Markdown files on github). Have a look at the [R Markdown files](https://github.com/data-camp/introduction_to_R) of the "Introduction to R" course.
- **The web interface - Course management:**<br>
After uploading chapters to datacamp.com, you can use the webinterface to view and organize your courses with their chapters. You can use the web interface to make sure your course was uploaded correctly and make various changes to the course's state.

## Getting started

###Install the datacamp R package
   ```ruby
install.packages("devtools")
library("devtools")
install_github("datacampSCT", "data-camp")
install_github("datacamp", "data-camp")
install_github("slidify", "ramnathv", ref = "dev")
install_github("slidifyLibraries", "ramnathv")
library("datacamp")
```
The code above will download and install the datacamp R package. Alternatively, you can also download the source code above.

###Scaffold a course with chapter
   ```ruby
author_course("course_name")
```
The `author_course` function will:
  1. create a folder in you current working directory with the name "course_name"
  2. create a `course.yml` file, a scaffold to create your course
  3. create a `chapter1.Rmd` file, a scaffold for creating your first chapter
The generated template contains extra instructions on the building blocks of chapters. We strongly advise you to put your folder under git source control at this point.

###Directory structure
Every course consists of a `course.yml` file along with various `.Rmd` chapter files. An example course is structured as follows:
   ```
.
|__ course.yml
|__ chapter1.Rmd
|__ chapter2.Rmd
|__ chapter3.Rmd
|__ ...
```
Note that the chapter `.Rmd` files can have any chosen name.

###Log in to datacamp.com
   ```ruby
datacamp_login()
```
This will prompt you for your username and password and log you in to the datacamp server. Note that you must also log into datacamp.com with your browser.

###The `course.yml` file
This file contains information about your course and the structure of its chapters. After `author_course()`, you get the following scaffold:
   ```yml
# course.yml scaffold
title: Insert the course title here
author_field: The author(s) name(s)
description: Insert course description here
```
Change the fields and call the function `upload_course()`. This will create your course and add its id to the `course.yml` file. This way your local course is linked to the one on datacamp.com.
   ```yml
# course.yml after creation on server
id: 314
title: Hello world
author_field: Your name
description: A first course
```

###Uploading chapters to datacamp.com
Every chapter is described in its corresponding `chapterX.Rmd` file. The first time you create a chapter, it's a good idea to start from the `chapter1.Rmd` template that was generated using `author_course("course_name")`. This template contains information about the markup language, different types of exercises, etc.
   ```yml
# chapter1.Rmd scaffold
--- 
title       : Insert the chapter title here
description : What is this chapter about? Add here your description
framework   : datacamp
mode        : selfcontained

---
## The title of the first exercise
...
```
Adapt the scaffold and use the function `upload_chapter("chapter1.Rmd")` to add the chapter to your course on datacamp.com. This will create the chapter and add it to the `course.yml` file. Every time you add a new chapter to a course, it is added to the `course.yml` file. An example:
   ```yml
# e.g. course.yml
id: 314
title: Hello world
author_field: Your name
description: A first course
chapters:
  - chapter1.Rmd: 753
  - chapter2.Rmd: 760
```
As you can see, the file contains a list of chapters with a mapping of their file names on their id. The order of the list dictates the order of the chapters within the course. This helps you organize your course and avoid overwriting chapters. For example, say we want chapter 2 to appear first on datacamp.com:
```yml
# course.yml
...
chapters:
  - chapter2.Rmd: 760
  - chapter1.Rmd: 753
```
Any changes to this list requires the course to be uploaded with `upload_course()` for changes to take effect.

You can also upload all chapters at once with `upload_all_chapters()`.

###Share the love
A course is just a collection of chapters, and a chapter is essentially just a simple R markdown document. Therefore, you can easily collaborate with others on a course. For example, by sharing the [R markdown documents](https://github.com/data-camp/introduction_to_R) on github. We believe this "open-course" type of collaboration for interactive R and statistics courses will benefit everyone. Check out the open-source repo of our Introduction to R course and help us improve it.


## Submission Correctness Tests
The key ingredient to an interactive course is the Submission Correctness Test (SCT). For all information regarding SCTs, please refer to the [datacampSCT package](https://github.com/Data-Camp/datacampSCT).
