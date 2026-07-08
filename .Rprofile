# Pin non-deterministic environment factors so results do not depend on the
# machine's locale or clock. LC_COLLATE drives string sort/factor order (a
# silent source of cross-machine differences); TZ drives date parsing and
# "today". Set both explicitly. Adjust TZ if the analysis is not JST-based.
invisible(Sys.setlocale("LC_COLLATE", "C"))
Sys.setenv(TZ = "Asia/Tokyo")

# Activate renv only after it has been initialized (renv::init writes
# renv/activate.R). The guard keeps R startup from erroring in a fresh
# template checkout where renv has not been initialized yet.
if (file.exists("renv/activate.R")) {
  source("renv/activate.R")
}
