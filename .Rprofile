# Activate renv only after it has been initialized (renv::init writes
# renv/activate.R). The guard keeps R startup from erroring in a fresh
# template checkout where renv has not been initialized yet.
if (file.exists("renv/activate.R")) {
  source("renv/activate.R")
}
