
test_that("c() interpolates union and setdiff operations (#130)", {
  expect_identical(select_pos(mtcars, c(mpg:disp, -(mpg:cyl))), c(disp = 3L))

  expect_identical(select_pos(mtcars, c(mpg, -mpg)), set_names(int(), chr()))
  expect_identical(select_pos(mtcars, c(mpg, -mpg, mpg)), c(mpg = 1L))
  expect_identical(select_pos(mtcars, c(mpg, -mpg, mpg, -mpg)), set_names(int(), chr()))

  expect_identical(select_pos(mtcars, c(mpg, cyl, -mpg)), c(cyl = 2L))
  expect_identical(select_pos(mtcars, c(mpg, cyl, -mpg, -cyl)), set_names(int(), chr()))
  expect_identical(select_pos(mtcars, c(mpg, cyl, -mpg, mpg, -cyl)), c(mpg = 1L))
})

test_that("c() expands dots", {
  fn <- function(...) select_pos(mtcars, c(...))
  expect_identical(fn(), set_names(int(), chr()))
  expect_identical(fn(mpg), c(mpg = 1L))
  expect_identical(fn(mpg, cyl), c(mpg = 1L, cyl = 2L))
  expect_identical(fn(mpg, cyl, disp), c(mpg = 1L, cyl = 2L, disp = 3L))
})

test_that("c() combines names tidily", {
  expect_identical(select_pos(mtcars, c(foo = mpg)), set_names(1L, "foo"))
  expect_identical(select_pos(mtcars, c(foo = c(bar = mpg))), set_names(1L, "foo...bar"))

  expect_identical(select_pos(mtcars, c(foo = mpg:cyl)), set_names(1:2, c("foo1", "foo2")))
  expect_identical(select_pos(mtcars, c(foo = c(bar = mpg:cyl))), set_names(1:2, c("foo...bar1", "foo...bar2")))
})

test_that("c() renames duplicates", {
  x <- list(a = 1L, b = 2L, a = 3L)
  expect_identical(select(x, foo = a, bar = b), list(foo = 1L, foo = 3L, bar = 2L))
})

test_that("allow named negative selections for consistency even if it has no effect", {
  expect_identical(select_pos(iris, c(foo = -!Species)), c(Species = 5L))
})

test_that("c() handles names consistently", {
  x <- list(a = 1L, b = 2L)
  expect_identical(select(x, a, foo = a), list(foo = 1L))
  expect_identical(select(x, a, foo = a, bar = a), list(foo = 1L, bar = 1L))
  expect_identical(select(x, foo = a, -a), named(list()))
  expect_identical(select(x, foo = a, -c(bar = a)), list(foo = 1L))
})

test_that("with uniquely-named inputs names are propagated with disambiguation", {
  expect_identical(select_pos(mtcars, c(foo = c(mpg, cyl))), c(foo1 = 1L, foo2 = 2L))
  expect_identical(select_pos(mtcars, c(bar = c(foo = c(mpg, cyl)))), c(bar...foo1 = 1L, bar...foo2 = 2L))
})

test_that("with minimally-named inputs names are propagated without disambiguation", {
  expect_identical(select_pos(unclass(mtcars), c(foo = c(mpg, cyl))), c(foo = 1L, foo = 2L))
  expect_identical(select_pos(unclass(mtcars), c(bar = c(foo = c(mpg, cyl)))), c(bar...foo = 1L, bar...foo = 2L))
})

test_that("uniquely-named inputs can't rename duplicates", {
  df <- vctrs::new_data_frame(list(a = 1, b = 2, a = 3))

  expect_error(select_pos(df, c(foo = a)), class = "tidyselect_error_names_must_be_unique")
  expect_identical(select_pos(unclass(df), c(foo = a)), c(foo = 1L, foo = 3L))

  verify_output(test_path("outputs", "c-rename-duplicates.txt"), {
    names(df)
    select_pos(df, c(foo = a))
  })
})