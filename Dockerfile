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

# Bring in the rest of the package, install it, then build the CmdStan
# toolchain itself (a separate binary cmdstanr needs to actually sample
# models - baked into the image so it isn't rebuilt on every container start).
# Diagnostic prints: install.packages() keeps reporting every Import as
# unavailable despite renv::restore() having just installed all of them,
# across two different guesses at why - print what this session's own
# .libPaths()/installed.packages() actually look like so the next failure
# (if any) says something concrete instead of requiring another guess.
COPY . .
RUN Rscript -e "\
    source('renv/activate.R'); \
    print(.libPaths()); \
    print('dplyr' %in% rownames(installed.packages())); \
    install.packages('.', repos = NULL, type = 'source', dependencies = FALSE)"
RUN Rscript -e "source('renv/activate.R'); cmdstanr::install_cmdstan(cores = parallel::detectCores())"

# Railway assigns the port dynamically via $PORT and routes to it.
EXPOSE 8080
CMD ["Rscript", "-e", "source('renv/activate.R'); BExTE::run_bexte_app(host = '0.0.0.0', port = as.integer(Sys.getenv('PORT', 8080)))"]
