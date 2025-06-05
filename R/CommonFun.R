Coverage = function(x, rho, m) {
  
  n = sum(x)
  N = ceiling(n / rho)
  x = x[x > 0]
  f1 = sum(x == 1)
  f2 = sum(x == 2)
  
  sapply(m, function(k) {
    
    if (k < n) {
      
      Chat = 1 - (N - k)/N * sum(x/n * exp(lgamma(n - x + 1) - lgamma(n - x - k + 1) - lgamma(n) + lgamma(n - k)))
      
    } else {
      
      ms = k - n
      N1 = 1 + (N - n) * 2 * f2 / (n - 1) / f1
      if (N1 == "NaN") N1 = 0
      
      Chat = 1 - (1 - rho) * f1/n * (1 - ms / (N - n))^N1
      
      if (rho == 1) Chat = 1
      
      if (ms > N - n) Chat = 1
      
    }
    
    Chat
    })
  }

check.data <- function(data) {
  
  if (inherits(data, "list")) {
    
    if (is.null(names(data))) names(data) = paste0("Assemblage_", 1:length(data))
    
  } else if (inherits(data, c("numeric", "integer", "double"))) {
    
    data = list("Assemblage_1" = data)
  }
  
  if (sum(sapply(data, sum) == 0) > 0) stop("Data values are all zero in some assemblages. Please remove these assemblages.", call. = FALSE)
  
  return(data)
}

check.q <- function(q) {
  
  if(!inherits(q, "numeric"))
    stop("invalid class of order q, q should be a postive value/vector of numeric object", call. = FALSE)
  
  if(min(q) < 0) {
    warning("ambigous of order q, we only compute postive q", call. = FALSE)
    q <- q[q >= 0]
  }
  
  return(q)
}

check.conf <- function(conf) {
  
  if ((conf < 0) | (conf > 1) | (is.numeric(conf) == F)) stop('Please enter value between zero and one for the confidence interval.', call. = FALSE)
  
  return(conf)
}

check.nboot <- function(nboot) {
  
  if ((nboot < 0) | (is.numeric(nboot) == F)) stop('Please enter non-negative integer for nboot.', call. = FALSE)
  
  return(nboot)
}

check.base <- function(base) {
  
  BASE <- c("size", "coverage")
  
  if (is.na(pmatch(base, BASE))) stop("invalid base type")
  if (pmatch(base, BASE) == -1) stop("ambiguous base type")
  
  base <- match.arg(base, BASE)
  
  return(base)
}

check.size <- function(data, rho, size, endpoint, knots) {
  
  if (length(knots) != length(data)) knots <- rep(knots, length(data))
  
  if (is.null(size)) {
    
    if (is.null(endpoint)) {
      
      endpoint <- sapply(1:length(data), function(i) min(sum(data[[i]]) / rho[i], 2*sum(data[[i]])))
      
    } else {
      
      if (length(endpoint) != length(data)) {
        
        endpoint <- rep(endpoint, length(data))
      }
      
    }
    
    size <- lapply(1:length(data), function(i){
      
      n <- sum(data[[i]])
      
      if (endpoint[i] <= n) {
        
        mi <- floor(seq(1, endpoint[i], length.out = knots[i]))
        
      } else {
        
        mi <- floor(c(seq(1, n, length.out = floor(knots[i] / 2)), seq(n + 1, endpoint[i], length.out = knots[i] - floor(knots[i] / 2))))
      }
      
      unique(mi)
    })
    
  } else {
    
    if (inherits(size, c("numeric", "integer", "double"))) size <- list(size = size)
    
    if (length(size) != length(data)) size <- lapply(1:length(data), function(x) size[[1]])
    
    size <- lapply(1:length(data),function(i){
      
      n <- sum(data[[i]])
      
      if ( (sum(size[[i]] == n) == 0) & (sum(size[[i]] > n) != 0) & (sum(size[[i]] < n) != 0) ) 
        mi <- sort(c(n, size[[i]])) else mi <- sort(size[[i]])
      
      if (sum(mi < 0) > 0) stop("Sample size cannot be a negative value.", call. = FALSE)
      
      unique(mi)
    })
  }
  
  return(size)
}

check.level <- function(data, rho, base, level) {
  
  if (is.null(level) & base == 'size') {
    
    level <- sapply(1:length(data), function(i) min(2 * sum(data[[i]]), sum(data[[i]]) / rho[i]))
    
    level <- min(level)
    
  } else if (is.null(level) & base == 'coverage') {
    
    level <- sapply(1:length(data), function(i) Coverage(data[[i]], rho = rho[i], m = 2 * sum(data[[i]])))
    
    level <- min(level)
  }
  
  if (base == "size" & sum(level < 0) > 0) stop("Sample size cannot be a negative value.", call. = FALSE)
  
  if (base == "coverage" & sum(level < 0 | level > 1) > 0) stop("The sample coverage values should be between zero and one.", call. = FALSE)  
  
  return(level)
}

