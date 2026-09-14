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
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Restore the exact package versions from renv.lock in their own layer, so
# editing app/package source doesn't invalidate this step on every build.
# The CRAN entry is swapped for Posit Package Manager's Ubuntu 22.04 (jammy)
# binary mirror first, so renv installs pre-built binaries (crucially for
# rstan/StanHeaders, RBesT's dependency, which otherwise takes tens of
# minutes to compile from source) instead of building everything from
# source. Other recorded repos (e.g. the stan r-universe one cmdstanr comes
# from) are untouched, since renv.lock stores their full URL per package.
COPY .Rprofile renv.lock ./
COPY renv/activate.R renv/settings.json renv/
RUN Rscript -e "\
    source('renv/activate.R'); \
    repos <- getOption('repos'); \
    repos['CRAN'] <- 'https://packagemanager.posit.co/cran/__linux__/jammy/latest'; \
    options(repos = repos); \
    renv::restore()"

# Bring in the rest of the package, install it, then build the CmdStan
# toolchain itself (a separate binary cmdstanr needs to actually sample
# models - baked into the image so it isn't rebuilt on every container start).
COPY . .
RUN Rscript -e "source('renv/activate.R'); install.packages('.', repos = NULL, type = 'source', INSTALL_opts = '--no-build-vignettes')"
RUN Rscript -e "source('renv/activate.R'); cmdstanr::install_cmdstan(cores = parallel::detectCores())"

# Railway assigns the port dynamically via $PORT and routes to it.
EXPOSE 8080
CMD ["Rscript", "-e", "source('renv/activate.R'); BExTE::run_bexte_app(host = '0.0.0.0', port = as.integer(Sys.getenv('PORT', 8080)))"]
