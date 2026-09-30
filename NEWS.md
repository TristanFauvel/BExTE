# BExTE 0.0.2
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
