# BExTE 0.0.2
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
