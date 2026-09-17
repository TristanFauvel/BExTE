
methods_labels <<- list(
  RMP = list(
    full_name = "Robust Mixture Prior",
    short_name = "RMP",
    label = "RMP"
  ),
  separate = list(
    full_name = "Separate analysis",
    short_name = "Separate",
    label = "Separate"
  ),
  pooling = list(
    full_name = "Pooling",
    short_name = "Pooling",
    label = "Pooling"
  ),
  conditional_power_prior = list(
    full_name = "Conditional Power Prior",
    short_name = "conditional_power_prior",
    label = "Conditional PP"
  ),
  commensurate_power_prior = list(
    full_name = "Commensurate Power Prior",
    short_name = "commensurate_power_prior",
    label = "Com. PP"
  ),
  commensurate_prior = list(
    full_name = "Commensurate Prior",
    short_name = "commensurate_prior",
    label = "Com. prior"
  ),
  NPP = list(
    full_name = "Normalized Power Prior",
    short_name = "NPP",
    label = "NPP"
  ),
  PDCCPP = list(
    full_name = "Prior-Data Conflict Calibrated Power Prior",
    short_name = "PDCCPP",
    label = "PDCCPP"
  ),
  EB_PP = list(
    full_name = "Empirical Bayes Power Prior",
    short_name = "EB_PP",
    label = "EBPP"
  ),
  p_value_based_PP = list(
    full_name = "p-value based PP",
    short_name = "pPP",
    label = "p-PP"
  ),
  test_then_pool_difference = list(
    full_name = "Test-then-pool (difference)",
    short_name = "TtP diff",
    label = "TtP (diff.)"
  ),
  test_then_pool_equivalence = list(
    full_name = "Test-then-pool (equivalence)",
    short_name = "TtP eq",
    label = "TtP (eq.)"
  )
)

# Fixed shape and base hue per method, so a method is drawn the same way in
# every figure it appears in. Both halves of that identity used to be derived
# from whatever happened to be in the frame: shapes were handed out by position
# in the list of methods present, so a case study missing one method shifted
# every later method's shape, and colours came from an unseeded sample(), so
# they differed between two runs of the same figure.
#
# The shape carries the method. Within a method, the parameter values become
# shades of its hue - see method_parameter_colors(), which ramps them over the
# range the methods configuration declares rather than over the values one
# figure happens to show, so w = 0.5 is the same shade whether the figure
# plots three weights or nine.
methods_style <<- list(
  RMP = list(shape = 16, hue = "#0072B2"),
  separate = list(shape = 4, hue = "#7F7F7F"),
  pooling = list(shape = 3, hue = "#000000"),
  conditional_power_prior = list(shape = 15, hue = "#009E73"),
  commensurate_power_prior = list(shape = 18, hue = "#CC79A7"),
  # The open diamond against the power prior's filled one, so the two
  # commensurate methods read as a pair without sharing a hue.
  commensurate_prior = list(shape = 23, hue = "#882255"),
  NPP = list(shape = 17, hue = "#D55E00"),
  PDCCPP = list(shape = 1, hue = "#56B4E9"),
  EB_PP = list(shape = 8, hue = "#E69F00"),
  p_value_based_PP = list(shape = 2, hue = "#9467BD"),
  test_then_pool_difference = list(shape = 0, hue = "#8C564B"),
  test_then_pool_equivalence = list(shape = 5, hue = "#17BECF")
)

# Contains information for plotting hyperparameters that are set using Empirical Bayes
empirical_bayes_hyperparameters <<- list(
  RMP = list(
    prior_weight = list(
      parameter_name = "prior_weight",
      parameter_label = "w",
      parameter_notation = "$w$",
      type = "continuous",
      range = c(0,1),
      suffix = ""
    )
  ),
  NPP = list(
    power_parameter_mean = list(
      parameter_name = "power_parameter_mean", # "Power parameter prior mean",
      parameter_label = "xi_gamma",
      parameter_notation = "$\\xi_\\gamma$",
      type = "continuous",
      range = c(0,1),
      suffix = ""
    ),
    power_parameter_std = list(
      parameter_name = "power_parameter_std", #"Power parameter prior std",
      parameter_label = "sigma_gamma",
      parameter_notation = "$\\sigma_\\gamma$",
      type = "continuous",
      range = NA,
      suffix = ""
    )
  ),
  separate = list(),
  pooling = list(),
  conditional_power_prior = list(),
  p_value_based_PP = list(
    power_parameter = list(
      parameter_name = "power_parameter",
      parameter_label = "gamma",
      parameter_notation = "$\\gamma$",
      type = "continuous",
      range = c(0,1),
      suffix = " estimate"
    )
  ),
  PDCCPP = list(
    power_parameter = list(
      parameter_name = "power_parameter",
      parameter_label = "gamma",
      parameter_notation = "$\\gamma$",
      type = "continuous",
      range = c(0,1),
      suffix = " estimate"
    )
  ),
  EB_PP = list(
    power_parameter = list(
      parameter_name = "power_parameter",
      parameter_label = "gamma",
      parameter_notation = "$\\gamma$",
      type = "continuous",
      range = c(0,1),
      suffix = " estimate"
    )
  ),
  test_then_pool_difference = list(
    pool = list(
      parameter_name = "Pooling fraction",
      parameter_label = "pooling_fraction",
      parameter_notation = "Pooling fraction",
      type = "continuous",
      range = c(0,1),
      suffix = ""
    )
  ),
  test_then_pool_equivalence = list(
    pool = list(
      parameter_name = "Pooling fraction",
      parameter_label = "pooling_fraction",
      parameter_notation = "Pooling fraction",
      type = "continuous",
      range = c(0,1),
      suffix = ""
    )
  ),
  commensurate_power_prior = list(
    heterogeneity_parameter_mean = list(
      parameter_name = "Heterogeneity parameter mean",
      parameter_label = "heterogeneity_parameter_mean",
      parameter_notation = "$\\mu_\\tau$",
      type = "continuous",
      range =  NA,
      suffix = ""
    ),
    heterogeneity_parameter_std = list(
      parameter_name = "Heterogeneity parameter std",
      parameter_label = "heterogeneity_parameter_mean",
      parameter_notation = "$\\sigma_\\tau$",
      type = "continuous",
      range =  NA,
      suffix = ""
    ),
    power_parameter_mean = list(
      parameter_name = "Power parameter mean",
      parameter_label = "power_parameter_mean",
      parameter_notation = "$\\mu_\\gamma$",
      type = "continuous",
      range =  c(0, 1),
      suffix = ""
    ),
    power_parameter_std = list(
      parameter_name = "Power parameter std",
      parameter_label = "power_parameter_std",
      parameter_notation = "$\\sigma_\\gamma$",
      type = "continuous",
      range =  NA,
      suffix = ""
    )
  ),
  # As above, minus the power parameter: this method does not have one.
  commensurate_prior = list(
    heterogeneity_parameter_mean = list(
      parameter_name = "Heterogeneity parameter mean",
      parameter_label = "heterogeneity_parameter_mean",
      parameter_notation = "$\\mu_\\tau$",
      type = "continuous",
      range =  NA,
      suffix = ""
    ),
    heterogeneity_parameter_std = list(
      parameter_name = "Heterogeneity parameter std",
      parameter_label = "heterogeneity_parameter_mean",
      parameter_notation = "$\\sigma_\\tau$",
      type = "continuous",
      range =  NA,
      suffix = ""
    )
  )
)
