test_that("season_report writes a self-contained HTML file", {
  path <- withr::local_tempfile(fileext = ".html")
  checks <- check_pitch_counts(data.frame(
    pitcher = c("Ava", "Ava"), age = 11, date = c("2026-05-02", "2026-05-03"),
    pitches = c(60, 20)))
  out <- season_report(reviewed_scorecards, path, title = "Test <season>",
                       pitch_check = checks, min_pa = 3)
  expect_equal(out, normalizePath(path))
  html <- paste(readLines(path), collapse = "\n")
  expect_match(html, "Test &lt;season&gt;", fixed = TRUE)
  expect_match(html, "5 games", fixed = TRUE)
  expect_match(html, "data:image/png;base64,", fixed = TRUE)
  expect_match(html, "short rest", fixed = TRUE)
  expect_false(grepl("<script", html, fixed = TRUE))
})

test_that("season_report handles all-small samples and clean pitch logs", {
  path <- withr::local_tempfile(fileext = ".html")
  checks <- check_pitch_counts(data.frame(pitcher = "Ava", age = 11,
                                          date = "2026-05-02", pitches = 20))
  season_report(reviewed_scorecards, path, pitch_check = checks, min_pa = 100)
  html <- paste(readLines(path), collapse = "\n")
  expect_false(grepl("data:image/png", html, fixed = TRUE))
  expect_match(html, "All 1 pitching days were within the guidelines", fixed = TRUE)
})

test_that("season_report refuses to overwrite and checks arguments", {
  path <- withr::local_tempfile(fileext = ".html")
  writeLines("keep", path)
  expect_error(season_report(reviewed_scorecards, path), "already exists")
  expect_equal(readLines(path), "keep")
  expect_error(season_report(reviewed_scorecards, file.path(tempdir(), "nope", "x.html")),
               "folder")
  expect_error(season_report(reviewed_scorecards, path, overwrite = NA), "overwrite")
  expect_error(season_report(reviewed_scorecards, path, overwrite = TRUE,
                             pitch_check = data.frame(a = 1)), "check_pitch_counts")
  expect_error(season_report(reviewed_scorecards[0, ], path, overwrite = TRUE),
               "no plate appearances")
})
