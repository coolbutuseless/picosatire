
library(satire)

canon_order <- function(df) {
  stopifnot(is.data.frame(df))
  canon_order <- order(apply(df, 1, function(x) {
    paste(x, collapse = "-")
  }))
  df <- df[canon_order,]
  rownames(df) <- NULL
  
  df
}



test_that("pico_solve_satire() works", {
  
  sat <- satire::sat_new()
  satire::sat_card_atmost_k(sat, letters[1:4], 3)
  sat$exprs
  sat$names
  
  # solns <- sat_solve_naive(sat)
  # solns 
  
  solns <- pico_solve_satire(sat, max_solutions = 15)
  solns
  
  
  # construct(solns, template = list(opts_atomic(compress = FALSE)))
  ref <- data.frame(
    a = c(
      FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE,
      FALSE, TRUE, FALSE
    ),
    b = c(
      TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE,
      TRUE, FALSE, FALSE
    ),
    c = c(
      TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE,
      FALSE, FALSE, FALSE
    ),
    d = c(
      TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE
    )
  )
  expect_true(all(rowSums(ref) <= 3))
  
  
  
  
  
  expect_equal(
    canon_order(solns), 
    canon_order(ref)
  )
})




test_that("pico_solve_literals() unsatisfiable returns NULL", {
  expect_null(
    pico_solve_literals(c(1, 0, -1, 0))
  )
})
