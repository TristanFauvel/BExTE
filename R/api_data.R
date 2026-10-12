#' Source study data
#'
#' @description Describes the source (historical) study that a borrowing prior
#'   takes information from. Give either the arm sizes and response counts of a
#'   binary endpoint, or the treatment effect estimate and its standard error
#'   of a continuous endpoint. Or read the same information from a case-study
#'   configuration with `config`.
#'
#'   The result is the first argument of every prior builder, such as [npp()]
#'   or [rmp()].
#'
#' @param n_control,n_treatment Number of patients in the control and
#'   treatment arms.
#' @param responses_control,responses_treatment Number of responders in each
#'   arm. Binary endpoint only.
#' @param estimate,se Treatment effect estimate and its standard error.
#'   Continuous endpoint only.
#' @param likelihood The scale of the treatment effect. `"normal"` analyses the
#'   log odds ratio (binary endpoint) or the mean difference (continuous
#'   endpoint) with a normal likelihood. `"binomial"` analyses the risk
#'   difference with the exact binomial likelihood (binary endpoint only).
#' @param theta_0 Boundary of the null hypothesis. Methods that adapt the
#'   borrowing to the hypothesis read it, and [decision()] uses it by default.
#' @param null_space `"left"` when the null hypothesis is
#'   `theta <= theta_0` (a positive effect is a benefit), `"right"` otherwise.
#' @param name A short name for the study, used in printed output.
#' @param config Optional case-study configuration: a path to a YAML file, or a
#'   list with the same fields. See the files in
#'   `system.file("conf/case_studies", package = "BExTE")`. When given, the
#'   other arguments are ignored.
#'
#' @return An object of class `bexte_source`.
#'
#' @seealso [target_data()], [posterior()].
#'
#' @examples
#' src <- source_data(
#'   n_control = 562, n_treatment = 563,
#'   responses_control = 218, responses_treatment = 285
#' )
#' src
#'
#' # The same study, read from a shipped case-study configuration.
#' source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
#' @export
source_data <- function(n_control,
                        n_treatment,
                        responses_control = NULL,
                        responses_treatment = NULL,
                        estimate = NULL,
                        se = NULL,
                        likelihood = c("normal", "binomial"),
                        theta_0 = 0,
                        null_space = c("left", "right"),
                        name = "source",
                        config = NULL) {
  if (!is.null(config)) {
    if (is.character(config)) {
      config <- yaml::yaml.load_file(config)
    }
    if (!is.list(config)) {
      stop("`config` should be a path to a YAML file or a list.", call. = FALSE)
    }
    if (is.null(config$sampling_approximation)) {
      config$sampling_approximation <- FALSE
    }
    if (is.null(config$name)) {
      config$name <- name
    }
  } else {
    likelihood <- match.arg(likelihood)
    null_space <- match.arg(null_space)
    assert_single_number(theta_0)
    arms <- api_check_arms(n_control, n_treatment, responses_control,
                           responses_treatment, estimate, se, "source_data")
    if (arms$endpoint == "continuous" && likelihood == "binomial") {
      stop("`likelihood = \"binomial\"` needs response counts, not `estimate` and `se`.",
           call. = FALSE)
    }
    source <- list(
      control = n_control,
      treatment = n_treatment,
      total = n_control + n_treatment
    )
    if (arms$endpoint == "binary") {
      source$responses <- list(control = responses_control, treatment = responses_treatment)
    } else {
      source$treatment_effect <- estimate
      source$standard_error <- se
    }
    config <- list(
      name = name,
      summary_measure_likelihood = likelihood,
      theta_0 = theta_0,
      endpoint = arms$endpoint,
      null_space = null_space,
      sampling_approximation = FALSE,
      source = source
    )
  }

  structure(
    list(config = config, data = ObservedSourceData$new(config)),
    class = c("bexte_source", "bexte_data")
  )
}


#' Target study data
#'
#' @description Describes the observed target (new) study, whose treatment
#'   effect [posterior()] estimates. Give either the arm sizes and response
#'   counts of a binary endpoint, or the treatment effect estimate and its
#'   standard error. The scale of the effect (log odds ratio or risk
#'   difference) follows the source data the prior was built from.
#'
#' @inheritParams source_data
#' @return An object of class `bexte_target`.
#'
#' @seealso [source_data()], [posterior()].
#'
#' @examples
#' target_data(n_control = 39, n_treatment = 53,
#'             responses_control = 17, responses_treatment = 28)
#' @export
target_data <- function(n_control,
                        n_treatment,
                        responses_control = NULL,
                        responses_treatment = NULL,
                        estimate = NULL,
                        se = NULL) {
  arms <- api_check_arms(n_control, n_treatment, responses_control,
                         responses_treatment, estimate, se, "target_data")
  structure(
    list(
      endpoint = arms$endpoint,
      n_control = n_control,
      n_treatment = n_treatment,
      responses_control = responses_control,
      responses_treatment = responses_treatment,
      estimate = estimate,
      se = se
    ),
    class = c("bexte_target", "bexte_data")
  )
}


#' Check the arms given to source_data() or target_data()
#'
#' @return A list with the `endpoint` the arguments describe.
#' @keywords internal
#' @noRd
api_check_arms <- function(n_control, n_treatment, responses_control,
                           responses_treatment, estimate, se, caller) {
  assert_single_number(n_control)
  assert_single_number(n_treatment)
  if (n_control <= 0 || n_treatment <= 0) {
    stop(caller, "(): `n_control` and `n_treatment` should be positive.", call. = FALSE)
  }
  has_counts <- !is.null(responses_control) || !is.null(responses_treatment)
  has_estimate <- !is.null(estimate) || !is.null(se)
  if (has_counts == has_estimate) {
    stop(caller, "(): give either `responses_control` and `responses_treatment`, ",
         "or `estimate` and `se`.", call. = FALSE)
  }
  if (has_counts) {
    assert_single_number(responses_control)
    assert_single_number(responses_treatment)
    if (responses_control < 0 || responses_control > n_control ||
        responses_treatment < 0 || responses_treatment > n_treatment) {
      stop(caller, "(): the response counts should lie between 0 and the arm size.",
           call. = FALSE)
    }
    return(list(endpoint = "binary"))
  }
  assert_single_number(estimate)
  assert_single_number(se)
  if (se <= 0) {
    stop(caller, "(): `se` should be positive.", call. = FALSE)
  }
  list(endpoint = "continuous")
}


#' Observed target data with arm counts
#'
#' @description `ObservedTargetData` holds only a summary measure. The binomial
#'   models also read the arm sizes and response rates, which this subclass
#'   adds.
#'
#' @keywords internal
#' @noRd
ObservedArmTargetData <- R6::R6Class(
  "ObservedArmTargetData",
  inherit = ObservedTargetData,
  public = list(
    endpoint = "binary",
    control_rate = NULL,

    initialize = function(n_control, n_treatment, responses_control,
                          responses_treatment, summary_measure_likelihood) {
      control_rate <- responses_control / n_control
      treatment_rate <- responses_treatment / n_treatment
      if (summary_measure_likelihood == "binomial") {
        estimate <- treatment_rate - control_rate
        se <- sqrt(treatment_rate * (1 - treatment_rate) / n_treatment +
                     control_rate * (1 - control_rate) / n_control)
      } else {
        odds_ratio <- compute_ORs(n_control, n_treatment, responses_control, responses_treatment)
        estimate <- odds_ratio$log_odds_ratio
        se <- odds_ratio$std_err_log_odds_ratio
      }
      super$initialize(
        treatment_effect_estimate = estimate,
        treatment_effect_standard_error = se,
        target_sample_size_control = n_control,
        target_sample_size_treatment = n_treatment,
        summary_measure_likelihood = summary_measure_likelihood
      )
      self$control_rate <- control_rate
      self$sample$sample_control_rate <- control_rate
      self$sample$sample_treatment_rate <- treatment_rate
    }
  )
)


#' The R6 target data object for a model
#'
#' @param target A `bexte_target`.
#' @param source A `bexte_source`.
#' @return An `ObservedTargetData` (or subclass) on the source's scale.
#' @keywords internal
#' @noRd
api_target_r6 <- function(target, source) {
  config <- source$config
  likelihood <- config$summary_measure_likelihood
  if (target$endpoint != config$endpoint) {
    stop("The target data describe a ", target$endpoint,
         " endpoint, but the source data describe a ", config$endpoint, " endpoint.",
         call. = FALSE)
  }
  if (target$endpoint == "binary") {
    return(ObservedArmTargetData$new(
      target$n_control, target$n_treatment,
      target$responses_control, target$responses_treatment,
      likelihood
    ))
  }
  ObservedTargetData$new(
    treatment_effect_estimate = target$estimate,
    treatment_effect_standard_error = target$se,
    target_sample_size_control = target$n_control,
    target_sample_size_treatment = target$n_treatment,
    summary_measure_likelihood = likelihood
  )
}


#' The planned target design a model calibrates to
#'
#' @description Methods such as the KL-calibrated NPP fix their
#'   hyperparameters from the target design (its sample size and expected
#'   standard error), not from the observed data. This builds that design, as
#'   the simulation pipeline does.
#'
#' @param source A `bexte_source`.
#' @param n_control,n_treatment Target arm sizes.
#' @param drift Treatment drift from the source effect.
#' @param control_drift Control drift from the source control rate.
#' @param target_to_source_std_ratio Ratio of the target to the source
#'   sampling standard deviation (continuous endpoint).
#' @return A `TargetData` object.
#' @keywords internal
#' @noRd
api_design_target <- function(source, n_control, n_treatment = n_control,
                              drift = 0, control_drift = 0,
                              target_to_source_std_ratio = 1) {
  TargetDataFactory$new()$create(
    source_data = source$data,
    case_study_config = source$config,
    target_sample_size_control = n_control,
    target_sample_size_treatment = n_treatment,
    control_drift = control_drift,
    treatment_drift = drift,
    summary_measure_likelihood = source$config$summary_measure_likelihood,
    target_to_source_std_ratio = target_to_source_std_ratio
  )
}
