#' Data information for reference samples
#' 
#' \code{DataInfoIE} provides basic data information for diversity based on a reference sample.
#' 
#' @param data data can be input as a vector of species abundances (for a single assemblage), matrix/data.frame (species by assemblages), or a list of species abundance vectors.
#' @param rho the sampling fraction can be input as a vector for each assemblage, or enter a single numeric value to apply to all assemblages.
#' 
#' @return a data.frame including assemblage name (\code{Assemblage}), sample size in the reference sample (\code{n}), 
#' total abundance in the overall assemblage (\code{N}), sampling fraction of the reference sample (\code{rho}), 
#' observed species richness in the reference sample (\code{S.obs}), 
#' sample coverage estimates of the reference sample (\code{SC(n)}), sample coverage estimate for twice the reference sample size (\code{SC(2n)}),
#' the first five species abundance counts (\code{f1}--\code{f5}).\cr
#'  
#' 
#' @examples
#' data("spider")
#' DataInfoIE(spider, rho = 0.3)
#' 
#'
#' @export
DataInfoIE <- function(data, rho = NULL) {
  
  data = check.data(data)
  rho = check.rho(data, rho)
  
  Fun <- function(x, rho){
    
    n <- sum(x)
    N = n / rho
    fk <- sapply(1:5, function(k) sum(x == k))
    Sobs <- sum(x > 0)
    Chat <- Coverage(x, rho, sum(x))
    Chat2n <- Coverage(x, rho, 2*sum(x))
    
    c(n, round(N), rho, Sobs, Chat, Chat2n, fk)
  }
  
  out <- lapply(1:length(data), function(i) Fun(data[[i]], rho[i])) %>% do.call(rbind,.)
  
  out <- data.frame(Assemblage = names(data), out)
  colnames(out) <-  c("Assemblage", "n", "N", "rho", "S.obs", "SC(n)", "SC(2n)", paste("f", 1:5, sep = ""))
  rownames(out) <- NULL
  
  return(out)
}


#' @useDynLib iNEXT.IE, .registration = TRUE
#' @importFrom Rcpp sourceCpp
NULL



#' iNterpolation and EXTrapolation of biodiversity
#' 
#' \code{iNEXTIE} mainly computes standardized diversity estimates with a common sample size or sample coverage for orders q = 0.5, 1 and 2. It also computes relevant information/statistics.\cr\cr 
#' Relevant data information is summarized in the output \code{$DataInfo}. 
#' Diversity estimates for rarefied and extrapolated samples are provided in the output \code{$iNextEst}, which includes two data frames (\code{"$size_based"} and \code{"$coverage_based"}) based on two different standardizations; 
#' in the size-based standardization, all samples are standardized to a common target sample size, whereas the in the latter standardization, all samples are standardized to a common target level of sample coverage. 
#' The maximum likelihood estimation and asymptotic diversity estimates for q = 0.5, 1 and 2 are provided in the list \code{$AsyEst}.\cr\cr 
#' 
#' @param data data can be input as a vector of species abundances (for a single assemblage), matrix/data.frame (species by assemblages), or a list of species abundance vectors.
#' @param rho the sampling fraction can be input as a vector for each assemblage, or enter a single numeric value to apply to all assemblages.
#' @param q a numerical vector specifying the diversity orders. Default is \code{c(0.5, 1, 2)}.
#' @param size an integer vector of sample sizes (number of individuals) for which diversity estimates will be computed. 
#' If \code{NULL}, then diversity estimates will be computed for those sample sizes determined by the specified/default \code{endpoint} and \code{knots}.
#' @param endpoint an integer specifying the sample size that is the \code{endpoint} for rarefaction/extrapolation. 
#' If \code{NULL}, then \code{endpoint} \code{=} the maximum sample sizes, which is set to double the reference sample size when rho is less than 0.2; triple the reference sample size when rho is between 0.2 and 0.4; and the total number of individuals when rho exceeds 0.4.
#' @param knots an integer specifying the number of equally-spaced \code{knots} (say K, default is 40) between size 1 and the \code{endpoint};
#' each knot represents a particular sample size for which diversity estimate will be calculated. \cr 
#' If the \code{endpoint} is smaller than the reference sample size, then \code{iNEXTIE()} computes only the rarefaction esimates for approximately K evenly spaced \code{knots}. \cr
#' If the \code{endpoint} is larger than the reference sample size, then \code{iNEXTIE()} computes rarefaction estimates for approximately K/2 evenly spaced \code{knots} between sample size 1 and the reference sample size, and computes extrapolation estimates for approximately K/2 evenly spaced \code{knots} between the reference sample size and the \code{endpoint}.
#' @param nboot a positive integer specifying the number of bootstrap replications when assessing sampling uncertainty and constructing confidence intervals. Enter 0 to skip the bootstrap procedures. Default is 50.
#' @param conf a positive number < 1 specifying the level of confidence interval. Default is 0.95.
#' 
#' @import dplyr
#' @import ggplot2
#' @import reshape2
#' @importFrom stats rmultinom
#' @importFrom stats qnorm
#' @importFrom stats sd
#' @importFrom stats optimize
#' @importFrom stats dhyper
#' @importFrom stats quantile
#' @importFrom grDevices hcl
#' 
#' @return a list of three objects: \cr\cr
#' (1) \code{$DataInfo} for summarizing data information for q = 0.5, 1 and 2. Refer to the output of \code{DataInfoIE} for details. \cr\cr
#' (2) \code{$iNextEst} for showing diversity estimates for rarefied and extrapolated samples along with related statistics. There are two data frames: \code{"$size_based"} and \code{"$coverage_based"}. \cr\cr
#'    In \code{"$size_based"}, the output includes:
#'    \item{Assemblage}{the name of assemblage.} 
#'    \item{Order.q}{the diversity order of q.}
#'    \item{m}{the target sample size.}
#'    \item{Method}{Rarefaction, Observed, or Extrapolation, depending on whether the target sample size is less than, equal to, or greater than the size of the reference sample.}
#'    \item{qIE}{the estimated diversity estimate.}
#'    \item{qIE.LCL and qIE.UCL}{the bootstrap lower and upper confidence limits for the diversity of order q at the specified level (with a default value of 0.95).}
#'    \item{SC}{the standardized coverage value.}
#'    \item{SC.LCL, SC.UCL}{the bootstrap lower and upper confidence limits for coverage at the specified level (with a default value of 0.95).}
#'  Similar output is obtained for \code{"$coverage_based"}. \cr\cr
#' (3) \code{$AsyEst} for showing maximum likelihood estimation and asymptotic diversity estimates along with related statistics: 
#'    \item{Assemblage}{the name of assemblage.} 
#'    \item{Order.q}{the diversity order of q.}
#'    \item{IE_MLE}{the maximum likelihood estimation estimates.}
#'    \item{IE_asy}{the asymptotic diversity estimates.}
#'    \item{s.e.}{standard error of asymptotic diversity.}
#'    \item{qIE.LCL and qIE.UCL}{the bootstrap lower and upper confidence limits for asymptotic diversity at the specified level (with a default value of 0.95).}
#' 
#' 
#' @examples
#' # Compute standardized estimates of diversity for abundance data with order q = 0.5, 1, 2
#' data("spider")
#' output_iNEXT <- iNEXTIE(spider, rho = 0.3, q = c(0.5, 1, 2))
#' output_iNEXT
#' 
#' 
#' @export
iNEXTIE <- function(data, rho = NULL, q = c(0.5, 1, 2), size = NULL, endpoint = NULL, knots = 40, nboot = 50, conf = 0.95) {
  
  data = check.data(data)
  rho = check.rho(data, rho)
  
  q = check.q(q)
  conf = check.conf(conf)
  nboot = check.nboot(nboot)
  size = check.size(data, rho, size, endpoint, knots)
  
  Fun <- function(x, rho, q, size, assem_name){
    
    out <- iNEXT(x = x, rho = rho, q = q, m = size, endpoint = ifelse(is.null(endpoint), 2*sum(x), endpoint), knots = knots, nboot = nboot, conf = conf)
    
    out <- lapply(out, function(out_) cbind(Assemblage = assem_name, out_))
    
    out
  }
  
  z <- qnorm(1 - (1 - conf) / 2)
  
  out <- lapply(1:length(data), function(i) Fun(data[[i]], rho[i], q, size[[i]], names(data)[i]))
  
  out <- list(size_based     = do.call(rbind, lapply(out, function(out_) out_[[1]])),
              coverage_based = do.call(rbind, lapply(out, function(out_) out_[[2]])))
  
  index <- rbind(est(data, rho, c(0.5, 1, 2), nboot, conf),
                 emp(data, rho, c(0.5, 1, 2), nboot, conf))
  
  LCL <- index$qIE.LCL[index$Method == 'Asymptotic']
  UCL <- index$qIE.UCL[index$Method == 'Asymptotic']
  
  index <- dcast(index, formula = Assemblage + Order.q ~ Method, value.var = 'qIE')
  index <- cbind(index, se = (UCL - index$Asymptotic) / z, LCL, UCL)
  
  index[,3:4] = index[,4:3]
  colnames(index) <- c("Assemblage", "Order.q", "IE_MLE", "IE_asy", "s.e.", "qIE.LCL", "qIE.UCL")
  
  
  out$size_based$Assemblage <- as.character(out$size_based$Assemblage)
  out$coverage_based$Assemblage <- as.character(out$coverage_based$Assemblage)
  
  info <- DataInfoIE(data, rho)
  
  out <- list("DataInfo" = info, "iNextEst" = out, "AsyEst" = index)
  
  class(out) <- c("iNEXTIE")
  
  return(out)
}


#' ggplot2 extension for an iNEXTIE object
#' 
#' \code{ggiNEXTIE} is a \code{ggplot} extension for an \code{iNEXTIE} object to plot sample-size- and coverage-based rarefaction/extrapolation sampling curves along with a bridging sample completeness curve.
#' @param output an \code{iNEXTIE} object computed by \code{iNEXTIE}.
#' @param type three types of plots: sample-size-based rarefaction/extrapolation curve (\code{type = 1}); 
#' sample completeness curve (\code{type = 2}); coverage-based rarefaction/extrapolation curve (\code{type = 3}).            
#' @param log2 whether to apply a log2 transformation to diversity or not. (only for type = 1 or 3)\cr
#' @return a \code{ggplot2} object for sample-size-based rarefaction/extrapolation curve (\code{type = 1}), sample completeness curve (\code{type = 2}), and coverage-based rarefaction/extrapolation curve (\code{type = 3}).
#' 
#' 
#' @examples
#' # Plot three types of curves of diversity for abundance data with order q = 0.5, 1, 2
#' data("spider")
#' output_iNEXT <- iNEXTIE(spider, rho = 0.3, q = c(0.5, 1, 2))
#' ggiNEXTIE(output_iNEXT)
#' 
#' 
#' @export
ggiNEXTIE = function(output, type = 1:3, log2 = FALSE) {
  
  x_list = output$iNextEst
  
  TYPE <-  c(1, 2, 3)
  if (sum(!(type %in% TYPE)) >= 1) stop("invalid plot type")
  type <- pmatch(type, 1:3)
  
  out = lapply(type, function(i) {
    
    if (i == 1) {
      
      output <- x_list$size_based
      if (log2) output = output %>% mutate(qIE = log2(qIE), qIE.LCL = log2(qIE.LCL), qIE.UCL = log2(qIE.UCL))
      
      output$y.lwr <- output$qIE.LCL
      output$y.upr <- output$qIE.UCL
      id <- match(c("m", "Method", "qIE", "qIE.LCL", "qIE.UCL", "Assemblage", "Order.q"), names(output), nomatch = 0)
      output[,1:7] <- output[, id]
      
      xlab_name <- "Number of individuals"
      ylab_name <- "Inter-specific encounter"
      
    } else if (i == 2) {
      
      output <- x_list$size_based
      
      if (length(unique(output$Order.q)) > 1) output <- subset(output, Order.q == unique(output$Order.q)[1])
      output$y.lwr <- output$SC.LCL
      output$y.upr <- output$SC.UCL
      id <- match(c("m", "Method", "SC", "SC.LCL", "SC.UCL", "Assemblage", "Order.q", "qIE", "qIE.LCL", "qIE.UCL"), names(output), nomatch = 0)
      output[,1:10] <- output[, id]
      
      xlab_name <- "Number of individuals"
      ylab_name <- "Sample coverage"
      
    } else if (i == 3) {
      
      output <- x_list$coverage_based %>% tibble
      if (log2) output = output %>% mutate(qIE = log2(qIE), qIE.LCL = log2(qIE.LCL), qIE.UCL = log2(qIE.UCL))
      
      output$y.lwr <- output$qIE.LCL
      output$y.upr <- output$qIE.UCL
      id <- match(c("SC", "Method", "qIE", "qIE.LCL", "qIE.UCL", "Assemblage", "Order.q", "m"), names(output), nomatch = 0)
      output[,1:8] <- output[, id]
      
      xlab_name <- "Sample coverage"
      ylab_name <- "Inter-specific encounter"
    }
    
    title <- c("Sample-size-based sampling curve", "Sample completeness curve", "Coverage-based sampling curve")[i]
    colnames(output)[1:7] <- c("x", "Method", "y", "LCL", "UCL", "Assemblage", "Order.q")
    
    output$col <- output$shape <- output$Assemblage
    
    data.sub = output
    tmp = output %>% filter(Method == "Observed") %>% mutate(Method = "Extrapolation")
    output$Method[output$Method == "Observed"] = "Rarefaction"
    output = rbind(output, tmp)
    output$lty <- factor(output$Method, levels = c("Rarefaction", "Extrapolation"))
    output$col <- factor(output$col)
    
    data.sub <- data.sub[which(data.sub$Method == "Observed"),]
    
    if (length(unique(output$Assemblage)) <= 8){
      cbPalette <- rev(c("#999999", "#E69F00", "#56B4E9", "#009E73", 
                         "#330066", "#CC79A7", "#0072B2", "#D55E00"))
    }else{
      
      cbPalette <- rev(c("#999999", "#E69F00", "#56B4E9", "#009E73", 
                         "#330066", "#CC79A7", "#0072B2", "#D55E00"))
      cbPalette <- c(cbPalette, ggplotColors(length(unique(output$Assemblage)) - 8))
    }
    
    g <- ggplot(output, aes_string(x = "x", y = "y", colour = "col")) + 
      geom_line(aes_string(linetype = "lty"), lwd = 1.5) +
      geom_point(aes_string(shape = "shape"), size = 5, data = data.sub) +
      geom_ribbon(aes_string(ymin = "y.lwr", ymax = "y.upr", fill = "factor(col)", colour = "NULL"), alpha = 0.2) +
      scale_fill_manual(values = cbPalette) +
      scale_colour_manual(values = cbPalette) +
      theme_bw() + 
      facet_wrap( ~ paste("q = ", Order.q, sep = ""), nrow = 1, scales = "free_y" ) + 
      labs(x = xlab_name, y = ylab_name) + 
      ggtitle(title) + 
      theme(legend.position = "bottom", 
            legend.box = "vertical",
            legend.key.width = unit(1.2, "cm"),
            legend.title = element_blank(),
            legend.margin = margin(0, 0, 0, 0),
            legend.box.margin = margin(0, 0, 0, 0),
            text = element_text(size = 16),
            plot.margin = unit(c(5.5, 5.5, 5.5, 5.5), "pt")) +
      guides(linetype = guide_legend(title = "Method", keywidth = 2.5),
             colour = guide_legend(title = "Guides"), 
             fill = guide_legend(title = "Guides"), 
             shape = guide_legend(title = "Guides"))
    
    if (i == 2) g <- g + theme(strip.background = element_blank(), strip.text.x = element_blank())
    
    if ((i != 2) & log2) g = g + labs(y = expression(paste(log[2], '(Inter-specific encounter)')))
    
    return(g)
    })
  
  
  if (length(type) == 1) out = out[[1]]
  
  return(out)
}



#' Compute diversity estimates with a particular set of sample sizes/coverages
#' 
#' \code{estimateIE} computes diversity with a particular set of user-specified levels of sample sizes or sample coverages. If no sample sizes or coverages are specified, this function by default computes diversity estimates for the minimum sample coverage or minimum sample size among all samples extrapolated to the maximum sample sizes (see arguments).
#' @param data data can be input as a vector of species abundances (for a single assemblage), matrix/data.frame (species by assemblages), or a list of species abundance vectors.
#' @param rho the sampling fraction can be input as a vector for each assemblage, or enter a single numeric value to apply to all assemblages.
#' @param q a numerical vector specifying the diversity orders. Default is \code{c(0.5, 1, 2)}.
#' @param base selection of sample-size-based (\code{base = "size"}) or coverage-based (\code{base = "coverage"}) rarefaction and extrapolation.
#' @param level A numerical vector specifying the particular sample sizes or sample coverages (between 0 and 1) for which diversity estimates (q = 0.5, 1 and 2) will be computed. \cr
#' If \code{base = "coverage"} (default) and \code{level = NULL}, then this function computes the diversity estimates for the minimum sample coverage among all samples extrapolated to the maximum sample sizes. \cr
#' If \code{base = "size"} and \code{level = NULL}, then this function computes the diversity estimates for the minimum sample size among all samples extrapolated to the maximum sample sizes. \cr
#' Specifically, the maximum extrapolation limit is set to double the reference sample size when rho is less than 0.2; triple the reference sample size when rho is between 0.2 and 0.4; and the total number of individuals when rho exceeds 0.4. 
#' @param nboot a positive integer specifying the number of bootstrap replications when assessing sampling uncertainty and constructing confidence intervals. Enter 0 to skip the bootstrap procedures. Default is 50.
#' @param conf a positive number < 1 specifying the level of confidence interval. Default is 0.95.
#' 
#' @return a data.frame of diversity table including the following arguments: (when \code{base = "coverage"})
#' \item{Assemblage}{the name of assemblage.}
#' \item{Order.q}{the diversity order of q.}
#' \item{SC}{the target standardized coverage value.}
#' \item{m}{the corresponding sample size for the standardized coverage value.}
#' \item{Method}{Rarefaction, Observed, or Extrapolation, depending on whether the target coverage is less than, equal to, or greater than the coverage of the reference sample.}
#' \item{qIE}{the estimated diversity of order q for the target coverage value. The estimate for complete coverage (when \code{base = "coverage"} and \code{level = 1}, or \code{rho = 1}) represents the estimated asymptotic diversity.}
#' \item{s.e.}{standard error of diversity estimate.}
#' \item{qIE.LCL and qIE.UCL}{the bootstrap lower and upper confidence limits for the diversity of order q at the specified level (with a default value of 0.95).}
#' Similar output is obtained for \code{base = "size"}. \cr\cr
#' 
#' 
#' @examples
#' data("spider")
#' output_est_cov <- estimateIE(spider, rho = 0.3, q = c(0.5, 1, 2), 
#'                              base = "coverage", level = c(0.94, 0.96))
#' output_est_cov
#' 
#' output_est_size <- estimateIE(spider, rho = 0.3, q = c(0.5, 1, 2),
#'                               base = "size", level = c(150, 250))
#' output_est_size
#' 
#' 
#' @export
estimateIE <- function(data, rho = NULL, q = c(0.5, 1, 2), base = "coverage", level = NULL, nboot = 50, conf = 0.95) {
  
  data = check.data(data)
  rho = check.rho(data, rho)
  
  q = check.q(q)
  conf = check.conf(conf)
  nboot = check.nboot(nboot)
  base = check.base(base)
  level = check.level(data, rho, base, level)
  
  if (base == "size") {
    
    out <- invSize(data, rho, q, size = level, nboot, conf = conf)
    
  } else if (base == "coverage") {
    
    out <- invChat(data, rho, q, C = level, nboot, conf = conf)
  }
  
  out$qIE.LCL[out$qIE.LCL < 0] <- 0
  
  return(out)
}


ggplotColors <- function(g){
  d <- 360 / g # Calculate the distance between colors in HCL color space
  h <- cumsum(c(15, rep(d, g - 1))) # Create cumulative sums to define hue values
  hcl(h = h, c = 100, l = 65) # Convert HCL values to hexadecimal color codes
  }


D.m.est = function(x, rho, q, m) {
  
  x = x[x > 0]
  n = sum(x)
  N = ceiling(n / rho)
  f1 = sum(x == 1); f2 = sum(x == 2)
  f0 = ifelse(f2 > 0, f1^2 / (n/(n - 1) * 2 * f2 + rho/(1 - rho) * f1), f1*(f1 - 1) / (n/(n - 1) * 2 + rho/(1 - rho) * f1))
  if (is.nan(f0)) f0 = 0
  
  
  D0.hat <- function(x, m) {
    
    Sub <- function(m) {
      if (m <= n) {
        
        sum(1 - dhyper(0, x, n - x, m)) - 1
        
      } else {
        
        ms = m - n
        # N0 = (N - n + 1) * f1 / (n * f0 + f1)
        # if (N0 == "NaN") N0 = 0
        
        # length(x) + f0 * (1 - (1 - ms/(N - n))^N0) - 1
        obs + (asy - obs) * (1 - (1 - ms / (N - n) )^beta) - 1
        
      }
    }
    
    obs <- length(x)
    asy <- length(x) + f0
    if (asy < obs) asy = obs
    
    RFD_m = Sub(n - 1) + 1
    beta <- (obs - RFD_m) / (asy - RFD_m) * (N - n)
    if (is.nan(beta)) beta = 0
    
    int.m = c(floor(m[m <= n]), ceiling(m[m <= n])) %>% unique %>% sort
    
    mRTD = sapply(int.m, function(m) if (m == 0) -1 else if (m == 1) 0 else Sub(m))
    
    ext.m = m[m > n] %>% unique
    if (length(ext.m) != 0) mETD = sapply(ext.m, function(m) Sub(m))
    
    sapply(m, function(m) {
      
      if (m <= n) {
        
        if (m == round(m)) mRTD[int.m == m] else 
          (ceiling(m) - m) * mRTD[int.m == floor(m)] + (m - floor(m)) * mRTD[int.m == ceiling(m)]
        
      } else mETD[ext.m == m]
      
    })
  }
  
  D1.hat <- function(x, m) {
    
    Sub <- function(m) {
      if (m <= n) {
        
        sapply(1:m, function(k) m * sum(dhyper(k, x, n - x, m)) * k / m * (digamma(m) - digamma(k)) ) %>% sum
        
      } else {
        
        ms = m - n
        # N0 = (N - n + 1) * f1 / (n * f0 + f1)
        # if (N0 == "NaN") N0 = 0
        
        # m * log(obs + (asy - obs) * (1 - (1 - ms / (N - n))^N0))
        m * log(obs + (asy - obs) * (1 - (1 - ms / (N - n))^beta))
      }
    }
    
    obs <- exp(IE(x, 1) / n)
    asy <- exp(Asy.IE(x, q = 1, rho) / N)
    if (asy < obs) asy = obs
    
    RFD_m = exp(Sub(n - 1) / (n - 1))
    beta <- (obs - RFD_m) / (asy - RFD_m) * (N - n)
    if (is.nan(beta)) beta = 0
    
    int.m = c(floor(m[m <= n]), ceiling(m[m <= n])) %>% unique %>% sort
    
    mRTD = sapply(int.m, function(m) if (m == 0) 0 else if (m == 1) 0 else Sub(m))
    
    ext.m = m[m > n] %>% unique
    if (length(ext.m) != 0) mETD = sapply(ext.m, function(m) Sub(m))
    
    sapply(m, function(m) {
      
      if (m <= n) {
        
        if (m == round(m)) mRTD[int.m == m] else 
          (ceiling(m) - m) * mRTD[int.m == floor(m)] + (m - floor(m)) * mRTD[int.m == ceiling(m)]
        
      } else mETD[ext.m == m]
      
    })
  }
  
  D2.hat <- function(x, m) {
    
    Sub <- function(m) {
      if (m <= n) {
        
        choose(m, 2) - sapply(2:m, function(k) sum(dhyper(k, x, n-x, m)) * choose(k, 2) ) %>% sum
        
      } else {
        
        choose(m, 2) * (1 - (1 - m/N) / m - (m + m/N - 1)/m * p2)
        
        # ms = m - n
        # N0 = (N - n + 1) * f1 / (n * f0 + f1)
        # if (N0 == "NaN") N0 = 0
        # 
        # exp(lgamma(m + 1) - lgamma(3) - lgamma(m - 1)) * (1 - (obs + (asy - obs) * (1 - (1 - ms / (N - n) )^N0)) ^ (-1))
        
      }
    }
    
    p2 = (1 - rho) * (sum(x * (x - 1)) + n * rho) / (n^2 - n + n * rho) +
      rho * sum(x * (x - 1) / n / (n - 1))
    
    # obs <- (1 - IE(x, 2)^2 / exp(lgamma(n + 1) - lgamma(3) - lgamma(n - 1)) ) ^ (-1)
    # asy <- (1 - Asy.IE(x, 2, rho)^2 / exp(lgamma(N + 1) - lgamma(3) - lgamma(N - 1)) ) ^ (-1)
    
    
    int.m = c(floor(m[m <= n]), ceiling(m[m <= n])) %>% unique %>% sort
    
    mRTD = sapply(int.m, function(m) if (m == 0) 0 else if (m == 1) 0 else Sub(m))
    
    ext.m = m[m > n] %>% unique
    if (length(ext.m) != 0) mETD = sapply(ext.m, function(m) Sub(m))
    
    sapply(m, function(m) {
      
      if (m <= n) {
        
        if (m == round(m)) mRTD[int.m == m] else 
          (ceiling(m) - m) * mRTD[int.m == floor(m)] + (m - floor(m)) * mRTD[int.m == ceiling(m)]
        
      } else mETD[ext.m == m]
      
    })
  }
  
  Dq.hat <- function(x, m, q) {
    
    Sub <- function(m) {
      if (m <= n) {
        
        # (exp(lgamma(m + 1) - lgamma(q + 1) - lgamma(m - q + 1)) - 
        #    sum( sapply(1:m, function(k) sum(dhyper(k, x, n-x, m)) * exp(lgamma(k + 1) - lgamma(q + 1) - lgamma(k - q + 1)) ) ) ) / (q - 1)
        
        ks = 1:m
        ks = ks[q < ks + 1]
        (exp(lgamma(m + 1) - lgamma(q + 1) - lgamma(m - q + 1)) - 
            sum( sapply(ks, function(k) sum(dhyper(k, x[q < (x + 1)], n-x[q < (x + 1)], m)) * exp(lgamma(k + 1) - lgamma(q + 1) - lgamma(k - q + 1)) ) ) ) / (q - 1)
        
      } else {
        
        ms = m - n
        # N0 = (N - n + 1) * f1 / (n * f0 + f1)
        # if (N0 == "NaN") N0 = 0
        
        # exp(lgamma(m + 1) - lgamma(q + 1) - lgamma(m - q + 1)) * (1 - (obs + (asy - obs) * (1 - (1 - ms / (N - n) )^N0)) ^ (1 - q)) / (q - 1)
        exp(lgamma(m + 1) - lgamma(q + 1) - lgamma(m - q + 1)) * (1 - (obs + (asy - obs) * (1 - (1 - ms / (N - n) )^beta)) ^ (1 - q)) / (q - 1)
        
      }
    }
    
    # obs <- (1 - (q - 1) * IE(x, q) / exp(lgamma(n + 1) - lgamma(q + 1) - lgamma(n - q + 1)) ) ^ (1 / (1 - q))
    # asy <- (1 - (q - 1) * Asy.IE(x, q, rho) / exp(lgamma(N + 1) - lgamma(q + 1) - lgamma(N - q + 1)) ) ^ (1 / (1 - q))
    
    obs <- (1 - (q - 1) * IE(x, q)^q / exp(lgamma(n + 1) - lgamma(q + 1) - lgamma(n - q + 1)) ) ^ (1 / (1 - q))
    asy <- (1 - (q - 1) * Asy.IE(x, q, rho)^q / exp(lgamma(N + 1) - lgamma(q + 1) - lgamma(N - q + 1)) ) ^ (1 / (1 - q))
    if (asy < obs) asy = obs
    
    RFD_m = (1 - (q - 1) * Sub(n - 1) / exp(lgamma(n) - lgamma(q + 1) - lgamma(n - q)) ) ^ (1 / (1 - q))
    beta <- (obs - RFD_m) / (asy - RFD_m) * (N - n)
    if (is.nan(beta)) beta = 0
    
    int.m = c(floor(m[m <= n]), ceiling(m[m <= n])) %>% unique %>% sort
    
    mRTD = sapply(int.m, function(m) if (m == 0) 0 else if (m == 1) 0 else Sub(m))
    
    ext.m = m[m > n] %>% unique
    if (length(ext.m) != 0) mETD = sapply(ext.m, function(m) Sub(m))
    
    sapply(m, function(m) {
      
      if (m <= n) {
        
        if (m == round(m)) mRTD[int.m == m] else 
          (ceiling(m) - m) * mRTD[int.m == floor(m)] + (m - floor(m)) * mRTD[int.m == ceiling(m)]
        
      } else mETD[ext.m == m]
      
    })
  }
  
  
  iNEXT.func <- function(x, q, m) {
    if (q == 0) 
      
      D0.hat(x, m)
    
    else if (q == 1) 
      
      D1.hat(x, m)
    
    else if (q == 2) 
      
      D2.hat(x, m)
    
    else Dq.hat(x, m, q)
  }
  
  # sapply(q, function(i) iNEXT.func(x, i, m)) %>% as.vector
  sapply(q, function(i) iNEXT.func(x, i, m)^(1 / i)) %>% as.vector
  }


iNEXT <- function(x, rho, q = 0, m = NULL, endpoint = 2*sum(x), knots = 40, nboot = 200, conf = 0.95) {
  
  qtile <- qnorm(1 - (1 - conf) / 2)
  n <- sum(x)
  
  Dq.hat <- D.m.est(x, rho, q, m)
  C.hat <- Coverage(x, rho, m)
  
  Dq.hat_unc <- Dq.hat
  refC <- Coverage(x, rho, n)
  
  if (nboot > 1) {
    
    Abun.Mat <- bootstrap(x, rho, nboot)
    
    ses_m <- apply(apply(Abun.Mat, 2, function(a) D.m.est(a, rho, q, m)), 1, sd, na.rm = TRUE)
    
    ses_C_on_m <- apply(apply(Abun.Mat, 2, function(a) Coverage(a, rho, m = m)), 1, sd, na.rm = TRUE)
    
    ses_C <- apply(apply(Abun.Mat, 2, function(a) D.m.est(a, rho, q = q, m = invC(a, rho, C.hat))), 1, sd, na.rm = TRUE)
    
  } else {
    
    ses_m <- rep(NA, length(Dq.hat))
    ses_C_on_m <- rep(NA, length(m))
    ses_C <- rep(NA, length(Dq.hat_unc))
  }
  
  out_m <- data.frame(Order.q = rep(q, each = length(m)),
                      m = rep(m, length(q)), 
                      qIE = Dq.hat, 
                      qIE.LCL = Dq.hat - qtile * ses_m,
                      qIE.UCL = Dq.hat + qtile * ses_m,
                      SC = rep(C.hat, length(q)), 
                      SC.LCL = C.hat - qtile * ses_C_on_m, 
                      SC.UCL = C.hat + qtile * ses_C_on_m) %>%
    mutate(Method = ifelse(m < n, "Rarefaction", ifelse(m == n, "Observed", "Extrapolation")), .before = "qIE")
  
  out_m$qIE.LCL[out_m$qIE.LCL < 0] = 0
  out_m$SC.LCL[out_m$SC.LCL < 0] = 0
  out_m$SC.UCL[out_m$SC.UCL > 1] = 1
  
  out_C <- data.frame(Order.q = rep(q, each = length(m)),
                      SC = rep(C.hat, length(q)), 
                      m = rep(m, length(q)), 
                      qIE = Dq.hat_unc, 
                      qIE.LCL = Dq.hat_unc - qtile * ses_C,
                      qIE.UCL = Dq.hat_unc + qtile * ses_C) %>%
    mutate(Method = ifelse(m < n, "Rarefaction", ifelse(m == n, "Observed", "Extrapolation")), .before = "qIE")
  
  out_C$qIE.LCL[out_C$qIE.LCL < 0] = 0
  
  return(list(size_based = out_m, coverage_based = out_C))
  }


invChat <- function(data, rho, q, C = NULL, nboot = 0, conf = NULL) {
  
  qtile <- qnorm(1 - (1 - conf) / 2)
  
  out <- lapply(1:length(data), function(i) {
    
    n = sum(data[[i]])
    size = invC(data[[i]], rho[i], C)
    est <- D.m.est(x = data[[i]], rho[i], q = q, m = size)
    
    if (nboot > 1) {
      
      Abun.Mat <- bootstrap(data[[i]], rho[i], nboot)
      
      ses <- apply(matrix(apply(Abun.Mat, 2, function(a) {
        
        size = invC(a, rho[i], C)
        est <- D.m.est(x = a, rho[i], q = q, m = size)
        
      }), nrow = length(q) * length(C)), 1, sd)
      
    } else {
      
      ses <- rep(0, length(est))
    }
    
    data.frame(Order.q = rep(q, each = length(C)),
               SC = rep(C, length(q)),
               m = rep(size, length(q)),
               Method = rep(ifelse(size > n, 'Extrapolation', ifelse(size < n, 'Rarefaction', 'Observed')), length(q)),
               qIE = est, 
               s.e. = ses,
               qIE.LCL = est - qtile * ses,
               qIE.UCL = est + qtile * ses)
    
  })
  
  out <- do.call(rbind, out)
  out = out %>% mutate(Assemblage = rep(names(data), each = length(q) * length(C)), .before = "Order.q")
  rownames(out) <- NULL
  
  out$qIE.LCL[out$qIE.LCL < 0] <- 0
  
  return(out)
  }


invC <- function(x, rho, C) {
  
  x <- x[x > 0]
  n <- sum(x)
  N = ceiling(n / rho)
  refC <- Coverage(x, rho, n)
  f1 = sum(x == 1)
  f2 = sum(x == 2)
  
  f <- function(m, C) abs(Coverage(x, rho, m) - C)
  
  mm <- sapply(C, function(cvrg) {
    
    if (refC == cvrg) {
      
      n
      
    } else if (refC > cvrg) {
      
      opt <- optimize(f, C = cvrg, lower = 0, upper = sum(x))
      
      opt$minimum
      
    } else if (refC < cvrg) {
      
      N1 = (2 * (N - n + 2) * f2 + (n - 1) * f1) / ((n - 1) * f1 + 2 * f2)
      if (N1 == "NaN" | N1 == Inf) N1 = 0
      
      if (N1 == 0 | f1 == 0) {
        
        ms = 0
        
        } else ms <- log((1 - cvrg) / (1 - rho) * n / f1) / log(1 - N1 / N) - 1
      
      n + ms
    }
  })
  
  mm[mm > N] = N
  
  return(mm)
  }


invSize <- function(data, rho, q, size = NULL, nboot = 0, conf = NULL) {
  
  qtile <- qnorm(1 - (1 - conf) / 2)
  
  out <- lapply(1:length(data), function(i){
    
    n = sum(data[[i]])
    est <- D.m.est(x = data[[i]], rho[i], q = q, m = size)
    
    if (nboot > 1) {
      
      Abun.Mat <- bootstrap(data[[i]], rho[i], nboot)
      
      ses <- apply(matrix(apply(Abun.Mat, 2, function(a) D.m.est(x = a, rho[i], q = q, m = size)),
                          nrow = length(q) * length(size)), 1, sd)
    } else {
      
      ses <- rep(NA, length(est))
    }
    
    data.frame(Order.q = rep(q, each = length(size)),
               m = rep(size,length(q)),
               Method = rep(ifelse(size > n, 'Extrapolation', ifelse(size < n, 'Rarefaction', 'Observed')), length(q)),
               SC = rep(Coverage(data[[i]], rho[i], size), length(q)),
               qIE = est, 
               s.e. = ses, 
               qIE.LCL = est - qtile * ses, 
               qIE.UCL = est + qtile * ses)
  })
  
  out <- do.call(rbind, out)
  out = out %>% mutate(Assemblage = rep(names(data), each = length(q) * length(size)), .before = "Order.q")
  rownames(out) <- NULL
  
  return(out)
  }



#' Maximum likelihood estimation and asymptotic diversity of order q
#' 
#' \code{MLEAsyIE} computes maximum likelihood estimation and asymptotic diversity of order q between 0.4 and 2 (in increments of 0.2); these diversity values with different order q can be used to depict a q-profile in the \code{ggMLEAsyIE} function.\cr\cr 
#' 
#' @param data data can be input as a vector of species abundances (for a single assemblage), matrix/data.frame (species by assemblages), or a list of species abundance vectors.
#' @param rho the sampling fraction can be input as a vector for each assemblage, or enter a single numeric value to apply to all assemblages.
#' @param q a numerical vector specifying the diversity orders. Default is \code{seq(0.4, 2, by = 0.2)}.
#' @param nboot a positive integer specifying the number of bootstrap replications when assessing sampling uncertainty and constructing confidence intervals. Enter 0 to skip the bootstrap procedures. Default is 50.
#' @param conf a positive number < 1 specifying the level of confidence interval. Default is 0.95.
#' @param method Select \code{'Asymptotic'} or \code{'MLE'}.
#' 
#' @return a data frame including the following information/statistics: 
#' \item{Assemblage}{the name of assemblage.}
#' \item{Order.q}{the diversity order of q.}
#' \item{qIE}{the estimated asymptotic diversity or maximum likelihood estimation estimates of order q.} 
#' \item{s.e.}{standard error of diversity.}
#' \item{qIE.LCL and qIE.UCL}{the bootstrap lower and upper confidence limits for the diversity of order q at the specified level (with a default value of 0.95).}
#' \item{Method}{\code{"Asymptotic"} means asymptotic diversity and \code{"MLE"} means maximum likelihood estimation.}
#' 
#' 
#' @examples
#' # Compute the maximum likelihood estimation and asymptotic diversity for abundance data
#' # with order q between 0.4 and 2 (in increments of 0.2 by default)
#' data("spider")
#' output_MLEAsy <- MLEAsyIE(spider, rho = 0.3)
#' output_MLEAsy
#' 
#' 
#' @export
MLEAsyIE <- function(data, rho = NULL, q = seq(0.4, 2, 0.2), nboot = 50, conf = 0.95, method = c('Asymptotic', 'MLE')) {
  
  data = check.data(data)
  rho = check.rho(data, rho)
  
  q = check.q(q)
  conf = check.conf(conf)
  nboot = check.nboot(nboot)
  
  
  if (sum(method == "Asymptotic") == length(method)) 
    
    out = est(data, rho, q, nboot, conf) else if (sum(method == "MLE") == length(method)) 
      
      out = emp(data, rho, q, nboot, conf) else if (sum(method == c("Asymptotic", "MLE")) == length(method)) 
        
        out = rbind(est(data, rho, q, nboot, conf), 
                    emp(data, rho, q, nboot, conf))
  
  return(out)
}


#' ggplot2 extension for plotting q-profile
#'
#' \code{ggMLEAsyIE} is a \code{ggplot2} extension for an \code{MLEAsyIE} object to plot q-profile (which depicts the maximum likelihood estimation and asymptotic diversity estimate with respect to order q) for q between 0.4 and 2 (in increments of 0.2).\cr\cr 
#' In the plot, only confidence intervals of the asymptotic diversity will be shown when both the maximum likelihood estimation and asymptotic diversity estimate are computed.
#' 
#' @param output the output of the function \code{MLEAsyIE}.\cr
#' @param log2 whether to apply a log2 transformation to diversity or not.\cr
#' @return a q-profile based on the maximum likelihood estimation and the asymptotic diversity estimate.\cr\cr
#'
#' @examples
#' # Plot diversity for data with order q between 0.4 and 2 (in increments of 0.2 by default).
#' data("spider")
#' output_MLEAsy <- MLEAsyIE(spider, rho = 0.3)
#' ggMLEAsyIE(output_MLEAsy)
#' 
#' 
#' @export
ggMLEAsyIE <- function(output, log2 = FALSE) {
  
  if (sum(unique(output$Method) %in% c("Asymptotic", "MLE")) == 0) stop("Please use the output from specified function 'MLEAsyIE'")
  
  if (log2) output = output %>% mutate(qIE = log2(qIE), qIE.LCL = log2(qIE.LCL), qIE.UCL = log2(qIE.UCL))
  
  out = ggplot(output, aes(x = Order.q, y = qIE, colour = Assemblage, fill = Assemblage))
  
  if (length(unique(output$Method)) == 1) {
    
    out = out + geom_line(size = 1.5) + 
      geom_ribbon(aes(ymin = qIE.LCL, ymax = qIE.UCL, fill = Assemblage), linetype = 0, alpha = 0.2)
    
    if (unique(output$Method == 'Asymptotic')) out = out + labs(x = 'Order q', y = 'Asymptotic inter-specific encounter')
    if (unique(output$Method == 'MLE')) out = out + labs(x = 'Order q', y = 'Maximum likelihood estimation of inter-specific encounter')
    
  } else {
    
    out = out + geom_line(aes(lty = Method), size = 1.5) + 
      geom_ribbon(data = output %>% filter(Method == "Asymptotic"), aes(ymin = qIE.LCL, ymax = qIE.UCL), linetype = 0, alpha = 0.2)
    
    out = out + labs(x = 'Order q', y = 'Inter-specific encounter')
  }
  
  if (length(unique(output$Assemblage)) <= 8){
    
    cbPalette <- rev(c("#999999", "#E69F00", "#56B4E9", "#009E73", 
                       "#330066", "#CC79A7", "#0072B2", "#D55E00"))
    
  } else {
    
    cbPalette <- rev(c("#999999", "#E69F00", "#56B4E9", "#009E73", 
                       "#330066", "#CC79A7", "#0072B2", "#D55E00"))
    cbPalette <- c(cbPalette, ggplotColors(length(unique(output$Assemblage)) - 8))
  }
  
  out = out +
    scale_colour_manual(values = cbPalette) + theme_bw() + 
    scale_fill_manual(values = cbPalette) +
    theme(legend.position = "bottom", 
          legend.box = "vertical",
          legend.key.width = unit(1.2, "cm"),
          legend.title = element_blank(),
          legend.margin = margin(0, 0, 0, 0),
          legend.box.margin = margin(-10, -10, -5, -10),
          text = element_text(size = 16),
          plot.margin = unit(c(5.5, 5.5, 5.5, 5.5), "pt")) +
    guides(linetype = guide_legend(keywidth = 2.5))
  
  if (log2) out = out + labs(y = expression(paste(log[2], '(Inter-specific encounter)')))
  
  return(out)
}


Asy.IE <- function(x, q, rho) {
  
  x = x[x > 0]
  n = sum(x)
  f1 = sum(x == 1); f2 = sum(x == 2)
  N = ceiling(n / rho)
  # p1 = ifelse(f2 > 0, ((1 - rho) * 2 * f2 + rho * f1) / ((n-1) * f1 + 2 * f2), 0)
  p1 = ifelse(f2 > 0, ((1 - rho) * 2 * f2 + rho * f1) / ((n-1) * f1 + 2 * f2), ifelse(f1 > 0, ((1 - rho) * 2 + rho * (f1 - 1)) / ((n-1) * (f1 - 1) + 2), 0))
  
  qD <- function(q) {
    
    if (q == 0) {
      
      lbd = ifelse(f2 > 0, f1^2 / (n/(n - 1) * 2 * f2 + rho/(1 - rho) * f1), f1 * (f1 - 1) / (n/(n - 1) * 2 + rho/(1 - rho) * f1))
      # sum(x > 0) + ifelse(is.nan(lbd), 0, lbd) - 1
      ( sum(x > 0) + ifelse(is.nan(lbd), 0, lbd) - 1 )^(1 / 0)
      
    } else if (q == 1) {
      
      A = (1 - rho) * sum(tab * sortx / n * (digamma(n) - digamma(sortx)))
      
      B <- D1_2nd(n, f1, f2, rho)
      
      if (B == "NaN" | B == Inf) B = 0
      
      MLEpart = sum(x / n * (digamma(n) - digamma(x)))
      
      N * (A + B + rho * MLEpart)
      
    } else if (q == 2) {
      
      # N * (N - 1) / 2 * (1 - (1 - rho) * (sum(x * (x - 1)) + n * rho) / (n^2 - n + n * rho) - 
      #                      rho * sum(x * (x - 1) / n / (n - 1)))
      
      ( N * (N - 1) / 2 * (1 - (1 - rho) * (sum(x * (x - 1)) + n * rho) / (n^2 - n + n * rho) -
                             rho * sum(x * (x - 1) / n / (n - 1))) )^(1 / 2)
      
      # ( N * (N - 1) / 2 * (1 - sum(x * (x - 1)) / (n * (n - 1))) )^(1 / 2)
      
    } else {
      
      AB = ans[which(q_part2 == q)]
      
      MLEpart = sum( exp(lgamma(x[q < (x + 1)] + 1) - lgamma(x[q < (x + 1)] - q + 1) - lgamma(n + 1) + lgamma(n - q + 1)) )
      
      # exp(lgamma(N + 1) - lgamma(q + 1) - lgamma(N - q + 1)) * (1 - (AB + rho * MLEpart)) / (q - 1)
      ( exp(lgamma(N + 1) - lgamma(q + 1) - lgamma(N - q + 1)) * (1 - (AB + rho * MLEpart)) / (q - 1) )^(1 / q)
      
    }
  }
  
  sortx = sort(unique(x))
  tab = table(x)
  
  q_part2 <- q[!q %in% c(0, 1, 2)]
  if (length(q_part2) > 0) ans <- Dq(ifi = cbind(i = sortx, fi = tab), n = n, qs = q_part2, f1 = f1, A = p1, rho = rho)
  
  sapply(q, qD)
}


IE <- function (x, q) {
  
  N = sum(x)
  x = x[x > 0]
  
  tmp = function(q) {
    
    x = x[q < (x + 1)]
    
    if (q != 1) {
      
      # (exp(lgamma(N + 1) - lgamma(q + 1) - lgamma(N - q + 1))  - sum( exp(lgamma(x + 1) - lgamma(q + 1) - lgamma(x - q + 1)) ) ) / (q - 1) 
      ( (exp(lgamma(N + 1) - lgamma(q + 1) - lgamma(N - q + 1))  - sum( exp(lgamma(x + 1) - lgamma(q + 1) - lgamma(x - q + 1)) ) ) / (q - 1) )^(1 / q)
      
    } else {
      
      N * (sum(x / N * (digamma(N) - digamma(x))))
    }
  }
  
  sapply(q, tmp)
  }


est = function(data, rho, q, nboot, conf) {
  
  out <- lapply(1:length(data),function(i){
    
    dq <- Asy.IE(data[[i]], q, rho[i])
    
    if (nboot > 1) {
      
      Abun.Mat <- bootstrap(data[[i]], rho[i], nboot)
      
      mt = apply(Abun.Mat, 2, function(xb) Asy.IE(xb, q, rho[i]))
      
      if (!is.matrix(mt)) mt = matrix(mt, nrow = 1)
      
      error <- qnorm(1 - (1 - conf) / 2) * apply(mt, 1, sd, na.rm = TRUE)
      
    } else error = NA
    
    out <- data.frame(Assemblage = names(data)[i], 
                      Order.q = q, 
                      qIE = dq, 
                      s.e. = error / qnorm(1 - (1 - conf)/2),
                      qIE.LCL = dq - error, 
                      qIE.UCL = dq + error, 
                      Method = "Asymptotic")
    
    out$qIE.LCL[out$qIE.LCL < 0] <- 0
    return(out)
    
  })
  
  do.call(rbind, out)
  }


emp = function(data, rho, q, nboot, conf) {
  
  out <- lapply(1:length(data),function(i){
    
    dq <- IE(data[[i]] / rho[i], q)
    
    if (nboot > 1) {
      
      Abun.Mat <- bootstrap(data[[i]], rho[i], nboot)
      
      mt = apply(Abun.Mat, 2, function(xb) IE(xb / rho[i], q))
      if (!is.matrix(mt)) mt = matrix(mt, nrow = 1)
      
      error <- qnorm(1 - (1 - conf) / 2) * apply(mt, 1, sd, na.rm=TRUE)
      
    } else error = NA
    
    out <- data.frame(Assemblage = names(data)[i], 
                      Order.q = q, 
                      qIE = dq, 
                      s.e. = error / qnorm(1 - (1 - conf) / 2),
                      qIE.LCL = dq - error, 
                      qIE.UCL = dq + error, 
                      Method = "MLE")
    
    out$qIE.LCL[out$qIE.LCL<0] <- 0
    return(out)
    
  })
  
  do.call(rbind, out)
  }


bootstrap <- function(x, rho, nboot) {
  
  x <- x[x != 0]
  n <- sum(x)
  N = ceiling(n / rho)
  f1 = sum(x == 1); f2 = sum(x == 2)
  
  f0 = ceiling( ifelse(f2 > 0, f1^2 / (n/(n - 1) * 2 * f2 + rho/(1 - rho) * f1), f1 * (f1 - 1) / (n/(n - 1) * 2 + rho/(1 - rho) * f1)) )
  if (f0 == "NaN") f0 = 0
  
  C_hat = 1 - f1 / n * (1 - rho)
  lamda_hat = (1 - C_hat) / sum((x / n) * (1 - rho)^(x / rho)) 
  
  if (lamda_hat == "NaN") lamda_hat = 0
  
  Ni_det = (x / rho)*(1 - lamda_hat * (1 - rho)^(x / rho)) 
  Ni_undet = N * (1 - C_hat) / f0
  
  if (Ni_undet == "NaN") Ni_undet = 0 else if (Ni_undet < 1 & Ni_undet > 0) Ni_undet = 1
  
  N_hat = round( c(Ni_det, rep(Ni_undet, f0)), 0)
  
  ex.sample = unlist(lapply(1:length(N_hat), function(i) rep(i, N_hat[i])))
  sample_result <- sapply(1:nboot, function(i) sample(ex.sample, n, replace = FALSE))
  random = lapply(1:nboot, function(j) as.numeric(table(sample_result[,j])))
  
  random <- do.call(cbind.data.frame,
                    lapply(lapply(random, unlist), `length<-`, max(lengths(random))))
  
  random[is.na(random)] <- 0
  colnames(random) = NULL
  
  return(random)
}


#' Printing iNEXTIE object
#' 
#' \code{print.iNEXTIE}: Print method for objects inheriting from class "iNEXTIE"
#' @param x an \code{iNEXTIE} object computed by \code{iNEXTIE}.
#' @param ... additional arguments.
#' @return a list of three objects (see \code{iNEXTIE} for more details) with simplified outputs and notes.
#' @export
print.iNEXTIE <- function(x, ...){
  
  site.n <- nrow(x[[1]])
  order.n <- paste(unique(x[[2]]$size_based$Order.q), collapse = ", ")
  
  cat("Compare ", site.n, " assemblages with Hill number order q = ", order.n,".\n", sep = "")
  cat("$class: iNEXTIE\n\n")
  
  cat(names(x)[1], ": basic data information\n", sep = "")
  print(x[[1]])
  cat("\n")
  
  cat(names(x)[2],": diversity estimates with rarefied and extrapolated samples.\n", sep = "")
  cat("$size_based (LCL and UCL are obtained for fixed size.)\n")
  cat("\n")
  
  res <- lapply(x[[2]], function(y){
    
    Assemblages <- unique(x[[2]]$size_based$Assemblage)
    
    tmp <- lapply(1:length(Assemblages), function(i){
      
      y_each <- y[y$Assemblage == Assemblages[i],]
      
      m <- quantile(unlist(y_each[,3]), type = 1)
      
      y_each[unlist(y_each[,3]) %in% m,]
    })
    
    do.call(rbind, tmp)
  })
  
  print(data.frame(res[[1]]))
  cat("\n")
  
  cat("NOTE: The above output only shows five estimates for each assemblage in each order q; call iNEXTIE.object$", names(x)[2],
      "$size_based to view complete output.\n", sep = "")
  cat("\n")
  
  cat("$coverage_based (LCL and UCL are obtained for fixed coverage; interval length is wider due to varying size in bootstraps.)\n")
  cat("\n")
  print(data.frame(res[[2]]))
  
  cat("\n")
  cat("NOTE: The above output only shows five estimates for each assemblage in each order q; call iNEXTIE.object$", names(x[2]), 
      "$coverage_based to view complete output.\n", sep = "")
  
  cat("\n")
  cat(names(x)[3], ": asymptotic diversity estimates along with related statistics.\n", sep = "")
  print(x[[3]])
  
  return(invisible())
}


## ========== no visible global function definition for R CMD check ========== ##
utils::globalVariables(c(".", "Order.q", "qIE", "Assemblage", "qIE.LCL", "qIE.UCL",
                         "Method", "Order.q"))




