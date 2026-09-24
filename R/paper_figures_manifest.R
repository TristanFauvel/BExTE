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
## grids thinned to their informative range, and test-then-pool (both
## variants) and PDCCPP left out of these panels entirely. They remain in the
## forest plots, which is where the paper compares every method.
##
## A method mapped to an empty list keeps all of its rows (it has no
## parameters to choose between); a method absent from this list is dropped.
PAPER_VS_TIE_COMBINATIONS <- list(
  pooling = list(),
  separate = list(),
  EB_PP = list(),
  RMP = list(prior_weight = seq(0.1, 0.9, by = 0.1)),
  conditional_power_prior = list(power_parameter = c(0.25, 0.5, 0.75)),
  ## The three inverse-gamma heterogeneity priors; the half-normal ones are
  ## not shown. Selecting on the family alone picks exactly those three. The
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
  NPP_KL = list()
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

  for (method in names(PAPER_VS_TIE_COMBINATIONS)) {
    spec <- PAPER_VS_TIE_COMBINATIONS[[method]]
    matches <- expanded$method == method
    for (column in names(spec)) {
      ## A parameter the run did not record cannot match. Bail out with
      ## an explicit all-FALSE rather than indexing a column that is not
      ## there: `expanded[[column]]` is NULL then, and `NULL %in% ...`
      ## collapses to logical(0), which silently shortens `matches`.
      if (!column %in% names(expanded)) {
        matches <- rep(FALSE, nrow(expanded))
        break
      }
      matches <- matches & expanded[[column]] %in% spec[[column]]
    }
    keep <- keep | matches
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
    manifest_forest("S26", "Probability of study success for the three principal treatment-effect scenarios in the Mepolizumab case study (N_T/2 = 45).", "mepolizumab", 6, "success_proba"),
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
    manifest_vs_tie("S44", "Interval score of the 95% credible interval versus type I error rate in the Teriflunomide case study, with 123 participants per arm and no treatment effect. Smaller is better.", "teriflunomide", 6, "interval_score", "no_effect")
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

paper_manifest_tables <- function() {
  list(
    list(
      id = "TS1", kind = "table",
      caption = "Total target-study sample sizes considered for each case study.",
      case_study = NA_character_, sample_size_factor = NA_real_, metric = NA_character_,
      needs = "configs",
      generator = function(ctx) {
        table_target_sample_sizes(ctx$case_studies, ctx$sample_size_factors,
                                  ctx$case_studies_config_dir, ctx$tables_dir)
      }
    ),
    list(
      id = "TS2", kind = "table",
      caption = "Treatment-effect drift ranges considered for each case study.",
      case_study = NA_character_, sample_size_factor = NA_real_, metric = NA_character_,
      ## Written by R/simulation_scenarios.R during the run itself.
      needs = "run_artifact",
      generator = function(ctx) {
        source_path <- file.path(ctx$results_dir, "drift_ranges.tex")
        if (!file.exists(source_path)) {
          stop("drift_ranges.tex is not in ", ctx$results_dir,
               " - it is written by the simulation run, not by the exporter.")
        }
        destination <- file.path(ctx$tables_dir, "drift_ranges.tex")
        file.copy(source_path, destination, overwrite = TRUE)
        destination
      }
    ),
    list(
      id = "TS7", kind = "table",
      caption = "Summary of the clinical case studies used to construct the simulation-study design.",
      case_study = NA_character_, sample_size_factor = NA_real_, metric = NA_character_,
      needs = "configs",
      generator = function(ctx) {
        table_case_study_summary(ctx$case_studies, ctx$case_studies_config_dir,
                                 ctx$tables_dir)
      }
    )
  )
}

#' The paper figure and table manifest
#'
#' @description Every figure and generated table in the paper, in publication
#'   order, each paired with the generator call that produces it. Table ids are
#'   prefixed `TS` so they never collide with a figure of the same number -
#'   figure S8 and table S8 are different objects, and only the figure is in
#'   scope.
#'
#' @return A list of manifest entries.
#'
#' @export
paper_manifest <- function() {
  entries <- c(
    paper_manifest_figures_forest(),
    paper_manifest_figures_vs_tie(),
    paper_manifest_figures_special(),
    paper_manifest_tables()
  )
  order_key <- function(entry) {
    if (entry$kind == "table") {
      return(1000 + as.numeric(sub("^TS", "", entry$id)))
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
#' @param id A manifest id, e.g. "1", "S20" or "TS7".
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
