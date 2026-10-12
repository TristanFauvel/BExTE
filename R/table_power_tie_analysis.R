table_noninflated_tie <- function(noninflated_cases_df){
  check_table_packages()
  noninflated_cases_df <- noninflated_cases_df[, intersect(c(unique_scenario_columns, "method", "parameters"), names(noninflated_cases_df))]

  file_path <- file.path(tables_dir, "noninflated_tie_cases")

  # Function to transform column names
  transform_column_names <- function(columns) {
    columns <- gsub("_", " ", columns)                   # Replace underscores with spaces
    columns <- sub("^(\\w)", "\\U\\1", columns, perl = TRUE) # Capitalize only the first letter of the string
    columns <- gsub("([0-9]+)", "\\1", columns)          # Preserve numbers
    return(columns)
  }

  noninflated_cases_df <- noninflated_cases_df[order(noninflated_cases_df$target_sample_size_control + noninflated_cases_df$target_sample_size_treatment,
                                   noninflated_cases_df$target_sample_size_control), ]

  noninflated_cases_df$method <- format_results_df_parameters(noninflated_cases_df)
  noninflated_cases_df <- noninflated_cases_df[, !names(noninflated_cases_df) %in% "parameters"]
  # Apply the transformation
  colnames(noninflated_cases_df) <- transform_column_names(colnames(noninflated_cases_df))
  noninflated_cases_df <- noninflated_cases_df[, c("Method", "Case study", "Target sample size control", "Target sample size treatment", "Source denominator change factor", "Target to source std ratio")]
  names(noninflated_cases_df)[names(noninflated_cases_df) == "Target to source std ratio"] <- "$\\sigma_T/\\sigma_S$"
  names(noninflated_cases_df)[names(noninflated_cases_df) == "Target sample size control"] <- "$n_C$"
  names(noninflated_cases_df)[names(noninflated_cases_df) == "Target sample size treatment"] <- "$n_T$"

  export_table(data_table = noninflated_cases_df, title = 'Cases in which no inflation of the TIE was observed', file_path = file_path)
}


table_power_gain <- function(power_gain_cases_df){
  check_table_packages()
  power_gain_cases_df <- power_gain_cases_df[, intersect(c(unique_scenario_columns, "method", "parameters"), names(power_gain_cases_df))]

  file_path <- file.path(tables_dir, "power_gain_cases")

  # Function to transform column names
  transform_column_names <- function(columns) {
    columns <- gsub("_", " ", columns)                   # Replace underscores with spaces
    columns <- sub("^(\\w)", "\\U\\1", columns, perl = TRUE) # Capitalize only the first letter of the string
    columns <- gsub("([0-9]+)", "\\1", columns)          # Preserve numbers
    return(columns)
  }

  power_gain_cases_df <- power_gain_cases_df[order(power_gain_cases_df$target_sample_size_control + power_gain_cases_df$target_sample_size_treatment,
                                   power_gain_cases_df$target_sample_size_control), ]

  power_gain_cases_df$method <- format_results_df_parameters(power_gain_cases_df)
  power_gain_cases_df <- power_gain_cases_df[, !names(power_gain_cases_df) %in% "parameters"]
  # Apply the transformation
  colnames(power_gain_cases_df) <- transform_column_names(colnames(power_gain_cases_df))
  power_gain_cases_df <- power_gain_cases_df[, c("Method", "Case study", "Target sample size control", "Target sample size treatment", "Source denominator change factor", "Target to source std ratio")]
  names(power_gain_cases_df)[names(power_gain_cases_df) == "Target to source std ratio"] <- "$\\sigma_T/\\sigma_S$"
  names(power_gain_cases_df)[names(power_gain_cases_df) == "Target sample size control"] <- "$n_C$"
  names(power_gain_cases_df)[names(power_gain_cases_df) == "Target sample size treatment"] <- "$n_T$"

  export_table(data_table = power_gain_cases_df, title = 'Cases in which power gains were observed at equivalent TIE compared to the frequentist method', file_path = file_path)
}

table_power_loss <- function(power_loss_cases_df){
  check_table_packages()
  power_loss_cases_df <- power_loss_cases_df[, intersect(c(unique_scenario_columns, "method", "parameters"), names(power_loss_cases_df))]

  file_path <- file.path(tables_dir, "power_loss_cases")

  # Function to transform column names
  transform_column_names <- function(columns) {
    columns <- gsub("_", " ", columns)                   # Replace underscores with spaces
    columns <- sub("^(\\w)", "\\U\\1", columns, perl = TRUE) # Capitalize only the first letter of the string
    columns <- gsub("([0-9]+)", "\\1", columns)          # Preserve numbers
    return(columns)
  }

  power_loss_cases_df <- power_loss_cases_df[order(power_loss_cases_df$target_sample_size_control + power_loss_cases_df$target_sample_size_treatment,
                                   power_loss_cases_df$target_sample_size_control), ]

  power_loss_cases_df$method <- format_results_df_parameters(power_loss_cases_df)
  power_loss_cases_df <- power_loss_cases_df[, !names(power_loss_cases_df) %in% "parameters"]
  # Apply the transformation
  colnames(power_loss_cases_df) <- transform_column_names(colnames(power_loss_cases_df))
  power_loss_cases_df <- power_loss_cases_df[, c("Method", "Case study", "Target sample size control", "Target sample size treatment", "Source denominator change factor", "Target to source std ratio")]
  names(power_loss_cases_df)[names(power_loss_cases_df) == "Target to source std ratio"] <- "$\\sigma_T/\\sigma_S$"
  names(power_loss_cases_df)[names(power_loss_cases_df) == "Target sample size control"] <- "$n_C$"
  names(power_loss_cases_df)[names(power_loss_cases_df) == "Target sample size treatment"] <- "$n_T$"

  export_table(data_table = power_loss_cases_df, title = 'Cases in which power losss were observed at equivalent TIE compared to the frequentist method', file_path = file_path)
}

table_power_loss_cases_inflated_tie <- function(power_loss_cases_inflated_tie_df){
  check_table_packages()
  power_loss_cases_inflated_tie_df <- power_loss_cases_inflated_tie_df[, intersect(c(unique_scenario_columns, "method", "parameters"), names(power_loss_cases_inflated_tie_df))]

  file_path <- file.path(tables_dir, "power_loss_cases")

  # Function to transform column names
  transform_column_names <- function(columns) {
    columns <- gsub("_", " ", columns)                   # Replace underscores with spaces
    columns <- sub("^(\\w)", "\\U\\1", columns, perl = TRUE) # Capitalize only the first letter of the string
    columns <- gsub("([0-9]+)", "\\1", columns)          # Preserve numbers
    return(columns)
  }

  power_loss_cases_df <- power_loss_cases_inflated_tie_df[order(power_loss_cases_inflated_tie_df$target_sample_size_control + power_loss_cases_inflated_tie_df$target_sample_size_treatment,
                                   power_loss_cases_inflated_tie_df$target_sample_size_control), ]

  power_loss_cases_df <- power_loss_cases_df %>%
    filter(!is.na(case_study))

  power_loss_cases_df$method <- format_results_df_parameters(power_loss_cases_df)
  power_loss_cases_df <- power_loss_cases_df[, !names(power_loss_cases_df) %in% "parameters"]
  # Apply the transformation
  colnames(power_loss_cases_df) <- transform_column_names(colnames(power_loss_cases_df))
  power_loss_cases_df <- power_loss_cases_df[, c("Method", "Case study", "Target sample size control", "Target sample size treatment", "Source denominator change factor", "Target to source std ratio")]
  names(power_loss_cases_df)[names(power_loss_cases_df) == "Target to source std ratio"] <- "$\\sigma_T/\\sigma_S$"
  names(power_loss_cases_df)[names(power_loss_cases_df) == "Target sample size control"] <- "$n_C$"
  names(power_loss_cases_df)[names(power_loss_cases_df) == "Target sample size treatment"] <- "$n_T$"

  export_table(data_table = power_loss_cases_df, title = 'Cases in which power losss were observed at equivalent TIE compared to the frequentist method, for a TIE higher than the nominal TIE', file_path = file_path)
}
