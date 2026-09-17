# BExTE 0.0.2
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
