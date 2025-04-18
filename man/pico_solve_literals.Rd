% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/picosat-core.R
\name{pico_solve_literals}
\alias{pico_solve_literals}
\title{Solve simple using literals}
\usage{
pico_solve_literals(literals, max_solutions = 1)
}
\arguments{
\item{literals}{integer literals}

\item{max_solutions}{limit number of solutions}
}
\value{
Return NULL is problem is unsatisfiable.  Otherwise return a list
        of integer sequences of literals - each sequence is a solution.
}
\description{
Solve simple using literals
}
\examples{
pico_solve_literals(c(1, 2, 0, 2, -3, 0))
}
