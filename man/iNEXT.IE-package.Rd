\name{iNEXT.IE-package}
\alias{iNEXT.IE-package}
\alias{iNEXT.IE}
\docType{package}
\title{
Interpolation and Extrapolation for inter-specific encounter diversity
}
\description{
\code{iNEXT.IE} (iNterpolation and EXTrapolation for inter-specific encounter diversity) is a framework for biodiversity methodology. 
An online version "iNEXT.IE Online"
(https://kaihsiang-hu.shinyapps.io/iNEXT_IE/) is also available for users without an R background.

\code{iNEXT.IE} features two statistical analyses (non-asymptotic and asymptotic):

(1) A non-asymptotic approach based on interpolation and extrapolation for diversity 

\code{iNEXT.IE} computes the estimated diversity for standardized samples with a common sample size or sample completeness. This approach enables comparison of diversity estimates for equally-large (with a common sample size) or equally-complete (with a common sample coverage) samples; it is based on the seamless rarefaction and extrapolation (R/E) sampling curves of diversity for q = 0.5, 1 and 2. \code{iNEXT.IE} offers three types of R/E sampling curves:

* Sample-size-based (or size-based) R/E sampling curves: This type of sampling curve plots the diversity estimates with respect to sample size.

* Coverage-based R/E sampling curves: This type of sampling curve plots the diversity estimates with respect to sample coverage.

* Sample completeness curve: This curve depicts how sample coverage varies with sample size. The sample completeness curve provides a bridge between the size- and coverage-based R/E sampling curves.

(2) An asymptotic approach to infer asymptotic diversity 

\code{iNEXT.IE} computes the estimated asymptotic diversity and also plots diversity profiles (q-profiles) for q between 0.4 and 2, in comparison with the maximum likelihood estimation. Typically, the asymptotic estimates for q \eqn{\geq} 1 are reliable, but for q < 1 (especially when q is near zero), they represent lower bounds only. \cr

There are six main functions in this package: \cr

1. \code{iNEXTIE} computes standardized diversity of order q = 0.5, 1 and 2 for rarefied and extrapolated samples at specified sample coverage values and sample sizes. \cr

2. \code{ggiNEXTIE} visualizes the output from the function \code{iNEXTIE}. \cr

3. \code{MLEAsyIE} computes maximum likelihood estimation and asymptotic diversity of order q between 0.4 and 2 (in increments of 0.2) for diversity. \cr

4. \code{ggMLEAsyIE} visualizes the output from the function \code{MLEAsyIE}. \cr

5. \code{estimateIE} computes diversity of order q = 0.5, 1 and 2 with a particular set of user-specified level of sample sizes or sample coverage values. \cr

6. \code{DataInfoIE} provides basic data information based on the observed data. \cr

}
\author{
Kai-Hsiang Hu and Anne Chao \cr

Maintainer: Kai-Hsiang Hu <river19951224@gmail.com>
}
\keyword{package}
