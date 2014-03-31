# Build your own interactive course(s)!

## Introduction
Creating interactive courses for data analysis with R can and should be easy. This tutorial explains <b>how you can create interactive courses</b> on the DataCamp platform. Furthermore, the tutorial explains the <b>Submission Correctness Test</b> - the key concept to add interactivity to your course or tutorial.

## Two interfaces to create interactive courses
You can choose from the following options to create interactive courses that your students, employees or clients will love:
- <b>The web interface - create interactive courses completely online:</b><br>
On your dashboard, you see an overview of the courses you created. It is easy to add new courses, and add chapters to each course. Furthermore, you can add exercises by simply dragging and dropping them into the chapter. We provide a seperate exercise creation interface to construct all the components of an interactive exercise. Have a look at your dashboard to get started!
- <b>The R interface - Use R Markdown and the datacamp R packageto create interactive courses:</b><br>
The datacamp R package enables you to write interactive R courses in R Markdown (e.g. using RStudio locally) and then upload them to the datacamp.com platform. The DataCamp package is essentially a wrapper around the [slidify](http://slidify.org/) package. This way, you can also use existing R Markdown files as the basis of your interactive courses, and collaborate easily with others on courses (e.g. by sharing the Markdown files on github). Have a look at the [R Markdown files](https://github.com/data-camp/introduction_to_R) of the "Summer of R" course.
- <b>Use a combination of both interfaces (recommended):</b><br>
If you're not yet familiar with R Markdown, it's probably a good idea to get started with the web interface to create short tutorials. If you are familiar with R Markdown, or in case you want to create longer courses, we advice you to you to use the datacamp R package and write courses in R Markdown. This has several advantages, such as reusing existing tutorials written in R Markdown or collaborating easily on R Markdown documents, etc. After uploading chapters to datacamp.com, you can use the webinterface to structure you chapters and exercises very easily, make changes to the exercises and to preview the course. (Please note: At the moment, you can't convert a course written in the webinterface back to R Markdown, but we'll be working on that).

## Create interactive courses using the datacamp R package
1. Install the datacamp R package:

```r
install.packages("devtools"); library("devtools");
install_github("datacampSCT","data-camp");
install_github("datacamp","data-camp");
install_github("slidify","ramnathv",ref="dev");
library("datacamp");
```
The code above will download and install the datacamp R package. Alternatively, you can also download the source code above.

2. Author a course/chapter:

```r
author_course("courseName")
```
The `author_course` function will: (i) create a folder in you current working directory with the name "courseName", (ii) initialize a Git repo for version control, (iii) copy a demo file "index.Rmd" inside that folder so you can get started, and (iv) open "index.Rmd", a template for creating a chapter, such that you can start writing exercises in the template. Find more information on the (necessary) blocks of an interactive exercise on DataCamp below or just read the instructions in the template.

3. Preview your chapter locally:

```r
preview_chapter("chapterFileName.Rmd")
```
This will open your browser with a preview of the chapter locally. Currently it is just an easy way to get an overview of your chapter. In the future, the preview will inform you on the completeness, correctness and quality of your tutorial.

4. Log in to datacamp.com:

```r
datacamp_login("youremail@someprovider.com","yourpassword")
```
This will allow you to upload a chapter directly to datacamp.com, with the upload_chapter function.

5. Upload a chapter to DataCamp:

```r
upload_chapter("chapterFileName.Rmd")
```
The file `chapterFileName` will be parsed by the slidify package, and uploaded to datacamp.com under your account. When the chapter is successfully uploaded, your browser will automatically open the web interface, so you can preview the course or tutorial online.

6. Share the love:

A course is just a collection of chapters, and a chapter is essentially just a simple R markdown document. Therefore, you can easily collaborate with others on a course. For example, by sharing the [R markdown documents](https://github.com/data-camp/introduction_to_R) on github. We believe this "open-course" type of collaboration for interactive R and statistics courses will benefit everyone. Check out the open-source repo of our Introduction to R course and help us improve it.
