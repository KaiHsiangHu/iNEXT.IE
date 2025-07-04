% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MainFun.r
\name{MLEAsyIE}
\alias{MLEAsyIE}
\title{Asymptotic diversity and maximum likelihood diversity estimates of order q}
\usage{
MLEAsyIE(
  data,
  rho,
  q = seq(0, 2, 0.2),
  nboot = 50,
  conf = 0.95,
  method = c("Asymptotic", "MLE")
)
}
\arguments{
\item{data}{data can be input as a vector of species abundances (for a single assemblage), matrix/data.frame (species by assemblages), or a list of species abundance vectors.}

\item{rho}{the sampling fraction can be input as a vector for each assemblage or a numeric common value for all assemblages.}

\item{q}{a numerical vector specifying the diversity orders. Default is \code{seq(0, 2, by = 0.2)}.}

\item{nboot}{a positive integer specifying the number of bootstrap replications when assessing sampling uncertainty and constructing confidence intervals. Enter 0 to skip the bootstrap procedures. Default is 50.}

\item{conf}{a positive number < 1 specifying the level of confidence interval. Default is 0.95.}

\item{method}{Select \code{'Asymptotic'} or \code{'MLE'}.}
}
\value{
a data frame including the following information/statistics: 
\item{Assemblage}{the name of assemblage.}
\item{Order.q}{the diversity order of q.}
\item{qIE}{the estimated asymptotic diversity or maximum likelihood diversity of order q.} 
\item{s.e.}{standard error of diversity.}
\item{qIE.LCL and qIE.UCL}{the bootstrap lower and upper confidence limits for the diversity of order q at the specified level (with a default value of 0.95).}
\item{Method}{\code{"Asymptotic"} means asymptotic diversity and \code{"MLE"} means maximum likelihood diversity.}
}
\description{
\code{MLEAsyIE} computes maximum likelihood and asymptotic diversity of order q between 0 and 2 (in increments of 0.2); these diversity values with different order q can be used to depict a q-profile in the \code{ggMLEAsyIE} function.\cr\cr
}
\examples{
# Compute the maximum likelihood and asymptotic diversity for abundance data
# with order q between 0 and 2 (in increments of 0.2 by default)
set.seed(2025)
data = list("Site_1" = as.numeric(rmultinom(1, 200, 1:30)), 
            "Site_2" = as.numeric(rmultinom(1, 300, 1:40)))
output_ObsAsy <- MLEAsyIE(data, rho = 0.3)
output_ObsAsy


}
