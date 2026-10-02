## For future work:

### Drop

[] Create a print_model_summary method for each model
   - Only the RMP classes have one, and nothing in the pipeline calls it.

[] Prior predictive checks for models that use Stan
   - Less relevant now that the binomial borrowing posteriors use quadrature instead of MCMC.

[] Make the code more robust using private attributes
   - The code base has almost no private fields; converting it is churn with no change in behaviour.

[] Distinguish public/private/active classes elements
   - Same as the item above.

[] Transform data to handle non zero theta and left null hypothesis space in the Model class
   - A generalisation nothing currently needs.

[] Use source_data$sample as well, for consistency
   - Too vague to act on as written.

### Real but large

[] Generalize the code to allow for different sample sizes in the arms of the target study
   - sample_size_per_arm appears ~600 times in R/; a deep refactor.

[] Use consistent naming for methods (with Gaussian or Binomial as suffix)
   - Names are currently mixed (SeparateGaussian, Gaussian_NPP, BinomialPooling, PoolGaussian). Renaming changes keys in configs, saved results and figure manifests; only do it alongside a full rerun.
