# TZ drives date parsing and "today". Safe to set before renv activates.
# Adjust if the analysis is not JST-based. LC_COLLATE is the other
# non-deterministic environment factor, but it is pinned at the BOTTOM of this
# file -- see the comment there for why it cannot be set here.
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

# Pin string collation LAST. LC_COLLATE drives sort/order/factor level order
# and is a silent source of cross-machine differences -- most visibly for
# non-ASCII data, where the system locale and C order disagree.
#
# This MUST come after renv activates. `renv/activate.R` resets LC_COLLATE to
# the system locale, so setting it earlier is undone with no error and no
# warning: the profile runs, `Sys.setlocale()` returns "C", and the session
# still ends up on the system locale. Found 2026-08-06 on macOS with renv 1.2.4
# under LANG=ja_JP.UTF-8, where it had silently defeated the pin in a
# downstream project since the template was adopted.
#
# Check with: Rscript -e 'Sys.getlocale("LC_COLLATE")'  -> must print "C"
invisible(Sys.setlocale("LC_COLLATE", "C"))
