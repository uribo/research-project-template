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

# Locale pin, layer 3 of 3. Two categories are pinned, for two different
# reasons:
#
#   LC_COLLATE drives sort()/order()/factor() level order and is a silent
#   source of cross-machine differences -- even for pure ASCII, where C sorts
#   by code point ("Zebra" < "apple") and most system locales sort
#   case-insensitively ("apple" < "Zebra").
#
#   LC_TIME drives the month and weekday names from format()/strftime() with
#   %b/%B/%a/%A, and so the default date axis labels of ggplot2. Unpinned under
#   LANG=ja_JP.UTF-8 a date axis reads "1月 / 2月 / 3月" instead of
#   "Jan / Feb / Mar" -- an English manuscript quietly gets Japanese figures.
#   Note this category also affects parsing: as.Date(x, format = "%B") on
#   localized month names stops matching under C. A project that reads such
#   strings should pin to their locale instead of removing the pin.
#
# Never pin either of these with LC_ALL. LC_ALL overrides LC_CTYPE as well, and
# under LC_ALL=C a comparison like `area == "沖縄県"` silently stops matching,
# so the selected rows vanish from the output with no error raised. See
# Renviron.example for the incident that established this.
#
# The three layers, and why one is not enough:
#
#   1. Renviron.example -> .Renviron   LC_COLLATE=C and LC_TIME=C in the
#      environment. The primary pin: renv's reset (see below) reads the
#      environment, so it lands back on C. Requires the user to have copied
#      .Renviron.
#   2. .claude/settings.json, .codex/config.toml
#      Agent sessions set R_ENVIRON_USER=/dev/null to keep credentials out of
#      model-initiated processes. R treats ./.Renviron as the *user* Renviron,
#      so that also suppresses layer 1 -- hence both are set there too.
#   3. these lines
#      Fallback for a checkout with no .Renviron and no agent config.
#
# This line MUST come after renv activates. `renv/activate.R` can reset
# LC_COLLATE to the system locale, so setting it earlier is undone with no
# error and no warning: the profile runs, `Sys.setlocale()` returns "C", and
# the session still ends up on the system locale. The mechanism is upstream --
# renv:::renv_parse_impl_native() defers a bare `Sys.setlocale()`, which resets
# LC_ALL to the environment default instead of restoring the saved value, so it
# fires whenever renv falls back to native-encoding parsing. That also makes
# this layer the weakest of the three: a later renv call can undo it again,
# which is why layers 1 and 2 (which change what the reset resets *to*) carry
# the real guarantee.
#
# Found 2026-08-06 on macOS with renv 1.2.3/1.2.4 under LANG=ja_JP.UTF-8, where
# it had silently defeated the pin in four downstream projects.
#
# Verify: Rscript -e 'Sys.getlocale("LC_COLLATE")'  -> must print "C"
#         Rscript -e 'Sys.getlocale("LC_TIME")'     -> must print "C"
invisible(Sys.setlocale("LC_COLLATE", "C"))
invisible(Sys.setlocale("LC_TIME", "C"))
