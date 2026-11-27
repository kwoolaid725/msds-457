# Checks every condition and names the failing expression, like stopifnot(),
# so hand-calculated baseball facts read as one compact list.
expect_all <- function(...) {
  conditions <- as.list(substitute(list(...)))[-1]
  values <- list(...)
  for (i in seq_along(values)) {
    label <- paste(deparse(conditions[[i]]), collapse = " ")
    expect(isTRUE(all(values[[i]])), paste0(label, " is not TRUE."))
  }
  invisible(TRUE)
}
