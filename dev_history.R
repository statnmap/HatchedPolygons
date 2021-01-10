usethis::use_build_ignore("dev_history.R")
usethis::use_build_ignore("README.Rmd")
usethis::use_build_ignore("reference")

# License
usethis::use_gpl3_license("Sébastien Rochette")
# CI
usethis::use_github_action_check_standard()

# deps
attachment::att_amend_desc()

# pkgdown
usethis::use_github_action("pkgdown")
