\name{author_course}
\alias{author_course}
\title{Generate course and chapter scaffold}
\usage{
author_course(course_name, ...)
}
\arguments{
  \item{course_name}{String indicating the course name (and
  thus the name of the folder that will be created)}

  \item{...}{Extra arguments you'd like to pass to the
  function. Under the hood, the \code{author} function from
  the \code{slidify} package is called.}
}
\value{
No return values.
}
\description{
The \code{author_course} function will: \enumerate{ \item
create a folder in you current working directory with the
name "course_name" \item create and open a `course.yml`
file, a scaffold to create your course \item create and
open a `chapter1.Rmd` file, a scaffold for creating your
first chapter } The generated template contains extra
instructions on the building blocks of chapters.
}
\examples{
author_course("myNewTutorialName")
}

