# Deploys the BExTE Shiny app (inst/shiny_app/) to Railway.
#
# No volume is attached on purpose: results/logs/user_configs live inside the
# container's own writable layer and are lost on every restart/redeploy. That
# is an accepted tradeoff, not a bug - see the deployment discussion this
# Dockerfile came out of.
FROM rocker/r-ver:4.5.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    curl \
    pandoc \
    pngquant \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgit2-dev \
    gfortran \
    libblas-dev \
    liblapack-dev \
    zlib1g-dev \
    libuv1-dev \
    libmpfr-dev \
    libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Restore the exact package versions from renv.lock in their own layer, so
# editing app/package source doesn't invalidate this step on every build.
# CRAN is overridden to Posit Package Manager's Ubuntu 24.04 (noble) binary
# mirror - matching rocker/r-ver:4.5.2's actual base image, confirmed from a
# build log's gcc version string; pointing this at jammy (22.04) instead
# built stringi's binary against an ICU version this image doesn't have -
# so renv installs pre-built binaries (crucially for rstan/StanHeaders,
# RBesT's dependency, which otherwise takes tens of minutes to compile from
# source) instead of building everything from source. This has to be a real
# environment variable, not an `options(repos = ...)` call made in the R
# session before renv::restore() - renv recomputes `repos` from what's
# recorded in renv.lock (plain CRAN) as restore begins, silently discarding
# a session-level override. RENV_CONFIG_REPOS_OVERRIDE is renv's own
# documented mechanism for exactly this, checked ahead of the lockfile.
# Other recorded repos (e.g. the stan r-universe one cmdstanr comes from)
# are untouched, since renv.lock stores their full URL per package.
# renv defaults its library root to ~/.cache/R/renv/library on Linux, which
# turned out not to reliably persist across separate RUN layers on Railway's
# builder: renv::restore() below reports every package installing "OK", but
# by the next RUN step the library holds only renv itself - confirmed by
# listing it directly. Redirecting the library root under /app instead,
# a location directly confirmed to persist (our own COPY'd files are always
# there), fixes it.
ENV RENV_PATHS_LIBRARY_ROOT=/app/renv/library
ENV RENV_CONFIG_REPOS_OVERRIDE=https://packagemanager.posit.co/cran/__linux__/noble/latest
COPY .Rprofile renv.lock ./
COPY renv/activate.R renv/settings.json renv/
RUN Rscript -e "\
    source('renv/activate.R'); \
    options(HTTPUserAgent = sprintf( \
      'R/%s R (%s)', \
      getRversion(), \
      paste(getRversion(), R.version\$platform, R.version\$arch, R.version\$os) \
    )); \
    renv::restore()"

# Bring in the rest of the package and install it directly with R CMD
# INSTALL rather than install.packages(): the latter spawns R CMD INSTALL
# as a child process that does not source .Rprofile (so renv/activate.R
# never runs in it, regardless of what the calling session's own
# .libPaths() looks like). Computing the renv library path in this session
# and exporting it as R_LIBS instead forces the child's .libPaths() to
# include it directly - R_LIBS is read by every R process at startup,
# independent of profile-sourcing.
COPY . .
# renv/activate.R prints its own bootstrap/status messages to stdout, so the
# command substitution has to take only the last line - cat()'s own output -
# rather than everything Rscript printed, or RENV_LIB ends up holding that
# whole noisy transcript instead of a path.
RUN RENV_LIB=$(Rscript -e "source('renv/activate.R'); cat(.libPaths()[1])" | tail -1) && \
    echo "renv library: $RENV_LIB" && \
    R_LIBS="$RENV_LIB" R CMD INSTALL --library="$RENV_LIB" /app
RUN Rscript -e "source('renv/activate.R'); cmdstanr::install_cmdstan(cores = parallel::detectCores())"

# Railway assigns the port dynamically via $PORT and routes to it.
EXPOSE 8080
CMD ["Rscript", "-e", "source('renv/activate.R'); BExTE::run_bexte_app(host = '0.0.0.0', port = as.integer(Sys.getenv('PORT', 8080)))"]
