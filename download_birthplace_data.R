library(tidyverse)
library(tidycensus)

post_soviet_countries <- c(
  "Armenia", "Azerbaijan", "Belarus", "Georgia", "Kazakhstan",
  "Latvia", "Lithuania", "Moldova", "Russia", "Ukraine", "Uzbekistan"
)

years <- c(2013, 2018, 2023)

birthplace_estimates <- map_dfr(years, \(year) {
  country_variables <- load_variables(year, "acs5") |>
    filter(
      str_detect(name, "^B05006_[0-9]{3}$"),
      str_detect(
        label,
        str_c("!!(", str_c(post_soviet_countries, collapse = "|"), ")$")
      )
    ) |>
    select(name, label)

  get_acs(
    geography = "county",
    state = "FL",
    county = "Sarasota",
    variables = country_variables$name,
    year = year,
    survey = "acs5"
  ) |>
    left_join(country_variables, by = c("variable" = "name")) |>
    transmute(
      country = str_extract(label, "[^!]+$"),
      year = year,
      estimate,
      moe
    )
})

dir.create("data", showWarnings = FALSE)
write_csv(birthplace_estimates, "data/birthplace_estimates.csv")
