usethis::use_build_ignore("dev_history.R")
usethis::use_build_ignore("README.Rmd")
usethis::use_build_ignore("reference")
usethis::use_build_ignore('.github')
usethis::use_build_ignore('dev')

# License
usethis::use_gpl3_license()

# CI
usethis::use_github_action('check_standard')

# deps
attachment::att_amend_desc()

# pkgdown
usethis::use_github_action("pkgdown")
