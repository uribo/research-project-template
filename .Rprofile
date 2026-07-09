# Pin non-deterministic environment factors so results do not depend on the
# machine's locale or clock. LC_COLLATE drives string sort/factor order (a
# silent source of cross-machine differences); TZ drives date parsing and
# "today". Set both explicitly. Adjust TZ if the analysis is not JST-based.
invisible(Sys.setlocale("LC_COLLATE", "C"))
Sys.setenv(TZ = "Asia/Tokyo")

# renv user-level config. Must be set BEFORE renv activates: renv resolves
# config as R option > RENV_CONFIG_* env var > default, and some options are
# read at load time.
options(
  # Snapshot library changes into renv.lock automatically. Convenience over
  # strictness: review the renv.lock diff before committing regardless.
  renv.config.auto.snapshot = TRUE,
  # Route renv::install()/restore() through pak.
  renv.config.pak.enabled = TRUE,
  # This project has no DESCRIPTION; the renv::dependencies() code scan is the
  # only dependency declaration. A file the scanner cannot parse must stop the
  # enumeration (default "reported" silently drops its dependencies).
  renv.config.dependency.errors = "fatal"
)

# Activate renv only after it has been initialized (renv::init writes
# renv/activate.R). The guard keeps R startup from erroring in a fresh
# template checkout where renv has not been initialized yet.
if (file.exists("renv/activate.R")) {
  source("renv/activate.R")
}
