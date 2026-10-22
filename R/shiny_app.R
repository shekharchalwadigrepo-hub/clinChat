#' Launch a Shiny chat application for clinical data
#'
#' Starts an interactive Shiny app that lets users chat with a clinical dataset
#' using a large language model. Uses shinychat for the interface and ellmer
#' for the model backend.
#'
#' @param data A data.frame of clinical data.
#' @param system_prompt Optional custom system prompt.
#' @param provider Provider string for ellmer (e.g. "openai/gpt-4o-mini").
#' @param title Title shown in the app.
#' @param ... Additional arguments passed to [shiny::runApp()].
#'
#' @return Invisibly returns the Shiny app object. Called for its side effect
#'   of launching the app.
#' @export
#'
#' @examples
#' \dontrun{
#' data <- iris
#' run_clinchat_app(data, title = "Iris Explorer")
#' }
run_clinchat_app <- function(data,
                             system_prompt = NULL,
                             provider = NULL,
                             title = "Clinical Data Chat",
                             ...) {
  if (!requireNamespace("shiny", quietly = TRUE) ||
      !requireNamespace("shinychat", quietly = TRUE)) {
    stop("Packages 'shiny' and 'shinychat' are required.", call. = FALSE)
  }

  ui <- shinychat::chat_ui(
    id = "chat",
    title = title,
    greeting = paste(
      "**Welcome to clinChat.**",
      "Ask questions about your clinical dataset.",
      "The model will use tools to query the data safely."
    )
  )

  server <- function(input, output, session) {
    chat <- create_clinical_chat(
      data = data,
      system_prompt = system_prompt,
      provider = provider
    )

    shinychat::chat_server(
      "chat",
      client = chat
    )
  }

  app <- shiny::shinyApp(ui, server)
  shiny::runApp(app, ...)
}
