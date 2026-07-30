# Dependency declarations that the renv code scan cannot see.
#
# THIS FILE IS NEVER SOURCED. It exists only so that `renv::dependencies()`
# finds these packages. Do not put runnable code here, and do not move it into
# R/ (everything in R/ is loaded by `tar_source()`).
#
# Why this file exists: this project has no DESCRIPTION, so the
# `renv::dependencies()` code scan is the ONLY dependency declaration (see
# .Rprofile). The scan reads R/Rmd/qmd *code*; it does not read YAML metadata.
# A package named only in a YAML key is therefore invisible to it, and because
# .Rprofile sets `renv.config.auto.snapshot = TRUE`, the next snapshot silently
# drops that package from renv.lock. The failure surfaces later, on a different
# machine or in CI, as an unrelated-looking render error.
#
# `renv::record()` alone does not fix this: the package returns to renv.lock,
# but `renv::status()` keeps reporting it as not used, and the next snapshot
# removes it again. The declaration has to live in a file the scanner reads.
#
# Verify a declaration works:
#   renv::dependencies()   # this file must appear in the Source column
#   renv::status()         # must report no issues
#
# Add a `library()` call below for every package referenced only from YAML,
# with a comment naming the YAML key that requires it. Remove the entry when
# the YAML reference goes away.

# notes/_metadata.yml -> knitr.opts_chunk.dev: ragg_png
library(ragg)
