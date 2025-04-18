% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/picosat-core.R
\name{pico_version}
\alias{pico_version}
\title{Return a list of version information of the PicoSAT library}
\usage{
pico_version()
}
\value{
Named list of version information. \code{PICOSAT_API_VERSION} is the
        internal C API version, and \code{release} is the numbering of the 
        software release tarball.
}
\description{
Return a list of version information of the PicoSAT library
}
\examples{
pico_version()
}
