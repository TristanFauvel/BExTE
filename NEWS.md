# BExTE 0.0.2
* Removed `TruncatedGaussianRMP`, `TruncatedEgidiMixture` and the internal
  `GaussianRMP`, which `Model$create()` no longer built since `BinomialRMP`
  and `BinomialEgidiMixture` replaced them, together with the helpers only
  they used, among them the exported `truncated_normal_mixture_elir()`.
* Table S5 (`table_precision_ecp()`) adds the interval score beside precision
  and coverage, and shows a column's estimate alone when its operating
  characteristics are exact, rather than a zero-width interval.
* The paper manifest produces the five interval-score figures the supplement
  includes without a figure number (X4-X8): the Teriflunomide forest plot at
  123 per arm, and the versus-type-I-error figures for Dapagliflozin (66),
  Belimumab (140) and Aprepitant (143), and the Botox forest plot at 117 per
  arm (X8).
* `export_paper_outputs()` copies figures into `paper_outputs/` as PDF, the
  vector format the manuscript includes, rather than PNG, and removes PNG
  copies an earlier export left there.
* Every method now analyses a binary endpoint with a binomial likelihood
  (Aprepitant) through the binomial likelihoods of both arms, rather than a
  normal approximation of the risk difference. New, on the lattice of
  response rates that the binomial power priors use:
  - `BinomialCommensuratePowerPrior` and `BinomialCommensuratePrior`: separate
    source and target risk differences linked by a normal kernel of variance
    1/tau, truncated to the admissible effects, with the five priors on tau of
    the normal models and, for the power prior, gamma | tau ~ Beta(g(tau), 1).
    Integrated over everything but the target control rate and effect, the
    prior is tabulated once per worker, so a dataset costs one weighted sum.
  - `BinomialNPP_KL`: the Beta prior on the power parameter is calibrated with
    the criterion of `Gaussian_NPP_KL`, the posterior of the power parameter
    under its two hypothetical results (the design's expected responder
    counts) being computed from the exact binomial marginal likelihood, and
    the data are analysed with `BinomialNPP`. For Aprepitant the calibrated
    prior differs from the normal criterion's by about 0.002 in mean; the
    marginal likelihoods are tabulated once per design, in a few seconds.
  - `BinomialPDCCPP`: the power parameter rule of PDCCPP, the binomial
    conditional power prior analysis, and a calibration on the exact type I
    error of that analysis - a sum over every outcome under the null - instead
    of the normal closed form. The per-design table it needs is saved under
    `tools::R_user_dir("BExTE", "cache")` (or `BEXTE_CACHE_DIR`).
  - `BinomialRMP` and `BinomialEgidiMixture`: the robust mixture priors with
    an exact binomial informative component - the conditional power prior
    with full borrowing, i.e. the source posterior of the risk difference -
    instead of its normal approximation N(theta_S_hat, SE_S^2), and a weak
    component giving both target response rates independent uniform priors.
    Egidi's conflict p-value is computed from the exact prior-predictive
    tables of the two components; the weak one is uniform over the pairs of
    counts. The previous classes, `TruncatedGaussianRMP` and
    `TruncatedEgidiMixture`, remain, and their posterior is now computed on
    the lattice too, which corrects a small error under conflict
    (P(theta > 0) 0.0514 instead of 0.0519 against brute force).
* Fixed: for a binary endpoint, the KL-calibrated NPP took the expected target
  standard error at the scenario's true response rates, so its prior depended
  on the true treatment effect. It is now taken at zero treatment drift, as
  the analysis step already did. This changes the KL-NPP results of Aprepitant
  and Belimumab.
* The empirical Bayes power prior (EB-PP) of a binary endpoint uses the
  binomial likelihoods of the two arms of each study
  (`BinomialGravestockEBPP`), instead of the closed form of a normal
  approximation. The power parameter maximizes the marginal likelihood of the
  target data under the binomial power prior, computed on the lattice of the
  conditional power prior, and the target data are analysed with that power
  prior. The initial prior is proper, so the marginal likelihood is finite at
  a power parameter of 0, and strong conflict discards the source entirely,
  which the normal closed form never does. Rerun the Aprepitant EB-PP
  scenarios to update existing results.
* The normalized power prior (NPP) of a binary endpoint uses the binomial
  likelihoods of the two arms of each study, with the risk difference shared
  between them, instead of a normal approximation of the risk difference
  (`BinomialNPP`). The power parameter's Beta prior is integrated out exactly:
  integrated over it, the NPP is a fixed prior on the target control rate and
  the risk difference, computed once per worker on a lattice of 1,000
  response rates, so a dataset costs one weighted sum. The posterior mean and
  standard deviation of the power parameter are reported as before. Rerun the
  Aprepitant NPP scenarios to update existing results.
* Fixed: the binomial conditional power prior and the binomial p-value-based
  power prior were wrong when the target data conflict with the source. Their
  quadrature placed its nodes on the quantiles of the source and target
  control rates' own likelihoods, and under conflict the posterior moves into
  the tails of the source likelihood, which those nodes did not reach. At a
  power parameter of 1, P(theta > 0) was 0.582 instead of 0.597 (71/39 control
  and 71/20 treatment responders), and the posterior mean -0.256 instead of
  -0.188 (143/79 and 143/0), against Stan. The posterior is now computed on
  the same lattice as the NPP, which covers the whole unit square and agrees
  with Stan to Monte Carlo error. Rerun the Aprepitant conditional power prior
  and p-value-based power prior scenarios to update existing results.
* The frequentist reference test every borrowing method's power is read
  against - at the method's own type I error and at the nominal one - is
  calibrated on its actual type I error in the design's null scenario rather
  than on its nominal level. It is a one-sample t-test, whose nominal level is
  its actual size only for t-distributed statistics; on the approximately
  normal Wald statistics of the time-to-event, recurrent-event and binary
  case studies it is slightly conservative, and its level was also set to the
  method's estimated type I error, Monte Carlo error included. Together these
  made the reference spend less type I error than the method: the Bayesian
  separate analysis of Teriflunomide (n = 123) showed a spurious power gain of
  0.015. Where operating characteristics are simulated, the critical value is
  now read off the null scenario's simulated trials, the same ones the
  methods' type I error is estimated on; where they are enumerated
  (Aprepitant, Belimumab), the reference is an exact randomised test whose
  rejected null probability is exactly the target level. Continuous
  endpoints keep their closed-form t-test, which is exact there. The new
  `frequentist_reference_calibration` column records which reference a row
  carries. Rerun the two power-baseline analysis steps to update existing
  results.
* The separate and pooled binomial analyses, and so test-then-pool, are 2.5
  to 2.9 times faster under exact enumeration and more accurate. The
  distribution function of the difference of the two Beta posteriors is
  integrated by Gauss-Legendre, split where the treatment rate would leave
  [0, 1], instead of by 1,024 midpoints, whose error reached 8e-5 at outcomes
  with 0 or n responders. Interval ends move by at most 5e-5 and the reported
  operating characteristics by at most 1.5e-4; 3 of 66,816 decisions flip, at
  the 0.975 threshold.
* The slow `assertions::assert_number()` and `assert_logical()` checks on the
  per-outcome path are replaced by equivalent base-R ones, and the conjugate
  models compute each credible interval once: test-then-pool's first drift at
  Aprepitant's n = 71 took 44 s instead of 69 s, with identical results.
* Cached analyses are keyed on the outputs requested, so a call asking for
  more outputs than an earlier one on the same data no longer fails.
* Under a binomial likelihood the design priors of the Bayesian operating
  characteristics are taken given the control rate the trials are simulated
  at. The treatment effect is then a difference in response rates confined to
  `(-p_c, 1 - p_c)`, but the analysis prior of the separate analysis, for
  instance, spread over (-1, 1) and put a quarter of its mass on effects an
  Aprepitant trial cannot have, which the tail extrapolation then counted as
  certain success or failure. The separate, pooled and conditional power prior
  analysis priors and the source posterior are conditioned exactly; the
  unit-information prior, defined on the effect alone, is truncated and
  renormalised. The pooled analysis's prior given the control rate is the
  source posterior, as for a continuous endpoint, rather than the uniform prior
  it updates. Aprepitant's Bayesian operating characteristics change.
* The analytic power of the pooled analysis (`nominal_frequentist_power_pooling`)
  holds the source data fixed, as the simulation does, instead of treating the
  pooled estimate as if both studies were resampled: with equal standard
  errors and null effects a one-sided 5% z-test rejects 1% of the time, not
  5%. The binomial branch sums over the target responder counts exactly. The
  column feeds no figure or table.
* The Monte Carlo Bayesian operating characteristics (`compute_bayesian_ocs_mc`,
  off by default) average the decisions of the replicates actually analysed.
  Replicates dropped for a non-estimable summary measure used to count as
  failures, or to stop the run.
* On a binary endpoint the parallel simulation hands the drift scenarios of
  one design and method to the same worker, whose inference cache then serves
  all of them. They used to go one at a time to whichever worker was free, so
  every worker analysed every design's trial outcomes afresh - under exact
  enumeration nearly all of the cost. Aprepitant's RMP at the smallest design
  took 109 s instead of 321 s, with identical results in the same order. A
  method with fewer designs than workers has each design cut into as many
  pieces as keep the workers busy.
* The binomial test-then-pool methods, the binomial p-value based power prior
  and the Egidi mixture are much faster under exact enumeration. At
  Aprepitant's n = 71, test-then-pool took 83 s instead of 1770 s and the
  p-value power prior 326 s instead of 1702 s, with identical results apart
  from the ELIR effective sample size. Test-then-pool reports the ELIR of the
  component its test selected, fitted once, instead of refitting a mixture
  for every replicate, and shares analyses across drifts through the
  inference cache. The p-value power prior interpolates its ELIR from nodes
  on a grid of power parameters, each averaged over ten fits. The Egidi
  prior-predictive tables are built once per worker, and its mixture-weight
  scan reads all candidate weights off one sort. The commensurate models
  compile their Stan program only if they are asked to sample.
* The Shiny app moved to its own repository,
  [BExTE-app](https://github.com/TristanFauvel/BExTE-app), which imports
  BExTE. `run_bexte_app()` and `create_bexte_shortcut()` are now
  `BExTEapp::run_bexte_app()` and `BExTEapp::create_bexte_shortcut()`, and
  BExTE no longer depends on shiny, bslib, plotly or DT. `forest_plot()`,
  `forest_plot_bayesian()`, `get_parameters()`, `simulation_scenarios()` and
  `run_progress_tracker()` are now exported, for the app.
* The analysis step is faster again: 162 s instead of 273 s for the three
  power and Bayesian steps on a full Teriflunomide frame, with identical
  results. The steps share one worker cluster, started the first time one of
  them needs it, instead of standing up and stopping one each at 15-30 s a
  time. And every simulated power of a design - the separate analysis's at
  the equivalent and at the nominal type I error, and the pooled analysis's -
  now reads one set of trials: the nominal step takes them from the
  equivalent step instead of generating them twice more. The
  `p_value_cache` argument of `frequentist_power_at_equivalent_tie()` is
  now `trial_cache`, and `compute_freq_power_pooling()` takes the trials to
  reuse.
* `export_paper_outputs()` can produce the paper's items in parallel, each in
  a forked process, through the new `workers` argument. `reproduce_paper.R`
  uses as many workers as the simulation (capped by `BEXTE_MAX_WORKERS`;
  `BEXTE_PARALLEL=false` keeps one). The full export took 99 s on 8 workers
  instead of 386 s, on a loaded machine. Each item writes into its own
  staging directories and the files are copied into place in manifest order,
  so the files, the PNG bytes, the manifest and the status of every item are
  those of a sequential run. The default stays sequential, which the Shiny
  app keeps: its progress bar cannot be driven from a forked process.
* `sweet_spot()` failed on time-to-event results with "arguments imply
  differing number of rows". It pooled every design of a case study -
  dropout, event time distribution, treatment delay - into one curve per
  method, then bound one results row per design to sweet spots found on the
  mixture. Each design is now its own curve with its own sweet spot. A curve
  with several `power_larger_than_nominal` or
  `success_proba_smaller_than_nominal_TIE` sweet spots now gets one row with
  list columns, as the other metrics already did, instead of one row per
  sweet spot.
* The frequentist power baselines of the time-to-event sensitivity designs
  were computed on the primary design's trials. `load_data()` rebuilt a
  scenario's target data without its dropout probability, event time
  distribution and treatment delay, so the power at the equivalent type I
  error and the separate and pooled powers at the nominal one were the same
  for every such design. It now reads them from the results row, and falls
  back to the primary design for results written before those columns
  existed. The sensitivity figures' power baselines change; rerun the
  analysis step for time-to-event results.
* The deterministic Bayesian operating characteristics run on a cluster when
  the analysis is parallelised: 26 s instead of 65 s for the 448 method and
  design combinations of a Teriflunomide run, most of it cluster start-up.
  Each combination is now an independent job, seeded on its own, and the
  results are identical to the sequential ones and to before.
* The frequentist power at the equivalent type I error is about a hundred
  times faster on the case studies where it is simulated (time-to-event,
  recurrent-event and binary): 1 s instead of 129 s for 336 Teriflunomide
  rows. It used to simulate the separate analysis's trials once per result
  row, although they depend only on the design, so every method and parameter
  combination of a design drew the same trials again. They are now simulated
  once per design, on a cluster when there are enough designs, and the
  nominal-TIE step reuses them rather than simulating them a third time. The
  t-test is computed on all replicates at once instead of calling
  `BSDA::tsum.test()` per replicate, with bit-identical p-values; the same
  applies to the pooled analysis's simulated power. The type I error draws
  behind the power's interval are now seeded, so its three columns are
  reproducible between runs; they move within Monte Carlo error of their
  previous values.
* The operating characteristics of the binary case studies, Aprepitant and
  Belimumab, can now be computed exactly instead of simulated. A trial there
  reaches the analysis only through the responder counts of its two arms, so
  each operating characteristic - probability of success, coverage, MSE, bias,
  precision, interval score, the effective sample sizes - is summed over every
  pair of counts, weighted by its binomial probability, instead of averaged
  over random replicates. The pairs left out have probability below 1e-10,
  reported in the new `enumeration_omitted_mass` column. There is no Monte
  Carlo error, so the intervals collapse onto the estimates, `mcse_success_proba`
  is 0, the new `exact_ocs` column is `TRUE`, and the curves across drift are
  smooth. The type I error is exact too, so the separate analysis's power at
  the equivalent type I error is evaluated at an exact level; that power is
  itself still simulated, so it keeps its own Monte Carlo interval. The new
  `exact_enumeration` key of `scenarios_config.yml` lists the case studies
  to enumerate. It is set for Aprepitant and Belimumab in `full`, `combined`
  and the `combined_*` environments, and in the paper replication; the other
  environments still simulate them.
* The binomial models of the Aprepitant case study - the separate and pooled
  analyses, the conditional and p-value-based power priors, the robust mixture
  prior and its Egidi variant - could condition on one responder too few.
  They rebuilt each arm's responder count from its rate as
  `as.integer(n * rate)`, and `(k / n) * n` often falls just below `k` in
  floating point (7 of 71, 14 of 71, 3 of 47, ...), which truncation turned
  into `k - 1`. The count is now rounded, and a rate that is not a whole
  number of responders is an error. Aprepitant results for these methods shift
  slightly; rerun them.
* A binary scenario at the edge of the drift range, where an arm's response
  rate is 0 or 1, could make the analysis steps fail with "No simulated trial
  has an estimable summary measure": rebuilt from the drift read back from the
  results file, the rate came out at -1e-16, and every simulated trial was NA.
  The rates are now clamped to [0, 1] once checked to lie within rounding of
  it.
* Each scenario's replicates are now generated once and shared by every
  method and parameter setting that simulates it, instead of being
  regenerated about 56 times in the paper's grid. They were identical anyway:
  every simulation of a scenario seeds the generator the same way. The
  Mepolizumab and Teriflunomide case studies fit a model to each generated
  trial, which made regeneration the larger part of their run time; a small
  Mepolizumab run is 6.6 times faster, with identical results. The shared
  replicates are stored under the run's `results/<env>/generated/`, keyed by
  the design, the replicate count and the generator state, and deleted once
  each case study is done.
* The commensurate power prior, which took more than half the simulation
  time, is about ten times faster: 9 s instead of 97 s for a scenario of
  10000 replicates. Posterior quantiles of normal mixtures are found by a
  safeguarded Newton iteration instead of bisection, with identical results to
  1e-12; the conditional power-parameter rule uses 12 nodes instead of 24,
  which moves posterior quantiles by less than 0.2% of a posterior standard
  deviation; and the replicates are analysed in chunks of 1000, which bounds
  each worker's memory. The quantile change also speeds up every other
  mixture-based method, the NPP among them.
* The PDCCPP, the second most expensive method, now computes every replicate
  at once instead of one at a time: 10 to 40 times faster per scenario. Its
  calibration depends on a replicate only through the target sampling
  variance, so it is searched at 200 variances across the replicates' range
  and interpolated, instead of searched for each replicate. These few searches
  run to a tolerance of 1e-9, so the power parameter is closer to the exactly
  calibrated one than a per-replicate search at the configured tolerance was.
  Test decisions are unchanged.
* The binomial borrowing models of the Aprepitant case study - the robust
  mixture prior, its Egidi variant, the conditional power prior and the
  p-value-based power prior - now compute their posterior exactly, by
  deterministic quadrature over the control rates and the treatment effect,
  instead of sampling it with Stan. The posterior has two or three parameters,
  so the grid is exact to about 1e-5, far below the Monte Carlo error of the
  sampler, and a replicate takes tens of milliseconds instead of seconds. The
  new `engine` key of `mcmc_config.yml` chooses between `quadrature`, the
  default, and `stan`, which keeps the sampling path for comparison. Since the
  analysis no longer carries sampling error, replicates with the same counts
  now share one analysis through the inference cache, including for the
  empirical Bayes models, whose prior is a function of the replicate's sample.
* The frequentist baselines (power of the separate and pooled analyses, at
  the nominal and at the equivalent type I error) are now simulated for
  Mepolizumab, as for every endpoint that is not continuous. They used to be
  computed in closed form, although Mepolizumab's trials are generated patient
  by patient from a negative binomial with the standard error re-estimated in
  each one. The simulated baselines also leave out replicates whose summary
  measure is not estimable (an arm with no event), as the Bayesian operating
  characteristics already did; one such replicate used to make the whole
  simulated power NA. Rerun the analysis steps to update Mepolizumab's
  baselines.
* The paper replication gains figures S45-S50 for the Teriflunomide case
  study: how loss to follow-up, Weibull event times and control-arm
  heterogeneity change the number of events and, through it, each prior's
  probability of success, MSE and coverage. S45-S47 are forest plots, one per
  level of each axis, captioned with the expected number of events
  (`time_to_event_expected_events()`); S48-S50 plot each method against drift
  with one line per level. Selecting them makes `reproduce_paper.R` simulate
  the sensitivity designs at N_T/2 = 123, one axis at a time (the new
  `sensitivity_one_at_a_time` scenarios key). Every other figure now reads
  the primary time-to-event design alone: before, a results file holding
  sensitivity designs would have pooled them into the teriflunomide figures.
  The full-study configs `combined` and `full` now simulate the same
  sensitivity designs, so a full-study run also carries their data.
* New time-to-event axis `treatment_delay`: the treatment effect starts only
  after a delay, a departure from proportional hazards that the Cox analysis
  does not model. The scenario's treatment effect is the Cox model's
  large-sample limit under the trial's censoring, and the hazard ratio after
  the delay is solved to match it (`time_to_event_delayed_log_hr()`), so drift,
  bias and the null hypothesis keep their meaning. Figures S51-S52 show 12- and
  24-week delays for Teriflunomide. Scenarios without a delay simulate exactly
  as before.
* New borrowing method `egidi_empirical_mixture`, the data-dependent mixture
  prior of Egidi, Pauli and Torelli. It reuses the robust mixture prior's two
  components unchanged and selects the mixture weight from each replicate's own
  target data, as the smallest weight on the weak component at which the
  prior-predictive conflict p-value reaches `alpha_pc` (0.05). The conflict
  p-value is computed exactly: deterministically for a normal summary measure,
  and by enumerating the sample space for the binary endpoint. Because the
  target data are used both to choose the prior and to update it, the selected
  weight is not a prior probability and the method is reported separately from
  the robust mixture prior. Existing results have no rows for it, so the paper
  figures must be regenerated.
* New frequentist operating characteristic `interval_score`: the interval
  score of the 95% credible interval (Winkler 1972; Gneiting and Raftery 2007),
  which charges an interval for its width and for missing the true treatment
  effect in a single number. Results produced before this release do not carry
  the column and must be regenerated to gain it.

# BExTE 0.0.1 - June 4th 2024
* Initial release
