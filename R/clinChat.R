#' Create a clinical data chat object
#'
#' Creates an [ellmer::Chat] object pre-configured with tools for exploring
#' a clinical dataset. Data remains local; only tool results are shared with
#' the model.
#'
#' @param data A data.frame containing clinical data.
#' @param system_prompt Character. System prompt for the model. Defaults to a
#'   clinical analyst persona that emphasizes accuracy and privacy.
#' @param provider Character or NULL. Provider string for [ellmer::chat()],
#'   e.g. `"openai/gpt-4o-mini"`. If NULL, uses the default from ellmer.
#' @param ... Additional arguments passed to [ellmer::chat()].
#'
#' @return An ellmer Chat object with clinical tools registered.
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: Simple clinical data
#' data <- data.frame(
#'   patient_id = 1:30,
#'   age = sample(25:80, 30, replace = TRUE),
#'   sex = sample(c("M", "F"), 30, replace = TRUE),
#'   outcome = sample(c("responder", "non-responder"), 30, replace = TRUE)
#' )
#' chat <- create_clinical_chat(data)
#' chat$chat("How many responders are there by sex?")
#'
#' # Example 2: With a custom provider
#' chat2 <- create_clinical_chat(
#'   data,
#'   provider = "openai/gpt-4o-mini",
#'   system_prompt = "Be concise and use tools."
#' )
#' }
create_clinical_chat <- function(data,
                                 system_prompt = NULL,
                                 provider = NULL,
                                 ...) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  if (is.null(system_prompt)) {
    system_prompt <- paste(
      "You are a careful clinical data analyst.",
      "Answer questions about the provided dataset using only the tools available to you.",
      "Never invent or hallucinate patient-level data.",
      "Prefer aggregated summaries. If you need more detail, call a tool.",
      "Always note when a result is based on a tool call."
    )
  }

  # Create the chat
  if (is.null(provider)) {
    chat_obj <- ellmer::chat(system_prompt = system_prompt, ...)
  } else {
    chat_obj <- ellmer::chat(provider, system_prompt = system_prompt, ...)
  }

  # Register clinical tools
  tools <- clinical_tools(data)
  for (t in tools) {
    chat_obj$register_tool(t)
  }

  # Attach data as an attribute for convenience
  attr(chat_obj, "clinical_data") <- data

  chat_obj
}

#' Generate a list of tools for clinical data exploration
#'
#' @param data A data.frame.
#' @return A list of ellmer tool objects.
#' @export
clinical_tools <- function(data) {
  list(
    tool_summarize(data),
    tool_describe_columns(data),
    tool_count(data),
    tool_group_summary(data)
  )
}

# Internal tool constructors --------------------------------------------------

tool_summarize <- function(data) {
  ellmer::tool(
    fun = function() {
      # Safe summary: dimensions + types + basic numeric stats
      n_rows <- nrow(data)
      n_cols <- ncol(data)
      col_types <- sapply(data, function(x) class(x)[1])
      numeric_cols <- names(data)[sapply(data, is.numeric)]

      summary_list <- list(
        n_rows = n_rows,
        n_cols = n_cols,
        column_types = as.list(col_types)
      )

      if (length(numeric_cols) > 0) {
        num_summary <- lapply(numeric_cols, function(col) {
          x <- data[[col]]
          list(
            mean = mean(x, na.rm = TRUE),
            median = median(x, na.rm = TRUE),
            sd = sd(x, na.rm = TRUE),
            min = min(x, na.rm = TRUE),
            max = max(x, na.rm = TRUE),
            n_missing = sum(is.na(x))
          )
        })
        names(num_summary) <- numeric_cols
        summary_list$numeric_summary <- num_summary
      }

      summary_list
    },
    name = "summarize_dataset",
    description = "Get a high-level summary of the clinical dataset including row/column counts, variable types, and basic statistics for numeric variables."
  )
}

tool_describe_columns <- function(data) {
  ellmer::tool(
    fun = function() {
      lapply(names(data), function(col) {
        x <- data[[col]]
        list(
          name = col,
          type = class(x)[1],
          n_unique = length(unique(x)),
          n_missing = sum(is.na(x)),
          example_values = if (is.factor(x) || is.character(x)) {
            unique(head(as.character(x), 5))
          } else {
            NULL
          }
        )
      })
    },
    name = "describe_columns",
    description = "Describe each column in the dataset: type, number of unique values, missingness, and example values for categorical variables."
  )
}

tool_count <- function(data) {
  ellmer::tool(
    fun = function(column = NULL, value = NULL) {
      if (is.null(column)) {
        return(list(total_rows = nrow(data)))
      }
      if (!column %in% names(data)) {
        return(list(error = glue::glue("Column '{column}' not found.")))
      }
      if (is.null(value)) {
        tab <- table(data[[column]], useNA = "ifany")
        return(as.list(tab))
      }
      n <- sum(data[[column]] == value, na.rm = TRUE)
      list(column = column, value = value, count = n)
    },
    name = "count_values",
    description = "Count rows overall, or count occurrences of a specific value in a column, or get frequency table for a column.",
    arguments = list(
      column = ellmer::type_string("Optional column name to count within.", required = FALSE),
      value = ellmer::type_string("Optional specific value to count.", required = FALSE)
    )
  )
}

tool_group_summary <- function(data) {
  ellmer::tool(
    fun = function(group_by_col, summary_col, fun = "mean") {
      if (!group_by_col %in% names(data)) {
        return(list(error = "group_by_col not found"))
      }
      if (!summary_col %in% names(data)) {
        return(list(error = "summary_col not found"))
      }
      if (!is.numeric(data[[summary_col]])) {
        return(list(error = "summary_col must be numeric"))
      }

      result <- data |>
        dplyr::group_by(.data[[group_by_col]]) |>
        dplyr::summarise(
          n = dplyr::n(),
          result = if (fun == "mean") mean(.data[[summary_col]], na.rm = TRUE)
                   else if (fun == "median") median(.data[[summary_col]], na.rm = TRUE)
                   else if (fun == "sum") sum(.data[[summary_col]], na.rm = TRUE)
                   else NA_real_,
          .groups = "drop"
        )

      as.list(result)
    },
    name = "group_summary",
    description = "Compute a summary statistic (mean, median, or sum) of a numeric column, grouped by another column.",
    arguments = list(
      group_by_col = ellmer::type_string("Column to group by."),
      summary_col = ellmer::type_string("Numeric column to summarize."),
      fun = ellmer::type_string("Summary function: 'mean', 'median', or 'sum'.", required = FALSE)
    )
  )
}
