% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MainFun.r
\name{iNEXTIE}
\alias{iNEXTIE}
\title{iNterpolation and EXTrapolation of biodiversity}
\usage{
iNEXTIE(
  data,
  rho,
  q = c(0, 1, 2),
  size = NULL,
  endpoint = NULL,
  knots = 40,
  nboot = 50,
  conf = 0.95
)
}
\arguments{
\item{data}{data can be input as a vector of species abundances (for a single assemblage), matrix/data.frame (species by assemblages), or a list of species abundance vectors.}

\item{rho}{the sampling fraction can be input as a vector for each assemblage or a numeric common value for all assemblages.}

\item{q}{a numerical vector specifying the diversity orders. Default is \code{c(0, 1, 2)}.}

\item{size}{an integer vector of sample sizes (number of individuals or sampling units) for which diversity estimates will be computed. 
If \code{NULL}, then diversity estimates will be computed for those sample sizes determined by the specified/default \code{endpoint} and \code{knots}.}

\item{endpoint}{an integer specifying the sample size that is the \code{endpoint} for rarefaction/extrapolation. 
If \code{NULL}, then \code{endpoint} \code{=} double reference sample size.}

\item{knots}{an integer specifying the number of equally-spaced \code{knots} (say K, default is 40) between size 1 and the \code{endpoint};
each knot represents a particular sample size for which diversity estimate will be calculated.  
If the \code{endpoint} is smaller than the reference sample size, then \code{iNEXTIE()} computes only the rarefaction esimates for approximately K evenly spaced \code{knots}. 
If the \code{endpoint} is larger than the reference sample size, then \code{iNEXTIE()} computes rarefaction estimates for approximately K/2 evenly spaced \code{knots} between sample size 1 and the reference sample size, and computes extrapolation estimates for approximately K/2 evenly spaced \code{knots} between the reference sample size and the \code{endpoint}.}

\item{nboot}{a positive integer specifying the number of bootstrap replications when assessing sampling uncertainty and constructing confidence intervals. Enter 0 to skip the bootstrap procedures. Default is 50.}

\item{conf}{a positive number < 1 specifying the level of confidence interval. Default is 0.95.}
}
\value{
a list of three objects: \cr\cr
(1) \code{$DataInfo} for summarizing data information for q = 0, 1 and 2. Refer to the output of \code{DataInfo} for details. \cr\cr
(2) \code{$iNextEst} for showing diversity estimates for rarefied and extrapolated samples along with related statistics. There are two data frames: \code{"$size_based"} and \code{"$coverage_based"}. \cr\cr
   In \code{"$size_based"}, the output includes:
   \item{Assemblage}{the name of assemblage.} 
   \item{Order.q}{the diversity order of q.}
   \item{m}{the target sample size (or number of sampling units for incidence data).}
   \item{Method}{Rarefaction, Observed, or Extrapolation, depending on whether the target sample size is less than, equal to, or greater than the size of the reference sample.}
   \item{qIE}{the estimated diversity estimate.}
   \item{qIE.LCL and qIE.UCL}{the bootstrap lower and upper confidence limits for the diversity of order q at the specified level (with a default value of 0.95).}
   \item{SC}{the standardized coverage value.}
   \item{SC.LCL, SC.UCL}{the bootstrap lower and upper confidence limits for coverage at the specified level (with a default value of 0.95).}
 Similar output is obtained for \code{"$coverage_based"}. \cr\cr
(3) \code{$AsyEst} for showing asymptotic diversity estimates along with related statistics: 
   \item{Assemblage}{the name of assemblage.} 
   \item{Order.q}{the diversity order of q.}
   \item{IE_MLE}{the maximum likelihood estimate.}
   \item{IE_asy}{the asymptotic diversity estimate.}
   \item{s.e.}{standard error of asymptotic diversity.}
   \item{qIE.LCL and qIE.UCL}{the bootstrap lower and upper confidence limits for asymptotic diversity at the specified level (with a default value of 0.95).}
}
\description{
\code{iNEXTIE} mainly computes standardized diversity estimates with a common sample size or sample coverage for orders q = 0, 1 and 2. It also computes relevant information/statistics.\cr\cr 
Relevant data information is summarized in the output \code{$DataInfo}. 
Diversity estimates for rarefied and extrapolated samples are provided in the output \code{$iNextEst}, which includes two data frames (\code{"$size_based"} and \code{"$coverage_based"}) based on two different standardizations; 
in the size-based standardization, all samples are standardized to a common target sample size, whereas the in the latter standardization, all samples are standardized to a common target level of sample coverage. 
The asymptotic diversity estimates for q = 0, 1 and 2 are provided in the list \code{$AsyEst}.\cr\cr
}
\examples{
# Compute standardized estimates of diversity for abundance data with order q = 0, 1, 2
set.seed(2025)
data = list("Site_1" = as.numeric(rmultinom(1, 200, 1:30)), 
            "Site_2" = as.numeric(rmultinom(1, 300, 1:40)))
output_iNEXT <- iNEXTIE(data, rho = 0.3, q = c(0, 1, 2))
output_iNEXT


}
