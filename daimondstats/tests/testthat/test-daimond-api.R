# The API is mocked: these tests never touch the network, so they also run
# on CRAN and offline. Fixture shape follows the app's v1 contract.
fixture <- jsonlite::read_json(
  system.file("extdata", "api_v1_games_sample.json", package = "daimondstats"))
key <- "di_pat_abcdefghijklmnopqrstuvwxyz012345"

test_that("daimond_auth validates and stores the key for the session", {
  withr::local_envvar(DAIMOND_API_KEY = NA)
  expect_error(daimond_auth(), "No API key found")
  expect_error(daimond_auth("sk-not-ours"), "di_pat_")
  expect_error(daimond_auth(c(key, key)), "di_pat_")
  expect_true(daimond_auth(key))
  expect_equal(Sys.getenv("DAIMOND_API_KEY"), key)
  expect_true(daimond_auth())
})

test_that("daimond_games returns the package column contract across pages", {
  withr::local_envvar(DAIMOND_API_KEY = key)
  page_two <- list(api_version = 1, next_cursor = NULL, games = list())
  seen <- character()
  httr2::local_mocked_responses(function(req) {
    seen <<- c(seen, req$url)
    expect_equal(httr2::req_get_headers(req, "reveal")$Authorization,
                 paste("Bearer", key))
    body <- if (grepl("cursor=", req$url, fixed = TRUE)) page_two else fixture
    httr2::response_json(body = body)
  })
  out <- daimond_games(from = "2026-04-01", to = as.Date("2026-07-31"))
  expect_length(seen, 2L)
  expect_match(seen[1], "/api/v1/games?from=2026-04-01&to=2026-07-31", fixed = TRUE)
  expect_named(out, c("games", "plays", "pitchers"))
  expect_equal(nrow(out$games), 1L)
  expect_s3_class(out$plays$game_date, "Date")
  expect_identical(names(out$plays)[1:7], names(demo_scorecards))
  expect_equal(nrow(out$pitchers), 2L)
  expect_true(out$plays$needs_review[3])
  reviewed <- out$plays[!out$plays$needs_review, ]
  expect_equal(nrow(calculate_youth_stats(reviewed, min_pa = 0)), 2L)
})

test_that("an empty account returns empty frames that still validate", {
  withr::local_envvar(DAIMOND_API_KEY = key)
  httr2::local_mocked_responses(function(req) {
    httr2::response_json(body = list(api_version = 1, games = list(), next_cursor = NULL))
  })
  out <- daimond_games()
  expect_equal(nrow(out$plays), 0L)
  expect_equal(nrow(calculate_youth_stats(out$plays)), 0L)
})

test_that("HTTP failures become plain-language errors", {
  withr::local_envvar(DAIMOND_API_KEY = key)
  respond <- function(status, error = NULL) {
    httr2::local_mocked_responses(function(req) {
      httr2::response_json(status_code = status, body = list(error = error))
    }, env = parent.frame())
  }
  respond(401)
  expect_error(daimond_games(), "not accepted")
  respond(403, "upgrade at /pricing")
  expect_error(daimond_games(), "does not include API access (upgrade at /pricing)",
               fixed = TRUE)
  respond(429)
  expect_error(daimond_games(), "Too many requests")
  respond(500)
  expect_error(daimond_games(), "HTTP 500")
  httr2::local_mocked_responses(function(req) {
    httr2::response_json(body = list(api_version = 2, games = list()))
  })
  expect_error(daimond_games(), "Update the package")
})

test_that("daimond_games checks arguments before any request", {
  withr::local_envvar(DAIMOND_API_KEY = NA)
  expect_error(daimond_games(), "daimond_auth")
  withr::local_envvar(DAIMOND_API_KEY = key)
  expect_error(daimond_games(from = "April 1"), "from")
  expect_error(daimond_games(from = "2026-05-01", to = "2026-04-01"), "on or before")
  expect_error(daimond_games(league = ""), "league")
  expect_error(daimond_games(base_url = "ftp://x"), "base_url")
})
