<!-- README.md is generated from README.Rmd. Please edit that file -->

# iNEXT.IE (R package)

<h5 align="right">
Latest version: 2025-09-25
</h5>
<font color="394CAE">
<h3 color="394CAE" style="font-weight: bold">
Introduction to iNEXT.IE (R package): Excerpt from iNEXT.IE User’s Guide
</h3>
</font> <br>
<h5>
<b>Kai-Hsiang Hu and Anne Chao</b> <br><br> <i>Institute of Statistics,
National Tsing Hua University, Hsin-Chu, Taiwan 30043</i>
</h5>

<br> `iNEXT.IE` (INterpolation and EXTrapolation for Inter-specific
Encounter) is a framework for biodiversity methodology. An online
version “iNEXT.IE Online”
(<https://kaihsiang-hu.shinyapps.io/iNEXT_IE/>) is also available for
users without an R background.

`iNEXT.IE` features two statistical analyses (non-asymptotic and
asymptotic):

1.A non-asymptotic approach based on interpolation and extrapolation for
diversity

`iNEXT.IE` computes the estimated diversity for standardized samples
with a common sample size or sample completeness. This approach aims to
compare diversity estimates for equally-large (with a common sample
size) or equally-complete (with a common sample coverage) samples; it is
based on the seamless rarefaction and extrapolation (R/E) sampling
curves of diversity for q = 0, 1 and 2. `iNEXT.IE` offers three types of
R/E sampling curves:

-   Sample-size-based (or size-based) R/E sampling curves: This type of
    sampling curve plots the diversity estimates with respect to sample
    size.

-   Coverage-based R/E sampling curves: This type of sampling curve
    plots the diversity estimates with respect to sample coverage.

-   Sample completeness curve: This curve depicts how sample coverage
    varies with sample size. The sample completeness curve provides a
    bridge between the size- and coverage-based R/E sampling curves.

2.An asymptotic approach to infer asymptotic diversity

`iNEXT.IE` computes the estimated asymptotic diversity and also plots
diversity profiles (q-profiles) for q between 0 and 2, in comparison
with the maximum likelihood estimation. Typically, the asymptotic
estimates for q ≥ 1 are reliable, but for q \< 1 (especially for q = 0,
species richness), the asymptotic estimates represent only lower bounds.

## How to cite

If you publish your work based on results from `iNEXT.IE` package, you
should make references to the following methodology paper and the
package:

-   Hu, K.-H. and Chao, A. (2025). The iNEXT.IE package: INterpolation
    and EXTrapolation for Inter-specific Encounter. R package available
    from CRAN.

## SOFTWARE NEEDED TO RUN iNEXT.IE IN R

-   Required: [R](https://cran.r-project.org/)
-   Suggested: [RStudio
    IDE](https://www.rstudio.com/products/RStudio/#Desktop)

## HOW TO RUN iNEXT.IE:

The `iNEXT.IE` package can be downloaded from CRAN or Kai-Hsiang Hu’s
[iNEXT.IE_github](https://github.com/KaiHsiangHu/iNEXT.IE) using the
commands below. For a first-time installation, some additional packages
must be installed and loaded; see package manual.

``` r
## install iNEXT.IE package from CRAN
install.packages("iNEXT.IE")  

## or install the latest version from github
install.packages('devtools')
library(devtools)
install_github('KaiHsiangHu/iNEXT.IE')

## import packages
library(iNEXT.IE)
```

There are six main functions in this package:

Two functions for non-asymptotic analysis with graphical displays:

-   **iNEXTIE** computes standardized diversity estimates of order q =
    0, 1 and 2 for rarefied and extrapolated samples at specified sample
    coverage values and sample sizes.

-   **ggiNEXTIE** visualizes the output from the function `iNEXTIE`.

Two functions for point estimation and basic data information

-   **estimateIE** computes diversity of order q = 0, 1 and 2 with a
    particular set of user-specified level of sample sizes or sample
    coverage values.

-   **DataInfoIE** provides basic data information based on the observed
    data.

Two functions for asymptotic analysis with graphical displays:

-   **MLEAsyIE** computes maximum likelihood estimation and asymptotic
    diversity estimates of order q between 0 and 2 (in increments of
    0.2) for diversity.

-   **ggMLEAsyIE** visualizes the output from the function `MLEAsyIE`.

## <span style="color:red;">DATA INPUT FORMAT</span>

### Species abundance data format

For `iNEXT.IE` package, information on species identity (or any unique
identification code) and assemblage affiliation is not required.

Individual-based abundance data: Data can be input as a vector of
species abundances (for a single assemblage), a species (in rows) by
assemblage (in columns) matrix/data.frame, or a list of species
abundance vectors.

For example, we use “spider” data for illustration.

``` r
spider
$Girdled
 [1] 46 22 17 15 15  9  8  6  6  4  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1

$Logged
 [1] 88 22 16 15 13 10  8  8  7  7  7  5  4  4  4  3  3  3  3  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1  1  1
```

## <span style="color:red;">MAIN FUNCTION iNEXTIE(): RAREFACTION/EXTRAPOLATION</span>

We first describe the main function `iNEXTIE()` with default arguments:

``` r
iNEXTIE(data, rho, q = c(0, 1, 2), size = NULL, endpoint = NULL, knots = 40, nboot = 50, conf = 0.95)
```

The arguments of this function are briefly described below, and will be
explained in more details by illustrative examples in later text. This
main function computes standardized diversity estimates of order q = 0,
1 and 2, the sample coverage estimates, and related statistics for K (if
`knots = K` in the specified argument) evenly-spaced knots (sample
sizes) between size 1 and the `endpoint`, where the endpoint is
described below. Each knot represents a particular sample size for which
diversity estimates will be calculated. By default, `endpoint` = double
the reference sample size or total individuals. For example, if
`endpoint = 10`, `knot = 4` is specified, diversity estimates will be
computed for a sequence of samples with sizes (1, 4, 7, 10).

<table class="gmisc_table" style="border-collapse: collapse; margin-top: 1em; margin-bottom: 1em;">
<thead>
<tr>
<th style="font-weight: 900; border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;">
Argument
</th>
<th style="font-weight: 900; border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;">
Description
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: left;">
data
</td>
<td style="text-align: left;">
data can be input as a vector of species abundances (for a single
assemblage), matrix/data.frame (species by assemblages), or a list of
species abundance vectors.
</td>
</tr>
<tr>
<td style="text-align: left;">
rho
</td>
<td style="text-align: left;">
the sampling fraction can be input as a vector for each assemblage or a
numeric common value for all assemblages.
</td>
</tr>
<tr>
<td style="text-align: left;">
q
</td>
<td style="text-align: left;">
a numerical vector specifying the diversity orders. Default is
<code>c(0, 1, 2)</code>.
</td>
</tr>
<tr>
<td style="text-align: left;">
datatype
</td>
<td style="text-align: left;">
data type of input data: individual-based abundance data (<code>datatype
= ‘abundance’</code>), or species by sampling-units incidence/occurrence
matrix (<code>datatype = ‘incidence_raw’</code>) with all entries being
0 (non-detection) or 1 (detection).
</td>
</tr>
<tr>
<td style="text-align: left;">
size
</td>
<td style="text-align: left;">
an integer vector of sample sizes (number of individuals) for which
diversity estimates will be computed. If <code>NULL</code>, then
diversity estimates will be computed for those sample sizes determined
by the specified/default <code>endpoint</code> and <code>knots</code>.
</td>
</tr>
<tr>
<td style="text-align: left;">
endpoint
</td>
<td style="text-align: left;">
an integer specifying the sample size that is the <code>endpoint</code>
for rarefaction/extrapolation. If NULL, then <code>endpoint</code>
<code>=</code> double the reference sample size or total individuals.
</td>
</tr>
<tr>
<td style="text-align: left;">
knots
</td>
<td style="text-align: left;">
an integer specifying the number of equally-spaced <code>knots</code>
(say K, default is 40) between size 1 and the <code>endpoint</code>;
each knot represents a particular sample size for which diversity
estimate will be calculated. If the <code>endpoint</code> is smaller
than the reference sample size, then <code>iNEXTIE()</code> computes
only the rarefaction estimates for approximately K evenly spaced
<code>knots</code>. If the <code>endpoint</code> is larger than the
reference sample size, then <code>iNEXTIE()</code> computes rarefaction
estimates for approximately K/2 evenly spaced <code>knots</code> between
sample size 1 and the reference sample size, and computes extrapolation
estimates for approximately K/2 evenly spaced <code>knots</code> between
the reference sample size and the <code>endpoint</code>.
</td>
</tr>
<tr>
<td style="text-align: left;">
nboot
</td>
<td style="text-align: left;">
a positive integer specifying the number of bootstrap replications when
assessing sampling uncertainty and constructing confidence intervals.
Enter 0 to skip the bootstrap procedures. Default is 50.
</td>
</tr>
<tr>
<td style="border-bottom: 2px solid grey; text-align: left;">
conf
</td>
<td style="border-bottom: 2px solid grey; text-align: left;">
a positive number \< 1 specifying the level of confidence interval.
Default is 0.95.
</td>
</tr>
</tbody>
</table>

The main function `iNEXTIE()` returns the `iNEXTIE` object, which can be
further used to make plots using the function `ggiNEXTIE()` to be
described below. The `"iNEXTIE"` object includes three lists:

1.  `$DataInfo` for summarizing data information.

2.  `$iNextEst` for showing diversity estimates along with related
    statistics for a series of rarefied and extrapolated samples; there
    are two data frames (`$size_based` and `$coverage_based`)
    conditioning on standardized sample size or sample coverage,
    respectively.

3.  `$AsyEst` for showing maximum likelihood estimation and asymptotic
    diversity estimates along with related statistics.

## <span style="color:red;">FUNCTION ggiNEXTIE(): GRAPHIC DISPLAYS</span>

The function `ggiNEXTIE()`, which extends `ggplot2` with default
arguments, is described as follows:

``` r
ggiNEXTIE(output, type = 1:3)  
```

Here `output` is the `iNEXTIE()` object. Three types of curves are
allowed for diversity:

1.  Sample-size-based R/E curve (`type = 1`): This curve plots diversity
    estimates with confidence intervals as a function of sample size.

2.  Sample completeness curve (`type = 2`): This curve plots the sample
    coverage with respect to sample size.

3.  Coverage-based R/E curve (`type = 3`): This curve plots the
    diversity estimates with confidence intervals as a function of
    sample coverage.

The `ggiNEXTIE()` function is a wrapper with the package `ggplot2` to
create a rarefaction/extrapolation sampling curve in a single line of
code. The figure object is of class `"ggplot"`, so it can be manipulated
by using the `ggplot2` tools.

## <span style="color:blue;">RAREFACTION/EXTRAPOLATION VIA EXAMPLES</span>

### EXAMPLE: rarefaction/extrapolation for abundance data

Based on the dataset, the following commands return all numerical
results. The first list of the output (`$DataInfo`) returns basic data
information including the name of the Assemblage, sample size (`n`),
total abundance (`N`), sampling fraction (`rho`), observed species
richness (`S.obs`), sample coverage estimate of the reference sample
with size n (`SC(n)`), sample coverage estimate of the extrapolated
sample with size 2n (`SC(2n)`) as well as the first five species
abundance frequency counts in the reference sample (`f1-f5`). If only
data information is required, the simpler function `DataInfoIE()` (see
later text) can be used to obtain the same output. More information
about the maximum likelihood estimation (for any order q between 0 and
2) can be obtained by function `MLEAsyIE()`, which will be introduced
later.

``` r
output_iNEXT <- iNEXTIE(spider, rho = 0.3, q = c(0, 1, 2))
output_iNEXT$DataInfo
```

    $DataInfo
      Assemblage   n   N rho S.obs SC(n) SC(2n) f1 f2 f3 f4 f5
    1    Girdled 168 560 0.3    26 0.950  0.988 12  4  0  1  0
    2     Logged 252 840 0.3    37 0.961  0.989 14  4  4  3  1

The second list of the output (`$iNextEst`) includes size- and
coverage-based standardized diversity estimates and related statistics
computed for 40 knots by default. There are two data frames
(`$size_based` and `$coverage_based`).

The first data frame (`$size_based`) includes the name of the assemblage
(`Assemblage`), diversity order (`Order.q`), the target sample size
(`m`), the `Method` (`Rarefaction`, `Observed`, or `Extrapolation`,
depending on whether the size `m` is less than, equal to, or greater
than the reference sample size), the diversity estimate of order q
(`qIE`), the lower and upper confidence limits of diversity (`qIE.LCL`
and `qIE.UCL`) conditioning on the sample size, and the corresponding
sample coverage estimate (`SC`) along with the lower and upper
confidence limits of sample coverage (`SC.LCL` and `SC.UCL`). These
sample coverage estimates with confidence intervals are used for
plotting the sample completeness curve. If the argument `nboot` is
greater than zero, then a bootstrap method is applied to obtain the
confidence intervals for the diversity and sample coverage estimates.
Otherwise, all confidence intervals will not be computed. Here only the
first six rows of the `$size_based` output are displayed:

``` r
output_iNEXT$iNextEst$size_based
```

      Assemblage Order.q  m      Method    qIE qIE.LCL qIE.UCL    SC SC.LCL SC.UCL
    1    Girdled       0  1 Rarefaction  0.000   0.000   0.000 0.124  0.101  0.147
    2    Girdled       0  9 Rarefaction  5.050   4.749   5.350 0.578  0.540  0.616
    3    Girdled       0 18 Rarefaction  8.178   7.588   8.767 0.736  0.703  0.770
    4    Girdled       0 27 Rarefaction 10.312   9.470  11.155 0.808  0.777  0.838
    5    Girdled       0 36 Rarefaction 11.963  10.882  13.043 0.846  0.818  0.875
    6    Girdled       0 44 Rarefaction 13.198  11.911  14.484 0.868  0.840  0.896

The second data frame (`$coverage_based`) includes the name of
assemblage (`Assemblage`), the diversity order (`Order.q`), the target
sample coverage value (`SC`), the corresponding sample size (`m`), the
`Method` (`Rarefaction`, `Observed`, or `Extrapolation`, depending on
whether the coverage `SC` is less than, equal to, or greater than the
reference sample coverage), the diversity estimate of order q (`qIE`),
the lower and upper confidence limits of diversity (`qIE.LCL` and
`qIE.UCL`) conditioning on the target sample coverage value. Here only
the first six rows of the `$coverage_based` output are displayed below:
(Note for a fixed coverage value, the confidence interval in the
`$coverage_based` table is wider than the corresponding interval in the
`$size_based` table. This is because, for a given coverage value, the
sample size needed to attain a fixed coverage value varies with
bootstrap replication, leading to higher uncertainty on the resulting
diversity estimate.)

``` r
output_iNEXT$iNextEst$coverage_based
```

      Assemblage Order.q    SC  m      Method    qIE qIE.LCL qIE.UCL
    1    Girdled       0 0.124  1 Rarefaction  0.000   0.000   0.183
    2    Girdled       0 0.578  9 Rarefaction  5.050   4.199   5.900
    3    Girdled       0 0.736 18 Rarefaction  8.178   6.857   9.499
    4    Girdled       0 0.808 27 Rarefaction 10.312   8.529  12.095
    5    Girdled       0 0.846 36 Rarefaction 11.963   9.676  14.250
    6    Girdled       0 0.868 44 Rarefaction 13.198  10.440  15.956

The third list of the output (`$AsyEst`) includes the name of the
Assemblage, diversity order (q = 0, 1, 2), the maximum likelihood
estimation estimate (`IE_MLE`), asymptotic diversity estimate (`IE_asy`)
and its estimated bootstrap standard error (`s.e.`) as well as the
confidence intervals for asymptotic diversity (`qIE.LCL` and `qIE.UCL`).
These statistics are computed only for q = 0, 1 and 2. More detailed
information about maximum likelihood estimation and asymptotic diversity
estimates for any order q between 0 and 2 can be obtained from function
`MLEAsyIE()`. The output for `$AsyEst` is shown below:

``` r
output_iNEXT$AsyEst
```

      Assemblage Order.q     IE_MLE     IE_asy     s.e.    qIE.LCL    qIE.UCL
    1    Girdled       0     25.000     35.917    6.968     22.260     49.574
    2    Girdled       1   1407.199   1459.750   44.878   1371.792   1547.709
    3    Girdled       2 136800.000 137200.978 1818.409 133636.962 140764.993
    4     Logged       0     36.000     49.968    6.482     37.263     62.673
    5     Logged       1   2260.176   2331.295   62.810   2208.190   2454.400
    6     Logged       2 300622.222 301208.694 4555.370 292280.333 310137.055

The `ggiNEXTIE` function can be used to make graphical displays for
rarefaction and extrapolation sampling curves. An example for showing
sample-size-based rarefaction/extrapolation curves (`type = 1`) is given
below:

``` r
# Sample-size-based R/E curves
ggiNEXTIE(output_iNEXT, type = 1)
```

<img src="README/README-unnamed-chunk-15-1.png" style="display: block; margin: auto;" />

The following commands return the sample completeness (sample coverage)
curve (`type = 2`) in which different colors represent different
assemblages.

``` r
# Sample completeness curves for abundance data
ggiNEXTIE(output_iNEXT, type = 2)
```

<img src="README/README-unnamed-chunk-16-1.png" style="display: block; margin: auto;" />

The following commands return the coverage-based
rarefaction/extrapolation sampling curves in which different color
curves represent two assemblages within each diversity order.

``` r
# Coverage-based R/E curves
ggiNEXTIE(output_iNEXT, type = 3)
```

<img src="README/README-unnamed-chunk-17-1.png" style="display: block; margin: auto;" />

## <span style="color:red;">FUNCTION DataInfoIE(): DATA INFORMATION</span>

The function `DataInfoIE()` provides basic data information for the
reference sample in each assemblage. The function `DataInfoIE()` with
default arguments is shown below:

``` r
DataInfoIE(data, rho) 
```

All arguments in the above function are the same as those for the main
function `iNEXTIE`. Running the `DataInfoIE()` function returns basic
data information including sample size, total abundance, sampling
fraction, observed species richness, sample coverage estimates of the
reference sample (`SC(n)`), sample coverage estimate for twice the
reference sample size (`SC(2n)`). We use data to demo the function.

### Basic data information for abundance data

``` r
DataInfoIE(spider, rho = 0.3)
```

      Assemblage   n   N rho S.obs SC(n) SC(2n) f1 f2 f3 f4 f5
    1    Girdled 168 560 0.3    26 0.950  0.988 12  4  0  1  0
    2     Logged 252 840 0.3    37 0.961  0.989 14  4  4  3  1

Output description:

-   `Assemblage` = assemblage name.

-   `n` = number of observed individuals in the reference sample (sample
    size).

-   `N` = total abundance in the overall assemblage.

-   `rho` = sampling fraction of the reference sample.

-   `S.obs` = number of observed species in the reference sample.

-   `SC(n)` = sample coverage estimate of the reference sample with size
    n.

-   `SC(2n)` = sample coverage estimate of the reference sample with
    size 2n.

-   `f1`-`f5` = the first five species abundance frequency counts in the
    reference sample.

## <span style="color:red;">FUNCTION estimateIE(): POINT ESTIMATION</span>

`estimateIE` is used to compute diversity estimates with q = 0, 1, 2
under any specified levels of sample size (when `base = "size"`) and
sample coverage values (when `base = "coverage"`) for abundance data.
When `base = "size"`, `level` can be specified with a particular vector
of sample sizes (greater than 0); if `level = NULL`, this function
computes the diversity estimates for the minimum sample size among all
samples extrapolated to the double reference sizes or total individuals.
When `base = "coverage"`, `level` can be specified with a particular
vector of sample coverage values (between 0 and 1); if `level = NULL`,
this function computes the diversity estimates for the minimum sample
coverage among all samples extrapolated to the double reference sizes or
total individuals. All arguments in the function are the same as those
for the main function `iNEXTIE`.

``` r
estimateIE(data, rho, q = c(0, 1, 2), base = "coverage", level = NULL, nboot = 50, conf = 0.95) 
```

### Example: abundance data with two target coverage values (97% and 99%)

The following commands return the estimates with two specified levels of
sample coverage (97% and 99%).

``` r
output_est_cov <- estimateIE(spider, rho = 0.3, q = c(0, 1, 2), base = "coverage", level = c(0.97, 0.99))
output_est_cov
```

       Assemblage Order.q   SC       m        Method        qIE      s.e.   qIE.LCL    qIE.UCL
    1     Girdled       0 0.97 238.845 Extrapolation     29.370     5.606    18.381     40.358
    2     Girdled       0 0.99 350.815 Extrapolation     33.736     7.048    19.923     47.550
    3     Girdled       1 0.97 238.845 Extrapolation    617.559   143.173   336.946    898.173
    4     Girdled       1 0.99 350.815 Extrapolation    912.022   183.083   553.186   1270.859
    5     Girdled       2 0.97 238.845 Extrapolation  24838.324 10535.470  4189.181  45487.466
    6     Girdled       2 0.99 350.815 Extrapolation  53729.316 19863.392 14797.783  92660.849
    7      Logged       0 0.97 313.778 Extrapolation     39.194     5.515    28.385     50.002
    8      Logged       0 0.99 511.083 Extrapolation     46.378     7.166    32.333     60.423
    9      Logged       1 0.97 313.778 Extrapolation    863.797   158.647   552.855   1174.738
    10     Logged       1 0.99 511.083 Extrapolation   1414.640   229.081   965.649   1863.631
    11     Logged       2 0.97 313.778 Extrapolation  41861.601 15948.716 10602.693  73120.509
    12     Logged       2 0.99 511.083 Extrapolation 111333.509 33561.248 45554.672 177112.345

### Example: abundance data with two target sample sizes (150 and 250)

The following commands return the estimates with two specified levels of
sample sizes (150 and 250).

``` r
output_est_size <- estimateIE(spider, rho = 0.3, q = c(0, 1, 2), base = "size", level = c(150, 250))
output_est_size
```

       Assemblage Order.q   m        Method    SC       qIE    s.e.   qIE.LCL   qIE.UCL
    1     Girdled       0 150   Rarefaction 0.944    23.671   2.266    19.229    28.112
    2     Girdled       0 250 Extrapolation 0.973    29.937   3.768    22.553    37.322
    3     Girdled       1 150   Rarefaction 0.944   384.433  12.203   360.514   408.351
    4     Girdled       1 250 Extrapolation 0.973   646.864  21.103   605.502   688.226
    5     Girdled       2 150   Rarefaction 0.944  9807.998 134.357  9544.664 10071.333
    6     Girdled       2 250 Extrapolation 0.973 27222.876 372.918 26491.971 27953.782
    7      Logged       0 150   Rarefaction 0.934    29.327   1.238    26.902    31.753
    8      Logged       0 250   Rarefaction 0.961    35.889   2.027    31.915    39.862
    9      Logged       1 150   Rarefaction 0.934   406.734  11.084   385.010   428.459
    10     Logged       1 250   Rarefaction 0.961   686.424  18.652   649.867   722.982
    11     Logged       2 150   Rarefaction 0.934  9560.197 168.254  9230.426  9889.968
    12     Logged       2 250   Rarefaction 0.961 26627.395 468.626 25708.906 27545.885

## <span style="color:red;">FUNCTION MLEAsyIE: MAXIMUM LIKELIHOOD ESTIMATION AND ASYMPTOTIC DIVERSITY PROFILES</span>

``` r
MLEAsyIE(data, rho, q = seq(0, 2, 0.2), nboot = 50, conf = 0.95, method = c('Asymptotic', 'MLE'))
```

All arguments in the above function are the same as those for the main
function `iNEXTIE` (except that the default of `q` here is
`seq(0, 2, 0.2)`). The function `MLEAsyIE()` computes maximum likelihood
estimation and asymptotic diversity of order q between 0 and 2 (in
increments of 0.2) for diversity; these values with different order q
can be used to depict a q-profile in the `ggMLEAsyIE` function. By
default, both the maximum likelihood estimation and asymptotic diversity
estimates will be computed.

## <span style="color:red;">FUNCTION ggMLEAsyIE(): GRAPHIC DISPLAYS OF DIVERSITY PROFILES</span>

``` r
ggMLEAsyIE(output)
```

`ggMLEAsyIE` is a ggplot2 extension for an `MLEAsyIE` object to plot
q-profile (which depicts the maximum likelihood estimation and
asymptotic diversity estimate with respect to order q) for q between 0
and 2 (in increments of 0.2).

In the plot of profiles, only confidence intervals of the asymptotic
diversity will be shown when both the maximum likelihood estimation and
asymptotic diversity estimates are computed.

### Example: q-profiles for abundance data

The following commands returns the maximum likelihood estimation and
asymptotic taxonomic diversity, along with its confidence interval for
diversity order q between 0 to 2. Here only the first ten rows of the
output are shown.

``` r
output_MLEAsy <- MLEAsyIE(spider, rho = 0.3)
output_MLEAsy
```

       Assemblage Order.q       qIE    s.e.   qIE.LCL   qIE.UCL     Method
    1     Girdled     0.0    35.917   5.591    24.958    46.875 Asymptotic
    2     Girdled     0.2    68.580   7.964    52.970    84.189 Asymptotic
    3     Girdled     0.4   136.116  10.509   115.519   156.713 Asymptotic
    4     Girdled     0.6   284.879  14.570   256.323   313.436 Asymptotic
    5     Girdled     0.8   629.864  22.262   586.230   673.498 Asymptotic
    6     Girdled     1.0  1459.750  38.429  1384.431  1535.070 Asymptotic
    7     Girdled     1.2  3504.825  74.053  3359.683  3649.967 Asymptotic
    8     Girdled     1.4  8620.532 154.037  8318.624  8922.440 Asymptotic
    9     Girdled     1.6 21529.984 334.297 20874.773 22185.194 Asymptotic
    10    Girdled     1.8 54257.185 738.603 52809.550 55704.820 Asymptotic

The following commands plot the corresponding q-profiles, along with its
confidence interval for q between 0 to 2.

``` r
ggMLEAsyIE(output_MLEAsy)
```

<img src="README/README-unnamed-chunk-30-1.png" style="display: block; margin: auto;" />

## License

The iNEXT.IE package is licensed under the GPLv3. To help refine
`iNEXT.IE`, your comments or feedback would be welcome (please send them
to Anne Chao or report an issue on the iNEXT.IE github
[iNEXT.IE_github](https://github.com/KaiHsiangHu/iNEXT.IE)).

## References
