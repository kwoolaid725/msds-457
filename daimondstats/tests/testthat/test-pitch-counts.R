log <- function(pitcher, age, date, pitches) {
  data.frame(pitcher = pitcher, age = age, date = date, pitches = pitches,
             stringsAsFactors = FALSE)
}

test_that("rules table matches the published Pitch Smart chart", {
  r <- pitch_smart_rules
  expect_equal(nrow(r), 28L)
  maxes <- unique(r[c("age_min", "daily_max")])
  expect_equal(maxes$daily_max, c(50, 75, 85, 95, 95, 105))
  # 13-14: 51-65 pitches need three days; 17-18: 61-80 need three days.
  expect_equal(r$rest_days[r$age_min == 13 & r$pitches_min == 51], 3L)
  expect_equal(r$rest_days[r$age_min == 17 & r$pitches_min == 61], 3L)
  expect_false(any(r$rest_days[r$age_min == 7] > 2))
})

test_that("rest days and eligibility follow the bands at each boundary", {
  # Age 11: 20 -> 0, 21 -> 1, 35 -> 1, 36 -> 2, 65 -> 3, 66 -> 4.
  x <- log(letters[1:6], 11, "2026-05-02", c(20, 21, 35, 36, 65, 66))
  out <- check_pitch_counts(x)
  expect_equal(out$rest_days, c(0L, 1L, 1L, 2L, 3L, 4L))
  expect_equal(out$next_eligible, as.Date("2026-05-02") + c(1, 2, 2, 3, 4, 5))
  expect_true(all(out$status == "ok"))
  # Age 15 uses the older bands: 30 -> 0, 31 -> 1.
  older <- check_pitch_counts(log(c("a", "b"), 15, "2026-05-02", c(30, 31)))
  expect_equal(older$rest_days, c(0L, 1L))
})

test_that("over the daily max and short rest are flagged", {
  x <- log(c("Ava", "Ava", "Ben"), c(11, 11, 12),
           c("2026-05-02", "2026-05-04", "2026-05-02"), c(60, 30, 90))
  out <- check_pitch_counts(x)
  expect_equal(out$status, c("ok", "short rest", "over daily max"))
  expect_equal(out$rest_days[out$pitcher == "Ben"], 4L)
  both <- check_pitch_counts(log(c("Cy", "Cy"), 9, c("2026-06-01", "2026-06-02"),
                                 c(40, 80)))
  expect_equal(both$status[2], "over daily max; short rest")
})

test_that("a short outing does not erase rest still owed", {
  # 70 pitches on day 1 (4 days rest, eligible day 6); 10 on day 2 is short
  # rest; returning on day 4 is still inside the first rest period.
  x <- log("Dee", 12, c("2026-06-01", "2026-06-02", "2026-06-04", "2026-06-06"),
           c(70, 10, 10, 10))
  out <- check_pitch_counts(x)
  expect_equal(out$short_rest, c(FALSE, TRUE, TRUE, FALSE))
})

test_that("same-day appearances are added together; input order does not matter", {
  x <- log(c("Eli", "Eli"), 15, c("2026-07-04", "2026-07-04"), c(50, 50))
  out <- check_pitch_counts(x)
  expect_all(nrow(out) == 1L, out$pitches == 100, out$appearances == 2L, out$over_max)
  y <- log(c("A", "A"), 10, c("2026-06-05", "2026-06-01"), c(10, 70))
  out <- check_pitch_counts(y)
  expect_equal(out$date, as.Date(c("2026-06-01", "2026-06-05")))
  expect_equal(out$short_rest, c(FALSE, TRUE))
  expect_equal(nrow(check_pitch_counts(y[0, ])), 0L)
  zero <- check_pitch_counts(log("Z", 8, "2026-06-01", 0))
  expect_equal(zero$rest_days, 0L)
})

test_that("stricter league rules can be supplied", {
  strict <- pitch_smart_rules
  strict$daily_max[strict$age_min == 11] <- 70L
  out <- check_pitch_counts(log("Ava", 11, "2026-05-02", 75), rules = strict)
  expect_true(out$over_max)
})

test_that("check_pitch_counts rejects bad input", {
  ok <- log("Ava", 11, "2026-05-02", 40)
  expect_error(check_pitch_counts(list()), "data frame")
  expect_error(check_pitch_counts(ok[-4]), "pitches")
  expect_error(check_pitch_counts(transform(ok, age = 21)), "covered by `rules`")
  expect_error(check_pitch_counts(transform(ok, age = 11.5)), "whole numbers")
  expect_error(check_pitch_counts(transform(ok, pitches = -1)), "nonnegative")
  expect_error(check_pitch_counts(transform(ok, pitches = NA_real_)), "missing")
  expect_error(check_pitch_counts(transform(ok, date = "05/02/2026")), "YYYY-MM-DD")
  expect_error(check_pitch_counts(transform(ok, pitcher = "")), "pitcher")
  expect_error(check_pitch_counts(rbind(ok, transform(ok, age = 12))), "two different ages")
  expect_error(check_pitch_counts(ok, rules = pitch_smart_rules[0, ]), "rules")
})
