## Which generator call produces each figure and table in the paper.
##
## The leaf plot and table functions already take the scenario coordinates
## explicitly, so every entry here is a direct call rather than a
## reimplementation. The loop functions in inst/scripts/plots.R emit every
## combination in the results frame under generated filenames; this manifest is
## what lets a caller ask for "Figure 3" instead.
##
## Captions are quoted from the manuscript, with two author-confirmed
## corrections recorded in specs/2026-09-11-replicate-paper-page-design.md:
## figure S4's "lambda = 20" is a typo for lambda = 0.5, and figure S5 is the
## partially consistent treatment effect.

#' Resolve a sample size factor to a target sample size per arm
#'
#' @description Mirrors the arithmetic the simulation itself uses
#'   (R/simulation_scenarios.R): the total target sample size is the source
#'   study's arm sizes summed and divided by the factor, and the per-arm size
#'   is half of that, floored. Note this uses `control + treatment` rather than
#'   the `total:` field, which duplicates them and has drifted out of step
#'   before (aprepitant's once read 673).
#'
#' @param case_study Case study name.
#' @param factor Sample size factor.
#' @param case_studies_config_dir Directory holding the case study YAMLs,
#'   trailing slash included.
#'
#' @return The target sample size per arm, as an integer.
#'
#' @export
paper_sample_size_per_arm <- function(case_study, factor, case_studies_config_dir) {
  config <- yaml::read_yaml(file.path(case_studies_config_dir, paste0(case_study, ".yml")))
  source_total <- config$source$control + config$source$treatment
  floor((source_total / factor) / 2)
}

## Internal constructors. Each returns one manifest entry; `ctx` is the list
## export_paper_outputs() builds - see R/paper_replication.R - carrying `df`
## (the slice already filtered to this entry's case study, sample size,
## denominator factor and std ratio), `case_studies_config_dir` and
## `results_dir`.

manifest_forest <- function(id, caption, case_study, factor, metric,
                            relative = FALSE) {
  list(
    id = id, kind = "figure", caption = caption,
    case_study = case_study, sample_size_factor = factor, metric = metric,
    needs = "frequentist",
    ## Every method is drawn on this plot, so a selection cannot narrow it.
    methods = "all",
    generator = function(ctx) {
      forest_plot(ctx$df, metric, relative_to_separate = relative)
    }
  )
}

## The method-parameter combinations the versus-type-I-error figures draw.
##
## Those figures plot one point per combination, and every combination the
## run simulated comes to about 45 of them - behind a legend taller than the
## panel it explains. The paper shows a curated subset instead: the parameter
## grids thinned to their informative range, and PDCCPP left out of these
## panels. It remains in the forest plots, which compare every method.
##
## Test-then-pool keeps half the settings of each variant, spread over the type
## I error range. The text reads its conclusions about test-then-pool - less
## power, larger MSE and worse coverage at a given type I error rate - off
## these very panels, so they have to show it, but all ten settings crowded
## the legend.
##
## A method mapped to an empty list keeps all of its rows (it has no
## parameters to choose between); a method absent from this list is dropped.
PAPER_VS_TIE_COMBINATIONS <- list(
  pooling = list(),
  separate = list(),
  EB_PP = list(),
  RMP = list(prior_weight = c(0.1, 0.3, 0.5, 0.7, 0.9)),
  conditional_power_prior = list(power_parameter = c(0.25, 0.5, 0.75)),
  ## The inverse-gamma heterogeneity priors; the half-normal and Cauchy ones
  ## are not shown. Selecting on the family alone picks exactly those. The
  ## same holds for the plain commensurate prior, which runs the same grid.
  commensurate_power_prior = list(`heterogeneity_prior.family` = "inverse_gamma"),
  commensurate_prior = list(`heterogeneity_prior.family` = "inverse_gamma"),
  ## The weight is selected from the data rather than swept, so there is a
  ## single combination and nothing to thin.
  egidi_empirical_mixture = list(),
  p_value_based_PP = list(shape_parameter = 1, equivalence_margin = 0.5),
  NPP = list(power_parameter_mean = 0.5, power_parameter_std = 0.2),
  ## Both maximum-tolerable-discrepancy multipliers: the calibration is what
  ## distinguishes this method from the plain NPP, and the multiplier is the
  ## knob it turns, so thinning to one would hide the thing being shown.
  NPP_KL = list(),
  ## Half the settings of each variant, chosen to span the type I error range
  ## and to keep the settings the text cites. Difference test: eta = 0.8
  ## (median TIE 0.07, and the largest losses at a matched TIE) and eta = 0.1
  ## (0.29). Equivalence test: eta = lambda = 0.1 (0.03, near nominal),
  ## eta = 0.5 with lambda = 0.1 (0.10, the largest Teriflunomide gain) and
  ## eta = 0.1 with lambda = 0.8 (0.35).
  test_then_pool_difference = list(significance_level = c(0.1, 0.8)),
  test_then_pool_equivalence = list(
    list(significance_level = 0.1, equivalence_margin = 0.1),
    list(significance_level = 0.5, equivalence_margin = 0.1),
    list(significance_level = 0.1, equivalence_margin = 0.8)
  )
)

## Keep only the rows PAPER_VS_TIE_COMBINATIONS names.
##
## Matching is on the expanded parameter columns rather than the raw JSON
## string, so a combination is identified by its values and not by how the
## run happened to serialise them.
paper_vs_tie_subset <- function(df) {
  ## drop = FALSE: `df[, "parameters"]` collapses to a bare vector for a
  ## plain data frame (it survives only because readr hands back a
  ## tibble), and get_parameters() then fails on an atomic argument -
  ## the same drop-dimensions trap that made figure S3 plot every gamma.
  expanded <- cbind(df, get_parameters(df[, "parameters", drop = FALSE]))
  keep <- rep(FALSE, nrow(expanded))

  ## Rows of `method` whose parameters take the values one named spec lists.
  matching <- function(method, spec) {
    matches <- expanded$method == method
    for (column in names(spec)) {
      ## A parameter the run did not record cannot match. Bail out with
      ## an explicit all-FALSE rather than indexing a column that is not
      ## there: `expanded[[column]]` is NULL then, and `NULL %in% ...`
      ## collapses to logical(0), which silently shortens `matches`.
      if (!column %in% names(expanded)) {
        return(rep(FALSE, nrow(expanded)))
      }
      matches <- matches & expanded[[column]] %in% spec[[column]]
    }
    matches
  }

  for (method in names(PAPER_VS_TIE_COMBINATIONS)) {
    spec <- PAPER_VS_TIE_COMBINATIONS[[method]]
    ## A named spec selects the cross product of its values; an unnamed list
    ## of named specs selects the union of theirs, for combinations that do
    ## not form a product.
    alternatives <- if (length(spec) > 0 && is.null(names(spec))) spec else list(spec)
    for (alternative in alternatives) {
      keep <- keep | matching(method, alternative)
    }
  }

  df[keep, , drop = FALSE]
}

manifest_vs_tie <- function(id, caption, case_study, factor, metric,
                            treatment_effect) {
  list(
    id = id, kind = "figure", caption = caption,
    case_study = case_study, sample_size_factor = factor, metric = metric,
    needs = "frequentist",
    ## Every method is drawn on this plot, so a selection cannot narrow it.
    methods = "all",
    generator = function(ctx) {
      operating_characteristic_vs_tie(
        paper_vs_tie_subset(ctx$df),
        case_study = case_study,
        target_sample_size_per_arm = ctx$target_sample_size_per_arm,
        treatment_effect = treatment_effect,
        operating_characteristic = frequentist_metrics[[metric]],
        source_denominator_change_factor = 1,
        target_to_source_std_ratio = 1
      )
    }
  )
}

## The difference between a method's power and the power a frequentist test of
## the target data alone reaches at the same type I error rate - the method's
## own, not the nominal one - with its interval from flag_power_differences().
## A method above zero is more powerful than a test that spends as much type I
## error; on zero, its extra power is what that extra type I error buys anyway.
POWER_GAIN_METRIC <- list(
  name = "power_gain",
  label = "Power gain over a test at the same TIE",
  reference_line = 0
)

manifest_power_gain_vs_tie <- function(id, caption, case_study, factor,
                                       treatment_effect) {
  list(
    id = id, kind = "figure", caption = caption,
    case_study = case_study, sample_size_factor = factor,
    ## Read off the probability of success and the power at the equivalent
    ## type I error, which the success_proba requirements already bring in.
    metric = "success_proba",
    needs = "frequentist",
    methods = "all",
    generator = function(ctx) {
      df <- flag_power_differences(paper_vs_tie_subset(ctx$df))
      df$power_gain <- df$power_difference
      df$conf_int_power_gain_lower <- df$power_difference_lower
      df$conf_int_power_gain_upper <- df$power_difference_upper
      operating_characteristic_vs_tie(
        df,
        case_study = case_study,
        target_sample_size_per_arm = ctx$target_sample_size_per_arm,
        treatment_effect = treatment_effect,
        operating_characteristic = POWER_GAIN_METRIC,
        source_denominator_change_factor = 1,
        target_to_source_std_ratio = 1
      )
    }
  )
}

paper_manifest_figures_forest <- function() {
  list(
    manifest_forest("1", "Probability of success for the three principal treatment-effect scenarios in the Botox case study (N_T/2 = 58).", "botox", 4, "success_proba"),
    manifest_forest("3", "Mean squared error (MSE) for the three principal treatment-effect scenarios in the Botox case study (N_T/2 = 117).", "botox", 2, "mse"),
    manifest_forest("S6", "Moment-based ESS across methods for the three principal treatment-effect scenarios in the Botox case study (N_T/2 = 117).", "botox", 2, "ess_moment"),
    manifest_forest("S7", "Bias and associated 95% confidence intervals for the three principal treatment-effect scenarios in the Botox case study (N_T/2 = 117).", "botox", 2, "bias"),
    manifest_forest("S9", "Type I error and power relative to a separate analysis for the three principal treatment-effect scenarios in the Botox case study (N_T/2 = 58).", "botox", 4, "success_proba", relative = TRUE),
    manifest_forest("S11", "Coverage probability of the 95% credible interval for the three principal treatment-effect scenarios in the Dapagliflozin case study (N_T/2 = 66).", "dapagliflozin", 2, "coverage"),
    manifest_forest("S12", "MSE for the three principal treatment-effect scenarios in the Dapagliflozin case study (N_T/2 = 66).", "dapagliflozin", 2, "mse"),
    manifest_forest("S13", "Probability of study success for the three principal treatment-effect scenarios in the Dapagliflozin case study (N_T/2 = 66).", "dapagliflozin", 2, "success_proba"),
    manifest_forest("S14", "Probability of study success relative to a separate analysis for the three principal treatment-effect scenarios in the Dapagliflozin case study (N_T/2 = 66).", "dapagliflozin", 2, "success_proba", relative = TRUE),
    manifest_forest("S16", "Probability of study success for the three principal treatment-effect scenarios in the Belimumab case study (N_T/2 = 140).", "belimumab", 4, "success_proba"),
    manifest_forest("S17", "Probability of study success relative to a separate analysis for the three principal treatment-effect scenarios in the Belimumab case study (N_T/2 = 140).", "belimumab", 4, "success_proba", relative = TRUE),
    manifest_forest("S18", "MSE for the three principal treatment-effect scenarios in the Belimumab case study (N_T/2 = 140).", "belimumab", 4, "mse"),
    manifest_forest("S19", "Precision, measured by the mean half-width of the 95% credible interval, for the three principal treatment-effect scenarios in the Belimumab case study, with 140 participants per arm.", "belimumab", 4, "precision"),
    manifest_forest("S21", "Coverage probability of the 95% credible interval for the three principal treatment-effect scenarios in the Belimumab case study, with 140 participants per arm.", "belimumab", 4, "coverage"),
    manifest_forest("S24", "MSE for the three principal treatment-effect scenarios in the Mepolizumab case study (N_T/2 = 68).", "mepolizumab", 4, "mse"),
    manifest_forest("S25", "Empirical coverage probability for the three principal treatment-effect scenarios in the Mepolizumab case study (N_T/2 = 68).", "mepolizumab", 4, "coverage"),
    ## The manuscript's caption reads N_T/2 = 45, but its relative companion
    ## S27, like every other Mepolizumab figure, is at 68, and each other case
    ## study pairs its absolute and relative panels at one sample size. The
    ## author confirmed 68.
    manifest_forest("S26", "Probability of study success for the three principal treatment-effect scenarios in the Mepolizumab case study (N_T/2 = 68).", "mepolizumab", 4, "success_proba"),
    manifest_forest("S27", "Probability of study success relative to a separate analysis for the three principal treatment-effect scenarios in the Mepolizumab case study (N_T/2 = 68).", "mepolizumab", 4, "success_proba", relative = TRUE),
    manifest_forest("S30", "MSE for the three principal treatment-effect scenarios in the Teriflunomide case study (N_T/2 = 185).", "teriflunomide", 4, "mse"),
    manifest_forest("S31", "Probability of study success for the three principal treatment-effect scenarios in the Teriflunomide case study (N_T/2 = 123).", "teriflunomide", 6, "success_proba"),
    manifest_forest("S32", "Probability of study success relative to a separate analysis for the three principal treatment-effect scenarios in the Teriflunomide case study (N_T/2 = 123).", "teriflunomide", 6, "success_proba", relative = TRUE),
    manifest_forest("S34", "MSE for the three principal treatment-effect scenarios in the Aprepitant case study, with 143 participants per arm.", "aprepitant", 2, "mse"),
    manifest_forest("S35", "Empirical coverage of the 95% credible interval for the three principal treatment-effect scenarios in the Aprepitant case study, with 143 participants per arm.", "aprepitant", 2, "coverage"),
    manifest_forest("S36", "Probability of study success for the three principal treatment-effect scenarios in the Aprepitant case study (N_T/2 = 143).", "aprepitant", 2, "success_proba"),
    manifest_forest("S37", "Probability of study success relative to a separate analysis for the three principal treatment-effect scenarios in the Aprepitant case study (N_T/2 = 143).", "aprepitant", 2, "success_proba", relative = TRUE),

    ## Added in revision: a reviewer observed that the width of a credible
    ## interval says little without its coverage, and asked for the interval
    ## score, which charges an interval for its width and for excluding the
    ## true effect in one number. These accompany the precision and coverage
    ## figures for the same slice - S11, S19 and S21, S25, S35 - so that each
    ## pair can be read together. Unlike every caption above, these are
    ## written here rather than quoted from the manuscript.
    manifest_forest("S38", "Interval score of the 95% credible interval, which combines its width with the penalty for excluding the true treatment effect, for the three principal treatment-effect scenarios in the Dapagliflozin case study (N_T/2 = 66). Smaller is better.", "dapagliflozin", 2, "interval_score"),
    manifest_forest("S39", "Interval score of the 95% credible interval, which combines its width with the penalty for excluding the true treatment effect, for the three principal treatment-effect scenarios in the Belimumab case study, with 140 participants per arm. Smaller is better.", "belimumab", 4, "interval_score"),
    manifest_forest("S40", "Interval score of the 95% credible interval, which combines its width with the penalty for excluding the true treatment effect, for the three principal treatment-effect scenarios in the Mepolizumab case study (N_T/2 = 68). Smaller is better.", "mepolizumab", 4, "interval_score"),
    manifest_forest("S41", "Interval score of the 95% credible interval, which combines its width with the penalty for excluding the true treatment effect, for the three principal treatment-effect scenarios in the Aprepitant case study, with 143 participants per arm. Smaller is better.", "aprepitant", 2, "interval_score")
  )
}

paper_manifest_figures_vs_tie <- function() {
  list(
    manifest_vs_tie("2", "Probability of success versus type I error rate in the Botox case study, with 58 participants per arm and a partially consistent treatment effect.", "botox", 4, "success_proba", "partially_consistent"),
    manifest_vs_tie("4", "MSE versus type I error rate in the Botox case study, with 117 participants per arm and a partially consistent treatment effect.", "botox", 2, "mse", "partially_consistent"),
    manifest_vs_tie("S8", "Coverage of the 95% interval versus type I error rate in the Botox case study, with 117 participants per arm, no treatment effect, and a target-to-source standard-deviation ratio of 1.", "botox", 2, "coverage", "no_effect"),
    manifest_vs_tie("S10", "MSE versus type I error rate in the Dapagliflozin case study, with 33 participants per arm and a partially consistent treatment effect.", "dapagliflozin", 4, "mse", "partially_consistent"),
    manifest_vs_tie("S15", "MSE versus type I error rate in the Belimumab case study, with 140 participants per arm and a partially consistent treatment effect.", "belimumab", 4, "mse", "partially_consistent"),
    manifest_vs_tie("S22", "MSE versus type I error rate in the Mepolizumab case study (N_T/2 = 68), with a partially consistent treatment effect.", "mepolizumab", 4, "mse", "partially_consistent"),
    manifest_vs_tie("S23", "Coverage of the 95% interval versus type I error rate in the Mepolizumab case study, with 68 participants per arm and no treatment effect.", "mepolizumab", 4, "coverage", "no_effect"),
    manifest_vs_tie("S28", "MSE versus type I error rate in the Teriflunomide case study (N_T/2 = 123), with a partially consistent treatment effect.", "teriflunomide", 6, "mse", "partially_consistent"),
    manifest_vs_tie("S29", "Coverage of the 95% interval versus type I error rate in the Teriflunomide case study, with 123 participants per arm and no treatment effect.", "teriflunomide", 6, "coverage", "no_effect"),
    manifest_vs_tie("S33", "MSE versus type I error rate in the Aprepitant case study (N_T/2 = 71), with a partially consistent treatment effect.", "aprepitant", 4, "mse", "partially_consistent"),

    ## Added in revision; see the note in paper_manifest_figures_forest().
    ## One per coverage-versus-type-I-error figure - S8, S23, S29 - on the
    ## same slice, so the score can be read against the coverage it folds in.
    manifest_vs_tie("S42", "Interval score of the 95% credible interval versus type I error rate in the Botox case study, with 117 participants per arm, no treatment effect, and a target-to-source standard-deviation ratio of 1. Smaller is better.", "botox", 2, "interval_score", "no_effect"),
    manifest_vs_tie("S43", "Interval score of the 95% credible interval versus type I error rate in the Mepolizumab case study, with 68 participants per arm and no treatment effect. Smaller is better.", "mepolizumab", 4, "interval_score", "no_effect"),
    manifest_vs_tie("S44", "Interval score of the 95% credible interval versus type I error rate in the Teriflunomide case study, with 123 participants per arm and no treatment effect. Smaller is better.", "teriflunomide", 6, "interval_score", "no_effect"),

    ## Added in revision: the power gain at a matched type I error rate the
    ## results text quantifies, on the designs it cites - the largest gains
    ## (Teriflunomide, and Aprepitant at 143), and the largest losses
    ## (Aprepitant at 71, Botox at 58).
    manifest_power_gain_vs_tie("S53", "Power gain over a frequentist test of the target data alone performed at the same type I error rate, versus type I error rate, in the Teriflunomide case study, with 123 participants per arm and a consistent treatment effect. Error bars are 95% intervals for the difference.", "teriflunomide", 6, "consistent"),
    manifest_power_gain_vs_tie("S54", "Power gain over a frequentist test of the target data alone performed at the same type I error rate, versus type I error rate, in the Aprepitant case study, with 143 participants per arm and a consistent treatment effect. Error bars are 95% intervals for the difference.", "aprepitant", 2, "consistent"),
    manifest_power_gain_vs_tie("S55", "Power gain over a frequentist test of the target data alone performed at the same type I error rate, versus type I error rate, in the Aprepitant case study, with 71 participants per arm and a consistent treatment effect. Error bars are 95% intervals for the difference.", "aprepitant", 4, "consistent"),
    manifest_power_gain_vs_tie("S56", "Power gain over a frequentist test of the target data alone performed at the same type I error rate, versus type I error rate, in the Botox case study, with 58 participants per arm and a consistent treatment effect. Error bars are 95% intervals for the difference.", "botox", 4, "consistent")
  )
}

## These PDFs are referenced by the manuscript but have no figure number in
## the paper manifest. Keep separate ids so their outputs and failures are
## visible during a replication run.
paper_manifest_figures_unnumbered <- function() {
  list(
    manifest_vs_tie("X1", "Coverage versus type I error rate in the Botox case study, with 117 participants per arm and a partially consistent treatment effect.", "botox", 2, "coverage", "partially_consistent"),
    manifest_vs_tie("X2", "Coverage versus type I error rate in the Mepolizumab case study, with 68 participants per arm and a partially consistent treatment effect.", "mepolizumab", 4, "coverage", "partially_consistent"),
    manifest_forest("X3", "Coverage probability for the three principal treatment-effect scenarios in the Teriflunomide case study, with 123 participants per arm.", "teriflunomide", 6, "coverage"),
    ## The interval-score counterparts the supplement places beside the
    ## coverage and precision figures that S38-S44 do not cover: the
    ## Teriflunomide forest plot of X3's slice, and the versus-type-I-error
    ## figures on the slices of S38, S39 and S41.
    manifest_forest("X4", "Interval score of the 95% credible interval, which combines its width with the penalty for excluding the true treatment effect, for the three principal treatment-effect scenarios in the Teriflunomide case study, with 123 participants per arm. Smaller is better.", "teriflunomide", 6, "interval_score"),
    manifest_vs_tie("X5", "Interval score of the 95% credible interval versus type I error rate in the Dapagliflozin case study, with 66 participants per arm, no treatment effect, and a target-to-source standard-deviation ratio of 1. Smaller is better.", "dapagliflozin", 2, "interval_score", "no_effect"),
    manifest_vs_tie("X6", "Interval score of the 95% credible interval versus type I error rate in the Belimumab case study, with 140 participants per arm and no treatment effect. Smaller is better.", "belimumab", 4, "interval_score", "no_effect"),
    manifest_vs_tie("X7", "Interval score of the 95% credible interval versus type I error rate in the Aprepitant case study, with 143 participants per arm and no treatment effect. Smaller is better.", "aprepitant", 2, "interval_score", "no_effect")
  )
}

## S3, S4, S5 and S20 each have their own generator rather than sharing one of
## the two shapes above.
paper_manifest_figures_special <- function() {
  list(
    list(
      id = "S3", kind = "figure",
      methods = "conditional_power_prior",
      caption = "Probability of success versus treatment-effect drift for the Conditional Power Prior (gamma = 0.25) in the Belimumab case study, with 93 participants per arm; includes comparisons with t-tests at nominal and matched type I error rates.",
      case_study = "belimumab", sample_size_factor = 6, metric = "success_proba",
      needs = "frequentist",
      generator = function(ctx) {
        plot_success_proba_vs_drift(
          metric = "success_proba",
          results_metrics_df = ctx$df,
          theta_0 = ctx$theta_0,
          case_study = "belimumab",
          method = "conditional_power_prior",
          target_sample_size_per_arm = ctx$target_sample_size_per_arm,
          target_to_source_std_ratio = 1,
          source_denominator_change_factor = 1,
          parameters_combinations = data.frame(power_parameter = 0.25),
          xvars = xvars,
          join_points = TRUE,
          baseline_success_proba = c("at_equivalent_TIE", "at_nominal_TIE")
        )
      }
    ),
    list(
      id = "S4", kind = "figure",
      methods = "p_value_based_PP",
      ## The manuscript prints "lambda = 20"; the author confirmed this is a
      ## typo for lambda = 0.5, which is what the configs actually simulate.
      caption = "Probability of success versus treatment-effect drift for the p-value-based Power Prior (k = 20, lambda = 0.5) in the Botox case study, with 58 participants per arm; includes comparisons with t-tests at nominal and matched type I error rates.",
      case_study = "botox", sample_size_factor = 4, metric = "success_proba",
      needs = "frequentist",
      generator = function(ctx) {
        plot_success_proba_vs_drift(
          metric = "success_proba",
          results_metrics_df = ctx$df,
          theta_0 = ctx$theta_0,
          case_study = "botox",
          method = "p_value_based_PP",
          target_sample_size_per_arm = ctx$target_sample_size_per_arm,
          target_to_source_std_ratio = 1,
          source_denominator_change_factor = 1,
          parameters_combinations = data.frame(shape_parameter = 20, equivalence_margin = 0.5),
          xvars = xvars,
          join_points = TRUE,
          baseline_success_proba = c("at_equivalent_TIE", "at_nominal_TIE")
        )
      }
    ),
    list(
      id = "S5", kind = "figure",
      methods = "all",
      caption = "MSE versus mean moment-based effective sample size (ESS) in the Botox case study, with 117 participants per arm.",
      case_study = "botox", sample_size_factor = 2, metric = "mse",
      needs = "frequentist",
      generator = function(ctx) {
        plot_metric_vs_ess(
          results_metrics_df = ctx$df,
          case_study = "botox",
          target_sample_size_per_arm = ctx$target_sample_size_per_arm,
          treatment_effect = "partially_consistent",
          ess_method = inference_metrics$ess_moment,
          metric = frequentist_metrics$mse,
          source_denominator_change_factor = 1,
          target_to_source_std_ratio = 1
        )
      }
    ),
    list(
      id = "S20", kind = "figure",
      methods = "RMP",
      caption = "MSE versus treatment-effect drift for the Robust Mixture Prior in the Belimumab case study, with 93 participants per arm, across different informative-component weights w.",
      case_study = "belimumab", sample_size_factor = 6, metric = "mse",
      needs = "frequentist",
      generator = function(ctx) {
        plot_metric_vs_drift(
          metric = "mse",
          results_metrics_df = ctx$df,
          theta_0 = ctx$theta_0,
          case_study = "belimumab",
          method = "RMP",
          category = "parameters",
          control_drift = FALSE,
          target_sample_size_per_arm = ctx$target_sample_size_per_arm,
          parameters_combinations = NULL,
          xvars = xvars,
          target_to_source_std_ratio = 1,
          source_denominator_change_factor = 1,
          analysis_config = ctx$analysis_config
        )
      }
    )
  )
}

## ---- Time-to-event sensitivity figures (S45-S52) ---------------------
##
## Added in revision, like S38-S44, with captions written here. S45-S50 show
## how the number of events - moved by loss to follow-up, by Weibull rather
## than exponential event times, and by control-arm heterogeneity - changes the
## operating characteristics of each prior in the Teriflunomide case study.
## S51-S52 depart from proportional hazards: the treatment effect starts only
## after a delay, which the Cox analysis does not model. The scenario's
## treatment effect is then the Cox model's large-sample limit, so drift and
## the null hypothesis keep their meaning (see time_to_event_delayed_log_hr()).
## Each varies one axis with the other two at their primary value; the run
## simulates them at N_T/2 = 123 only (see PAPER_TTE_SENSITIVITY).

## The metrics the sensitivity forest plots (S45-S47) and drift curves
## (S48-S50) draw.
PAPER_TTE_FOREST_METRICS <- c("success_proba", "mse", "coverage")
PAPER_TTE_DRIFT_METRICS <- c("success_proba", "mse")

## One setting per method for the drift curves, which draw a single line per
## level of the axis and so cannot show a parameter grid as well. These are
## the methods configs' important values. A method mapped to an empty list has
## a single combination; a method absent from this list is not drawn.
PAPER_TTE_SENSITIVITY_COMBINATIONS <- list(
  separate = list(),
  pooling = list(),
  EB_PP = list(),
  PDCCPP = list(),
  egidi_empirical_mixture = list(),
  RMP = list(prior_weight = 0.5),
  conditional_power_prior = list(power_parameter = 0.5),
  p_value_based_PP = list(shape_parameter = 1, equivalence_margin = 0.5),
  NPP = list(power_parameter_mean = 0.5, power_parameter_std = 0.2),
  commensurate_power_prior = list(
    `heterogeneity_prior.family` = "inverse_gamma", `heterogeneity_prior.alpha` = 1 / 7
  ),
  commensurate_prior = list(
    `heterogeneity_prior.family` = "inverse_gamma", `heterogeneity_prior.alpha` = 1 / 7
  ),
  test_then_pool_difference = list(significance_level = 0.1),
  test_then_pool_equivalence = list(significance_level = 0.5, equivalence_margin = 0.5)
)

## The parameter combination PAPER_TTE_SENSITIVITY_COMBINATIONS picks for one
## method out of the rows of a results frame, as a one-row data frame, or NULL
## when the method is not drawn or the run did not simulate that setting.
## Numbers are compared with a tolerance: the results' JSON keeps four
## decimals, so 1/7 comes back as 0.1429.
paper_tte_parameters <- function(df, method) {
  spec <- PAPER_TTE_SENSITIVITY_COMBINATIONS[[method]]
  if (is.null(spec)) {
    return(NULL)
  }
  params <- unique(get_parameters(df[df$method == method, "parameters", drop = FALSE]))
  keep <- rep(TRUE, nrow(params))
  for (column in names(spec)) {
    if (!column %in% names(params)) {
      return(NULL)
    }
    value <- spec[[column]]
    keep <- keep & if (is.numeric(value)) {
      abs(suppressWarnings(as.numeric(params[[column]])) - value) < 1e-4
    } else {
      params[[column]] == value
    }
  }
  keep[is.na(keep)] <- FALSE
  if (!any(keep)) {
    return(NULL)
  }
  params[which(keep)[1], , drop = FALSE]
}

## How one level of a sensitivity axis is named in filenames and subtitles.
paper_tte_level_suffix <- function(axis, level) {
  switch(axis,
    dropout_probability = paste0("_dropout=", level),
    event_time_distribution = paste0("_", level),
    control_drift = paste0("_control_drift=", level),
    treatment_delay = paste0("_delay=", round(52 * level), "w")
  )
}

paper_tte_level_label <- function(axis, level) {
  switch(axis,
    dropout_probability = sprintf("Loss to follow-up %g%%", 100 * level),
    event_time_distribution = paste(tools::toTitleCase(level), "event times"),
    control_drift = sprintf("Control-arm heterogeneity %+g", level),
    treatment_delay = if (level == 0) {
      "Proportional hazards"
    } else {
      sprintf("Treatment effect delayed by %d weeks", round(52 * level))
    }
  )
}

manifest_tte_forest <- function(id, caption, axis) {
  list(
    id = id, kind = "figure", caption = caption,
    case_study = "teriflunomide", sample_size_factor = 6,
    metric = "success_proba", design_axis = axis,
    needs = "frequentist",
    ## Every method is drawn on this plot, so a selection cannot narrow it.
    methods = "all",
    generator = function(ctx) {
      df <- ctx$df[time_to_event_varies_only(ctx$df, axis), , drop = FALSE]
      levels <- sort(unique(df[[axis]]))
      if (length(levels) < 2) {
        stop("No ", axis, " sensitivity designs at ",
             ctx$target_sample_size_per_arm, " per arm.")
      }
      case_config <- yaml::read_yaml(
        file.path(ctx$case_studies_config_dir, "teriflunomide.yml")
      )
      for (level in levels) {
        design <- list(control_drift = 0, dropout_probability = 0,
                       event_time_distribution = "exponential",
                       treatment_delay = 0)
        design[[axis]] <- level
        events <- time_to_event_expected_events(
          case_config, ctx$target_sample_size_per_arm,
          control_drift = design$control_drift,
          dropout_probability = design$dropout_probability,
          event_time_distribution = design$event_time_distribution,
          treatment_delay = design$treatment_delay
        )
        subtitle <- sprintf(
          "%s: about %.0f control and %.0f treatment events expected (consistent effect)",
          paper_tte_level_label(axis, level), events[["control"]], events[["treatment"]]
        )
        for (metric in PAPER_TTE_FOREST_METRICS) {
          forest_plot(
            df[df[[axis]] == level, , drop = FALSE], metric,
            filename_suffix = paper_tte_level_suffix(axis, level),
            subtitle = subtitle
          )
        }
      }
    }
  )
}

manifest_tte_drift <- function(id, caption, axis) {
  list(
    id = id, kind = "figure", caption = caption,
    case_study = "teriflunomide", sample_size_factor = 6,
    metric = "success_proba", design_axis = axis,
    needs = "frequentist",
    methods = "all",
    generator = function(ctx) {
      for (method in intersect(names(PAPER_TTE_SENSITIVITY_COMBINATIONS),
                               unique(ctx$df$method))) {
        parameters <- paper_tte_parameters(ctx$df, method)
        if (is.null(parameters)) {
          next
        }
        for (metric in PAPER_TTE_DRIFT_METRICS) {
          plot_metric_vs_drift(
            metric = metric,
            results_metrics_df = ctx$df,
            theta_0 = ctx$theta_0,
            case_study = "teriflunomide",
            method = method,
            category = axis,
            control_drift = FALSE,
            target_sample_size_per_arm = ctx$target_sample_size_per_arm,
            parameters_combinations = parameters,
            xvars = xvars,
            join_points = TRUE,
            target_to_source_std_ratio = 1,
            source_denominator_change_factor = 1,
            analysis_config = ctx$analysis_config
          )
        }
      }
    }
  )
}

paper_manifest_figures_tte_sensitivity <- function() {
  list(
    manifest_tte_forest("S45", "Probability of study success, MSE and coverage of the 95% credible interval for the three principal treatment-effect scenarios in the Teriflunomide case study (N_T/2 = 123), with 0%, 5% and 10% of patients lost to follow-up. One figure per level; the subtitle gives the expected number of events.", "dropout_probability"),
    manifest_tte_forest("S46", "Probability of study success, MSE and coverage of the 95% credible interval for the three principal treatment-effect scenarios in the Teriflunomide case study (N_T/2 = 123), with exponential and Weibull event times. One figure per distribution; the subtitle gives the expected number of events.", "event_time_distribution"),
    manifest_tte_forest("S47", "Probability of study success, MSE and coverage of the 95% credible interval for the three principal treatment-effect scenarios in the Teriflunomide case study (N_T/2 = 123), with a target placebo relapse rate two thirds of, equal to, and half again the source one. One figure per level; the subtitle gives the expected number of events.", "control_drift"),
    manifest_tte_drift("S48", "Probability of study success and MSE versus treatment-effect drift for each method in the Teriflunomide case study (N_T/2 = 123), with 0%, 5% and 10% of patients lost to follow-up.", "dropout_probability"),
    manifest_tte_drift("S49", "Probability of study success and MSE versus treatment-effect drift for each method in the Teriflunomide case study (N_T/2 = 123), with exponential and Weibull event times.", "event_time_distribution"),
    manifest_tte_drift("S50", "Probability of study success and MSE versus treatment-effect drift for each method in the Teriflunomide case study (N_T/2 = 123), under control-arm heterogeneity of -0.405, 0 and 0.405 on the log hazard scale.", "control_drift"),
    manifest_tte_forest("S51", "Probability of study success, MSE and coverage of the 95% credible interval for the three principal treatment-effect scenarios in the Teriflunomide case study (N_T/2 = 123), when the treatment effect starts 0, 12 or 24 weeks after randomisation. Under a delay, hazards are not proportional; the treatment effect is the large-sample limit of the Cox estimate. One figure per delay; the subtitle gives the expected number of events.", "treatment_delay"),
    manifest_tte_drift("S52", "Probability of study success and MSE versus treatment-effect drift for each method in the Teriflunomide case study (N_T/2 = 123), when the treatment effect starts 0, 12 or 24 weeks after randomisation. Under a delay, hazards are not proportional; the treatment effect is the large-sample limit of the Cox estimate.", "treatment_delay")
  )
}

## Table numbers follow the revised supplement, in which the drift ranges and
## the target sample sizes were merged into table S1. Tables S2 (methods and
## parameters) and S4 (simulation configuration) are written by hand in the
## manuscript and have no generator. The precision and coverage table is not
## yet numbered in the manuscript; S5 is the next free number.
paper_manifest_tables <- function() {
  list(
    list(
      id = "TS1", kind = "table",
      caption = "Drift and treatment effect ranges, and target study sample sizes considered for each case study.",
      case_study = NA_character_, sample_size_factor = NA_real_, metric = NA_character_,
      needs = "configs",
      generator = function(ctx) {
        table_drift_ranges_and_sample_sizes(ctx$case_studies_config_dir, ctx$tables_dir)
      }
    ),
    list(
      id = "TS3", kind = "table",
      caption = "Summary of the clinical case studies used to construct the simulation-study design.",
      case_study = NA_character_, sample_size_factor = NA_real_, metric = NA_character_,
      needs = "configs",
      generator = function(ctx) {
        table_case_study_summary(ctx$case_studies, ctx$case_studies_config_dir,
                                 ctx$tables_dir)
      }
    ),
    list(
      id = "TS5", kind = "table",
      caption = "Precision and empirical coverage probability for the three principal treatment-effect scenarios in the Belimumab case study, with 140 participants per arm.",
      case_study = "belimumab", sample_size_factor = 4, metric = "precision_ecp",
      needs = "frequentist", methods = "all",
      generator = function(ctx) {
        table_precision_ecp(ctx$df, ctx$tables_dir)
      }
    )
  )
}

#' The paper figure and table manifest
#'
#' @description Every figure and generated table in the paper, plus unnumbered
#'   figures referenced by the manuscript, each paired with its generator.
#'   Table ids are prefixed `TS` so they never collide with a figure of the
#'   same number; unnumbered manuscript figures use `X` ids.
#'
#' @return A list of manifest entries.
#'
#' @export
paper_manifest <- function() {
  entries <- c(
    paper_manifest_figures_forest(),
    paper_manifest_figures_vs_tie(),
    paper_manifest_figures_special(),
    paper_manifest_figures_unnumbered(),
    paper_manifest_figures_tte_sensitivity(),
    paper_manifest_tables()
  )
  order_key <- function(entry) {
    if (entry$kind == "table") {
      return(1000 + as.numeric(sub("^TS", "", entry$id)))
    }
    if (startsWith(entry$id, "X")) {
      return(500 + as.numeric(sub("^X", "", entry$id)))
    }
    if (startsWith(entry$id, "S")) {
      return(100 + as.numeric(sub("^S", "", entry$id)))
    }
    as.numeric(entry$id)
  }
  entries[order(vapply(entries, order_key, numeric(1)))]
}

#' Ids of every paper item in the manifest
#'
#' @return A character vector of ids in publication order.
#'
#' @export
paper_manifest_ids <- function() {
  vapply(paper_manifest(), function(entry) entry$id, character(1))
}

#' Look up one manifest entry by id
#'
#' @param id A manifest id, e.g. "1", "S20" or "TS3".
#'
#' @return The matching manifest entry.
#'
#' @export
paper_manifest_entry <- function(id) {
  entries <- paper_manifest()
  match_index <- which(vapply(entries, function(entry) entry$id, character(1)) == id)
  if (length(match_index) == 0) {
    stop("No paper manifest entry with id ", id, ".")
  }
  entries[[match_index]]
}
