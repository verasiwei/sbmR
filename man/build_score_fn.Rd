% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_score_fn.R
\name{build_score_fn}
\alias{build_score_fn}
\title{Build score function from heuristic}
\usage{
build_score_fn(heuristic)
}
\arguments{
\item{heuristic}{How the best partitioning is defined. Takes either a
function that takes one/two arguments: an entropy vector and an optional
number of blocks vector with each element corresponding to a given
location, or a string labeling algorithm. Currently only \code{"lowest"},
\code{"dev_from_rolling_mean"}, \code{"delta_ratio"}, \code{"trend_deviation"}, and \code{"nls_residual"} are supported.}
}
\value{
A function that takes and entropy and number of block vector and
returns a score for partitioning (higher = better)
}
\description{
(Internal) Takes a heuristic object and turns it into a function that takes
two arguments, entropy and number of blocks that is used to calculate the
score for a given entropy-number of blocks step for agglomerative merging
algorithms.
}
\examples{

# Setup fake entropy and number of blocks vectors
entropy <- -(10:1)*1000 + rnorm(10, 200)
num_blocks <- 1:10

# Works with heuristic functions that take two arguments
nls_score <- function(e, k){
  entropy_model <- nls(e ~ a + b * log(k), start = list(a = max(e), b = -25))
  -residuals(entropy_model)
}

build_score_fn(nls_score)(entropy, num_blocks)

# Works with functions that take one argument
invert_score <- function(e) -e/2
build_score_fn(invert_score)(entropy, num_blocks)

# Works with predefined strings
build_score_fn("dev_from_rolling_mean")(entropy, num_blocks)
build_score_fn("lowest")(entropy, num_blocks)

}
\seealso{
Other helpers: 
\code{\link{get_combination_indices}()},
\code{\link{get_sweep_pair_counts}()},
\code{\link{get_sweep_results}()},
\code{\link{print.sbm_network}()},
\code{\link{rolling_mean}()},
\code{\link{verify_model}()}
}
\concept{helpers}
