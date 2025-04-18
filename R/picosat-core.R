

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Solve simple using literals
#' 
#' @param literals integer literals
#' @param max_solutions limit number of solutions
#' @return Return NULL is problem is unsatisfiable.  Otherwise return a list
#'         of integer sequences of literals - each sequence is a solution.
#' @examples
#' pico_solve_literals(c(1, 2, 0, 2, -3, 0))
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pico_solve_literals <- function(literals, max_solutions = 1) {
  res <- .Call(pico_solve_, as.integer(literals), max_solutions, NULL)
  if (is.null(res)) {return(NULL)}
  
  if (max_solutions == 1 && length(res) == 1) {
    res[[1]]
  } else {
    res
  }
  
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Solve simple using 'satire' 
#' 
#' @inheritParams pico_solve_literals
#' @param sat SAT problem definition as created by \code{satire::sat_new()} or
#'        \code{satire::read_dimacs()}
#' @param remove regular expression for variables to remove when blocking solutions
#'        and assembling values to return. Default: "^dummy" will block all
#'        variables starting with the word "dummy" (as this is how the 'satire' 
#'        package automatically creates dummy variables.)
#'        If NULL no variables will be removed.
#' @return Return NULL is problem is unsatisfiable.  Otherwise return a data.frame
#'         of solutions where each column represents a named variable in the 
#'         problem and each row is a solution.
#' @examples
#' sat <- satire::sat_new()
#' satire::sat_add_exprs(sat, "a -> (b & c)")
#' pico_solve_satire(sat, max_solutions = 10)
#' satire::sat_solve_naive(sat)
#' satire::sat_solve_dpll(sat, max_solutions = 10)
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pico_solve_satire <- function(sat, max_solutions = 1, remove = "^dummy") {
  
  stopifnot(inherits(sat, "sat_prob"))
  keep_idxs <- which(!grepl(remove, sat$names)) - 1L
  
  if (length(keep_idxs) == 0) {
    stop("No variable names to return. Empty problem, or 'remove' too aggressive")
  }
  
  res <-.Call(pico_solve_, sat$literals, max_solutions, keep_idxs)
  if (is.null(res)) {return(NULL)}
  
  # Map to named logicals
  res <- lapply(res, function(soln) {
    satire::sat_literals_to_lgl(sat, soln, remove = remove)
  })
  
  # Convert to data.frrame
  res <- as.data.frame(do.call(rbind, res))
  res <- res[!duplicated(res), , drop = FALSE]
  rownames(res) <- NULL
  
  res
}

 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Return a list of version information of the PicoSAT library
#' 
#' @return Named list of version information. \code{PICOSAT_API_VERSION} is the
#'         internal C API version, and \code{release} is the numbering of the 
#'         software release tarball.
#' @examples
#' pico_version()
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pico_version <- function() {
  list(
    PICOSAT_API_VERSION = 953,
    release = 965
  )
}


