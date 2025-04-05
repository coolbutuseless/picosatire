
<!-- README.md is generated from README.Rmd. Please edit that file -->

# picosatire

<!-- badges: start -->

![](https://img.shields.io/badge/cool-useless-green.svg)
[![CRAN](https://www.r-pkg.org/badges/version/picosatire)](https://CRAN.R-project.org/package=picosatire)
[![R-CMD-check](https://github.com/coolbutuseless/picosatire/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/coolbutuseless/picosatire/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`{picosatire}` is a SAT solver for R using the
[PicoSAT](https://fmv.jku.at/picosat/) library.

See the [`{satire}` package](https://github.com/coolbutuseless/satire)
for a more comprehensive introduction to building SAT problems in R.

This packages includes PicoSAT release 965 (with API version 953).

### What’s in the box

- `pico_solve_literals()` solve problems which are presented as a
  sequence of literals (i.e. an integer vector)
- `pico_solve_satire()` solve problems developed as a `sat` object with
  the [`{satire}` package](https://github.com/coolbutuseless/satire)
- `pico_version()` returns version information about the PicoSAT C
  library included in this package.

## Installation

<!-- This package can be installed from CRAN -->

<!-- ``` r -->

<!-- install.packages('picosatire') -->

<!-- ``` -->

You can install the latest development version from
[GitHub](https://github.com/coolbutuseless/picosatire) with:

``` r
# install.package('remotes')
remotes::install_github('coolbutuseless/picosatire')
```

Pre-built source/binary versions can also be installed from
[R-universe](https://r-universe.dev)

``` r
install.packages('picosatire', repos = c('https://coolbutuseless.r-universe.dev', 'https://cloud.r-project.org'))
```

### Example: `pico_solve_literals()`

Integer literals are a standard encoding for SAT solving.

Using literals involves developing Boolean expressions in conjunctive
normal form. Variables are then replaced by integers - the positive
version of the integer indicating `TRUE` and the negative version
indicates `FALSE`. Zeros are used to represent logical `AND`.

When is the following expression true?

`(a | b) & (a | !c)`

Let:

- a = 1
- b = 2
- c = 3

So expresion becomes: `(1 | 2) & (1 | -3)`.

Drop the logical `OR` statements, replace logical `AND` with `0`, and
add a trailing zero on the end. I.e.

`1 2 0 1 -3 0`

Asking PicoSAT to solve this expression:

``` r
pico_solve_literals(c(1L, 2L, 0L, 1L, -3L, 0L), max_solutions = 8)
```

    #> [[1]]
    #> [1]  1  2 -3
    #> 
    #> [[2]]
    #> [1] 1 2 3
    #> 
    #> [[3]]
    #> [1]  1 -2 -3
    #> 
    #> [[4]]
    #> [1]  1 -2  3
    #> 
    #> [[5]]
    #> [1] -1  2 -3

This indicates that there are 5 solutions to the problem. The fifth
solution `-1 2 -3` says that when `a = FALSE, b = TRUE and c = FALSE`
the original statement is `TRUE`

### Example: `pico_solve_satire()`

Using `{satire}` to define the problem makes creation easier and the
solution easier to interpret.

``` r
library(satire)
sat <- sat_new()
sat_add_exprs(sat, "(a | b) & (a | !c)")
sat
```

    #> <sat> vars = 3 , clauses = 2

``` r
pico_solve_satire(sat, max_solutions = 8)
```

    #>       a     b     c
    #> 1  TRUE  TRUE FALSE
    #> 2  TRUE  TRUE  TRUE
    #> 3  TRUE FALSE FALSE
    #> 4  TRUE FALSE  TRUE
    #> 5 FALSE  TRUE FALSE

### Example: Unsatisfiable problems

If the SAT problem is unsatisfiable, the returned solution will be
`NULL`

E.g.

``` r
library(satire)
sat <- sat_new()
sat_add_exprs(sat, "a & !a")
sat
```

    #> <sat> vars = 1 , clauses = 2

``` r
pico_solve_satire(sat, max_solutions = 8)
```

    #> NULL
